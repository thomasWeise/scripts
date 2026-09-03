#!/bin/bash -

# Add an OCR-Layer to a PDF document.
#
# The script expects the following parameters:
# 1. The path to a source document.
# 2. The optional path to the destination document.
# 3. Optionally: The languages to be used, e.g., eng, deu

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Add an OCR layer to a PDF document."
    echo "All fonts are dropped, all text is turned into vector graphics, and a new text layer based on OCR is put on top of the document."
    echo "Parameters:"
    echo " 1. path to source document"
    echo " 2. OPTIONAL: the path to the destination document (default: source + _ocr)"
    echo " 3. OPTIONAL: the languages/scrips to use, like deu, eng, ... (default: all)"
    exit 0
fi

if ! ( command -v tesseract &> /dev/null ); then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): tesseract is not installed but needed."
    echo "You can install it via 'sudo apt-get install tesseract-ocr"
    echo "More languages can be installed via 'sudo apt-get install tesseract-ocr-deu tesseract-ocr-end tesseract-ocr-chi-sim ...'."
    exit 1
fi

if ! ( command -v ocrmypdf &> /dev/null ); then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): ocrmypdf is not installed but needed."
    echo "You can install it via 'sudo apt-get install ocrmypdf'."
    exit 1
fi

if ! ( command -v gs &> /dev/null ); then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): ghostscript (gs) is not installed but needed."
    echo "You can install it via 'sudo apt-get install ghostscript'."
    exit 1
fi

if ! ( command -v gs &> /dev/null ); then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): qpdf is not installed but needed."
    echo "You can install it via 'sudo apt-get install qpdf'."
    exit 1
fi

srcDocument="$(realpath "$1")"
if [ -f "$srcDocument" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Got source document '$srcDocument'."
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Source document $srcDocument' does not exist."
    exit 1
fi

dstDocument="${2:-}"
if [ -n "$dstDocument" ]; then
      dstDocument="$(realpath "$dstDocument")"
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination document is specified as '$dstDocument'."
else
    dstDocument="$(realpath "${srcDocument%.*}_ocr.pdf")"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Using default destination document '$dstDocument'."
fi

langs="${3:-}"
if [ -n "$langs" ]; then
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The languages to use are '$langs'."
else
    langs="$(tesseract --list-langs 2>&1)"
    langs="${langs#*:}"
    langs="${langs##+([[:space:]])}"
    langs="${langs%%+([[:space:]])}"
    langs="$(echo "$langs" | tr '\n' '+')"
    langs="${langs%%\+}"
    langs="${langs##\+}"
    langs="${langs//+osd/}"
    langs="${langs//osd+/}"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Using all available languages, namely '$langs'."
fi

tempPdfA="$(mktemp --suffix=.pdf)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We first create the temporary pdf with the rasterized/OCRed images as '$tempPdfA'."
ocrmypdf -l "$langs" --output-type pdfa --no-tesseract-downsample-large-images --deskew --clean-final --continue-on-soft-render-error --optimize 0 --force-ocr "$srcDocument" "$tempPdfA"

tempPdfB="$(mktemp --suffix=.pdf)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we remove all images from '$tempPdfA' and store it as '$tempPdfB'."
gs -dAutoRotatePages=/None \
   -dBATCH \
   -dCannotEmbedFontPolicy=/Error \
   -dCompatibilityLevel="1.7" \
   -dCompressFonts=true \
   -dCompressStreams=true \
   -dCreateJobTicket=false \
   -dDoThumbnails=false \
   -dEmbedAllFonts=true \
   -dFastWebView=false \
   -dFILTERIMAGE \
   -dFILTERVECTOR \
   -dHaveTransparency=true \
   -dNOPAUSE \
   -dNOPROMPT \
   -dOptimize=true \
   -dPDFSTOPONERROR=true \
   -dPDFSTOPONWARNING=true \
   -dPreserveCopyPage=false \
   -dPreserveEPSInfo=false \
   -dPreserveHalftoneInfo=false \
   -dPreserveOPIComments=false \
   -dPreserveOverprintSettings=false \
   -dPreserveSeparation=false \
   -dPreserveDeviceN=false \
   -dPreserveMarkedContent=false \
   -dPrinted=false \
   -dOmitInfoDate=true \
   -dOmitID=true \
   -dOmitXMP=true \
   -dQUIET \
   -dSAFER \
   -dSubsetFonts=true \
   -dUCRandBGInfo=/Remove \
   -dUNROLLFORMS \
   -sDEVICE=pdfwrite \
   -sOutputFile="$tempPdfB" \
   "$tempPdfA" \
   -q

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we delete '$tempPdfA'."
rm "$tempPdfA"

tempPdfC="$(mktemp --suffix=.pdf)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we remove all text from '$srcDocument' and store it as '$tempPdfC'."
gs -dAutoRotatePages=/None \
   -dBATCH \
   -dCompatibilityLevel="1.7" \
   -dCompressStreams=true \
   -dCreateJobTicket=false \
   -dDoThumbnails=false \
   -dFastWebView=false \
   -dHaveTransparency=true \
   -dNOPAUSE \
   -dNOPROMPT \
   -dNoOutputFonts \
   -dOptimize=true \
   -dPDFSTOPONERROR=true \
   -dPDFSTOPONWARNING=true \
   -dPreserveCopyPage=false \
   -dPreserveEPSInfo=false \
   -dPreserveHalftoneInfo=false \
   -dPreserveOPIComments=false \
   -dPreserveOverprintSettings=false \
   -dPreserveSeparation=false \
   -dPreserveDeviceN=false \
   -dPreserveMarkedContent=false \
   -dPrinted=false \
   -dOmitInfoDate=true \
   -dOmitID=true \
   -dOmitXMP=true \
   -dQUIET \
   -dSAFER \
   -dSubsetFonts=true \
   -dUCRandBGInfo=/Remove \
   -dUNROLLFORMS \
   -sDEVICE=pdfwrite \
   -sOutputFile="$tempPdfC" \
   "$srcDocument" \
   -q

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finally, we super-impose the text layer from '$tempPdfB' onto '$tempPdfC' and store it as '$dstDocument'."

qpdf "$tempPdfC" --overlay "$tempPdfB" -- "$dstDocument"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we delete '$tempPdfB'."
rm "$tempPdfB"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we delete '$tempPdfC'."
rm "$tempPdfC"

if [ -f "$dstDocument" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished OCRing '$srcDocument' to '$dstDocument'."
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination document '$dstDocument' was not created."
    exit 1
fi
