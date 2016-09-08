#!/bin/bash

# =================================================================================================
# Generic functions
# =================================================================================================
function HEVC_encode () {
	codec="H265"

	# Manage setup parameters
	source ./ToS_encode_opts.sh

	echo "- Prepare commands"
	case "$options" in
		"DASH" )
			echo "    + DASH is ON"
			extraOptions="--min-keyint=$((raw_fps*2)) --keyint $((raw_fps*2)) --min-keyint $((raw_fps)) --no-scenecut"
			;;
		* )
			echo "    + No supplementary options set (No DASH)"
			extraOptions="--min-keyint 30 --keyint 300"
			;;
	esac

	# Barcode
	# Old value - Issues with 4k video
	#vbvBuffSize=1000
	vbvBuffSize=$maxVideoBitRate
	case "$barCodeOption" in
		"NOBARCODE" )
			echo "    + Barcode is OFF"
			commandLineParams="$videoEncoderHEVC1 -y -i $inputVideo -i $inputAudio -filter_complex '[0:v]drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextTop:x=w/6:y=h/4-ascent/2:enable=lt\(t\\,5\),drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextBottom:x=w/6:y=h*.75-ascent/2:enable=lt\(t\\,5\),crop=min\(iw\\,ih*\(16/9\)\):ow/\(16/9\),scale=${outputResolution}[outv]' -sws_flags lanczos -map '[outv]' -map 1 -r $fps -f yuv4mpegpipe -pix_fmt yuv420p -an - | $videoEncoderHEVC2 --preset placebo --y4m -o ${outputDir}/${outputFileName}.hevc --output-depth ${extraOptionsBits} --bitrate $videoBitRate --vbv-maxrate $maxVideoBitRate ${extraOptions} --vbv-bufsize $vbvBuffSize --aq-mode 2 --aq-strength 1.5 --psy-rd 1.0 --psy-rdoq 1.0 --repeat-headers --level $videoLevel"
			;;
		"BARCODE" )
			echo "    + Barcode is ON"
			commandLineParams="$videoEncoderHEVC1 -y -i $inputVideo -loop 1 -r $fps -i ${inputDir}/${barcodeFolder}/frame%d.png -i $inputAudio -filter_complex '[1:v]scale=iw*0.75:-1[barcode];[0:v][barcode]overlay=\(W-w\)/2:\(H-h\)/2:shortest=1,drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextTop:x=w/6:y=h/4-ascent/2:enable=lt\(t\\,5\),drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextBottom:x=w/6:y=h*.75-ascent/2:enable=lt\(t\\,5\),crop=min\(iw\\,ih*\(16/9\)\):ow/\(16/9\),scale=${outputResolution}[outv]' -sws_flags lanczos -map '[outv]' -map 2 -r $fps -f yuv4mpegpipe -pix_fmt yuv420p -an - | $videoEncoderHEVC2 --preset placebo --y4m -o ${outputDir}/${outputFileName}.hevc --output-depth ${extraOptionsBits} --bitrate $videoBitRate --vbv-maxrate $maxVideoBitRate ${extraOptions} --vbv-bufsize $vbvBuffSize --aq-mode 2 --aq-strength 1.5 --psy-rd 1.0 --psy-rdoq 1.0 --repeat-headers --level $videoLevel"
			;;
		* )
			echo "ERROR - Wrong parameter for barcode: $barCodeOption"
			exit 1
			;;
	esac

    # Command line used to generate aac file used as input
	# commandLineParams="ffmpeg -i $inputAudio -c:a libfdk_aac -b:a $audioBitRate ${outputDir}/tearsofsteel-stereo-$audioBitRate.aac"
    # echo $commandLineParams
    # eval  $commandLineParams
    # exit
	# Build final command line
	commandLine1="$commandLineParams --pass 1 --stats ${tempDir}/${outputFileName}.log -"
	commandLine2="$commandLineParams --pass 2 --stats ${tempDir}/${outputFileName}.log -"
	commandLine3="$videoPostProcessHEVC -new -add ${outputDir}/${outputFileName}.hevc -add ${inputDir}/tearsofsteel-stereo-$audioBitRate.aac ${outputDir}/${outputFileName}.mp4"
	commandLine4="$videoPostProcessHEVC -dash 4000 -profile full -min-buffer 4000 -out ${outputDir}/${outputFileName}.mpd ${outputDir}/${outputFileName}.mp4#video ${outputDir}/${outputFileName}.mp4#audio"
	commandLine5="extractVideoInfo '${outputDir}/${outputFileName}.mp4'"

	# Process commands
	source ./ToS_encode_exec.sh
}
