#!/bin/bash

# =================================================================================================
# Generic functions
# =================================================================================================
function VP8_encode () {
	codec="VP8"

	# Manage setup parameters
	source ./ToS_encode_opts.sh

	echo "- Prepare commands"
	case "$options" in
		"DASH" )
			echo "    + DASH is ON - NOT MANAGED FOR NOW"
			exit 1
			;;
		* )
			echo "    + No supplementary options set (No DASH)"
			extraOptions=""
			commentExtension=""
			;;
	esac

	# // processing
	maxNbCpu=8
	maxNbThreads=${maxNbCpu}

	# Barcode
	case "$barCodeOption" in
		"NOBARCODE" )
			echo "    + Barcode is OFF"
		commandLineParams="$videoEncoderVP8_1 -y -i $inputVideo -i $inputAudio               -filter_complex '[0:v]drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextTop:x=w/6:y=h/4-ascent/2:enable=lt\(t\\,5\),drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextBottom:x=w/6:y=h*.75-ascent/2:enable=lt\(t\\,5\),crop=min\(iw\\,ih*\(16/9\)\):ow/\(16/9\),scale=${outputResolution}[outv]' -sws_flags lanczos -map '[outv]' -map 1 -r $fps -f yuv4mpegpipe -pix_fmt yuv420p -an - | $videoEncoderVP8_2 --codec=vp8 --threads=${maxNbThreads} --passes=2 --good --cpu-used=0 --target-bitrate=$videoBitRate --end-usage=vbr --auto-alt-ref=1 --lag-in-frames=24 --kf-max-dist=150 --kf-min-dist=0 --maxsection-pct=100 --minsection-pct=90 --static-thresh=0 --min-q=0 --max-q=63 --arnr-maxframes=7 --arnr-strength=5 --arnr-type=3 --passes=2 --bit-depth=${extraOptionsBits} --profile=0"

#xxx--codec=vp9
#--threads=${maxNbThreads}
#--passes=2
#--good
#xx--cpu-used=0
#--target-bitrate=$videoBitRate
#--end-usage=vbr
#x--frame-parallel=1
#x--tile-columns=$tileColumn
#xx--auto-alt-ref=1
#--lag-in-frames=24
#--kf-max-dist=150
#--kf-min-dist=0
#--maxsection-pct=100
#--minsection-pct=90
#--static-thresh=0
#--min-q=0
#--max-q=63
#xx--arnr-maxframes=7
#xx--arnr-strength=5
#xx--arnr-type=3
#--passes=2
#--bit-depth=${extraOptionsBits}
#--profile=0"


			# Faire vbr avec min/max section %

#			--frame-parallel=1 --tile-columns=$tileColumn --auto-alt-ref=1 --lag-in-frames=24 --kf-max-dist=150 --kf-min-dist=0 --maxsection-pct=300 --minsection-pct=60 --static-thresh=0 --min-q=0 --max-q=63 --arnr-maxframes=7 --arnr-strength=5 --arnr-type=3 --bit-depth=${extraOptionsBits}"
#	vbvBuffSize=$maxVideoBitRate
#--vbv-maxrate $maxVideoBitRate ${extraOptions} --vbv-bufsize $vbvBuffSize
			;;
		"BARCODE" )
			echo "    + Barcode is ON"
#			commandLineParams="$videoEncoderVP8_1 -y -i $inputVideo -loop 1 -r $fps -i ${inputDir}/${barcodeFolder}/frame%d.png -i $inputAudio -filter_complex '[1:v]scale=iw*0.75:-1[barcode];[0:v][barcode]overlay=\(W-w\)/2:\(H-h\)/2:shortest=1,drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextTop:x=w/6:y=h/4-ascent/2:enable=lt\(t\\,5\),drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextBottom:x=w/6:y=h*.75-ascent/2:enable=lt\(t\\,5\),crop=min\(iw\\,ih*\(16/9\)\):ow/\(16/9\),scale=${outputResolution}[outv]' -sws_flags lanczos -map '[outv]' -map 2 -r $fps -f yuv4mpegpipe -pix_fmt yuv420p -an - | $videoEncoderVP8_2 --codec=vp8 --cpu-used=0 --threads=${maxNbThreads} --target-bitrate=$videoBitRate --auto-alt-ref=1 --lag-in-frames=24 --kf-max-dist=150 --kf-min-dist=0 --maxsection-pct=300 --minsection-pct=60 --static-thresh=0 --min-q=0 --max-q=63 --arnr-maxframes=7 --arnr-strength=5 --arnr-type=3 --end-usage=vbr --passes=2 --bit-depth=${extraOptionsBits}"
			commandLineParams="$videoEncoderVP8_1 -y -i $inputVideo -loop 1 -r $fps -i ${inputDir}/${barcodeFolder}/frame%d.png -i $inputAudio -filter_complex '[1:v]scale=iw*0.75:-1[barcode];[0:v][barcode]overlay=\(W-w\)/2:\(H-h\)/2:shortest=1,drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextTop:x=w/6:y=h/4-ascent/2:enable=lt\(t\\,5\),drawtext=fontfile=${inputDir}/IntelClear_Rg.ttf:fontsize=40:fontcolor=white:textfile=$inputTextBottom:x=w/6:y=h*.75-ascent/2:enable=lt\(t\\,5\),crop=min\(iw\\,ih*\(16/9\)\):ow/\(16/9\),scale=${outputResolution}[outv]' -sws_flags lanczos -map '[outv]' -map 2 -r $fps -f yuv4mpegpipe -pix_fmt yuv420p -an - | $videoEncoderVP8_2 --codec=vp8 --cpu-used=0 --threads=${maxNbThreads} --target-bitrate=$videoBitRate --auto-alt-ref=1 --lag-in-frames=24 --kf-max-dist=150 --kf-min-dist=0 --maxsection-pct=300 --minsection-pct=60 --static-thresh=0 --min-q=0 --max-q=63 --arnr-maxframes=7 --arnr-strength=5 --arnr-type=3 --end-usage=cbr --passes=2 --bit-depth=${extraOptionsBits}"
			;;
		* )
			echo "ERROR - Wrong parameter for barcode: $barCodeOption"
			exit 1
			;;
	esac

	# Build final command line
	commandLine1="$commandLineParams --pass=1 --fpf=${tempDir}/${outputFileName}.log -o ${outputDir}/${outputFileName}.vp8 -"
	commandLine2="$commandLineParams --pass=2 --fpf=${tempDir}/${outputFileName}.log -o ${outputDir}/${outputFileName}.vp8 -"
	commandLine3="$videoPostProcessVP8 -y -i ${outputDir}/${outputFileName}.vp8 -i $inputAudio -map 0 -map 1:a -c:v copy -c:a libvorbis -b:a $audioBitRate ${outputDir}/${outputFileName}.webm"
	commandLine4=""
	commandLine5="extractVideoInfo '${outputDir}/${outputFileName}.webm'"

	# Process commands
	source ./ToS_encode_exec.sh
}
