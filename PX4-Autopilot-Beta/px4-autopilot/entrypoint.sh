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



# DIRECTORY TO PX4-AutoPilot SOURCE
PX4_SRC_DIR=/home/user/PX4-Autopilot


# A. INITIALIZATION SCRIPT MODIFIER
## CASE A-1. gazebo SIMULATION
if [ "${SITL_TYPE}" = "gazebo" ]; then

    ## A-1. CHECK IF PREVIOUS BUILD EXISTS OR NOT
    ### CASE A-1-1. PREVIOUS BUILD EXISTS
    if [ -d "${PX4_SRC_DIR}/build" ]; then

        echo "INFO [SITL] PREVIOUS BUILD EXISTS!"
        SITL_rcS_DIR=${PX4_SRC_DIR}/build/px4_sitl_default/etc/init.d-posix

    ### CASE A-1-2. NOTHING WAS BUILD BEFORE
    else

        echo "INFO [SITL] NO BUILD EXISTS!"
        SITL_rcS_DIR=${PX4_SRC_DIR}/ROMFS/px4fmu_common/init.d-posix

    fi

    # COMMENT-OUT PROBLEMATIC/REDUNDANT LINES FROM gazebo rcS SCRIPT
    COMMENT_START=$(grep -wn "if \[ -f ./gz_env.sh \]; then" ${SITL_rcS_DIR}/px4-rc.simulator | cut -d: -f1)
    COMMENT_END=$(grep -wn "gazebo already running world: \${gz_world}" ${SITL_rcS_DIR}/px4-rc.simulator | cut -d: -f1)

    COMMENT_START=$(($COMMENT_START - 1))
    COMMENT_END=$(($COMMENT_END + 2))

    sed -i "${COMMENT_START},${COMMENT_END}s/\(.*\)/#\1/g" \
        ${SITL_rcS_DIR}/px4-rc.simulator

## CASE A-2. gazebo-classic SIMULATION [ERROR]
elif [ "${SITL_TYPE}" = "gazebo-classic" ]; then

    echo "ERROR [SITL] gazebo-classic IS NOT SUPPORTED YET"
    exit 1

## CASE A-3. NO SIMULATION DESIGNATED [ERROR]
else
    echo "ERROR [SITL] NO \${SITL_TYPE} DESIGNATED"
    exit 1
fi


# RUN MAVLINK ROUTER REGARLESS OF THE DEBUG_MODE FLAG
nohup mavlink-routerd -e ${QGC_IP}:14550 127.0.0.1:14550 &


# B. DEBUG MODE / SIMULATION SELCTOR
## CASE B-1: DEBUG MODE
if [ "${DEBUG_MODE}" -eq "1" ]; then

    debug_message

## CASE B-2: SIMULATION MODE
else
    
    ## B-2. SIMULATION TYPE SELECTOR
    ### CASE B-2-1: gazebo SIMULATION
    if [ "${SITL_TYPE}" = "gazebo" ]; then

        echo "INFO [SITL] RUNNING ${SITL_TYPE} SITL"

        PX4_SYS_AUTOSTART=${SITL_AIRFRAME_ID} \
        PX4_GZ_MODEL=${SITL_AIRFRAME} \
        PX4_GZ_MODEL_POSE=${SITL_POSE} \
        ${PX4_SRC_DIR}/build/px4_sitl_default/bin/px4

    ### CASE B-2-2: gazebo-classic SIMULATION [ERROR]
    elif [ "${SITL_TYPE}" = "gazebo-classic" ]; then

        echo "ERROR [SITL] gazebo-classic IS NOT SUPPORTED YET"
        exit 1

    ### CASE B-2-3: NO SIMULATION DESIGNATED [ERROR]
    else

        echo "ERROR [SITL] NO \${SITL_TYPE} DESIGNATED"
        exit 1
        
    fi
fi

# KEEP CONTAINER ALIVE
sleep infinity