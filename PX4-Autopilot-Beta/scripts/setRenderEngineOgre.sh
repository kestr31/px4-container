#! /bin/bash

SIMULATOR_SCRIPT_DIR=/home/user/PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/px4-rc.simulator

TARGET_STRING_Linux="gz_sub_command=\"sim\""
TARGET_STRING_WSLg="gz_sub_command=\"sim --render-engine ogre\""

timestamp()
{
 date +"%Y-%m-%d %T"
}

echo "$(timestamp): [CHANGE RENDERING ENGINE]"

if grep -q "${TARGET_STRING_Linux}" ${SIMULATOR_SCRIPT_DIR}; then
  echo "$(timestamp): GAZEBO RENDERING ENGINE: OGRE2"
  echo "$(timestamp): CHANGING RENDERING ENDINE TO OGRE...(FOR WSLg)"

  sed -i "s/${TARGET_STRING_Linux}/${TARGET_STRING_WSLg}/g" ${SIMULATOR_SCRIPT_DIR}

  echo "$(timestamp): CHANGED GAZEBO RENDERING ENGINE TO: OGRE"
  echo "$(timestamp): DONE!"
elif grep -q "${TARGET_STRING_WSLg}" ${SIMULATOR_SCRIPT_DIR}; then
  echo "$(timestamp): GAZEBO RENDERING ENGINE: OGRE"
  echo "$(timestamp): CHANGING RENDERING ENDINE TO OGRE2...(FOR Generic Linux Systems)"
  sed -i "s/${TARGET_STRING_WSLg}/${TARGET_STRING_Linux}/g" ${SIMULATOR_SCRIPT_DIR}

  echo "$(timestamp): CHANGED GAZEBO RENDERING ENGINE TO: OGRE2"
  echo "$(timestamp): DONE!"
else
  echo "$(timestamp): SOMEONE ALREADY HAVE MODIFIED:"
  echo "$(timestamp): ${SIMULATOR_SCRIPT_DIR}"

  echo "$(timestamp): PLEASE CHECK THE SCIPT TO MAKE THIS SCRIPT WORK"
  echo "$(timestamp): ERROR!"
fi