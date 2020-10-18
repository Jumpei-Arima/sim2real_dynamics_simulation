FROM arijun/dl_remote:latest

# upgrade pip version
RUN source /root/.zshrc && \
    pip install --upgrade pip

# mujoco
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        libgl1-mesa-dev \
        libgl1-mesa-glx \
        libglew-dev \
        libosmesa6-dev \
        software-properties-common \
        net-tools \
        unzip \
        vim \
        virtualenv \
        wget \
        xpra \
        xserver-xorg-dev \
        libglfw3-dev \
        patchelf

RUN mkdir -p /root/.mujoco \
    && wget https://www.roboti.us/download/mjpro150_linux.zip -O mujoco.zip \
    && unzip mujoco.zip -d /root/.mujoco \
    && rm mujoco.zip
COPY ./mjkey.txt /root/.mujoco/
RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.mujoco/mjpro150/bin' >> /root/.zshrc

# PyKDL
WORKDIR /root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cmake \
        libeigen3-dev \
        python3-dev
RUN git clone https://github.com/orocos/orocos_kinematics_dynamics.git && \
    cd /root/orocos_kinematics_dynamics/orocos_kdl && \
    git checkout 6bbea2e0c837dfcded7caaec0a61f09b23c8ae13 && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j4 && \
    make install && \
    cd /root/orocos_kinematics_dynamics/python_orocos_kdl && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_VERSION=3 .. && \
    make -j4 && \
    cp PyKDL.cpython-36m-x86_64-linux-gnu.so  /root/.pyenv/versions/3.6.7/lib/python3.6/site-packages/

# kdl_parser_py
WORKDIR /root
RUN git clone -b fixing_setup_py https://github.com/eugval/kdl_parser.git && \ 
    source /root/.zshrc && \
    pip install -e kdl_parser/kdl_parser_py

# simple-pid
WORKDIR /root
RUN git clone -b allow_arrays https://github.com/eugval/simple-pid.git && \
    source /root/.zshrc && \
    pip install -e simple-pid

# urdf_parser_py
WORKDIR /root
RUN git clone https://github.com/ros/urdf_parser_py.git && \
    cd urdf_parser_py && \
    source /root/.zshrc && \
    pip install catkin_pkg && \
    pip install -e .

# sim2real_dyanmics_simulation
WORKDIR /root
RUN git clone https://github.com/eugval/sim2real_dynamics_simulation.git && \
    source /root/.zshrc && \
    cd sim2real_dynamics_simulation && \
    pip install -r requirements.txt && \
    pip install -e sim2real-policies && \
    pip install -e sim2real-calibration-characterisation && \
    pip install -e robosuite-extra && \
    pip install --no-cache-dir \
        'gym[all]' \
        IPython \
        robosuite==0.1.0 \
        h5py \
        PyYAML

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root/sim2real_dynamics_simulation