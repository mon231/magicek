#!/system/bin/sh
MODDIR=${0%/*}
LOGFILE=/data/local/tmp/magicek.log
CESERVER_PATH="/system/bin/ceserver"
BACKUP_PATH="$MODDIR/backup"
MAX_RETRIES=5
RETRY_COUNT=0

# Log function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> $LOGFILE
}

# Clear previous log
rm -f $LOGFILE
log "Magicek service started (v1.1)"

# Detect architecture
ARCH=$(getprop ro.product.cpu.abi)
log "Device architecture: $ARCH"

# Map architecture to ceserver binary name
case $ARCH in
    arm64*) CE_ARCH="arm64" ;;
    armeabi*|arm*) CE_ARCH="arm32" ;;
    x86_64*) CE_ARCH="x86_64" ;;
    x86*) CE_ARCH="x86" ;;
    *) 
        log "ERROR: Unsupported architecture: $ARCH"
        log "Attempting to use arm64 as fallback"
        CE_ARCH="arm64"
        ;;
esac
log "Using ceserver for architecture: $CE_ARCH"

# Wait for boot to complete
log "Waiting for boot to complete..."
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
log "Boot completed"

# Verify ceserver binary exists
if [ ! -f "$CESERVER_PATH" ]; then
    log "ERROR: ceserver binary not found at $CESERVER_PATH"
    
    # Check if we have a backup
    if [ -f "$BACKUP_PATH/ceserver_$CE_ARCH" ]; then
        log "Found backup binary, attempting to restore"
        cp "$BACKUP_PATH/ceserver_$CE_ARCH" "$CESERVER_PATH"
        chmod 755 "$CESERVER_PATH"
        
        if [ ! -f "$CESERVER_PATH" ]; then
            log "ERROR: Failed to restore ceserver from backup"
            exit 1
        else
            log "Successfully restored ceserver from backup"
        fi
    else
        log "ERROR: No backup found, cannot continue"
        exit 1
    fi
fi

# Start ceserver function
start_ceserver() {
    log "Starting ceserver..."
    $CESERVER_PATH &
    PID=$!
    
    # Verify process started
    if ! kill -0 $PID 2>/dev/null; then
        log "ERROR: Failed to start ceserver"
        return 1
    fi
    
    log "ceserver started with PID: $PID"
    return 0
}

# Main monitoring loop
while true; do
    # Start ceserver if not running
    if ! pgrep -f ceserver >/dev/null; then
        log "ceserver not running, starting..."
        
        if ! start_ceserver; then
            RETRY_COUNT=$((RETRY_COUNT + 1))
            log "Failed to start ceserver (attempt $RETRY_COUNT of $MAX_RETRIES)"
            
            if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
                log "ERROR: Maximum retry attempts reached, giving up"
                log "Please check if the ceserver binary is compatible with your device"
                log "You may need to reinstall the module or update to a newer version"
                log "Check for updates at: https://github.com/mon231/magicek/releases"
                sleep 3600  # Sleep for an hour before trying again
                RETRY_COUNT=0
            else
                sleep 30  # Wait before retrying
            fi
        else
            RETRY_COUNT=0  # Reset retry counter on successful start
        fi
    else
        # ceserver is running, reset retry counter
        RETRY_COUNT=0
        
        # Log status every hour
        if [ $(($(date +%s) % 3600)) -lt 30 ]; then
            PID=$(pgrep -f ceserver)
            log "ceserver is running with PID: $PID"
        fi
    fi
    
    sleep 30
done
