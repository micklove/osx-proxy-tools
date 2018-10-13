# Proxy tools for OSX

### Usage
Used to manage location switching, proxies, etc... from the commandline, using a json config file.

### Prerequisites
`jq` is required. Follow the instructions [here](https://github.com/stedolan/jq) to install it.
openconnect is used to run the vpn script. Can be installed with `brew`

### Commands
See example configuration file at [dummy-proxy-config.json](dummy-proxy-config.json)

#### 1. Add your proxy details to the OSX keychain
For security, it's better for your scripts to retrieve proxy details from the osx keychain.
nb: A regex, loaded from the config, is used to ensure the username is in the correct format e.g. d123478
```bash
upsert-proxy-creds-to-keychain.sh /path/to/proxy-config.json myproxyusername
```

#### 2. Create / Load Locations
Uses the OSX Network Location feature, to switch between Locations.
If the network Location (my-vpn in the example below), is not an existing osx network Location, the script uses the details in the config file to create the location.
```bash
./run-location.sh /path/to/proxy-config.json my-vpn 
```
If the network Location IS an existing osx Network Location, the script simply switches to that Location.

#### 3. Run the vpn command
Use the vpn details from the config file, hostname, etc...
To help with route issues, on script exit, the proxy is disabled and the vpn route is removed. Will require sudo.

```bash
./run-vpn.sh /path/to/proxy-config.json
```

#### 4. Create Proxy config
Creates a web proxy and secure proxy, in the Location, host, port, bypass domains, etc... mentioned in the config file
nb: Uses proxy username and password from the keychain.

```bash
./run-proxy.sh /path/to/proxy-config.json
```
nb: If you `source` the [common.sh](common.sh) script, you can use the following helper functions:

```bash
start_proxy Wi-Fi
start_proxy Ethernet
status_proxy Wi-Fi
status_proxy Ethernet
stop_proxy Wi-Fi
dump_location_details
```

#### 5. Add Proxy config as env variables
TODO
