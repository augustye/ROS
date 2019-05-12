
# mavproxy - http://ardupilot.org/dev/docs/raspberry-pi-via-mavlink.html
sudo apt install python-future python-lxml
sudo pip install pymavlink
sudo pip install mavproxy
sudo chmod 666 /dev/ttyUSB0
sudo mavproxy.py --master=/dev/ttyUSB0 --baudrate 9600 --aircraft MyCopter
# param show ARMING_CHECK
# param set ARMING_CHECK 0
# arm throttle

# mavros - http://ardupilot.org/dev/docs/ros-install.html#installing-mavros
#        - http://ardupilot.org/dev/docs/ros-connecting.html
sudo apt-get install ros-kinetic-mavros ros-kinetic-mavros-extras
wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
chmod a+x install_geographiclib_datasets.sh
./install_geographiclib_datasets.sh
sudo apt-get install ros-kinetic-rqt ros-kinetic-rqt-common-plugins ros-kinetic-rqt-robot-plugins

roscore &

sudo vi /opt/ros/kinetic/share/mavros/launch/apm_config.yaml #fix indent error on line 103 in: /opt/ros/kinetic/share/mavros/launch/apm_config.yaml
roslaunch mavros apm.launch fcu_url:=/dev/ttyUSB0:9600

rosrun mavros mavparam set ARMING_CHECK 0
rosrun mavros mavparam get ARMING_CHECK
rosrun mavros mavsafety disarm 
rosrun mavros mavsafety arm 

# ap navigation - http://ardupilot.org/dev/docs/ros-object-avoidance.html
sudo apt install ros-kinetic-navigation ros-kinetic-roslaunch ros-kinetic-catkin
sudo cp node.launch /opt/ros/kinetic/share/mavros/launch/node.launch

cd ~/catkin_ws/src
wget https://github.com/ArduPilot/companion/raw/master/Common/ROS/ap_navigation.zip
unzip ap_navigation.zip

cd ~/catkin_ws
sudo su
catkin_make install -DCMAKE_INSTALL_PREFIX=/opt/ros/kinetic
cp -rfv /home/ubuntu/catkin_ws/src/ap_navigation/* /opt/ros/kinetic/share/ap_navigation/
exit
source /opt/ros/kinetic/setup.bash

# Open all
# Arm the vehicle and switch to Guided mode
# Use rviz’s “2D Nav Goal” button to set a position target. If all goes well a green line will appearing showing the route the vehicle will take to the target
export DISPLAY=:1
sudo chmod 666 /dev/ttyUSB0
sudo chmod 666 /dev/ttyUSB1
roslaunch mavros apm.launch fcu_url:=/dev/ttyUSB0:9600
roslaunch rplidar_ros rplidar.launch &
roslaunch cartographer_ros demo_revo_lds.launch
roslaunch ap_navigation ap_nav.launch


# TBD: change to HDMI display