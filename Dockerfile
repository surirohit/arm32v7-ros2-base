FROM arm32v7/ubuntu:bionic

RUN echo 'Etc/UTC' > /etc/timezone && ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime 

RUN apt-get update && \
    apt-get install -q -y \
    bash-completion \
    curl \
    dirmngr \
    git \
    gnupg2 \
    libasio-dev \
    libtinyxml2-dev \
    lsb-release \
    python3-pip \
    tzdata wget && \
    rm -rf /var/lib/apt/lists/*

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN . /etc/os-release && \
    echo "deb http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update && \
    apt-get install -y python3-catkin-pkg && \
    rm -rf /var/lib/apt/lists/*
RUN pip3 install -U \
    argcomplete \
    colcon_common_extensions \
    flake8 \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-docstrings \
    flake8-import-order \
    flake8-quotes \
    lark-parser \
    pytest-repeat \
    pytest-rerunfailures \
    rosdep \
    rosinstall_generator \
    vcstool

RUN rosdep init && rosdep update

ENV ROS2_WS /root/ros2_ws
RUN mkdir -p $ROS2_WS/src
WORKDIR $ROS2_WS

RUN wget https://raw.githubusercontent.com/ros2/ros2/crystal/ros2.repos && vcs import src < ros2.repos

RUN apt-get update && \
    rosdep install \
    --from-paths src \
    --ignore-src \
    --rosdistro crystal -y \
    --skip-keys \
    "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 rti-connext-dds-5.3.1 urdfdom_headers python3-lark-parser python3-catkin-pkg-modules" && \
    rm -rf /var/lib/apt/lists/*

RUN colcon --log-level info build --cmake-args -DSECURITY=ON --no-warn-unused-cli --symlink-install

RUN cp /etc/skel/.bashrc ~/

COPY ./ros2_entrypoint.sh /

ENTRYPOINT ["/ros2_entrypoint.sh"]

CMD ["bash"]
