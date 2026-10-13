#!/bin/bash
# Samples CPU and resident memory of the running "Tinycast Dev" process, for the backdrop budget.
#
# Usage: Scripts/measure-backdrop.sh [seconds]   (default 10)
#        TINYCAST_PROCESS=name Scripts/measure-backdrop.sh   (another process name, for a dry run)
#
# Pick the theme first: Settings > General > Theme > Tron, or run
#   defaults write com.tinycast.app.dev visualTheme tron
# yourself, then relaunch. Run this three times against the same process:
#   1. palette hidden (baseline)
#   2. palette open on the launcher, Tron animating
#   3. palette hidden again (must return to the baseline CPU within 0.5)
# Budget: run 2 minus run 1 under 5.0 %CPU and under 8192 KB RSS; run 3 equals run 1.
#
# CPU is the growth of the process's accumulated CPU time (`ps -o cputime=`) between the first and
# last sample, divided by the wall time between them, so it covers only this window. `ps -o %cpu` is a
# decayed average that lags a state change and would blur the open versus hidden difference.
# RSS is the mean of the per-second `ps -o rss=` samples.

set -euo pipefail

seconds=${1:-10}
if ! [[ "$seconds" =~ ^[0-9]+$ ]] || [ "$seconds" -lt 1 ]; then
    echo "usage: $0 [seconds]   (a whole number of seconds, 1 or more)" >&2
    exit 2
fi
name=${TINYCAST_PROCESS:-Tinycast Dev}
pid=$(pgrep -x "$name" | head -n 1 || true)
if [ -z "$pid" ]; then
    echo "$name is not running" >&2
    exit 1
fi

now() {
    perl -MTime::HiRes=time -e 'printf "%.3f\n", time'
}

# Accepts [[d-]hh:]mm:ss[.ss]; prints seconds.
cpu_seconds() {
    awk -v t="$1" 'BEGIN {
        days = 0
        if (index(t, "-")) { split(t, d, "-"); days = d[1]; t = d[2] }
        n = split(t, p, ":")
        s = 0
        for (i = 1; i <= n; i++) s = s * 60 + p[i]
        printf "%.3f", s + days * 86400
    }'
}

sample() {
    ps -o cputime=,rss= -p "$pid" || { echo "process exited" >&2; exit 1; }
}

first=$(sample)
read -r cpu0 rss <<< "$first"
wall0=$(now)
rss_sum=$rss
count=1
for _ in $(seq 1 "$seconds"); do
    sleep 1
    last=$(sample)
    read -r cpu1 rss <<< "$last"
    rss_sum=$((rss_sum + rss))
    count=$((count + 1))
done
wall1=$(now)

awk -v a="$(cpu_seconds "$cpu0")" -v b="$(cpu_seconds "$cpu1")" -v w="$wall1" -v w0="$wall0" \
    -v rss="$rss_sum" -v n="$count" \
    'BEGIN { printf "mean CPU %.1f %%  mean RSS %d KB  (%d samples, %.1f s)\n", (b - a) / (w - w0) * 100, rss / n, n, w - w0 }'
