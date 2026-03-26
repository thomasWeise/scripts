#!/bin/bash -

# Convert a PDF to a series of images, page-by-page.
#
# The script expects the following parameters:
# 1. The path to a source document.
# 2. OPTIONAL: The resolution (DPI) of the images to generate (default: 300)
# 3. OPTIONAL: The destination file type (default: jpg)
# 4. OPTIONAL: The destination folder path (default: name-images)

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Convert a PDF document to a sequence of images."
    echo "Parameters:"
    echo " 1. path to source document"
    echo " 2. OPTIONAL: resolution (DPI) of destination images, default: 300"
    echo " 3. OPTIONAL: file type [png|jpg], default: jpg"
    echo " 4. OPTIONAL: path to destination folder, default: source name + '-images'"
    exit 0
fi

if ! ( command -v gs &> /dev/null ); then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Ghostscript is not installed but needed."
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): You can install it via 'sudo apt-get install ghostscript'."
    exit 1
fi

srcDocument="$(realpath "$1")"
if [ -f "$srcDocument" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Got source document '$srcDocument'."
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Source document $srcDocument' does not exist."
    exit 1
fi

dpi="${2:-}"
if [ -n "$dpi" ]; then
    if [ "$dpi" -lt 1 ]; then
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination image resolution must be at least 1, but is '$dpi'."
    else
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination image resolution is specified as '$dpi'."
    fi
else
    dpi="300"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Using default destination image resolution '$dpi'."
fi

outType="${3:-}"
if [ -n "$outType" ]; then
    if [ "$outType" == "jpg" ]; then
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Will create JPEG images."
        device="jpeg"
    elif [ "$outType" == "jpeg" ]; then
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Will create JPEG images."
        device="jpeg"
    elif [ "$outType" == "png" ]; then
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Will create PNG images."
        device="pngalpha"
    else
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Output type '$outType' not supported."
        exit 1
    fi
else
    outType="jpg"
    device="jpeg"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Using default output type '$outType'."
fi


destFolder="${4:-}"
srcPattern="$(basename "$srcDocument")"
srcPattern="${srcPattern%.*}"
if [ -n "$destFolder" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination folder '$destFolder' specified."
else
  destFolder="${srcPattern}-images"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Using default destination folder '$destFolder'."
fi
destFolder="$(realpath "$destFolder")"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Creating destination folder '$destFolder'."
mkdir -p "$destFolder"

destPattern="${destFolder}/${srcPattern}-%05d.${outType}"
destPattern="$(realpath "$destPattern")"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination file name pattern is '$destPattern'."

gs -dAntiAliasColorImages=true \
   -dAntiAliasGrayImages=true \
   -dAntiAliasMonoImages=true \
   -dAutoFilterColorImages=false \
   -dAutoFilterGrayImages=false \
   -dAutoRotatePages=/None \
   -dBATCH \
   -dColorConversionStrategy=/LeaveColorUnchanged \
   -dCreateJobTicket=false \
   -dDownsampleColorImages=false \
   -dDownsampleGrayImages=false \
   -dDownsampleMonoImages=false \
   -dEPSCrop \
   -dGraphicsAlphaBits=4 \
   -dHaveTransparency=true \
   -dMaxBitmap=2147483647 \
   -dNOPAUSE \
   -dNOPROMPT \
   -dPassThroughJPEGImages=true \
   -dPassThroughJPXImages=true \
   -dPDFSTOPONERROR=true \
   -dPDFSTOPONWARNING=true \
   -dPrinted=false \
   -dOmitInfoDate=true \
   -dOmitID=true \
   -dOmitXMP=true \
   -dQUIET \
   -dSAFER \
   -dTextAlphaBits=4 \
   -dUCRandBGInfo=/Remove \
   -r${dpi}*${dpi} \
   -sDEVICE="$device" \
   -sOutputFile="$destPattern" \
   "$srcDocument" \
   -q

if [ -f "${destFolder}/${srcPattern}-00001.${outType}" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done converting '$srcDocument' to '$outType' images in folder '$destFolder' at $dpi DPI."
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Error - no output file has been generated."
    exit 1
fi
