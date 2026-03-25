#!/bin/bash -

# Convert one vector graphic format to another.
# Supported input formats include svg, pdf, wmf, emf, eps, and ps.
# Supported output formats include svg, pdf, wmf, emf, eps, ps, and png.
#
# The script expects the following parameters:
# 1. The path to a source document.
# 2. Either a file extension or a path to a destination document.
#    The file extension will then be taken from that path.
# 3. Optional: For PDF input documents, you may specify "flatten", which
#              converts text to vector drawings. This may help in some
#              cases of corrupted output.
#
# This script is basically a wrapper around inkscape.
#
# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 2 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Convert one vector graphics format to another."
    echo "Parameters:"
    echo " 1. path to the source file (svg, pdf, wmf, emf, eps, ps)"
    echo " 2. destination file extension OR path to destination document"
    echo " 3. OPTIONAL: 'flatten' for PDF sources to convert text to curves"
    exit 1
fi

if ! ( command -v inkscape &> /dev/null ); then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Inkscape is not installed but needed."
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): You can install it via 'sudo apt-get install inkscape'."
    exit 1
fi

srcDocument="$(realpath "$1")"
srcExtension="${srcDocument##*.}"
if [ -f "$srcDocument" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Got source document '$srcDocument' with file extension '$srcExtension'."
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Source document $srcDocument' does not exist."
    exit 1
fi

outSpec="$2"
dstExtension="${outSpec##*.}"
if [[ "$dstExtension" != "$outSpec" ]]; then
    dstDocument="$(realpath "$outSpec")"
else
    dstExtension="$outSpec"
    dstDocument="$(realpath "${srcDocument%.*}.$dstExtension")"
fi
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We will convert document '$srcDocument' to '$dstDocument'."

moreArgs="--export-type=$dstExtension --export-background-opacity=0.0 --export-area-page --vacuum-defs"
if [ "$srcExtension" == "pdf" ]; then
    if [ "$dstExtension" != "ps" ]; then
        moreArgs="$moreArgs --pdf-page=1"
    fi
fi
if [ "$dstExtension" == "pdf" ]; then
    moreArgs="$moreArgs --export-pdf-version=1.5"
elif [ "$dstExtension" == "svg" ]; then
    moreArgs="$moreArgs --export-plain-svg"
elif [ "$dstExtension" == "ps" ]; then
    moreArgs="$moreArgs --export-ps-level=3"
elif [ "$dstExtension" == "eps" ]; then
    moreArgs="$moreArgs --export-ps-level=3"
fi

if [ $# \> 2 ]; then
    if [ "$3" == "flatten" ]; then
        if [ "$srcExtension" == "pdf" ]; then
            echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Try to flatten input PDF."
            moreArgs="${moreArgs} --pdf-poppler"
        else
            echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Flattening is only supported for PDF input."
        fi
    fi
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now using Inkscape to convert '$srcDocument' to '$dstDocument' with arguments '$moreArgs'."
inkscape --export-filename="$dstDocument" $moreArgs "$srcDocument"

if [ -f "$dstDocument" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished converting '$srcDocument' to '$dstDocument'."
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination document '$dstDocument' was not created."
    exit 1
fi
