
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
sudo chmod 666 /dev/ttyUSB0
sudo chmod 666 /dev/ttyUSB1
roslaunch mavros apm.launch fcu_url:=/dev/ttyUSB1:9600
roslaunch rplidar_ros rplidar.launch &
roslaunch cartographer_ros demo_revo_lds.launch
roslaunch ap_navigation ap_nav.launch
