##################################
# Magisk-Module Installer Script
##################################

##################################
# Configure flags
##################################

MODID=magicek
SKIPMOUNT=false
PROPFILE=false
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
}

##################################
# Extract binaries
##################################

on_install() {
  case $ARCH in
    arm64) CE_ARCH=$ARCH;;
    arm)   CE_ARCH=arm32;;
    x64)   CE_ARCH=x86_64;;
    x86)   CE_ARCH=$ARCH;;
    *)     ui_print "Unsupported architecture: $ARCH"; abort;;
  esac

  ui_print "- Detected architecture: $CE_ARCH"

  if [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
      ui_print "- Installing via Magisk $MAGISK_VER_CODE"
      UNZIP="/data/adb/magisk/busybox unzip"
  else
    ui_print "**********************************************"
    ui_print "! Chosen installation method is unsupported  *"
    ui_print "! Please install as zip from Magisk app      *"
    abort    "**********************************************"
  fi

  ui_print "- Extracting module files"
  CE_TARGETDIR="$MODPATH/system/bin"

  mkdir -p "$CE_TARGETDIR"
  chcon -R u:object_r:system_file:s0 "$CE_TARGETDIR"
  chmod -R 755 "$CE_TARGETDIR"

  $UNZIP -qq -o "$ZIPFILE" "files/ceserver_$CE_ARCH" -j -d "$CE_TARGETDIR"
  mv "$CE_TARGETDIR/ceserver_$CE_ARCH" "$CE_TARGETDIR/ceserver"
}

##################################
# Set permissions
##################################

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/system/bin/ceserver 0 2000 0755 u:object_r:system_file:s0
}
