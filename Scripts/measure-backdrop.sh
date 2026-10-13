#!/bin/bash
# Samples CPU and resident memory of the running "Tinycast Dev" process, for the backdrop budget.
#
# Usage: Scripts/measure-backdrop.sh [seconds]   (default 10)
#
# Pick the theme first: Settings > General > Theme > Tron, or yourself run
#   defaults write com.tinycast.app.dev visualTheme tron
# then relaunch. Run this three times against the same process:
#   1. palette hidden (baseline)
#   2. palette open on the launcher, Tron animating
#   3. palette hidden again (must return to the baseline CPU within 0.5)
# Budget: run 2 minus run 1 under 5.0 %CPU and under 8192 KB RSS; run 3 equals run 1.

set -euo pipefail

seconds=${1:-10}
pid=$(pgrep -x "Tinycast Dev" | head -n 1 || true)
if [ -z "$pid" ]; then
    echo "Tinycast Dev is not running" >&2
    exit 1
fi

cpu_sum=0
rss_last=0
for _ in $(seq 1 "$seconds"); do
    read -r cpu rss < <(ps -o %cpu=,rss= -p "$pid")
    cpu_sum=$(awk -v a="$cpu_sum" -v b="$cpu" 'BEGIN { print a + b }')
    rss_last=$rss
    sleep 1
done
awk -v sum="$cpu_sum" -v n="$seconds" -v rss="$rss_last" \
    'BEGIN { printf "mean CPU %.1f %%  RSS %d KB  (%d samples)\n", sum / n, rss, n }'
