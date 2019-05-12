树莓派ROS安装教程
================

1. 硬件配置:
    - 树莓派3B及有线网络 (无需屏幕)
    - PIX + RPLIDAR激光雷达 (均通过串口, 或USB转串口连接到树莓派)
    - 笔记本电脑 + Ubuntu系统 (用于X-forwarding, 接收树莓派发送的图形界面)

2. ROS Image下载:
    - 访问 https://downloads.ubiquityrobotics.com/pi.html 
    - 下载最新的Image: 2019-02-19-ubiquity-xenial-lxde
    - 烧录image到SD后，从SD卡启动树莓派

3. 进入笔记本电脑的Ubuntu系统，使用SSH + X-Forwarding连接树莓派:
    ```Bash
    ssh -X ubuntu@ubiquityrobot.local 
    ```
    - 登录地址: ubiquityrobot.local或者树莓派的局域网ip地址
    - 登录密码: ubuntu
    - 登录之后在树莓派上继续以下流程

4. 从github下载配置文件备用：
    ```Bash
    cd ~
    git clone https://github.com/augustye/ROS
    ```

5. 更改apt源为清华源：
    - 修改 /etc/apt/sources.list 为以下内容:
        ```
        deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial main multiverse restricted universe
        deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-security main multiverse restricted universe
        deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-updates main multiverse restricted universe
        deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-backports main multiverse restricted universe
        ```
    - 更新apt信息
        ```Bash
        sudo apt update
        ``` 
6. 检查pix和rplidar的连接
    - 确认相应的tty端口存在
        ```Bash
        ls /dev/tty*
        ``` 
    - 在本例中rplidar和pix均通过USB转UART连接到树莓派，rplidar是ttyUSB0, pix是ttyUSB1

7. 安装测试rplidar激光雷达驱动
    - 安装驱动: 
        ```Bash
        sudo apt install ros-kinetic-rplidar-ros 
        ```
    - 根据硬件连接修改这个配置文件中的串口名称: 
        ```Bash
        sudo vi /opt/ros/kinetic/share/rplidar_ros/launch/rplidar.launch
        ```
       本例中使用默认值 /dev/ttyUSB0
    - 修改串口权限:
        ```Bash
        sudo chmod 666 /dev/ttyUSB0
        ```
    - 启动雷达: 
        ```Bash
        roslaunch rplidar_ros rplidar.launch &
        ```
    - 如果出现如下输出则说明激光雷达正常工作, 如果出现错误提示可多试几次
        ```
        [ INFO] [1557589070.664179742]: Firmware Ver: 1.26
        [ INFO] [1557589070.664370783]: Hardware Rev: 5
        [ INFO] [1557589070.667883428]: RPLidar health status : 0
        [ INFO] [1557589071.230467999]: current scan mode: Standard, max_distance: 12.0 m, Point number: 2.0K , angle_compensate: 1
        ```
    - 查看激光雷达数据流:
        ```Bash
        rosrun rplidar_ros rplidarNodeClient
        ```
    - 查看激光雷达图: 
        ```Bash
        roslaunch rplidar_ros view_rplidar.launch
        ```
        图像会通过X-Forwarding显示在笔记本电脑上

8. 安装测试cartographer
    - 安装
        ```Bash
        sudo apt install ros-kinetic-cartographer ros-kinetic-cartographer-ros ros-kinetic-cartographer-ros-msgs ros-kinetic-cartographer-rviz
        ```
    - 拷贝修改过的配置文件
        ```Bash
        sudo cp /home/ubuntu/ROS/revo_lds.lua /opt/ros/kinetic/share/cartographer_ros/configuration_files/revo_lds.lua
        sudo cp /home/ubuntu/ROS/demo_revo_lds.launch /opt/ros/kinetic/share/cartographer_ros/launch/demo_revo_lds.launch
        ```
    - 确定已启动激光雷达: 
        ```Bash
        roslaunch rplidar_ros rplidar.launch &
        ```
    - 运行cartographer绘制地图: 
        ```Bash
        roslaunch cartographer_ros demo_revo_lds.launch
        ```
9. ROS与pix通信
    - 安装mavros
        ```Bash
        sudo apt install ros-kinetic-mavros ros-kinetic-mavros-extras ros-kinetic-rqt ros-kinetic-rqt-common-plugins ros-kinetic-rqt-robot-plugins python-future python-lxml
        wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
        chmod a+x install_geographiclib_datasets.sh
        sudo ./install_geographiclib_datasets.sh
        ```
    - 修复配置文件
        ```Bash
        sudo vi /opt/ros/kinetic/share/mavros/launch/apm_config.yaml 
        ```
        - 该文件第103行有一个格式缩进的错误，手动删除setpoint_raw前面的空格即可
    - 修改串口权限:
        ```Bash
        sudo chmod 666 /dev/ttyUSB1
        ```
        - 此处ttyUSB1是pix所连接的串口
    - 运行mavros
        ```Bash
        roslaunch mavros apm.launch fcu_url:=/dev/ttyUSB1:9600
        ```
        - 此处ttyUSB1是pix所连接的串口, 9600是mavlink的波特率。
        - pix本身也需要通过地面站做相应设置: 将对应接口的mavlink波特率设为9600，且将mavlink版本设置为v1。
  
     - 通过mavros与pix通信(读写参数):
        - 打开一个新的ssh窗口, 运行:
            ```Bash
            rosrun mavros mavparam set ARMING_CHECK 0
            rosrun mavros mavparam get ARMING_CHECK
            rosrun mavros mavsafety disarm 
            rosrun mavros mavsafety arm        
            ```
        - 通信有可能有不稳定的情况，如果出现运行失败，可以重试几次看看
     - 参考资料:
        - http://ardupilot.org/dev/docs/ros-install.html#installing-mavros
        - http://ardupilot.org/dev/docs/ros-connecting.html
     
10. ROS避障  
    - 安装ap_navigation:
        ```Bash
        sudo apt install ros-kinetic-navigation ros-kinetic-roslaunch ros-kinetic-catkin

        cd ~/catkin_ws/src
        wget https://github.com/ArduPilot/companion/raw/master/Common/ROS/ap_navigation.zip
        unzip ap_navigation.zip

        cd ~/catkin_ws
        sudo su
        catkin_make install -DCMAKE_INSTALL_PREFIX=/opt/ros/kinetic
        cp -rfv /home/ubuntu/catkin_ws/src/ap_navigation/* /opt/ros/kinetic/share/ap_navigation/
        exit
        source /opt/ros/kinetic/setup.bash
        ```
    - 拷贝修改过的配置文件
        ```Bash
        sudo cp /home/ubuntu/ROS/node.launch /opt/ros/kinetic/share/mavros/launch/node.launch
        ```
    - 运行: 
        - 树莓派: 同时运行上述步骤安装的几个程序
            ```Bash
            sudo chmod 666 /dev/ttyUSB0
            sudo chmod 666 /dev/ttyUSB1
            roslaunch mavros apm.launch fcu_url:=/dev/ttyUSB1:9600
            roslaunch rplidar_ros rplidar.launch &
            roslaunch cartographer_ros demo_revo_lds.launch
            roslaunch ap_navigation ap_nav.launch
            ```
        - pix: 切换到arm + guided模式
        - 笔记本电脑: 在打开的rviz界面中使用2D Nav Goal设置目标位置
        - 最终效果: 应该有一条绿线显示到达目标位置的规划路线 (待验证)
    - 参考资料: 
        - http://ardupilot.org/dev/docs/ros-object-avoidance.html
