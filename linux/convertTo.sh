#!/bin/bash -

# Convert a document from one type to another.
#
# The script expects the following parameters:
# 1. The path to a source document.
# 2. Either a file extension or a path to a destination document.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 2 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Convert one document to another type."
    echo "Parameters:"
    echo " 1. path to source document"
    echo " 2. destination file extension OR path to destination document"
    exit 0
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
    dstDocumentRaw="$dstDocument"
else
    dstExtension="$outSpec"
    dstDocumentRaw="$(realpath "${srcDocument%.*}")"
    dstDocument="$(realpath "${dstDocumentRaw}.$dstExtension")"
fi
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Got destination document '$dstDocument' with file extension '$dstExtension'."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The directory where we look for conversion scripts is '$scriptDir'."

case "$srcExtension" in
    doc|docx|ppt|pptx|xls|xlsx)
        case "$dstExtension" in
            pdf)
                "$scriptDir/office2pdf.sh" "$srcDocument" "$dstDocument"
                exit 0
            ;;
        esac
        ;;
    emf|eps|pdf|ps|svg|wmf)
        case "$dstExtension" in
            emf|eps|pdf|ps|svg|wmf)
                "$scriptDir/vec2vec.sh" "$srcDocument" "$dstDocument"
                exit 0
            ;;
            png)
                if [ "$dstDocument" == "$dstDocumentRaw" ]; then
                    "$scriptDir/vec2vec.sh" "$srcDocument" "$dstDocument"
                    exit 0
                fi
            ;;
        esac
        ;;&
    pdf)
        case "$dstExtension" in
            jpg|jpeg|png)
                "$scriptDir/pdf2imgs.sh" "$srcDocument" "" "$dstExtension" "$dstDocumentRaw"
                exit 0
            ;;
        esac
        ;;
esac

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): I don't know how to convert '$srcExtension' files to '$dstExtension' files."
exit 1
