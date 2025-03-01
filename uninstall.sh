#!/system/bin/sh
# Magicek Uninstall Script

# Define log function
log() {
  echo "Magicek Uninstaller: $1"
}

log "Starting uninstallation process"

# Kill any running ceserver processes
log "Stopping ceserver service"
pkill -f ceserver || log "No ceserver process found or failed to kill"

# Remove log file
log "Removing log files"
rm -f /data/local/tmp/magicek.log || log "Failed to remove log file"

# Check if we're running in Magisk context
if [ -n "$MODPATH" ]; then
  # We're in Magisk uninstaller context
  log "Running in Magisk uninstaller context"
  ui_print "- Uninstalling Magicek"
  ui_print "- Removed ceserver and log files"
  ui_print "- Uninstallation completed"
else
  # We're running manually
  log "Running in manual uninstall context"
  echo "Magicek has been uninstalled."
  echo "Please reboot your device to complete the uninstallation."
fi

log "Uninstallation completed"
exit 0
