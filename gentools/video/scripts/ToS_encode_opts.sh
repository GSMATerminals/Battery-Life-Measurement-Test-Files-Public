#!/bin/bash

# =================================================================================================
# Generic code for command line options management
# =================================================================================================
echo
echo
echo "EXECUTING $codec ENCODING"
echo "PROCESSING STARTED ON: `date`"

# Reassign input parameters
inputVideo="$1"
inputAudio="$2"
resolution="$3"
raw_fps="$4"
videoBitRate="$5"
nbBits="$6"
barCodeOption="$7"
options="$8"

maxVideoBitRate="$(echo ${videoBitRate}*${bitRateMargin}/1 | bc)"
outputFileName="ToS"

echo "- Input video: $inputVideo"
echo "- Input Audio: $inputAudio"

echo "- Output parameters"

# Resolution
case "$resolution" in
	"360p" )
		outputResolution="640:360"
		# H264 only
		videoProfile="main"
		# H264 and H265
		videoLevel="3.1"
		# H264 only
		refFrames="2"
		# VP9 only
		tileColumn="3"
		;;
	"720p" )
		outputResolution="1280:720"
		# H264 only
		videoProfile="main"
		# H264 and H265
		videoLevel="3.1"
		# H264 only
		refFrames="2"
		# VP9 only
		tileColumn="3"
		;;
	"1080pIntel" )
		outputResolution="1920:1080"
		# H264 only
		videoProfile="high"
		# H264 and H265
		videoLevel="4.1"
		# H264 only
		refFrames="4"
		# VP9 only
		tileColumn="3"
		;;
	"1080p" )
		outputResolution="1920:1080"
		# H264 only
		videoProfile="main"
		# H264 and H265
		videoLevel="4.0"
		# H264 only
		refFrames="4"
		# VP9 only
		tileColumn="3"
		;;
	"1080p60fpsNetflix" )
		outputResolution="1920:1080"
		# H264 only
		videoProfile="main"
		# H264 and H265
		videoLevel="4.1"
		# H264 only
		refFrames="4"
		# VP9 only
		tileColumn="3"
		;;
	"2160p" )
		outputResolution="3840:2160"
		# H264 only
		videoProfile="main"
		# H264 and H265
		videoLevel="5.1"
		# H264 only
		refFrames="5"
		# VP9 only
		tileColumn="4"
		;;
	"2160pNetflix" )
		outputResolution="3840:2160"
		# H264 only
		videoProfile="main"
		# H264 and H265
		videoLevel="5.0"
		# H264 only
		refFrames="5"
		# VP9 only
		tileColumn="4"
		;;
	"2160pYoutube" )
		outputResolution="3840:2160"
		# H264 only
		videoProfile="main"
		# H264 and H265
		videoLevel="5.0"
		# H264 only
		refFrames="5"
		# VP9 only
		tileColumn="4"
		;;
	"2160p60fpsNetflix" )
		outputResolution="3840:2160"
		# H264 only
		videoProfile="main"
		# H264 and H265
		videoLevel="5.1"
		# H264 only
		refFrames="5"
		# VP9 only
		tileColumn="4"
		;;
	* )
		echo "ERROR - Wrong resolution: $resolution"
		exit 1
		;;
esac
outputFileName="${outputFileName}_${resolution}"
echo "    + Resolution: $outputResolution"


# FPS
case "$raw_fps" in
	"30" )
		fps="29.97"
		;;
	"60" )
		fps="59.94"
		;;
	* )
		echo "ERROR - Wrong FPS: $raw_fps"
		exit 1
		;;
esac
outputFileName="${outputFileName}_${fps}fps"
echo "    + FPS: $fps"


# Codec choice
outputFileName="${outputFileName}_${codec}"

# Bit rate + margin
echo "    + Bit rate: ${videoBitRate}k / ${maxVideoBitRate}k"
outputFileName="${outputFileName}_${videoBitRate}kbps"

# Color depth
case "$nbBits" in
	"12" )
		echo "    + Color depth: 12 bits"
		extraOptionsBits="12"
		;;
	"10" )
		echo "    + Color depth: 10 bits"
		extraOptionsBits="10"
		;;
	"8" )
		echo "    + Color depth: 8 bits"
		extraOptionsBits="8"
		;;
	* )
		echo "    + Wrong color depth specified ($nbBits)"
		exit 1
		;;
esac
outputFileName="${outputFileName}_${nbBits}bits"


# Currently, no HDR supported
outputFileName="${outputFileName}_noHDR"


# Options - Dash
optionsText="_"
case "$options" in
	"DASH" )
		echo "    + DASH is ON"
		optionsText="${optionsText}$(if [[ "$optionsText" != "_" ]] ; then echo "-"; fi)dash"
		commentExtension="- DASH version"
		;;
	* )
		echo "    + No supplementary options set (No DASH)"
		commentExtension=""
		;;
esac

# Options - Barcode
case "$barCodeOption" in
	"NOBARCODE" )
		echo "    + Barcode is OFF"
		;;
	"BARCODE" )
		echo "    + Barcode is ON"
		optionsText="${optionsText}$(if [[ "$optionsText" != "_" ]] ; then echo "-"; fi)barcoded"
		;;
	* )
		echo "ERROR - Wrong parameter for barcode: $barCodeOption"
		exit 1
		;;
esac

# Add date as a version number
if [ -z "$VERSION" ]; then VERSION=$(date +%y%m%d%H%M); else echo "    + Reuse Version=$VERSION for file naming"; fi
optionsText="${optionsText}$(if [[ "$optionsText" != "_" ]] ; then echo "-"; fi)v$VERSION"
#optionsText="${optionsText}$(if [[ "$optionsText" != "_" ]] ; then echo "-"; fi)v$(date +%y%m%d%H%M)"

# Build the final output name
outputFileName="${outputFileName}$(echo ${optionsText} | sed 's/^_$//')"
echo "    + Output file name: ${outputDir}/${outputFileName}.mp4"

# Prepare text added at the beginning of the video
echo
source ./ToS_encode_text.sh
