MODDIR=${0%/*}

while [ "$(getprop sys.boot_completed)" != 1 ]; do
    sleep 1
done

while true; do
    sleep 5
    ceserver
done
