# ROS2 Docker

This repository is intended as a template for getting ROS2 running in a Docker container with full support for containerized development using the [Development Containers](https://containers.dev) spec.

## Launch

Launching the codebase is done through docker compose:
```bash
docker compose -f compose.launch.yaml up <service>
```
The launch services are defined at the top of `compose.launch.yaml`.
All new services should extend the `overlay` service in `compose.base.yaml`. The `overlay` image contains all code in `src/`, but must be rebuilt to copy any new changes:
```bash
docker compose -f compose.launch.yaml build [service]
```

## Dependencies
If additional dependencies are needed in addition to the code in `src/`, add them to the `dependencies.repos` file and rebuild. Dependencies are managed using [vcstool](https://github.com/dirk-thomas/vcstool), which is a common ROS tool to import external repositories into the workspace.

## Development

Development containers have been defined in `compose.dev.yaml` that includes dev tools and a friendly environment. Configuration for VSCode and the [devcontainer spec](https://containers.dev/) are included with useful extensions and settings. Changes in the dev container are synced back to the host folder.

1. Install the Dev Containers extension. [More Info](https://code.visualstudio.com/docs/devcontainers/tutorial)
2. Click the bottom left corner icon in the editor.
3. Choose either *Open Folder in Container* or *Reopen in Container* if you already have the repository folder open.

For other editors, refer to editor documentation on Dev Containers.

**Attaching to the container**: To run commands in the container from an external terminal, run `./attach.sh` while in the repository folder.

**Using Foxglove Studio**: The dev configuration can launch a foxglove_bridge sidecar. Uncomment the service in `compose.dev.yaml` to enable. Start Foxglove Studio on the host and connect to ws://localhost:8765 (the default).

## Docker Configuration

The configuration consists of three docker compose files:
1. `compose.base.yaml`: Contains base services for running the repository in ROS2
2. `compose.launch.yaml`: Contains launch services that extend the base services.
These definitions are intended for production environments.
3. `compose.dev.yaml`: Contains development services built on the base services.
These are run by the .devcontainer configuration.
The **dev** container provides additional development packages and tools, a non-root user with sudo access, and volumes to sync code changes between the container and the host.


The `compose.base.yaml` consists of three container definitions:
1. **base**: Contains core ROS2 packages and dependencies
2. **overlay**: Contains ROS2 packages from this repository
3. **dev**: Contains extra tools for development

For production environments, only **base** and **overlay** are deployed, containing the minimum set of packages necessary for running on a robot.

Networking in ROS2 should work automatically between any running containers and the host. This makes it easy to run additional ROS2 packages such as visualization tools on the host. However, ensure that you are using the [Cyclone DDS](https://docs.ros.org/en/humble/Installation/DDS-Implementations/Working-with-Eclipse-CycloneDDS.html) middleware on the host for communicating with Docker services through ROS2.

### Acknowledgements
These resources helped define much of the basics in this template:

[An Updated Guide to Docker and ROS 2 - Robotic Sea Bass](https://roboticseabass.com/2023/07/09/updated-guide-docker-and-ros2/)

[VSCode, Docker, and ROS2 - Allison Thackston](https://www.allisonthackston.com/articles/vscode-docker-ros2.html)

[panther-docker - Husarion](https://github.com/husarion/panther-docker/tree/ros2-devel)
