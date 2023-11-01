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

# Replace Client-Specific Strings in Airsim API Call Scripts
if [ -n ${AIRSIM_HOST} ]; then
	echo ">>>>>>>>>>>>>>>>Airsim Runs In Separate Container<<<<<<<<<<<<<<<"
	echo ">>>>>>>>>>>>>>>>Replacing Strings In API Scripts<<<<<<<<<<<<<<<<"
	echo "    ____  _______________   ________  ____________  "
	echo "   / __ \/ ____/_  __/   | / ____/ / / / ____/ __ \ "
	echo "  / / / / __/   / / / /| |/ /   / /_/ / __/ / / / / "
	echo " / /_/ / /___  / / / ___ / /___/ __  / /___/ /_/ /  "
	echo "/_____/_____/ /_/ /_/  |_\____/_/ /_/_____/_____/   "
	find /root/AirSim/python -type f -name "*.py" -print0 | xargs -0 sed -i "s/airsim.VehicleClient()/airsim.VehicleClient(ip=\"${AIRSIM_HOST}\", port=41451)/g"
	find /root/AirSim/python -type f -name "*.py" -print0 | xargs -0 sed -i "s/airsim.MultirotorClient()/airsim.MultirotorClient(ip=\"${AIRSIM_HOST}\", port=41451)/g"
fi

# Clear Shared Volume to Prevent Calling Ghost
rm -rf /root/shared/Map.png &
rm -rf /root/shared/simOn &
sleep 1s

# Wait Until AirSim starts up. Condition: /root/shared/simOn Exists?
simFlag=$(find /root/shared -maxdepth 1 -type f -name 'simOn')

while [ -z $simFlag ];
do
    simFlag=$(find /root/shared -maxdepth 1 -type f -name 'simOn')
	echo "Waiting until simulator starts up..."
	sleep 0.5s
done
sleep 1s

echo "   ______________    ____  ________  ______  "
echo "  / ___/_  __/   |  / __ \/_  __/ / / / __ \ "
echo "  \__ \ / / / /| | / /_/ / / / / / / / /_/ / "
echo " ___/ // / / ___ |/ _, _/ / / / /_/ / ____/  "
echo "/____//_/ /_/  |_/_/ |_| /_/  \____/_/       "

# Wait Until Map is Generated From AirSim Startup. Condition: /root/shared/Map.png Exists?
mapImg=$(find /root/shared -maxdepth 1 -type f -name '*.png')

while [ -z $mapImg ];
do
    mapImg=$(find /root/shared -maxdepth 1 -type f -name '*.png')
	echo "Finding generated map..."
	sleep 1s
done
sleep 1s

# Copy Gnerated Map to Process in Path-Planning Directory
echo "Found generated map! Copying to RRT directory"
# mkdir /root/ros_ws/src/a4vai/a4vai/path_planning/Map &&
rm -rf /root/ros_ws/src/a4vai/a4vai/path_planning/Map
mkdir /root/ros_ws/src/a4vai/a4vai/path_planning/Map
cp $mapImg /root/ros_ws/src/a4vai/a4vai/path_planning/Map/RawImage.png
sleep 5s

echo "    __  ______    ____  _____________   __ "
echo "   /  |/  /   |  / __ \/ ____/ ____/ | / / "
echo "  / /|_/ / /| | / /_/ / / __/ __/ /  |/ /  "
echo " / /  / / ___ |/ ____/ /_/ / /___/ /|  /   "
echo "/_/  /_/_/  |_/_/    \____/_____/_/ |_/    "

# Set environment variables in this shell script
source /root/px4_ros/install/setup.bash
source /root/ros_ws/install/setup.bash
source /root/AirSim/ros2/install/setup.sh
source /usr/share/gazebo-11/setup.sh

# Run microRTPS bridge for Communication in ROS2 msg
echo ">>>>>>>>>>>INITIALIZING microRTPS BRIDGE FOR ROS2 CONNECTION<<<<<<<<<<"
micrortps_agent -t UDP &
sleep 1s

# # Run MAVLink Router for Communication with QGC
# echo ">>>>>>>>>>>>>INITIALIZING MAVLINK ROUTER FOR QGC CONNECTION<<<<<<<<<<<"
nohup mavlink-routerd -e 172.21.0.7:14550 127.0.0.1:14550 &
# nohup mavlink-routerd -e 172.21.0.7:14550 172.21.0.6:14550 &
# sleep 3s

