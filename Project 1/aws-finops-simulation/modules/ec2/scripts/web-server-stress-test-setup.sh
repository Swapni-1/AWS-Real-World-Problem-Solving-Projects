#!/bin/bash
# EC2 Userdata – CPU Stress Scheduler Setup for Fedora
# Installs stress-ng, deploys scheduler script & systemd service
# Runs with root privileges (userdata), sudo is added for clarity

set -euo pipefail
exec > >(sudo tee /var/log/userdata.log) 2>&1

log() { echo "[$(date '+%F %T %Z')] $*"; }

# ---------- 1. Install stress-ng ----------
log "Installing stress-ng..."
sudo dnf install -y stress-ng

# ---------- 2. Create the CPU stress scheduler script ----------
log "Creating /usr/local/bin/cpu-stress-scheduler.sh"
sudo tee /usr/local/bin/cpu-stress-scheduler.sh > /dev/null << 'SCRIPT_EOF'
#!/bin/bash
# CPU Stress Scheduler – Fedora EC2
# Keeps CPU at 30% during 9am-9pm Asia/Kolkata,
# and injects 1–5 random 5‑minute spikes to 75‑80%.

set -euo pipefail

# ---------- Configuration ----------
TIMEZONE="Asia/Kolkata"
WINDOW_START_HOUR=9
WINDOW_END_HOUR=21
BASELINE_LOAD=30
SPIKE_LOAD=77                # midpoint of 75-80
SPIKE_DURATION=300           # 5 seconds
SPIKE_MIN_COUNT=1
SPIKE_MAX_COUNT=5
CHECK_INTERVAL=30            # seconds

# ---------- Helper functions ----------
log() { echo "[$(date '+%F %T %Z')] $*" >&2; }

rand_int() {
    echo $(( SPIKE_MIN_COUNT + RANDOM % (SPIKE_MAX_COUNT - SPIKE_MIN_COUNT + 1) ))  
}

kill_stress() {
    # Kill all stress-ng processes that are children of our main PID
    for pid in $(pgrep -P $$ stress-ng 2>/dev/null); do
        kill "$pid" 2>/dev/null || true
    done
    sleep 0.2
}

# ---------- Main ----------
trap 'log "Shutting down, killing stress processes"; kill_stress; exit 0' EXIT INT TERM

# Ensure stress-ng is available (should already be installed, but just in case)
if ! command -v stress-ng &>/dev/null; then
    log "stress-ng not found, trying to install..."
    sudo dnf install -y stress-ng
fi

export TZ="$TIMEZONE"
CORES=$(nproc)
LAST_DAY=""
SPIKE_INTERVALS=""
MODE=""
PID_FILE="/tmp/cpu-stress-scheduler.pid"

log "Starting CPU stress scheduler on $CORES cores"

while true; do
    NOW=$(date +%s)
    CURRENT_HOUR=$(date +%H | sed 's/^0//')

    # Outside 9am-9pm
    if (( CURRENT_HOUR < WINDOW_START_HOUR || CURRENT_HOUR >= WINDOW_END_HOUR )); then
        if [[ "$MODE" != "idle" ]]; then
            log "Outside active window (9am-9pm), stopping all stress"
            kill_stress
            MODE="idle"
        fi
        sleep $CHECK_INTERVAL
        continue
    fi

    # Inside active window
    TODAY=$(date +%F)
    if [[ "$TODAY" != "$LAST_DAY" ]]; then
        log "New day $TODAY – generating spike schedule"
        WINDOW_START=$(date -d "today 00:00:00" +%s)
        WINDOW_START=$(( WINDOW_START + WINDOW_START_HOUR * 3600 ))
        WINDOW_END=$(( WINDOW_START + (WINDOW_END_HOUR - WINDOW_START_HOUR) * 3600 ))

        EFFECTIVE_START=$(( NOW > WINDOW_START ? NOW : WINDOW_START ))
        MAX_OFFSET=$(( (WINDOW_END - SPIKE_DURATION) - EFFECTIVE_START ))

        SPIKE_INTERVALS=""
        if (( MAX_OFFSET > 0 )); then
            NUM_SPIKES=$(rand_int $SPIKE_MIN_COUNT $SPIKE_MAX_COUNT)
            # Generate N unique random offsets
            OFFSETS=$(shuf -i "0-$MAX_OFFSET" -n "$NUM_SPIKES" 2>/dev/null || seq 0 "$MAX_OFFSET" | sort -R | head -n "$NUM_SPIKES" | sort -n)
            RAW_STARTS=""
            for off in $OFFSETS; do
                START_EPOCH=$(( EFFECTIVE_START + off ))
                RAW_STARTS="$RAW_STARTS $START_EPOCH"
            done
            # Merge overlapping intervals
            SORTED_STARTS=$(echo "$RAW_STARTS" | tr ' ' '\n' | sort -n)
            PREV_START=0; PREV_END=0
            for s in $SORTED_STARTS; do
                e=$(( s + SPIKE_DURATION ))
                if (( PREV_END == 0 )); then
                    PREV_START=$s; PREV_END=$e
                elif (( s <= PREV_END )); then
                    PREV_END=$(( e > PREV_END ? e : PREV_END ))
                else
                    SPIKE_INTERVALS="$SPIKE_INTERVALS $PREV_START,$PREV_END"
                    PREV_START=$s; PREV_END=$e
                fi
            done
            SPIKE_INTERVALS="$SPIKE_INTERVALS $PREV_START,$PREV_END"
            log "Spike intervals for today:${SPIKE_INTERVALS}"
        else
            log "Not enough time left for a full spike – no spikes today"
        fi
        LAST_DAY="$TODAY"
    fi

    # Check if we are inside a spike now
    IN_SPIKE=false
    for interval in $SPIKE_INTERVALS; do
        IFS=',' read -r S E <<< "$interval"
        if (( NOW >= S && NOW < E )); then
            IN_SPIKE=true
            break
        fi
    done

    if $IN_SPIKE; then
        if [[ "$MODE" != "spike" ]]; then
            log "Entering SPIKE mode (${SPIKE_LOAD}% for 5 min)"
            kill_stress
            stress-ng --cpu "$CORES" --cpu-load "$SPIKE_LOAD" --timeout 0 &
            MODE="spike"
        fi
    else
        if [[ "$MODE" != "baseline" ]]; then
            log "Entering BASELINE mode (${BASELINE_LOAD}%)"
            kill_stress
            stress-ng --cpu "$CORES" --cpu-load "$BASELINE_LOAD" --timeout 0 &
            MODE="baseline"
        fi
    fi

    sleep $CHECK_INTERVAL
done
SCRIPT_EOF

# Make the script executable
sudo chmod +x /usr/local/bin/cpu-stress-scheduler.sh

# ---------- 3. Create systemd service unit ----------
log "Creating systemd service unit"
sudo tee /etc/systemd/system/cpu-stress-scheduler.service > /dev/null << 'UNIT_EOF'
[Unit]
Description=CPU Stress Scheduler (30% baseline + random spikes)
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/cpu-stress-scheduler.sh
Restart=always
RestartSec=10
Environment=TZ=Asia/Kolkata

[Install]
WantedBy=multi-user.target
UNIT_EOF

# ---------- 4. Reload systemd, enable & start ----------
sudo systemctl daemon-reload
sudo systemctl enable cpu-stress-scheduler.service
sudo systemctl start cpu-stress-scheduler.service

log "CPU Stress Scheduler has been installed and started."