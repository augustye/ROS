#Based on Ubuntu 16.04 in Vmware (disable 3D acceleration)

#fix copy & paste
sudo apt autoremove open-vm-tools
sudo apt install open-vm-tools
sudo apt install open-vm-tools-desktop

#ssh
sudo apt install ssh
service sshd start

# Anaconda
wget https://repo.anaconda.com/archive/Anaconda2-2019.03-Linux-x86_64.sh
bash Anaconda2-2019.03-Linux-x86_64.sh
source ~/.bashrc
python -V
mkdir ~/.pip/
cat > ~/.pip/pip.conf<<-EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple/
EOF

# Tensorflow + keras
sudo apt install python-pip git
pip install -U rosinstall msgpack empy defusedxml netifaces tensorflow keras

# ROS - http://emanual.robotis.com/docs/en/platform/turtlebot3/pc_setup/#install-dependent-ros-packages
sudo apt-get update
sudo apt-get upgrade
wget https://raw.githubusercontent.com/ROBOTIS-GIT/robotis_tools/master/install_ros_kinetic.sh && chmod 755 ./install_ros_kinetic.sh && bash ./install_ros_kinetic.sh
sudo apt install ros-kinetic-desktop-full ros-kinetic-joy ros-kinetic-teleop-twist-joy ros-kinetic-teleop-twist-keyboard ros-kinetic-laser-proc ros-kinetic-rgbd-launch ros-kinetic-depthimage-to-laserscan ros-kinetic-rosserial-arduino ros-kinetic-rosserial-python ros-kinetic-rosserial-server ros-kinetic-rosserial-client ros-kinetic-rosserial-msgs ros-kinetic-amcl ros-kinetic-map-server ros-kinetic-move-base ros-kinetic-urdf ros-kinetic-xacro ros-kinetic-compressed-image-transport ros-kinetic-rqt-image-view ros-kinetic-gmapping ros-kinetic-navigation ros-kinetic-interactive-markers
echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Turtlebot3 + Gazebo - http://emanual.robotis.com/docs/en/platform/turtlebot3/machine_learning/#machine-learning
mkdir -p ~/catkin_ws/src/
cd ~/catkin_ws/src/
git clone https://github.com/ROBOTIS-GIT/turtlebot3.git
git clone https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
git clone https://github.com/ROBOTIS-GIT/turtlebot3_machine_learning.git
cd ~/catkin_ws && catkin_make
echo "source /home/augustye/catkin_ws/devel/setup.bash" >> ~/.bashrc
echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
echo "export DISPLAY=:0" >> ~/.bashrc
source ~/.bashrc

gedit src/turtlebot3/turtlebot3_description/urdf/turtlebot3_burger.gazebo.xacro

roslaunch turtlebot3_gazebo turtlebot3_stage_3.launch
roslaunch turtlebot3_dqn turtlebot3_dqn_stage_3.launch
roslaunch turtlebot3_dqn result_graph.launch

# rviz - http://stevenshi.me/2017/07/11/ros-intermediate-tutorial-2/
#http://wiki.ros.org/slam_gmapping/Tutorials/MappingFromLoggedData?action=AttachFile&do=get&target=basic_localization_stage.bag
roscore &
rosparam set use_sim_time true
rosrun gmapping slam_gmapping scan:=base_scan &
rosbag play --clock ~/basic_localization_stage.bag
rosrun rviz rviz
