from random import *
#import airsim
# from tensorflow.keras.models import load_model
import onnx
import onnxruntime as ort
import cv2
import numpy as np
# import torch


class JBNU_Collision():
    def __init__(self):
        print("initialJBNU")
        
    def CA(self, img2d):
        Image = img2d
        Image = cv2.resize(Image, (300,300), cv2.INTER_AREA)

        # cv2.imshow('Test', Image)
        # cv2.waitKey(1)

        Image = np.expand_dims(Image, axis=0)

        onnx_model = onnx.load("/root/ros_ws/src/a4vai/a4vai/collision_avoidance/Inha_1_nov.onnx")
        onnx.checker.check_model(onnx_model)
        ort_session = ort.InferenceSession("/root/ros_ws/src/a4vai/a4vai/collision_avoidance/Inha_1_nov.onnx")
        input_name = ort_session.get_inputs()[0].name
        Act = ort_session.run(None, {input_name:Image.astype(np.float32)})
        vx = Act[0][0][0]
        vy = Act[0][0][1]
        # vz = 0.0
        vz = Act[0][0][2]
        vyaw = Act[0][0][3] * 5
        print(vx,'\t',vy,'\t', - vz,'\t', -vyaw)
        
        
        return float(vx), float(vy), float(vz), - float(vyaw)