# Run airsim_ros_pkgs to get sensor date from AirSim
echo ">>>>>>>INITIALIZING airsim_ros_pkgs for ROS2 Sensor Publishing<<<<<<<<"
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
	echo "    ___    _       ______      __ "
	echo "   /   |  (_)     / ____/___  / / "
	echo "  / /| | / /_____/ / __/ __ \/ /  "
	echo " / ___ |/ /_____/ /_/ / /_/ /_/   "
	echo "/_/  |_/_/      \____/\____(_)    "
	HEADLESS=${HEADLESS} make -C /root/PX4-Autopilot px4_sitl_rtps gazebo_${PX4_SIM_MODEL}__${PX4_SIM_WORLD} &
	sleep 5s

	# GAZEBO STARTUP CHECKER: CONSISTED OF FOUR GATES
	# Wait Until Gazebo Starts Up: Gate 1: Check .gazebo exists (Dir)
	# gazeoDir=$(find /root -type d -name ".gazebo" -print)
	# while [ -z ${gazeoDir1} ];
	# do
	# 	gazeoDir1=$(find /root -type d -name ".gazebo" -print)
	# 	echo "Waiting until gazebo starts up"
	# 	sleep 1s
	# done

	# # Wait Until Gazebo Starts Up: Gate 2: Check client-11345 exists (Dir)
	# gazeoDir2=$(find /root/.gazebo -type d -name "client-11345" -print)
	# while [[ -z ${gazeoDir2} ]];
	# do
	# 	gazeoDir2=$(find /root/.gazebo -type d -name "client-11345" -print)
	# 	echo "Waiting until gazebo starts up"
	# 	sleep 1s
	# done

	# # Wait Until Gazebo Starts Up: Gate 3: Check default.log exists (Dir)
	# gazeboStat1=$(find /root/.gazebo/client-11345 -type f -name "default.log" -print)
	# while [[ -z ${gazeboStat1} ]];
	# do
	# 	gazeboStat1=$(find /root/.gazebo/client-11345 -type f -name "default.log" -print)
	# 	echo "Waiting until gazebo starts up"
	# 	sleep 1s
	# done

	# # Wait Until Gazebo Starts Up: Gate 4: Check certain log in default.log exists (String)
	# gazeboStat2=$(cat /root/.gazebo/client-11345/default.log | grep "Connected to gazebo master")
	# while [[ -z ${gazeboStat2} ]];
	# do
	# 	gazeboStat2=$(cat /root/.gazebo/client-11345/default.log | grep "Connected to gazebo master")
	# 	echo "Waiting until gazebo starts up"
	# 	sleep 1s
	# done

	# Run AirSim-Gazebo Integration Binary
	# This only works on default AirSim container IP (172.21.0.5)
	# If IP Changed, You Must Rebuid GazeboDrone Package Manually
	# Refer to 'stage_airsim' in corresponding Dockerfile
	bash -c '/root/AirSim/GazeboDrone/build/GazeboDrone >> /dev/null &'
	sleep 5s

	echo "    _____ ____________       ______________    ____  ______ "
	echo "   / ___//  _/_  __/ /      / ___/_  __/   |  / __ \/_  __/ "
	echo "   \__ \ / /  / / / /       \__ \ / / / /| | / /_/ / / /    "
	echo "  ___/ // /  / / / /___    ___/ // / / ___ |/ _, _/ / /     "
	echo " /____/___/ /_/ /_____/   /____//_/ /_/  |_/_/ |_| /_/      "
fi

echo "DEEP SAC MODULE RUN"
ros2 run a4vai deep_sac_module &
sleep 10s

echo "PATH FOLLOWING GPR RUN"
ros2 run a4vai path_following_gpr &
# sleep 5s

echo "PATH FOLLOWING GUID RUN"
ros2 run a4vai path_following_guid &
# sleep 5s

echo "PATH FOLLOWING ATT RUN"
ros2 run a4vai path_following_att &
# sleep 5s

echo "JBNU MODULE RUN"
ros2 run a4vai JBNU_module &
sleep 10s

echo "RUN FINAL CONTROLLER"
ros2 run a4vai controller &

# # Keep container running. The Sleeping Beauty
sleep infinity