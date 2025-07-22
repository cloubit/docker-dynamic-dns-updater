# YDNS-Updater on Docker Image
[YDNS](https://ydns.io/)⁠ is a service that lets you host DNS records for your home network or your own domains. You can access your network from anywhere, use custom domains, and enjoy easy and free DNS hosting.
⁠
***

## Create Docker image
If you have Git installed, clone the docker-ydns-updater repository to your localhost with
```sh
git clone https://github.com/cloubit/docker-ydns-updater.git
```
or download the last repository.

If you have docker installed, you can create your own Docker Image about:
```sh
docker build -t ydns-updater:v1 .
```

## Instruction for start-up

### Register your YDNS host
1. Register your account on YDNS
2. Create a host
3. Copy your personal API Credentials


### Configure the .env file
1. Create a file like `touch ydns_update.env`.
2. Update your credentials in the following file example.
```
# your YDNS API credentials
YDNS_USER=YourUsername
YDNS_PASSWD=YourSecret

# all variable names must begin with 'DOMAIN', add as many as you want
DOMAIN1=your.domain.org

# enable/disable IP version
ENABLE_IPV4=True
# ENABLE_IPV6=True

# select the update repeat, default 300 if disabled
# UPDATE_DELAY=180
```

### Configure the compose.yaml
1. Create a file like `touch compose.yaml`
2. Copy the following filecontent in your `compose.yaml`
```
services:
  ydns-updater:
    image: cloubit/ydns-updater
    container_name: ydns_updater
    env_file:
        - ./ydns_update.env
    restart: always
    network_mode: host
```

### Start the YDNS-Updater
1. If you want to start the YDNS-Updater use folowing command:
`docker compose up`
2. Check the Output:

Your IP Adress Update changed: `dns_updater  | Status update: 'your.domain.org', good 111.222.333.444`

or:

No IP Adress has changed: `dns_updater  | Status update: 'your.domain.org', nochg 111.222.333.444`
All other Messages ar failure. Check the Credentials.

## Docker Hub
[Link to the ydns-updater Docker image](https://hub.docker.com/r/cloubit/ydns-updater)
