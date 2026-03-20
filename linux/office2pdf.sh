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

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

srcDocument="$(realpath "$1")"
dstDocument="${2:-}"
if [[ -n "$dstDocument" ]]; then
  dstDocument="$(realpath $dstDocument)"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Converting '$srcDocument' to the specified destination document '$dstDocument'."
else
  dstDocument="$(basename "${srcDocument%.*}.pdf")"
  dstDocument="$(realpath $dstDocument)"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now destination document specified, therefore converting '$srcDocument' to  '$dstDocument'."
fi

package="libreoffice"
if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): LibreOffice is installed, so we can use it."
else
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): LibreOffice is not installed. We install it now. This needs to be done only once."
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We first update the package cache. This requires sudo privileges."
  sudo apt-get update -y
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We now install LibreOffice. This requires sudo privileges."
  sudo apt-get install -y libreoffice
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Installation is finished."
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
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished converting '$srcDocument' to '$dstDocument'."
