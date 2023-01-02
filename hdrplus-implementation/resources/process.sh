#!/usr/bin/bash

###########################################################
#                                                         #
# Author: Sascha Scheid                                   #
# Date:   2023-01-01                                      #
#                                                         #
# This script triggers execution of the hdrplus program   #
# to process multiple image bursts in parallel.           #
#                                                         #
###########################################################

if [ ! -f /.dockerenv ] || [ ! -f /hdr-plus/hdrplus ]
then
    echo "This script is meant to run inside a container where hdrplus is present."
    echo "Standalone execution is not possible"
    exit 1
fi

INPUT_DIR=/bursts
OUTFILE=output.png

# Enable extended globbing to be able to only 
# use RAW files as arguments for hdrplus 
shopt -s extglob

# Start a hdrplus process for every burst directory.
# This enables processing multiple bursts in parallel.
for burstdir in "$INPUT_DIR"/*
do
    # Ignore burst directories that have already been processed
    if [ -d "$burstdir" ] && [ ! -f "$burstdir/$OUTFILE" ]
    then
        logfile="$burstdir/$(date '+%F_%T').log"
        ./hdr-plus/hdrplus "." "$burstdir/$OUTFILE" "$burstdir"/@(*.RAW|*.raw|*.ARW|*.arw|*.DNG|*.dng) > "$logfile" 2>&1 &
    fi
done

# Disable extended globbing
shopt -u extglob

# Wait for all jobs to finish.
# Without this the Docker container will
# shutdown after starting all jobs.
wait
