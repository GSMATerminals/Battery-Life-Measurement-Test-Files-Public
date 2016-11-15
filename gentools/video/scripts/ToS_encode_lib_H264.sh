#!/bin/bash

# =================================================================================================
# Generic functions
# =================================================================================================
function H264_encode () {
	codec="H264"

	# Manage setup parameters
	source ./ToS_encode_opts.sh

	echo "- Prepare commands"
	case "$options" in
		"DASH" )
			echo "    + DASH is ON"
			extraOptions="-movflags +faststart -g $((raw_fps)) -keyint_min $((raw_fps*2)) -x264opts \"keyint=$((raw_fps*2)):min-keyint=$((raw_fps)):no-scenecut\""
			;;
		* )
			echo "    + Only faststart option is set (No DASH)"
			extraOptions="-movflags +faststart"
			;;
	esac

	# Barcode
	# Old value - Issues with 4k video
	#vbvBuffSize=1835
	vbvBuffSize=$maxVideoBitRate
	case "$barCodeOption" in
		"NOBARCODE" )
			echo "    + Barcode is OFF"
			commandLineParams="$videoEncoderH264 -y -i $inputVideo -i $inputAudio -filter_complex '[0:v]drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextTop:x=w/6:y=h/4-ascent/2:enable=lt\(t\\,5\),drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextBottom:x=w/6:y=h*.75-ascent/2:enable=lt\(t\\,5\),crop=min\(iw\\,ih*\(16/9\)\):ow/\(16/9\),scale=${outputResolution}[outv]' -sws_flags lanczos -map '[outv]' -map 1 -r $fps -c:v libx264 -preset placebo -profile:v $videoProfile -level $videoLevel -refs $refFrames -b:v ${videoBitRate}k -maxrate ${maxVideoBitRate}k ${extraOptions} -bufsize ${vbvBuffSize}k -pix_fmt yuv420p -threads 0"
			;;
		"BARCODE" )
			echo "    + Barcode is ON"
			commandLineParams="$videoEncoderH264 -y -i $inputVideo -loop 1 -r $fps -i ${inputDir}/${barcodeFolder}/frame%d.png -i $inputAudio -filter_complex '[1:v]scale=iw*0.75:-1[barcode];[0:v][barcode]overlay=\(W-w\)/2:\(H-h\)/2:shortest=1,drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextTop:x=w/6:y=h/4-ascent/2:enable=lt\(t\\,5\),drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextBottom:x=w/6:y=h*.75-ascent/2:enable=lt\(t\\,5\),crop=min\(iw\\,ih*\(16/9\)\):ow/\(16/9\),scale=${outputResolution}[outv]' -sws_flags lanczos -map '[outv]' -map 2 -r $fps -c:v libx264 -preset placebo -profile:v $videoProfile -level $videoLevel -refs $refFrames -b:v ${videoBitRate}k -maxrate ${maxVideoBitRate}k ${extraOptions} -bufsize  ${vbvBuffSize}k -pix_fmt yuv420p -threads 0"
			;;
		* )
			echo "ERROR - Wrong parameter for barcode: $barCodeOption"
			exit 1
			;;
	esac

	# Build final command line
	commandLine1="$commandLineParams -pass 1 -passlogfile ${tempDir}/${outputFileName}.log -an -f mp4 /dev/null"
	commandLine2="$commandLineParams -pass 2 -passlogfile ${tempDir}/${outputFileName}.log -c:a libfdk_aac -b:a $audioBitRate ${outputDir}/${outputFileName}.mp4"
	commandLine3=""
	commandLine4="$videoPostProcessH264 -dash 4000 -profile full -min-buffer 4000 -out ${outputDir}/${outputFileName}.mpd ${outputDir}/${outputFileName}.mp4#video ${outputDir}/${outputFileName}.mp4#audio"
	commandLine5="extractVideoInfo '${outputDir}/${outputFileName}.mp4'"

	# Process commands
	source ./ToS_encode_exec.sh
}
