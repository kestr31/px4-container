import cv2
import numpy as np
from random import *
<<<<<<< HEAD
from tensorflow.keras.models import load_model
=======
#import airsim
# from tensorflow.keras.models import load_model
>>>>>>> 300e78317b258584294007e6d5df853cf1e37cea
import onnx
import onnxruntime as rt

class JBNU_Collision():
    def __init__(self):
<<<<<<< HEAD
        model_pretrained = onnx.load("/root/ros_ws/src/integration/integration/CollisionAvoidance/JBNU/feedforward.onnx")
        self.sess = rt.InferenceSession(model_pretrained, providers=rt.get_available_providers())
        self.output_name = self.sess.get_outputs()[0].name
        self.input_name = self.sess.get_inputs()[0].name
=======
        # AIRSIM DEPENDENT CODES: WILL BE REMOVED
        #self.client = airsim.CarClient()
        #self.client.confirmConnection()
        
        #self.model_pretrained = load_model('/root/ros_ws/src/integration/integration/CollisionAvoidance/JBNU/Best_feed_forward.h5')
        model_pretrained = onnx.load('/root/ros_ws/src/integration/integration/CollisionAvoidance/JBNU/feedforward.onnx')
        onnx.checker.check_model(model_pretrained)
        sess = rt.InferenceSession(model_pretrained.SerializeToString(),providers=rt.get_available_providers())

>>>>>>> 300e78317b258584294007e6d5df853cf1e37cea

    def main(self, Image):
        img2d = Image
        depth_8bit_lerped = np.interp(img2d, (0.0, 10), (0, 255))
        image=cv2.applyColorMap(cv2.convertScaleAbs(depth_8bit_lerped,alpha=1),cv2.COLORMAP_JET)
        image=cv2.resize(image,(200,200),cv2.INTER_AREA)
        infer = self.sess.run([self.output_name], {self.input_name: image})
        vx = infer[0][0]
        vy = 0.0
        vz = infer[0][1]
        vyaw = infer[0][2]
        return vx,vy,vz,vyaw

if __name__ == '__main__':
    tensor = JBNU_Collision()
    vx,vy,vz,vyaw =tensor.main()
    print(vx,vy,vz,vyaw)
 
