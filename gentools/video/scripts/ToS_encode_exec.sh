#!/bin/bash

# =================================================================================================
# Process commands
# =================================================================================================
echo
echo "- Encoding pass 1"
echo "    + `date`"
if [ $DEBUG -eq 0 ] || [ $DEBUG -eq 2 ]; then
	echo "$commandLine1"
fi
if [ $DEBUG -eq 0 ]; then
    echo $commandLine1
	eval $commandLine1
fi

echo
echo "- Encoding pass 2"
echo "    + `date`"
if [ $DEBUG -eq 0 ] || [ $DEBUG -eq 2 ]; then
	echo "$commandLine2"
fi
if [ $DEBUG -eq 0 ]; then
    echo $commandLine2
	eval $commandLine2
fi

echo
echo "- Postprocessing"
echo "    + `date`"
if [ $DEBUG -eq 0 ] || [ $DEBUG -eq 2 ]; then
	echo "$commandLine3"
fi
if [ $DEBUG -eq 0 ]; then
	eval $commandLine3
fi

echo
echo "    + DASH Postprocessing"
echo "    + `date`"
case "$options" in
	"DASH" )
		echo "    + DASH post-processing"
		if [ $DEBUG -eq 0 ] || [ $DEBUG -eq 2 ]; then
			echo "$commandLine4"
		fi
		if [ $DEBUG -eq 0 ]; then
			eval $commandLine4
		fi
		;;
	* )
		echo "    + No Postprocessing applied"
		;;
esac

echo
echo "    + Extracting video information"
echo "    + `date`"
if [ $DEBUG -eq 0 ] || [ $DEBUG -eq 2 ]; then
	echo "$commandLine5"
fi
if [ $DEBUG -eq 0 ]; then
	eval $commandLine5
fi

echo
echo "PROCESSING COMPLETED ON: `date`"
echo "--------------------------------------------------------------------------------"
