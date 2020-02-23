# xiaomi_temp_lywsd03mmc

Requirements:
- sudo apt-get install bc
- sudo apt-get install mosquitto-clients

Crontab
- */5 * * * * /home/pi/hass/xiaomi_temp_lywsd03mmc.sh >> /home/pi/hass/temperature.log 2>&1
