#!/bin/sh

with_fallback() {
    if [ -z "$2" ]; then
        echo $1
    else
        shift
        echo $@
    fi
}

print_metadata() {

    noproxyout=$(curl -s https://noproxy-api.okaeri.eu/v1/me)
    ip=$(echo "$noproxyout" | grep -oP '"ip":(\s+)?"([^"\\]|\\.)*",?' | awk -F '"' '{print $4}')
    asn=$(echo "$noproxyout" | grep -oP '"asn":(\s+)?([0-9]+),?' | grep -oP '[0-9]+')
    provider=$(echo "$noproxyout" | grep -oP '"provider":(\s+)?"([^"\\]|\\.)*",?' | awk -F '"' '{print $4}')
    country=$(echo "$noproxyout" | grep -oP '"country":(\s+)?"([^"\\]|\\.)*",?' | awk -F '"' '{print $4}')

    echo "#"
    echo "# Okaeri Timings 1.0"
    echo "#"
    echo "# User: $(with_fallback "<Unknown>" $(whoami))"
    echo "# Hostname: $(with_fallback "<Unknown>" $(hostname))"
    echo "#"
    echo "# IP: $(with_fallback "<Unknown>" $ip)"
    echo "# ASN: $(with_fallback "<Unknown>" $asn)"
    echo "# Provider: $(with_fallback "<Unknown>" $provider)"
    echo "# Country: $(with_fallback "<Unknown>" $country)"
    echo "#"
    echo "# Kernel: $(with_fallback "<Unknown>" $(uname -r))"
    echo "# OS: $(with_fallback "<Unknown>" $(cat /etc/os-release | grep PRETTY_NAME | awk -F '"' '{print $2}'))"
    echo "#"
    echo "# Arch: $(with_fallback "<Unknown>" $(lscpu | grep '^Architecture: ' | cut -d\  -f3- | awk '{$1=$1; print}'))"
    echo "# CPU: $(with_fallback "<Unknown>" $(lscpu | grep '^Model name: ' | cut -d\  -f3- | awk '{$1=$1; print}'))"
    echo "#"
    echo "# Hypervisor: $(with_fallback "N/A" $(lscpu | grep '^Hypervisor vendor: ' | cut -d\  -f3- | awk '{$1=$1; print}'))"
    echo "# Virtualization: $(with_fallback "N/A" $(lscpu | grep '^Virtualization type: ' | cut -d\  -f3- | awk '{$1=$1; print}'))"
    echo "#"
}

print_header() {
    echo "timestamp,cpu/user,cpu/nice,cpu/system,cpu/idle,cpu/iowait,cpu/irq,cpu/softirq,cpu/steal,cpu/guest,cpu/guest_nice,mem/total,mem/free,mem/available,mem/buffers,mem/cached,swap/cached,swap/total,swap/free"
}

print_data() {
    timestamp=$(date +%s)

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

dump_delay=60
dump_cycles="$((${1-60}))"
dump_file="okaeri-timings-$(date +%s).csv"

if [ "$dump_cycles" -lt 5 ]; then
    echo "Report duration cannot be shorter than 5 minutes!"
else
    echo "[$(date '+%Y/%m/%d %H:%M:%S')] Saving data to $dump_file"
    print_metadata > "$dump_file"
    print_header >> "$dump_file"

    i=0
    while [ "$i" -lt "$dump_cycles" ]; do
        print_data >> "$dump_file"
        i=$(( i + 1 ))
        # spinner - start
        if [ "$i" -ne "$dump_cycles" ]; then
            j=0
            l=0
            while [ "$j" -lt "$dump_delay" ]; do
                j=$(( j + 1 ))
                l=$(( l + 1 ))
                case "$l" in
                    1)
                        spinner="◢"
                        ;;
                    2)
                        spinner="◣"
                        ;;
                    3)
                        spinner="◤"
                        ;;
                    4)
                        spinner="◥"
                        l=0
                        ;;
                esac
                printf "[$(date '+%Y/%m/%d %H:%M:%S')] Progress: $i/$dump_cycles ($spinner)\r"
                sleep 1
            done
        fi
        # spinner - end
        printf "[$(date '+%Y/%m/%d %H:%M:%S')] Progress: $i/$dump_cycles (✓)\r"
        printf "\n"
    done

    echo "[$(date '+%Y/%m/%d %H:%M:%S')] Done!"
fi

