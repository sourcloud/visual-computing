#!/usr/bin/sh

#############################################################
#                                                           #
#   Author: Sascha Scheid                                   #
#   Date:   2023-01-01                                      #
#                                                           #
#   This script triggers execution of the hdrplus program   #
#   to process multiple image bursts in parallel.           #
#                                                           #
#############################################################


# Sanity check for script environment as this script
# is not meant to be portable and belongs to the
# specific Docker image
#
# USAGE: check_environment

check_environment() {
    if [ ! -f /.dockerenv ] || ! command -v hdrplus > /dev/null
    then
        echo "This script is meant to run inside a container where hdrplus is present and executable."
        echo "Standalone execution is not possible"
        exit 1
    fi
}


# To avoid RAM overload and swapping, the number of 
# parallel jobs is limited.
#
# When called, this function will check if amount of
# running jobs is lower than amount of available CPU
# threads and block further execution if not.
#
# When blocking, it rechecks every 5 seconds.
#
# NOTE: This assumes around 2-4 GB RAM per thread. 
#       To be save if your system does not meet this 
#       criteria you should consider changing "$(nproc)" 
#       to (amount of RAM in GB) / 4
#
# USAGE: wait_for_jobs

wait_for_jobs() {
    while [ "$(jobs | wc -l)" -ge "$(nproc)" ]
    do
        sleep 5
    done
}


# Utility to find RAW files in a given directory.
# Writes them as whitespace separated list to stdout
# and into specified logfile.
#
# USAGE: find_raws directory logfile

find_raws() {
    find "$1" -maxdepth 1 -type f \( -iname "*.RAW" -o -iname "*.ARW" -o -iname "*.DNG" \) -printf "%f\0" | xargs -0 | tee -a "$2"
}


# Checks if configuration is available for
# individual bursts. If present, it extracts
# values for gain / compression and sets the
# flags according to them.
#
# USAGE: determine_execution_flags configfile logfile

determine_execution_flags() {

    flags=""

    if [ -f "$1" ]
    then
        eval "$(tee -a "$2" < "$1" | xargs)"

        # Set flags according to configuration file if value is set
        [ -n "${GAIN+x}" ]        && flags="$flags -g $GAIN"
        [ -n "${COMPRESSION+x}" ] && flags="$flags -c $COMPRESSION"
    fi

    echo "$flags" | tee -a "$2"
}


##################################
#                                #
#   Actual script begins below   #
#                                #
##################################

check_environment

INPUT_DIR=/bursts
OUTFILE=output.png

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

        # Execution flags are evaluated per burst
        flags="$(determine_execution_flags "$configfile" "$logfile")"
        raws="$(find_raws "$burstdir" "$logfile")"

        # Only process another burst if a thread is available
        wait_for_jobs

        # Start procesisng another burst as a background job
        hdrplus $flags "$burstdir" "$OUTFILE" $raws >> "$logfile" 2>&1 &
    fi
done

# Wait for all jobs to finish.
# Without this the Docker container will
# shutdown after starting all jobs.
wait
