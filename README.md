# RouterOS Docker Setup and Build Script

This project automates the setup and deployment of MikroTik RouterOS in a Docker container, and exports the resulting container into an image.

## Prerequisites

- Debian 12 to build container
- Make sure Docker is installed and running on both build and deployment hosts:
  ```bash
  sudo apt-get update && sudo apt-get -y install docker.io
  ```
- RouterOS License Key (required for activating RouterOS after setup)

## Setup

### Step 1: Create a Docker Network

To facilitate communication between the RouterOS container, host, and the internet, create a custom Docker network with both IPv4 and IPv6 support. Run the following command on your build and deployment servers:

```bash
docker network create --driver bridge --ipv6 --subnet 192.168.200.0/24 --subnet fd00:dead:beef::/64 ros-bridge-net
```

This command creates a bridge network named `ros-bridge-net` with:

- **IPv4 Subnet**: `192.168.200.0/24`
- **IPv6 Subnet**: `fd00:dead:beef::/64`

### Step 2: Build the RouterOS Docker Container

Use the `Build.sh` script to build the Docker container running RouterOS. Make sure the Docker daemon is running, and you have sufficient permissions. To execute the script, run:

```bash
sudo sh Build.sh
```

### Step 3: Configure RouterOS

After running `Build.sh`, wait for RouterOS to boot up.

1. The default username and password are:
   - **Username**: `admin`
   - **Password**: (leave blank)

2. Run the following commands in the RouterOS terminal to configure IP addresses and routes:

```bash
/ip address add address=192.168.200.2/24 interface=ether1
/ip route add gateway=192.168.200.1
/ipv6 address add address=fd00:dead:beef::2/64 interface=ether1
/ipv6 route add gateway=fd00:dead:beef::1
```

3. Verify the system license with the command:

```bash
/system license print
```

4. Copy the `system-id` displayed from the above command, and use it in MikroTik's [Keygen](https://mikrotik.com/keygen) to generate a license key. Paste the license key into RouterOS, and reboot the system to activate it.

5. After the reboot, check the license status again with:

```bash
/system license print
```

6. Shut down RouterOS gracefully:

```bash
/system shutdown
```

7. `Build.sh` will then export the built image to `routeros-<VERSION_NUMBER>-final.tar`

### Step 4: Export the RouterOS Image

Once the RouterOS container is successfully built and configured, the image `routeros-<VERSION_NUMBER>-final.tar` is exported. This image can be used for future deployments.

## Usage

Once you have exported the image, you can deploy it on any Docker-compatible platform with the following steps:

1. Upload `routeros-<VERSION_NUMBER>-final.tar` & `Deploy_ROS.sh` to your other hosts
2. Install `docker.io`
3. Run:
```bash
sh Deploy_ROS.sh
```

## License

Make sure to obtain a valid RouterOS license to activate your deployment. You can get this from MikroTik's official site.

## Troubleshooting

- **Network issues**: Ensure that the `ros-bridge-net` network is properly configured and that your container has the correct IP addresses.
- **License issues**: Ensure that you have pasted the correct license key and rebooted RouterOS after applying it.

For more information on RouterOS, visit the [MikroTik Website](https://mikrotik.com).

Setup Guide: [MikroTik RouterOS First Time Configuration](https://help.mikrotik.com/docs/display/ROS/First+Time+Configuration).
