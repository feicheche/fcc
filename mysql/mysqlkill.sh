#!/bin/bash

useage="Useage: mysqlkill ip port busytime(sec) method(check/kill)"

if [ "$4" = "check" ]; then
    pt-kill --host=$1 --password='xxxx' --port=$2 --interval=1 --user=xxxx --busy-time=$3 --noversion-check --print --run-time 3
    #pt-kill --host=$1 --password='xxxx' --port=$2 --interval=1 --user=xxxx --busy-time=$3 --noversion-check --match-command=Query --print --run-time 3
elif [ "$4" = "kill" ]; then
    pt-kill --host=$1 --password='xxxx' --port=$2 --interval=1 --user=xxxx --busy-time=$3 --noversion-check --match-command=Query --print --kill --run-time 3
elif [ "$1" = "-h" -o "$1" = "--help" ]; then
    echo $useage
else
    echo $useage
fi