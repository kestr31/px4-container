ARG BASEIMAGE
ARG BASETAG

#          __                                     __ 
#    _____/ /_____ _____ ____        ____ _____  / /_
#   / ___/ __/ __ `/ __ `/ _ \______/ __ `/ __ \/ __/
#  (__  ) /_/ /_/ / /_/ /  __/_____/ /_/ / /_/ / /_  
# /____/\__/\__,_/\__, /\___/      \__,_/ .___/\__/  
#                /____/                /_/           

# BASE STAGE FOR CACHINE APT PACKAGE LISTS
FROM ${BASEIMAGE}:${BASETAG} as stage_apt

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN \
    rm -rf /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
	&& sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list \
    && apt-get update

RUN \
    apt install -y \
        ca-certificates \
        curl \
        software-properties-common \
        wget

RUN \
    add-apt-repository universe -y \
    && add-apt-repository ppa:kisak/kisak-mesa -y

RUN \
    wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null \
    && apt-get update


#          __                         _____             __
#    _____/ /_____ _____ ____        / __(_)___  ____ _/ /
#   / ___/ __/ __ `/ __ `/ _ \______/ /_/ / __ \/ __ `/ / 
#  (__  ) /_/ /_/ / /_/ /  __/_____/ __/ / / / / /_/ / /  
# /____/\__/\__,_/\__, /\___/     /_/ /_/_/ /_/\__,_/_/   
#                /____/                                   

FROM ${BASEIMAGE}:${BASETAG} as stage_final

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN \
    sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# ADD NON-ROOT USER user AND GRANT SUDO PERMISSION
RUN \
    groupadd user \
    && useradd -ms /bin/zsh user -g user

# DOWNLOAD 
COPY PX4-Autopilot-Beta/gazebo/aptdeps.txt /tmp/aptdeps.txt

# UPGRADE THE BASIC ENVIRONMENT FIRST
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get upgrade -y

# INSTALL ca-certifiactes TO AVOID CERTIFICATE ERROR FOR KISAK MESA DRIVERS
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y \
        ca-certificates

# INSTALL PACKAGES AVAIABLE BY APT REPOSITORY
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptdeps.txt) \
    && rm -rf /tmp/*

# SET LOCALE TO en_UT.UTF-8
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    apt install -y \
	    locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# ADD NON-ROOT USER user AND GRANT SUDO PERMISSION
RUN \
    echo "user ALL=NOPASSWD: ALL" >> /etc/sudoers

# CHANGE USER TO NEWLY GENERATED user AND CHANGE WORKING DIRECTORY TO user's HOME
USER user
WORKDIR /home/user

# FOR EASE OF DEVELOPMENT, INSTALL OH-MY-ZSH AND PLUGINS. SET ALIAS FOR CAT
RUN \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended \
    && sed -i "s/robbyrussell/agnoster/g" ${HOME}/.zshrc \
    && git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        ${HOME}/.oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting \
    && sed -i "s/(git)/(git zsh-autosuggestions zsh-syntax-highlighting)/g" ${HOME}/.zshrc \
    && echo "alias cat='batcat --paging=never'" >> ${HOME}/.zshrc

# DEV OPTION
RUN \
    git clone https://github.com/PX4/PX4-Autopilot.git -b v1.14.0-beta2 \
    && git -C PX4-Autopilot submodule update --init --recursive \
    && mkdir /home/user/gazebo

# DEV OPTION
RUN \
    PX4-Autopilot/Tools/setup/ubuntu.sh --no-nuttx --no-sim-tools \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean autoclean \
    && sudo rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# DEV OPTION
# RUN \
#     git clone https://github.com/gazebosim/gz-transport.git \
#     && mkdir /home/user/gz-transport/example/build \
#     && cmake -B /home/user/gz-transport/example/build -S /home/user/gz-transport/example \
#     && make -C /home/user/gz-transport/example/build -j4

COPY PX4-Autopilot-Beta/gazebo/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN \
    mkdir /home/user/scripts && \
    sudo ln -s /usr/local/bin/entrypoint.sh /home/user/scripts/entrypoint.sh

CMD [ "/usr/local/bin/entrypoint.sh" ]

# ------ RUN COMMAND (DEFAULT) -----
# docker run -it --rm \
#    -e DISPLAY=$DISPLAY \
#    -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
#    -e QT_NO_MITSHM=1 \
#    -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
#    -e NVIDIA_DRIVER_CAPABILITIES=all \
#    -v /run/user/1000:/run/user/1000 \
#    -v /tmp/.X11-unix:/tmp/.X11-unix \
#    -v /usr/share/vulkan/icd.d/nvidia_icd.json:/etc/vulkan/icd.d/nvidia_icd.json \
#    -v /usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/etc/vulkan/implicit_layer.d/nvidia_layers.json \
#    -v /usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json \
#    --device=/dev/dri:/dev/dri \
#    --net host \
#    --ipc host \
#    --gpus all \
#    --user user \
#    --privileged \
#    --name sitl-sim \
#    kestr3l/gazebo:garden-0.0.1-dev zsh

# ------- RUN COMMAND (WSL2) -------
# docker run -it --rm \
#    -e DISPLAY=$DISPLAY \
#    -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
#    -e QT_NO_MITSHM=1 \
#    -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
#    -e NVIDIA_DRIVER_CAPABILITIES=all \
#    -e PULSE_SERVER=/mnt/wslg/PulseServer \
#    -e LD_LIBRARY_PATH=/usr/lib/wsl/lib \
#    -v /run/user/1000:/run/user/1000 \
#    -v /tmp/.X11-unix:/tmp/.X11-unix \
#    -v /usr/share/vulkan/icd.d/nvidia_icd.json:/etc/vulkan/icd.d/nvidia_icd.json \
#    -v /usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/etc/vulkan/implicit_layer.d/nvidia_layers.json \
#    -v /usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json \
#    -v /mnt/wslg:/mnt/wslg \
#    -v /usr/lib/wsl:/usr/lib/wsl \
#    --device=/dev/dxg \
#    --device=/dev/dri/card0 \
#    --net host \
#    --ipc host \
#    --gpus all \
#    --user user \
#    --privileged \
#    --name sitl-sim \
#    kestr3l/gazebo:garden-0.0.1-dev zsh

# ------- BUILD COMMAND (CUDA) -------
# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.7.1-cudnn8-devel-ubuntu20.04 \
# -t kestr3l/gazebo:garden-0.0.1-cuda-dev \
# -f ./PX4-Autopilot-Beta/gazebo/Dockerfile .

# ------- BUILD COMMAND (PLAIN) ------
# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=ubuntu \
# --build-arg BASETAG=22.04 \
# -t kestr3l/gazebo:garden-0.0.1-dev \
# -f ./PX4-Autopilot-Beta/gazebo/Dockerfile .