#!/bin/bash
sensor=bedroom

#bt=$(timeout 15 gatttool -b A4:C1:38:63:71:EF --char-write-req --handle='0x0038' --value="0100" --listen)
echo "======================================"
NOW=$(date +"%m-%d-%Y %T")
echo $NOW
RET=1
count=0
bt=''
until ([ ${RET} -eq 124 ] && [ ! -z "$bt" ]) || [ "$count" -gt 5 ]; do
	#data=$(/usr/bin/timeout 30 /usr/bin/gatttool -b $bt --char-write-req --handle=0x10 -n 0100 --listen | grep "Notification handle" -m 2)
	echo "."
	count=$((count+1))
	bt=$(timeout 15 gatttool -b A4:C1:38:63:71:EF --char-write-req --handle='0x0038' --value="0100" --listen)
	RET=$?
	echo "$RET - Data:$bt."
	sleep 5
done


if [ -z "$bt" ]
then
	echo "The reading failed"
else
	#echo "Got data"
	#echo $bt
	temphexa=$(echo $bt | awk -F ' ' '{print $12$11}'| tr [:lower:] [:upper:] )
	#echo "Temperature $temphexa"
	humhexa=$(echo $bt | awk -F ' ' '{print $13}'| tr [:lower:] [:upper:])
	temperature100=$(echo "ibase=16; $temphexa" | bc)
	humidity=$(echo "ibase=16; $humhexa" | bc)
	#echo "Humidity $humhexa -> $humidity"
	#echo "Temperature $temperature100 -> "
	finalTemp=$(echo "scale=2;$temperature100/100"|bc)
	data=$(echo "{ \"humidity\": $humidity, \"temperature\": $finalTemp }")
	#$(echo mosquitto_pub -h 0.0.0.0 -p 1883 -t homeassistant/xiaomi/temp -m "{Temp=23, Hum=45, date=some}" -r)
	echo "Data to publish: $data"
	#/usr/bin/mosquitto_pub -h 0.0.0.0 -V mqttv311 -t "homeassistant/xiaomi/$sensor/temp" -m "$data"
	booleanNum=$(echo "$finalTemp < 100"|bc);
	echo $booleanNum;
	if [ ! -z "$finalTemp" ] && [ $booleanNum -eq 1 ]
	then
		/usr/bin/mosquitto_pub -h 0.0.0.0 -V mqttv311 -t "bedroom/temp" -m "$data"
		/usr/bin/mosquitto_pub -h 0.0.0.0 -V mqttv311 -t "bedroom/hum" -m "$data"
		echo "Data published to mqtt"
	else
		echo "Temperature empty"
	fi
	echo "EOS"

fi
exit
