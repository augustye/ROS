#Based on ubiquity ROS image - https://downloads.ubiquityrobotics.com/pi.html

# rplidar + hector - https://blog.csdn.net/EAIBOT/article/details/51044718
# cartographer     - https://xrp001.github.io/tutorial/2018/05/18/Jetson-tx2-rplidar-a2-cartographer/
sudo apt-get install ros-kinetic-rplidar-ros ros-kinetic-hector-slam ros-kinetic-cartographer ros-kinetic-cartographer-ros ros-kinetic-cartographer-ros-msgs ros-kinetic-cartographer-rviz
sudo cp hector_mapping_demo.launch /opt/ros/kinetic/share/rplidar_ros/launch/hector_mapping_demo.launch
sudo cp revo_lds.lua /opt/ros/kinetic/share/cartographer_ros/configuration_files/revo_lds.lua
sudo cp demo_revo_lds.launch /opt/ros/kinetic/share/cartographer_ros/launch/demo_revo_lds.launch

sudo chmod 666 /dev/ttyUSB0
Xvfb ':1' -screen 0 '1280x1024x24' &
x11vnc -rfbport 5901 -display ':1' -auth /var/run/slim.auth  -o /dev/stdout -noipv6 -bg -forever -N > /tmp/vnc.log
export DISPLAY=:1

roslaunch rplidar_ros view_rplidar.launch
roslaunch rplidar_ros rplidar.launch &
rosnode list
rosnode info /rplidarNode
rostopic echo /scan
rosrun rplidar_ros rplidarNodeClient
roslaunch rplidar_ros hector_mapping_demo.launch
roslaunch cartographer_ros demo_revo_lds.launch

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
# TBD...