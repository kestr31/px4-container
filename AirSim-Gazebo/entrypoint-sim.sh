#!/bin/bash

# ------------A4VAI DEFINED ENTRYPOINT-------------
echo "    ___   __ __      _    _____    ____"
echo "   /   | / // /     | |  / /   |  /  _/"
echo "  / /| |/ // /______| | / / /| |  / /  "
echo " / ___ /__  __/_____/ |/ / ___ |_/ /   "
echo "/_/  |_| /_/        |___/_/  |_/___/   "

source /opt/ros/galactic/setup.bash

# Rebuild ALL ROS2 nodes if activated
if [[ -n ${REBUILD_RPKG} ]]; then
	echo ">>>>>>>>>>>>>>>>integration ROS2 PKG REBUILD FLAG ENABLED<<<<<<<<<<<<<<<"
	echo ">>>>>>>>>START REBUILDING AND INSTALLATION OF PKG 'integration'<<<<<<<<<"
	echo "    ____  __________  __  ________    ____  "
	echo "   / __ \/ ____/ __ )/ / / /  _/ /   / __ \ "
	echo "  / /_/ / __/ / __  / / / // // /   / / / / "
	echo " / _, _/ /___/ /_/ / /_/ // // /___/ /_/ /  "
	echo "/_/ |_/_____/_____/\____/___/_____/_____/   "
	colcon build \
		--build-base /root/ros_ws/build \
        --install-base /root/ros_ws/install \
        --base-paths /root/ros_ws/src \
		--symlink-install
fi

if [[ -n ${DEBUG_ENTRYPOINT} ]]; then
	echo ">>>>>>>>>>ENTRYPOINT DEBUGGING ENABLED. DO NOT RUN ANY PROCESS<<<<<<<<<"
	echo "    ____  __________  __  ________"
	echo "   / __ \/ ____/ __ )/ / / / ____/"
	echo "  / / / / __/ / __  / / / / / __  "
	echo " / /_/ / /___/ /_/ / /_/ / /_/ /  "
	echo "/_____/_____/_____/\____/\____/   "
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>Noneun Ge Jeil JOAH<<<<<<<<<<<<<<<<<<<<<<<<<<"
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>Debugging JOAH<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
else
	echo ">>>>>>>>>>>>>>>>RUNNING ITE SITL WITH DEFINED CONDITION<<<<<<<<<<<<<<<<"
	echo "    ___    _       ______      __ "
	echo "   /   |  (_)     / ____/___  / / "
	echo "  / /| | / /_____/ / __/ __ \/ /  "
	echo " / ___ |/ /_____/ /_/ / /_/ /_/   "
	echo "/_/  |_/_/      \____/\____(_)    "

	# Start AirSim In Windowed Mode
	su -c "/home/user/ForestDeploy/ForestDeploy.sh -windowed" user &
	sleep 4s

	# Spawn Pine Tree in square area of (-240,-240) to (240,240)
	echo "Simulator startup! Generating Objects"
	python3 /root/AirSim/python/spawnObject.py -a Pine_01 -n 60 -r 240 240 -d 0
	sleep 10s
	
	python3 /root/AirSim/python/genMap.py

	# After Starting Up Airsim, Generate Flag File for Notification
	touch /root/shared/simOn

	# Wait Until AirSim starts up. Condition: /root/shared/simOn Exists?
	mapImg=$(find /home/user/ForestDeploy/ForestDeploy -maxdepth 1 -type f -name '*.png')
	while [ -z $mapImg ];
	do
		mapImg=$(find /home/user/ForestDeploy/ForestDeploy -maxdepth 1 -type f -name '*.png')
		echo "Finding generated map..."
		sleep 1s
	done

	echo "Found generated map! Copying to shared volume"
	sleep 1s

	echo "    __  ______    ____  _____________   __ "
	echo "   /  |/  /   |  / __ \/ ____/ ____/ | / / "
	echo "  / /|_/ / /| | / /_/ / / __/ __/ /  |/ /  "
	echo " / /  / / ___ |/ ____/ /_/ / /___/ /|  /   "
	echo "/_/  /_/_/  |_/_/    \____/_____/_/ |_/    "

	cp $mapImg /root/shared/Map.png

	# Run MAVLink Router for Communication with QGC
	echo ">>>>>>>>>>>>>INITIALIZING MAVLINK ROUTER FOR QGC CONNECTION<<<<<<<<<<<"
	nohup mavlink-routerd -e 172.21.0.7:14550 127.0.0.1:14550 &
	sleep 3s
fi

sleep infinity