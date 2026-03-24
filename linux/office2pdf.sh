#!/bin/bash -

# Convert an MS Office document (doc, docx, xls, xlsx, ppt, pptx, ...) to pdf.
#
# The script expects the following parameters:
# 1. The path to an office document, with an extension like those above.
# 2. OPTIONAL: the path to the destination document.
#
# If the destination path is not provided, it will create a document with the
# same name but .pdf as extension in the current directory.
# The conversion may not preserve some images correctly, but it more or less
# works.
#
# This script is basically a wrapper around LibreOffice.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Convert an MS Office document of PDF."
    echo "Parameters:"
    echo " 1. path to the source MS Office document"
    echo " 2. OPTIONAL: Path to destination document"
    exit 1
fi

package="libreoffice"
if ! ( (dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed") || (snap list | grep "^$package" -q) ); then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): $package is not installed but needed."
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): You can install it via 'sudo apt-get install $package'."
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
if [[ -n "$dstDocument" ]]; then
  dstDocument="$(realpath $dstDocument)"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Converting '$srcDocument' to the specified destination document '$dstDocument'."
else
  dstDocument="$(basename "${srcDocument%.*}.pdf")"
  dstDocument="$(realpath $dstDocument)"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): No destination document specified, therefore converting '$srcDocument' to  '$dstDocument'."
fi

tempDir="$(mktemp -d)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Using temporary directory '$tempDir'."

outDocument="$(basename "${srcDocument%.*}.pdf")"
outPath="$(realpath "$tempDir/$outDocument")"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now converting '$srcDocument' to '$outPath'."
libreoffice --headless --safe-mode --convert-to pdf "$srcDocument" --outdir "$tempDir"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Moving '$outPath' to '$dstDocument'."
mv "$outPath" "$dstDocument"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Removing '$tempDir'."
rm -d "$tempDir"

if [ -f "$dstDocument" ]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished converting '$srcDocument' to '$dstDocument'."
else
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination document '$dstDocument' was not created."
  exit 1
fi
