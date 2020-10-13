### ADASTEC fork for LGSVL.
Find the environment and vehicle files in [here](https://netorgft4229778.sharepoint.com/:f:/s/AdastecDevelopment/Er26cP7sxO1Iq1Cc5Wd-hEoBH9h9sFTvGZeZiNK4yLbNWQ?e=twSosn)
Find how to procedures [here](https://netorgft4229778.sharepoint.com/:f:/s/AdastecDevelopment/EldGYSc7E2FJvJ70_7bsUkYBBMIiV-VWe2Ee98B764mo_A?e=z6IBnx)
# V0	
- Clean start version of the project.
# V1	
- Karsan Map and Atak Bus has been imported.
- Added Traffic Lights, its code and Bus Stop.
- Some Code Changes and Bug Fixes.
- 5 LIDARS and other sensors are online.
- Can run in editor.
# V2	
- Vector map has been fully added.
- Actors, NavMesh has been added.
- Can run detection and motion planning with Autoware.
- Editor Hierarchy is presented clearly.-	
# V3
- Switched to LGSVL 2020.06 and Unity 2019.3.15f
- Dynamic and Static object spawn added.
- Ready to test swerve and stop.

## Added v3: v3.1, v3.2, v3.3 and API, v3.4 and API in 2020.06 version.

# V3.1	
* Added AdastecUI controls.
# V3.2
* Added jaywalk selection: not working with build.
# V3.3	
* Now have API build.
* Added stuff to map.
* Work on sensor: not working
# V3.4
* Changed move mechanics: now brakes with velocity, not accel input.
* Sensor is working now.
* API can communicate with simulator now.
* UI changes.
* Added MPC mechanics.
* Added new topic instead of VehicleCmd.
* Changes on couple scripts.
* Work on new dynamic steer rate: message is not built on autoware.
##### Autoware: 
* Adjusted base_link and vehicle measures as their real values. Simulator is running with MPC.
* When the steering rate is lowered to its real value, MPC does not work.
* When delay is added, MPC does not work.

