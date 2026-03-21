#!/bin/bash -

# (Down)scale a PDF file to the given DPI value.
#
# The script expects the following parameters:
# 1. The path to a source document.
# 2. The DPI value to scale to.
# 3. Optional: The output file name.
#
# If the output file name is not specified, we will create a document in the
# current directory based on the input document name, i.e., "123.pdf" becomes
# "123_200dpi.pdf" if 200 were specified as second parameter.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

srcDocument="$(realpath "$1")"
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

package="ghostscript"
if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): '$package' is installed, so we can use it."
else
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): '$package' is not installed. We install it now. This needs to be done only once."
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We first update the package cache. This requires sudo privileges."
  sudo apt-get update -y
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We now install '$package'. This requires sudo privileges."
  sudo apt-get install -y "$package"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The installation of '$package' is finished."
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now piping document '$srcDocument' through '$package', creating '$dstDocument'."

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

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished converting '$srcDocument' to '$dstDocument'."
