#!/bin/bash

# =================================================================================================
# Text added to the video file
# =================================================================================================
# Prepare text added at the beginning of the video
echo "- Prepare text"
rm -f $inputTextTop
rm -f $inputTextBottom
sync

if [ -z "$VERSION" ]; then VERSION=$(date +%y%m%d%H%M); else echo "    + Reuse Version=$VERSION for video comment"; fi
version="0v1"

cat <<EOT >> $inputTextTop
	Tears of Steel
	Sources provided by (CC) Blender Foundation | mango.blender.org and reworked by GSMA TSG BLM Group.
	Version: $VERSION
EOT

cat <<EOT >> $inputTextBottom
	Video Format: $codec ${outputResolution} ${nbBits}-bits ${fps}fps ${videoBitRate}kbps ${commentExtension}
	Notes:
          - Do not modify content (crop, cut, add), or re-encode. Please refer to GSMA/TSG/BLM TS.09 specification for other video formats.
          - Motion interpolation used to upconvert to ${fps}fps from original 24fps stream, expect minor actifacts.
EOT
