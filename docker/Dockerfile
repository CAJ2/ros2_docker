# syntax=docker/dockerfile:1.7-labs
ARG ROS_DISTRO=humble

# -------------------------------------------
# Base Image
# Contains core ROS packages and dependencies
# -------------------------------------------
FROM ros:${ROS_DISTRO}-ros-base as base
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

# Create Colcon workspace with external dependencies
RUN mkdir -p /base_ws/src
WORKDIR /base_ws/src
COPY dependencies.repos .
RUN vcs import < dependencies.repos

# Build the base Colcon workspace, installing dependencies first.
WORKDIR /base_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
 && apt-get update -y \
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
 && colcon build --symlink-install
# Use Cyclone DDS as middleware
RUN apt-get update && apt-get install -y --no-install-recommends \
 ros-${ROS_DISTRO}-rmw-cyclonedds-cpp
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# -------------------------------------------
# Overlay Image
# Contains main packages
# -------------------------------------------
FROM base AS overlay

# Create an overlay Colcon workspace
RUN mkdir -p /robot_ws/src
WORKDIR /robot_ws
COPY --parents ./src/*/package.xml ./
COPY --parents ./src/*/COLCON_IGNORE ./
RUN rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y
COPY ./src/ ./src/
RUN source /base_ws/install/setup.bash \
 && colcon build --symlink-install

# Set up the entrypoint
COPY ./docker/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# -------------------------------------------
# Development Image
# Contains extra tools for development
# -------------------------------------------
FROM overlay as dev

# Dev container arguments
ARG USERNAME=ros
ARG UID=1000
ARG GID=${UID}

# Install extra tools for development
RUN apt-get update && apt-get install -y --no-install-recommends \
 build-essential curl ca-certificates tar gettext libssl-dev zlib1g-dev \
 libcurl?-openssl-dev libexpat1-dev libpcre2-dev gnupg2 procps

RUN apt-get update && apt-get install -y --no-install-recommends \
 git ssh gdb gdbserver neovim htop tmux rsync ncdu strace jq zip unzip

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
 && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
 && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME} \
 && mkdir -p /home/${USERNAME} \
 && chown -R ${UID}:${GID} /home/${USERNAME} \
 && chown -R ${UID}:${GID} /robot_ws/

# Set the user and source entrypoint in the user's .bashrc file
USER ${USERNAME}
RUN echo 'eval "$(register-python-argcomplete3 ros2)"' >> /home/${USERNAME}/.bashrc \
 && echo 'eval "$(register-python-argcomplete3 colcon)"' >> /home/${USERNAME}/.bashrc \
 && echo "alias sws='source /robot_ws/install/setup.bash'" >> /home/${USERNAME}/.bashrc \
 && echo "source /entrypoint.sh" >> /home/${USERNAME}/.bashrc
