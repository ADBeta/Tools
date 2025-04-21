#!/bin/sh

# Downloads a months worth of Crosswords from the Guardian's
# online PDF Crossword Archive.
# Attempts to do 31 days of Crosswords with any given month,
# so some may fail if the month has less than 31 days.
# It is also expected that a few may fail because there are
# no Crosswords on Sundays. 
# Any failed file will be removed and progress will continue as normal.
#
# Each days Crossword will be merged into one PDF for the whole month,
# in date order so the next days Crossword is on the next page, along
# with the solution.
#
# (c) ADBeta   21 Apr 2025   Ver1.0

TMPDIR="/tmp/Crossword_Skimmer"
PREFIX="https://crosswords-static.guim.co.uk/gdn.quick."

# Create an output folder for the downloaded files in tmp
rm -r $TMPDIR
mkdir $TMPDIR

# Get the Month and Year from the user TODO: Sanitise
read -p "Enter Year         : " YEAR
read -p "Enter Month (1-12) : " MONTH

# Try 31 Days to catch all Months
for DAY in $(seq 1 31)
do
	# Create a date string - with DAY, MONTH and YEAR formatted
	DATE=$(printf "%d%02d%02d" $YEAR $MONTH $DAY)

	# Create the link for the desired Crossword PDF File
	PDFFILE="${PREFIX}${DATE}.pdf"

	# Print Status message
	echo -ne "Trying to download file $DATE.....\t"
	
	# Download the PDF File
	wget -q -O "$TMPDIR/$DATE.pdf" $PDFFILE
	# If successful, print message and continue
	if [ $? -eq 0 ];
	then
		echo -ne "DONE\n"
	else
	# If failed, print error and remove the dangling empty file
		echo -ne "FAILED\n"
		rm "$TMPDIR/$DATE.pdf"
	fi
done

# Combine the PDF Files into a single one
OUTFILE=$(printf "%s/Crosswords_%02d-%d.pdf" $PWD $MONTH $YEAR)
pdfunite $TMPDIR/*.pdf $OUTFILE

echo -e "\nCreated Output PDF File: $OUTFILE"
