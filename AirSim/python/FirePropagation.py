import setup_path
import airsim
import argparse
import random
import time
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--speed", type = float, help = "Propagation Speed Control. If s<1, it slows down. If s>1, it speeds up")
    args = parser.parse_args()
    if type(args.speed) == float:
        s = args.speed
    else:
        s = 1
    
    client = airsim.VehicleClient()
    posX = 0
    posY = 0
    posZ = 0.3
    pose = airsim.Pose(position_val=airsim.Vector3r(posX,posY,posZ))
    scale = airsim.Vector3r(random.uniform(1.0, 50.0), random.uniform(1.0, 50.0), random.uniform(1.0, 50.0))
    client.simSpawnObject('Test', 'Fire_mesh_BP', pose, scale, False, True)
    time.sleep(3/s)

    i = 0
    while True:
        DesiredName1 = f"Fire_{4*i-3}"
        DesiredName2 = f"Fire_{4*i-2}"
        DesiredName3 = f"Fire_{4*i-1}"
        DesiredName4 = f"Fire_{4*i}"

        posX = random.uniform(i-0.3, i+0.3)
        posY = random.uniform(i-0.3, i+0.3)
        posZ = 0
        pose1 = airsim.Pose(position_val=airsim.Vector3r(-posX + 1, posY, posZ))
        pose2 = airsim.Pose(position_val=airsim.Vector3r(posX + 1 , -posY, posZ))
        pose3 = airsim.Pose(position_val=airsim.Vector3r(-posX, posY, posZ))
        pose4 = airsim.Pose(position_val=airsim.Vector3r(posX, -posY, posZ))

        scale = airsim.Vector3r(random.uniform(1.0, 50.0), random.uniform(1.0, 50.0), random.uniform(1.0, 50.0))

        client.simSpawnObject(DesiredName1, 'Fire_mesh_BP', pose1, scale, False, True)
        time.sleep(0.5/s)
        client.simSpawnObject(DesiredName2, 'Fire_mesh_BP', pose2, scale, False, True)
        time.sleep(0.5/s)
        client.simSpawnObject(DesiredName3, 'Fire_mesh_BP', pose3, scale, False, True)
        time.sleep(0.5/s)
        client.simSpawnObject(DesiredName4, 'Fire_mesh_BP', pose4, scale, False, True)
        time.sleep(1/s)
        i = i + 1

if __name__ == "__main__":
    main()