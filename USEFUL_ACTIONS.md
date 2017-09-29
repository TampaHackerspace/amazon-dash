# Useful Scripts
I have made a few interesting scripts/actions to be performed when a dash button is clicked and I would like to share the more useful ones here. These scripts assume default installation to the /etc/dash folder on a Debian based system (e.g Raspberry Pi)

## Philips Hue Lights
### Install prerequisites
This script requires [jq JSON processor](https://stedolan.github.io/jq/) and [curl](https://curl.haxx.se/docs/manpage.html)

```bash
sudo apt-get install jq curl
```

Once jq is installed, you will need to configure your Philips Hue Bridge. There is an excellent resource called the [Philips Hue API Getting Started](http://www.developers.meethue.com/documentation/getting-started) that describes this process in detail but I have also included a script that will do this automatically. Ensure that the [hue.sh](https://github.com/TampaHackerspace/amazon-dash/blob/master/etc/dash/hue.sh) script is marked as executable.

```bash
sudo chmod a+x /etc/dash/hue.sh
sudo chmod a+x /etc/dash/scan-network.sh
```

Now we are ready to configure the script to work with the Hue Bridge. This can either be done manually by editing the /etc/dash/hue.config script with the IP address of the hue bridge and the API key (see [Philips Hue API Getting Started](http://www.developers.meethue.com/documentation/getting-started) for getting the key) or by running the autoconfig script after pressing the button on the Hue Bridge

```bash
sudo /etc/dash/hue.sh --action autoconfig
```

You will need to know which lights are to be controlled and reference them by a unique ID number. The [hue.sh](https://github.com/TampaHackerspace/amazon-dash/blob/master/etc/dash/hue.sh) script will once again help with that.

```bash
/etc/dash/hue.sh --action lights
```

This will return a list of the light indexes, names associated with those lights and the status (On or Off) of those lights.

## Network Scanner
### Install prerequisites
This script requires some standard networking tools

```bash
sudo apt-get install nmap curl grep
```
This script will scan the network that the system is attached to (all of them for multi-homed systems) for an open port of interest. This is useful for finding ssh or http servers and is used by the [hue.sh](https://github.com/TampaHackerspace/amazon-dash/blob/master/etc/dash/hue.sh) script to locate viable candidates for probing. This avoids probing every IP on the network. There are still a few enhancements that need to be made to this script. For instance right now it can only handle class C IP address ranges.

This script accomplishes it's scan by enumerating all of the network interfaces, calculating the IP/Netmask starting address, and then probing each address in the range using NMAP to find open ports. The IP addresses matching open ports are then displayed and can be parsed by a calling script.

For instance, to find all HTTP servers on the network you would invoke
```bash
./scan-network.sh 80
```
To find all SSH servers on the network (useful for finding devices like Raspberry Pi)
```bash
./scan-network.sh 22
```

Last updated by bald-kevin 20170929
