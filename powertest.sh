#!/bin/sh

HOST=gateway
TRIES=4
SUCCESS_STRING="bytes from $HOST"
DATE_COMMAND="date +'%d-%b-%Y %H:%M:%S'"
SHUTDOWN_INTERVAL=30

PROGRAM_SLEEP_INTERVAL="2m"
SHUTDOWN_SCHEDULED=0
LOGGER_TAG="powertest"


while true; do
    RESP_RECV=$(ping -Ac$TRIES $HOST | grep -c "$SUCCESS_STRING")

    # some response means the router is still on
    if (( $RESP_RECV != 0 )); then
        if (( SHUTDOWN_SCHEDULED != 0 )); then
            logger -sit $LOGGER_TAG "Power is back - Cancelling scheduled shutdown"
            shutdown -c
            SHUTDOWN_SCHEDULED=0
            /home/sujoy/bin/alliance
        fi
    # else the router is not powered on
    # assuming the router is connected at all times
    else
        if (( SHUTDOWN_SCHEDULED == 0 )); then
            logger -sit $LOGGER_TAG "Shut down scheduled in $SHUTDOWN_INTERVAL mins for power cut ..."
            /home/sujoy/bin/seagate.ext.manage -u
            shutdown -hP +$SHUTDOWN_INTERVAL "system shutdown initiated for power failure" &!
            SHUTDOWN_SCHEDULED=1
        fi
    fi

    sleep $PROGRAM_SLEEP_INTERVAL
done
