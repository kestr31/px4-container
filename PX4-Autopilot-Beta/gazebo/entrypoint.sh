#! /bin/bash

debug_message() {
    echo "
        ____  __________  __  ________   __  _______  ____  ______
       / __ \/ ____/ __ )/ / / / ____/  /  |/  / __ \/ __ \/ ____/
      / / / / __/ / __  / / / / / __   / /|_/ / / / / / / / __/   
     / /_/ / /___/ /_/ / /_/ / /_/ /  / /  / / /_/ / /_/ / /___   
    /_____/_____/_____/\____/\____/  /_/  /_/\____/_____/_____/   
    
    "
    echo "INFO [SITL] DEBUG_MODE IS SET. NOTHING WILL RUN"
}


# DIRECTORY TO PX4 gazebo SITL WORLD/MODEL OBJECTS
PX4_GZ_WORLDS=/home/user/PX4-Autopilot/Tools/simulation/gz/worlds
PX4_GZ_MODELS=/home/user/PX4-Autopilot/Tools/simulation/gz/models

# SET GAZEBO RESOURCE PATH
export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}:${PX4_GZ_MODELS}:${PX4_GZ_WORLDS}:${GZ_SIM_USER_RESOURCE_PATH}


# A. DEBUG MODE / SIMULATION SELCTOR
## CASE A-1: DEBUG MODE
if [ "${DEBUG_MODE}" -eq "1" ]; then

    debug_message

## CASE A-2: SIMULATION MODE
else

    echo "INFO [SIM] RUNNING gazebo SIMULATOR"

    ## A-2. CHECK IF USER IS USING WSLg OR NOT
    ### CASE A-2-1: USER IS USING WSLg
    if [ -d "/mnt/wslg" ]; then

        echo "INFO [SIM] DETECTED WSLg! USE ogre1 FOR RENDERING GAZEBO"
        gz sim -r --render-engine ogre ${PX4_GZ_WORLDS}/default.sdf
    
    ### CASE A-2-2: NO WSLg DETECTED
    else

        echo "INFO [SIM] USE ogre2 FOR RENDERING GAZEBO"
        gz sim -r ${PX4_GZ_WORLDS}/default.sdf

    fi

fi

# KEEP CONTAINER ALIVE
sleep infinity