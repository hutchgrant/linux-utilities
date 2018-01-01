#!/bin/bash

# Run Xbox 360 Controller Driver

# sudo apt-get install xboxdrv

# sudo xboxdrv -s  

# IF you see the following error:
# -- [ ERROR ] ------------------------------------------------------
# No Xbox or Xbox360 controller found

# Run: 
# lsusb

# Look for a device which isn't present when you unplug your controller and run lsusb again

# e.g. Bus 003 Device 007: ID 0e6f:011f Logic3 
# The 0e6f:011f is the Device(controller) ID
# The "Logic3" in this example is the Device(controller) Name

CONTROLLER_ID="0e6f:011f"
CONTROLLER_NAME="Logic3"

sudo xboxdrv -s --device-name "Logic3" --device-by-id 0e6f:011f --type xbox360  --mimic-xpad
