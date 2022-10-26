#!/bin/bash

# ------------A4VAI DEFINED ENTRYPOINT-------------
echo "    ___   __ __      _    _____    ____"
echo "   /   | / // /     | |  / /   |  /  _/"
echo "  / /| |/ // /______| | / / /| |  / /  "
echo " / ___ /__  __/_____/ |/ / ___ |_/ /   "
echo "/_/  |_| /_/        |___/_/  |_/___/   "

if [ -n $PX4_SIM_HOST_ADDR ]; then
	find /root/AirSim/python -type f -name "*.py" -print0 | xargs -0 sed -i "s/airsim.VehicleClient()/airsim.VehicleClient(ip=\"${PX4_SIM_HOST_ADDR}\", port=41451)/g"
	find /root/AirSim/python -type f -name "*.py" -print0 | xargs -0 sed -i "s/airsim.MultirotorClient()/airsim.MultirotorClient(ip=\"${PX4_SIM_HOST_ADDR}\", port=41451)/g"
fi

rm -rf /home/user/Documents/AirSim/settings.json
sleep 1s

su -c "/home/user/ForestDeploy/ForestDeploy.sh -windowed" user &
sleep 3s

touch /root/shared/simOn
mapImg=$(find /home/user/ForestDeploy/ForestDeploy -maxdepth 1 -type f -name '*.png')

while [ -z $mapImg ];
do
    mapImg=$(find /home/user/ForestDeploy/ForestDeploy -maxdepth 1 -type f -name '*.png')
	echo "Finding generated map..."
	sleep 1s
done

echo "Found generated map! Copying to shared volume"
sleep 1s

cp $mapImg /root/shared/Map.png

sleep infinity

sleep infinity