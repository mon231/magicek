##################################
# Magisk-Module Installer Script
##################################

##################################
# Configure flags
##################################

MODID=magicek
SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=false
LATESTARTSERVICE=true

##################################
# Configure replace-list
##################################

REPLACE="
"

##################################
# Author Message
##################################

print_modname() {
  ui_print " "
  ui_print "    ********************************************"
  ui_print "    *             Magicek by mon231            *"
  ui_print "    ********************************************"
  ui_print " "
  ui_print "    CheatEngine ceserver for Android"
  ui_print "    Will automatically start on boot"
  ui_print " "
}

##################################
# Extract binaries
##################################

on_install() {
  # Detect architecture
  ui_print "- Detecting device architecture"
  case $ARCH in
    arm64) CE_ARCH=arm64;;
    arm)   CE_ARCH=arm32;;
    x86_64) CE_ARCH=x86_64;;
    x86)   CE_ARCH=x86;;
    *)     ui_print "! Unsupported architecture: $ARCH"; abort;;
  esac

  ui_print "- Detected architecture: $CE_ARCH"

  # Verify installation method
  if [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
      ui_print "- Installing via Magisk $MAGISK_VER_CODE"
      UNZIP="/data/adb/magisk/busybox unzip"
  else
    ui_print "**********************************************"
    ui_print "! Chosen installation method is unsupported  *"
    ui_print "! Please install as zip from Magisk app      *"
    abort    "**********************************************"
  fi

  # Create target directory
  ui_print "- Preparing installation directories"
  CE_TARGETDIR="$MODPATH/system/bin"
  mkdir -p "$CE_TARGETDIR"
  
  # Check if the binary exists in the zip
  ui_print "- Checking for ceserver binary for $CE_ARCH"
  $UNZIP -qq -l "$ZIPFILE" "files/ceserver_$CE_ARCH" || {
    ui_print "! Error: ceserver binary for $CE_ARCH not found in the package"
    ui_print "! Please download the correct version from GitHub"
    abort "! Installation failed"
  }
  
  # Extract ceserver binary for the detected architecture
  ui_print "- Extracting ceserver binary for $CE_ARCH"
  $UNZIP -qq -o "$ZIPFILE" "files/ceserver_$CE_ARCH" -j -d "$CE_TARGETDIR" || {
    ui_print "! Error: Failed to extract ceserver binary"
    abort "! Installation failed"
  }
  
  # Verify extraction was successful
  if [ ! -f "$CE_TARGETDIR/ceserver_$CE_ARCH" ]; then
    ui_print "! Error: ceserver binary not found after extraction"
    abort "! Installation failed"
  fi
  
  # Rename the binary
  ui_print "- Installing ceserver binary"
  mv "$CE_TARGETDIR/ceserver_$CE_ARCH" "$CE_TARGETDIR/ceserver" || {
    ui_print "! Error: Failed to rename ceserver binary"
    abort "! Installation failed"
  }
  
  # Backup the binary for potential reinstallation
  mkdir -p "$MODPATH/backup"
  cp "$CE_TARGETDIR/ceserver" "$MODPATH/backup/ceserver_$CE_ARCH" || {
    ui_print "! Warning: Failed to create backup of ceserver binary"
    # Continue installation despite backup failure
  }
  
  # Set proper permissions
  ui_print "- Setting proper permissions"
  chmod 755 "$CE_TARGETDIR/ceserver" || {
    ui_print "! Error: Failed to set permissions"
    abort "! Installation failed"
  }
  
  chcon -R u:object_r:system_file:s0 "$CE_TARGETDIR" || {
    ui_print "! Warning: Failed to set SELinux context"
    # Continue installation despite SELinux context failure
  }
  
  ui_print "- Installation completed successfully"
  ui_print "- Check for updates at: https://github.com/mon231/magicek/releases"
}

##################################
# Set permissions
##################################

set_permissions() {
  # Set permissions for all files and directories
  set_perm_recursive $MODPATH 0 0 0755 0644
  
  # Set specific permissions for executable files
  set_perm $MODPATH/system/bin/ceserver 0 2000 0755 u:object_r:system_file:s0
  set_perm $MODPATH/common/service.sh 0 0 0755 u:object_r:system_file:s0
  set_perm $MODPATH/uninstall.sh 0 0 0755 u:object_r:system_file:s0
  
  ui_print "- Permissions set successfully"
}
