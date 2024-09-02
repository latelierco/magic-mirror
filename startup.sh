#!/bin/bash

# starting python3 virtual environment
source ~/venv/bin/activate

# starting magic mirror
cd /home/pi/magic-mirror/
DISPLAY=:0 npm start
