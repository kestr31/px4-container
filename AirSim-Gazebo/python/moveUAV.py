import setup_path 
import airsim
import time

client = airsim.MultirotorClient()
client.confirmConnection()

pose = client.simGetVehiclePose()

pose.position.x_val = 10.0
pose.position.y_val = 10.0

client.simSetVehiclePose(pose, True, "Typhoon_1")
