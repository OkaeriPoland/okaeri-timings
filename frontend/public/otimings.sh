#!/bin/sh

print_metadata() {
    echo "#"
    echo "# Okaeri Timings 1.0"
    echo "#"
    echo "# Hostname: $(hostname)"
#     echo "# IP: $(curl -s https://checkip.amazonaws.com/)"
    echo "# User: $(whoami)"
    echo "#"
    echo "# Kernel: $(uname -r)"
    echo "# OS: $(cat /etc/os-release | grep PRETTY_NAME | awk -F '"' '{print $2}')"
    echo "#"
}

print_header() {
    echo "timestamp,cpu/user,cpu/nice,cpu/system,cpu/idle,cpu/iowait,cpu/irq,cpu/softirq,cpu/steal,cpu/guest,cpu/guest_nice,mem/total,mem/free,mem/available,mem/buffers,mem/cached,swap/cached,swap/total,swap/free"
}

print_data() {
    timestamp=$(date --iso-8601=seconds)

    procstatout=$(cat /proc/stat | grep -m1 ^cpu | cut -d ' ' -f 3-)
    user=$(echo "$procstatout" | awk '{print $1}')
    nice=$(echo "$procstatout" | awk '{print $2}')
    system=$(echo "$procstatout" | awk '{print $3}')
    idle=$(echo "$procstatout" | awk '{print $4}')
    iowait=$(echo "$procstatout" | awk '{print $5}')
    irq=$(echo "$procstatout" | awk '{print $6}')
    softirq=$(echo "$procstatout" | awk '{print $7}')
    steal=$(echo "$procstatout" | awk '{print $8}')
    guest=$(echo "$procstatout" | awk '{print $9}')
    guest_nice=$(echo "$procstatout" | awk '{print $10}')

    meminfout=$(cat /proc/meminfo)
    memtotal=$(echo "$meminfout" | grep ^MemTotal: | awk '{print $2}')
    memfree=$(echo "$meminfout" | grep ^MemFree: | awk '{print $2}')
    membuffers=$(echo "$meminfout" | grep ^Buffers: | awk '{print $2}')
    memcached=$(echo "$meminfout" | grep ^Cached: | awk '{print $2}')
    memavailable=$(echo "$meminfout" | grep ^MemAvailable: | awk '{print $2}')
    swapcached=$(echo "$meminfout" | grep ^SwapCached: | awk '{print $2}')
    swaptotal=$(echo "$meminfout" | grep ^SwapTotal: | awk '{print $2}')
    swapfree=$(echo "$meminfout" | grep ^SwapFree: | awk '{print $2}')

    echo "$timestamp,$user,$nice,$system,$idle,$iowait,$irq,$softirq,$steal,$guest,$guest_nice,$memtotal,$memfree,$memavailable,$membuffers,$memcached,$swapcached,$swaptotal,$swapfree"
}

print_metadata
print_header
print_data
