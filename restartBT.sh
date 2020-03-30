echo "Killing xiaomi process"
pkill xiaomi
echo "Killong restartBT process"
pkill restartBT
echo "restartin the BT"
hciconfig hci0 down
hciconfig hci0 upi
echo "end restart BT"
