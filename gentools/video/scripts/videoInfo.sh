#!/bin/bash

function extractVideoInfo () {
	outputFile="$1.txt"

	echo "=====================================================================" > $outputFile
	echo "$1" >> $outputFile
	echo "=====================================================================" >> $outputFile
	echo "SUMMARY">> $outputFile
	echo "=====================================================================" >> $outputFile
	echo >> $outputFile
	echo "VIDEO" >> $outputFile
	mediainfo --Inform="Video;Width=%Width%\n\
	Height=%Height%\n\
	Frame rate = %FrameRate/String%\n\
	Codec = %Codec%\n\
	Average bit rate = %BitRate/String%\n\
	Nominal bit rate = %BitRate_Nominal/String%\n\
	Maximum bit rate = %BitRate_Maximum/String%\n\
	Profile = %Format_Profile%\n\
	Ref frame = %Format_Settings_RefFrames%\n\
	GOP = %Format_Settings_GOP%\n\
	Color space = %ColorSpace%\n\
	Chroma subsampling = %ChromaSubsampling%\n\
	Bits/(Pixel*Frame) = %Bits-(Pixel*Frame)%\n\
	" "$1" >> $outputFile

	echo "AUDIO" >> $outputFile
	mediainfo --Inform="Audio;Sampling rate = %SamplingRate/String%\n\
	Codec = %Codec%\n\
	Bit rate mode = %BitRate_Mode/String%\n\
	Average bit rate = %BitRate/String%\n\
	Maximum bit rate = %BitRate_Maximum/String%\n"\
	 "$1" >> $outputFile

	echo >> $outputFile
	echo "FFMPEG" >> $outputFile
	${ffmpegPath}/ffmpeg -i "$1" 2>&1 | grep "Stream">> $outputFile 2>&1
	echo >> $outputFile
	echo >> $outputFile

	echo "=====================================================================" >> $outputFile
	echo "DETAILLED INFORMATION">> $outputFile
	echo "=====================================================================" >> $outputFile
	echo >> $outputFile
	mediainfo -f "$1" >> $outputFile 2>&1
	echo >> $outputFile
	echo >> $outputFile


	# Post process to generate bit-rate infos
	PATH=$ffmpegPath:$PATH
	perl plotbitrate.pl "$1" -o "$1.png"

	# Generate MD5 for the video
	md5sum $1 > $1.md5.txt
}
