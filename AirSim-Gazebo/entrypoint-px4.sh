#!/bin/bash

# ------------A4VAI DEFINED ENTRYPOINT-------------
echo "    ___   __ __      _    _____    ____"
echo "   /   | / // /     | |  / /   |  /  _/"
echo "  / /| |/ // /______| | / / /| |  / /  "
echo " / ___ /__  __/_____/ |/ / ___ |_/ /   "
echo "/_/  |_| /_/        |___/_/  |_/___/   "

source /opt/ros/galactic/setup.bash

if [ -n $PX4_SIM_HOST_ADDR ]; then
	find /root/AirSim/python -type f -name "*.py" -print0 | xargs -0 sed -i "s/airsim.VehicleClient()/airsim.VehicleClient(ip=\"${PX4_SIM_HOST_ADDR}\", port=41451)/g"
	find /root/AirSim/python -type f -name "*.py" -print0 | xargs -0 sed -i "s/airsim.MultirotorClient()/airsim.MultirotorClient(ip=\"${PX4_SIM_HOST_ADDR}\", port=41451)/g"
fi

rm -rf /root/shared/Map.png &
rm -rf /root/shared/simOn &
sleep 1s

simFlag=$(find /root/shared -maxdepth 1 -type f -name 'simOn')

while [ -z $simFlag ];
do
    simFlag=$(find /root/shared -maxdepth 1 -type f -name 'simOn')
	echo "Waiting until simulator starts up..."
	sleep 1s
done

echo "Simulator startup! Generating Objects"
python3 /root/AirSim/python/spawnObject.py -a Pine_01 -r 240 240
sleep 3s

python3 /root/AirSim/python/moveUAV.py
sleep 5s

mapImg=$(find /root/shared -maxdepth 1 -type f -name '*.png')

while [ -z $mapImg ];
do
    mapImg=$(find /root/shared -maxdepth 1 -type f -name '*.png')
	echo "Finding generated map..."
	sleep 1s
done

echo "Found generated map! Copying to RRT directory"
sleep 1s

mkdir /root/ros_ws/src/integration/integration/PathPlanning/Map/
sleep 1s

cp $mapImg /root/ros_ws/src/integration/integration/PathPlanning/Map/Map.png
sleep 5s


# Rebuild ALL ROS2 nodes if activated
if [[ -n ${REBUILD_RPKG_INTEGRATION} ]]; then
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

# Set environment variables in this shell script
source /root/px4_ros/install/setup.bash
source /root/ros_ws/install/setup.bash
source /root/AirSim/ros2/install/setup.sh
source /usr/share/gazebo-11/setup.sh


# Run MAVLink Router for Communication with QGC
echo ">>>>>>>>>>>>>INITIALIZEING MAVLINK ROUTER FOR QGC CONNECTION<<<<<<<<<<<"
nohup mavlink-routerd -e 172.21.0.7:14550 127.0.0.1:14550 &
sleep 3s

# Run microRTPS bridge for Communication in ROS2 msg
echo ">>>>>>>>>>>INITIALIZEING microRTPS BRIDGE FOR ROS2 CONNECTION<<<<<<<<<<"
micrortps_agent -t UDP &
sleep 1s

# Run airsim_ros_pkgs to get sensor date from AirSim
echo "Starting AIRSIM ROS PKGS"
ros2 launch airsim_ros_pkgs airsim_node.launch.py host:=172.21.0.5 &
sleep 1s

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
	echo "   _________ _____   __________  ____  "
	echo "  / ____/   /__  /  / ____/ __ )/ __ \ "
	echo " / / __/ /| | / /  / __/ / __  / / / / "
	echo "/ /_/ / ___ |/ /__/ /___/ /_/ / /_/ /  "
	echo "\____/_/  |_/____/_____/_____/\____/   "
	HEADLESS=${HEADLESS} make -C /root/PX4-Autopilot px4_sitl_rtps gazebo_${PX4_SIM_MODEL}__${PX4_SIM_WOLRLD} &
	sleep 1s

	# Wait Until Gazebo starts up
	gazeoDir=$(find /root -type d -name ".gazebo" -print)

	while [ -z ${gazeoDir1} ];
	do
		gazeoDir1=$(find /root -type d -name ".gazebo" -print)
		echo "Waiting until gazebo starts up"
		sleep 1s
	done

	gazeoDir2=$(find /root/.gazebo -type d -name "client-11345" -print)

	while [[ -z ${gazeoDir2} ]];
	do
		gazeoDir2=$(find /root/.gazebo -type d -name "client-11345" -print)
		echo "Waiting until gazebo starts up"
		sleep 1s
	done

	gazeboStat1=$(find /root/.gazebo/client-11345 -type f -name "default.log" -print)

	while [[ -z ${gazeboStat1} ]];
	do
		gazeboStat1=$(find /root/.gazebo/client-11345 -type f -name "default.log" -print)
		echo "Waiting until gazebo starts up"
		sleep 1s
	done

	gazeboStat2=$(cat /root/.gazebo/client-11345/default.log | grep "Connected to gazebo master")

	while [[ -z ${gazeboStat2} ]];
	do
		gazeboStat2=$(cat /root/.gazebo/client-11345/default.log | grep "Connected to gazebo master")
		echo "Waiting until gazebo starts up"
		sleep 1s
	done

	# Run integration node for the one and the all
	echo "Run integration node"
	ros2 run integration IntegrationTest &

	echo "    _____ ____________       ______________    ____  ______ "
	echo "   / ___//  _/_  __/ /      / ___/_  __/   |  / __ \/_  __/ "
	echo "   \__ \ / /  / / / /       \__ \ / / / /| | / /_/ / / /    "
	echo "  ___/ // /  / / / /___    ___/ // / / ___ |/ _, _/ / /     "
	echo " /____/___/ /_/ /_____/   /____//_/ /_/  |_/_/ |_| /_/      "
fi

/root/AirSim/GazeboDrone/build/GazeboDrone &
sleep 3s

# # Keep container running. The Sleeping Beauty
sleep infinity
        # Test MPPI Callback