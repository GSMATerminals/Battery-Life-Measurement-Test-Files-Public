#!/bin/bash

# =================================================================================================
# This script was validated only
# for config targeted for GSMA (see below)
# =================================================================================================

# =================================================================================================
# Includes
# =================================================================================================
source "$(dirname "$0")/ToS_encode_lib_H264.sh"
source "$(dirname "$0")/ToS_encode_lib_H265.sh"
source "$(dirname "$0")/ToS_encode_lib_VP8.sh"
source "$(dirname "$0")/ToS_encode_lib_VP9.sh"
source "$(dirname "$0")/videoInfo.sh"


# =================================================================================================
# Global parameters
# =================================================================================================
# IO folders
inputDir="./input"
outputDir="./output"
tempDir="../raw/temp"

# Tools
#videoEncoderH264="/usr/bin/ffmpeg"
videoEncoderH264="/usr/local/bin/ffmpeg"
videoPostProcessH264="MP4Box"

#videoEncoderHEVC2=" /home/lab/ffmpeg_build/bin/x265"
videoEncoderHEVC1="/usr/local/bin/ffmpeg"
videoEncoderHEVC2=" /home/lab/ffmpeg_build/bin/x265"
videoPostProcessHEVC="MP4Box"

videoEncoderVP8_1="/usr/bin/ffmpeg"
#videoEncoderVP8_2="/usr/bin/vpxenc"
videoEncoderVP8_2="/usr/bin/vpxenc"

#videoPostProcessVP8="/usr/bin/ffmpeg"
videoPostProcessVP8="/usr/bin/ffmpeg"

# New to support VP9 10 bits
videoEncoderVP9_1="/usr/local/bin/ffmpeg"
#videoEncoderVP9_2="/usr/bin/vpxenc"
videoEncoderVP9_2="/usr/local/bin/vpxenc"

#videoPostProcessVP9="/usr/bin/ffmpeg"
videoPostProcessVP9="/usr/local/bin/ffmpeg"

ffmpegPath="/usr/bin"

# Input files
inputVideo30fps="${inputDir}/tearsofsteel-ff-crop-29.97fps.y4m"
inputVideo60fps="${inputDir}/tearsofsteel-ff-crop-59.94fps.y4m"
inputAudio="${inputDir}/tearsofsteel-stereo.flac"
inputTextTop=${tempDir}/input_text_top.txt
inputTextBottom=${tempDir}/input_text_bottom.txt

# Misc
audioBitRate="128k"
# Max bit-rate ratio vs. default one
bitRateMargin=1.2

# BarCode folder
barcodeFolder="barcode_PECA-OPTO"
#barcodeFolder="barcode_GRAYUXM"
#barcodeFolder="barcode_PECA-OPTO-GRAYUXM"


# =================================================================================================
# MAIN CODE
# =================================================================================================
# Log file management
mkdir -p log
logFile="log/Tos_Video_encoding_$(date +%y%m%d_%H%M%S).log"
exec 3>&1 1> >(tee ${logFile}) 2>&1


# Cleanup
mkdir -p ${tempDir}
###rm -Rf ${tempDir}/*

# potential ISSSUE + $videoEncoderHEVC binary
# Potential issue with MP4Box and aac file

# Debug level
# 0 = full debug + execution
# 1 = Only basic log
# 2 = Same as 1 + display command lines
DEBUG=0

# Processing
################################################################
# STREAMING
################################################################
VERSION=$(date +%y%m%d%H%M)
VERSION="1606081724"
VERSION="1v0"
echo "VERSION=$VERSION"

# <GSMA1> 
# H264_encode "$inputVideo30fps" "$inputAudio" "720p"  "30" "3000" "8" "NOBARCODE"

# <GSMA1> 
# H264_encode "$inputVideo30fps" "$inputAudio" "720p"  "30" "3000" "8" "NOBARCODE" "DASH"

# <GSMA2>
# H264_encode "$inputVideo30fps" "$inputAudio" "1080p" "30" "5800" "8" "NOBARCODE"

# <GSMA3>
# HEVC_encode "$inputVideo30fps" "$inputAudio" "720p" "30" "10000" "8" "NOBARCODE"

# <GSMA4>
# HEVC_encode "$inputVideo30fps" "$inputAudio" "1080p" "30" "12000" "8" "NOBARCODE"

# <GSMA5>
# HEVC_encode "$inputVideo60fps" "$inputAudio" "1080p60fpsNetflix" "60" "20000" "8" "NOBARCODE"

# <GSMA6>
# HEVC_encode "$inputVideo30fps" "$inputAudio" "2160pNetflix" "30" "25000" "10" "NOBARCODE"

# <GSMA7>
# HEVC_encode "$inputVideo60fps" "$inputAudio" "2160p60fpsNetflix" "60" "40000" "10" "NOBARCODE"

# <GSMA8>
#VP9_encode "$inputVideo30fps" "$inputAudio" "720p" "30" "1200" "8" "NOBARCODE"

# <GSMA9>
#VP9_encode "$inputVideo30fps" "$inputAudio" "1080p" "30" "2300" "8" "NOBARCODE"

# <GSMA10>
#VP9_encode "$inputVideo30fps" "$inputAudio" "2160pYoutube" "30" "17000" "8" "NOBARCODE"

