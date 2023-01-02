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

        logdir="$burstdir/logs"
        logfile="$logdir/$(date '+%F_%T').log"
        configfile="$burstdir/hdrplus.config"
    
        # Ensure log directory exists (modify permissions to be able to delete it from without the container!)
        [ -d "$logdir" ] || mkdir "$logdir" && chmod 0777 "$logdir"

        flags=""

        # Set flags according to configuration file if present
        if [ -f "$configfile" ]
        then
            cat "$configfile" >> "$logfile"
            eval $(cat "$configfile" | xargs)
            [ ! -z ${GAIN+x} ] && flags="$flags -g $GAIN" && [ ! -z ${COMPRESSION+x} ] && flags="$flags -c $COMPRESSION"
        fi
        ./hdr-plus/hdrplus $flags "." "$burstdir/$OUTFILE" "$burstdir"/@(*.RAW|*.raw|*.ARW|*.arw|*.DNG|*.dng) >> "$logfile" 2>&1 &
    fi
done

# Disable extended globbing
shopt -u extglob

# Wait for all jobs to finish.
# Without this the Docker container will
# shutdown after starting all jobs.
wait
