# syntax=docker/dockerfile:1.6
ARG ROS_DISTRO=jazzy
FROM ros:${ROS_DISTRO}-ros-core

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install additional dependencies if needed
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    vim \
    git \
    cmake \
    python3-pip \
    python3-vcstool \
    python3-rosdep \
    htop \
    mesa-utils \
    libglx-mesa0 \
    ros-dev-tools \
    python3-colcon-coveragepy-result \
	unzip \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init

# configurable UID/GID (defaults to 1000:1000)
ARG USERNAME=ubuntu
ARG UID=1000
ARG GID=1000

# create group/user if missing, add to sudo, and configure passwordless sudo
RUN set -eux; \
    if ! getent group "${GID}" >/dev/null; then groupadd -g "${GID}" "${USERNAME}"; fi; \
    if ! id -u "${UID}" >/dev/null 2>&1; then useradd -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"; fi; \
    usermod -aG sudo "${USERNAME}"; \
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USERNAME}"; \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"

USER ${USERNAME}
ENV HOME=/home/${USERNAME}
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR $HOME/data
RUN wget https://charts.noaa.gov/ENCs/02Region_ENCs.zip
RUN unzip 02Region_ENCs.zip
ENV ROS_S57_ENC_ROOT=$HOME/data/ENC_ROOT

WORKDIR $HOME/project11_ws/src

RUN git clone https://github.com/CCOMJHC/project11.git -b jazzy
RUN vcs import < project11/config/repos/simulator.repos

WORKDIR $HOME/project11_ws/
RUN ["/bin/bash", "-c", "source /opt/ros/${ROS_DISTRO}/setup.bash \
    && sudo apt update \
    && rosdep update \
    && rosdep install --from-paths src --ignore-src -r -y \
    && sudo rm -rf /var/lib/apt/lists/"]

WORKDIR $HOME/project11_ws/
RUN ["/bin/bash", "-c", "source /opt/ros/${ROS_DISTRO}/setup.bash \
    && colcon build --symlink-install \
    && echo 'source ~/project11_ws/install/setup.bash' >> ~/.bashrc"]

RUN sudo apt autoremove -y && sudo rm -rf /var/lib/apt/lists/