#! /bin/bash

nohup mavlink-routerd -e ${QGC_IP}:14550 127.0.0.1:14550 &

sleep infinity