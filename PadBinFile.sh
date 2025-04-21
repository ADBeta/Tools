#!/bin/sh

# Pads a binary file to any size in MB with 0xFF, for flashing NOR/NAND Flash
# (c) ADBeta    Apr 2024

ORIG_BIN_FILE=$1
TEMP_BIN_FILE="/tmp/ff_padded_bin_file.bin"

# Make sure the user padded an original (input) binary file, and that it exists
if [ -z "$ORIG_BIN_FILE" ]; then echo "Please provide an input Binary File"; exit; fi
if [ ! -f "$ORIG_BIN_FILE" ]; then echo "Input Binary File is not valid"; exit; fi

# Get the size in MB to make the file
read -p "Enter output filesize in MiB: " BIN_FILE_MB

if ! [[ "$BIN_FILE_MB" =~ ^[0-9]+$ ]]; then echo "Input is not a number"; exit; fi
if [[ $BIN_FILE_MB -gt 1024 ]]; then echo "Input is too large"; exit; fi


# Make a file of the specified size in MB
dd if=/dev/zero bs=1M count=$BIN_FILE_MB status=none | LC_ALL=C tr "\000" "\377" > $TEMP_BIN_FILE

# Combine the original bin and the temporary bin file
dd if=$ORIG_BIN_FILE of=$TEMP_BIN_FILE conv=notrunc status=none

# Move the tmp bin file to where the original bin file is, with _padded 
# appended before the extension
FILEPATH="${ORIG_BIN_FILE%.*}"
EXTENSION="${ORIG_BIN_FILE##*.}"

mv $TEMP_BIN_FILE ""$FILEPATH"_padded."$EXTENSION""
