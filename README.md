# cuckoo-docker
Quickly deploy Cuckoo service in Docker

## Overview
This project facilitates the Docker-based deployment of Cuckoo, a malware analysis system. It orchestrates the necessary components allowing the Cuckoo container to communicate with VirtualBox on the host machine using custom vbox-server and vbox-client setups. The project automates the building of a Docker image for Cuckoo, along with compiling the vbox-server and vbox-client binaries that relay VBoxManage commands from within the Docker container to the host's VirtualBox.

Additionally, this setup configures iptables to forward traffic so that the Cuckoo container can interact with virtual machines on the `vboxnet0` network (192.168.56.0) and allows these VMs to access the Cuckoo container's result_server on port 2042.

## Prerequisites
- Docker
- Go Compiler
- VirtualBox
- iptables (for setting up network forwarding)

## Building the Project
To build the vbox-server, vbox-client, and the Cuckoo Docker image, run the following command from the project directory:

```bash
make all
```

This command will:
- Compile the vbox-server and vbox-client binaries.
- Build the Docker image for Cuckoo tagged as `cuckoo:latest`.

## Cleanup
To clean up the binaries and temporary files generated during the build process, you can run:

```bash
make clean
```

## Preparing to Run
Before starting the Docker container, ensure the vbox-server is running:

```bash
./bin/vbox-server
```

This server will create a `vbox.sock` file, which is needed by the container.

## Running the Project
After ensuring the vbox-server is running and `vbox.sock` has been created, deploy the Cuckoo container with the following Docker command:

```bash
docker run -d --name cuckoo -v $(realpath ./vbox.sock):/opt/vbox/vbox.sock cuckoo:latest
```

### Optional Configurations
- To manage Cuckoo's current working directory (cwd) from the host, mount the `cwd` directory to a host directory:

  ```bash
  docker run -d --name cuckoo -v $(realpath ./vbox.sock):/opt/vbox/vbox.sock -v /path/to/cuckoo/cwd/on/host:/home/cuckoo/.cuckoo cuckoo:latest
  ```

- To facilitate easy access to the Cuckoo codebase within the container, you can mount the code directory:

  ```bash
  docker run -d --name cuckoo -v $(realpath ./vbox.sock):/opt/vbox/vbox.sock -v /path/to/cuckoo/code/on/host:/home/cuckoo/.local/lib/python2.7/site-packages/cuckoo cuckoo:latest
  ```

### Starting Additional Services
- To start the Cuckoo API within the running container:

  ```bash
  docker exec -d cuckoo cuckoo api --host 0.0.0.0 --port 8080
  ```

- If you want to use the Cuckoo web interface, ensure that the necessary configurations are done within the container before starting the web service.

## Network Configuration
- Set up iptables rules to forward traffic for proper communication between the Cuckoo container, the host, and the virtual machines:

  ```bash
  # Example iptables configuration commands
  sudo iptables -A FORWARD -o vboxnet0 -i docker0 -j ACCEPT
  sudo iptables -A FORWARD -i vboxnet0 -o docker0 -j ACCEPT
  ```

Replace `eth0` with the appropriate interface as necessary.

## Support
For any issues or contributions, please open an issue or a pull request on the project's GitHub repository.
