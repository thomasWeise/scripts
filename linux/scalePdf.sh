#!/bin/bash -

# (Down)scale a PDF file to the given DPI value.
#
# The script expects the following parameters:
# 1. The path to a source PDF document.
# 2. The DPI value to scale to.
# 3. Optional: The output file name.
#
# If the output file name is not specified, we will create a document in the
# current directory based on the input document name, i.e., "123.pdf" becomes
# "123_200dpi.pdf" if 200 were specified as second parameter.
#
# This script is basically a wrapper around Ghostscript.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 2 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): (Down)Scale the images in a PDF document."
    echo "Parameters:"
    echo " 1. path to the source PDF document"
    echo " 2. the DPI value to scale to"
    echo " 3. OPTIONAL: output file name"
    exit 1
fi

package="ghostscript"
if ! ( command -v gs &> /dev/null ); then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Ghostscript is not installed but needed."
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): You can install it via 'sudo apt-get install ghostscript'."
    exit 1
fi

srcDocument="$(realpath "$1")"
if [ -f "$srcDocument" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Source document is '$srcDocument'."
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Source document $srcDocument' does not exist."
    exit 1
fi

dpi="$2"
dstDocument="${3:-}"
if [[ -n "$dstDocument" ]]; then
    dstDocument="$(realpath $dstDocument)"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Scaling '$srcDocument' to the specified destination document '$dstDocument' using $dpi dpi."
else
    dstDocument="$(basename "${srcDocument%.*}_${dpi}dpi.pdf")"
    dstDocument="$(realpath $dstDocument)"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): No destination document specified, therefore converting '$srcDocument' to  '$dstDocument' using $dpi dpi."
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now piping document '$srcDocument' through GhostScript, creating '$dstDocument'."

gs -dAntiAliasColorImages=true \
   -dAntiAliasGrayImages=true \
   -dAntiAliasMonoImages=true \
   -dAutoFilterColorImages=false \
   -dAutoFilterGrayImages=false \
   -dAutoRotatePages=/None \
   -dBATCH \
   -dCannotEmbedFontPolicy=/Error \
   -dColorConversionStrategy=/LeaveColorUnchanged \
   -dColorImageDownsampleType=/Bicubic \
   -dColorImageFilter=/FlateEncode \
   -dColorImageResolution="$dpi" \
   -dCompatibilityLevel="1.7" \
   -dCompressFonts=true \
   -dCompressStreams=true \
   -dCreateJobTicket=false \
   -dDetectDuplicateImages=true \
   -dDoThumbnails=false \
   -dDownsampleColorImages=true \
   -dDownsampleGrayImages=true \
   -dDownsampleMonoImages=true \
   -dEmbedAllFonts=true \
   -dFastWebView=false \
   -dGrayImageFilter=/FlateEncode \
   -dGrayImageDownsampleType=/Bicubic \
   -dGrayImageResolution="$dpi" \
   -dHaveTransparency=true \
   -dMaxBitmap=2147483647 \
   -dMonoImageDownsampleType=/Subsample \
   -dMonoImageResolution="$dpi" \
   -dNOPAUSE \
   -dOptimize=true \
   -dPassThroughJPEGImages=true \
   -dPassThroughJPXImages=true \
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
   -sOutputFile="$dstDocument" \
   "$srcDocument" \
   -q

if [ -f "$dstDocument" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished scaling '$srcDocument' to $dpi DPI and writing output to '$dstDocument'."
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination document '$dstDocument' was not created."
    exit 1
fi
