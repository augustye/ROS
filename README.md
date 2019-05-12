树莓派ROS安装教程
================

1. 硬件配置:
    - 树莓派3B及有线网络 (无需屏幕)
    - PIX + RPLIDAR激光雷达 (均通过UART或USB转UART连接到树莓派)
    - 笔记本电脑 + Ubuntu系统 (用于X-forwarding，接收树莓派发送的图形界面)

2. ROS Image下载:
    - 访问 https://downloads.ubiquityrobotics.com/pi.html 
    - 下载最新的Image: 2019-02-19-ubiquity-xenial-lxde
    - 烧录image到SD后，从SD卡启动树莓派

3. 进入笔记本电脑的Ubuntu系统，使用SSH + X-Forwarding连接树莓派:
    ```Bash
    ssh -X ubuntu@ubiquityrobot.local 
    ```
    - 登录地址: ubiquityrobot.local或者局域网ip地址
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

6. 检查pix和rplidar的连接
    - 确认相应的tty端口存在
        ```Bash
        ls /dev/tty*
        ``` 
    - 在本例中rplidar和pix均通过USB转UART连接到树莓派，rplidar是ttyUSB0, pix是ttyUSB1
    - 修改串口权限:
        ```Bash
        sudo chmod 666 /dev/ttyUSB0
        sudo chmod 666 /dev/ttyUSB1
        ```

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

6. 安装测试cartographer
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
