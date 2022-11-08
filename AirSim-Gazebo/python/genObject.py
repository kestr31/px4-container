import setup_path
import airsim
import argparse
import random
import time
import os
import numpy as np
import threading

def genObj(asset_name,objPos,objScale,objnum,isBP):
    objList = list()

    client = airsim.VehicleClient()

    desired_name = f"{asset_name}_airsim_{objnum}"
    scale = airsim.Vector3r(objScale[0],objScale[1],objScale[2])
    pose = airsim.Pose(position_val=airsim.Vector3r(objPos[0],objPos[1],objPos[2]))

    obj_name = client.simSpawnObject(desired_name, asset_name, pose, scale, isBP)

def main():
    parser = argparse.ArgumentParser(
        description='Generate an available asset in AirSim environment with given parameters')

    optional = parser._action_groups.pop()
    required = parser.add_argument_group('Required')
    required.add_argument("-a", "--asset", dest="asset_name",
                          help="Unreal asset to create (string)", metavar="ASSET")
    required.add_argument("-p", "--position", dest="objPos",nargs='+',type=float,
                          help="Target position to create objects ([x,y,z])", metavar="POSITION")

    optional.add_argument("-s", "--scale", dest="objScale",type=float,
                          help="Scale size of an object to generate",
                          metavar="SCALE", default=[1,1,1])                          
    optional.add_argument("-n", "--number", dest="objNum",type=int,
                          help="Number of object to be described on UE4 World",
                          metavar="NUM", default=0)
    optional.add_argument("-b", "--isbp", dest="isBP",type=bool,
                          help="Whether object is BluePrint class or not",
                          metavar="BP", default=False)

    args = parser.parse_args()

    print(f"Start creating {args.asset_name}")
    startTime = time.time()

    genObj(args.asset_name,args.objPos,args.objScale,args.objNum,args.isBP)

    ellapsed = round(time.time() - startTime)
    print(f"This took {ellapsed} seconds")

if __name__ == "__main__":
    main()
