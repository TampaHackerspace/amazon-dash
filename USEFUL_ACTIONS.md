# Useful Scripts
I have made a few interesting scripts/actions to be performed when a dash button is clicked and I would like to share the more useful ones here. These scripts assume default installation to the /etc/dash folder on a Debian based system (e.g Raspberry Pi)

## Phillips Hue Lights
### Install prerequisites
This script requires [jq JSON processor](https://stedolan.github.io/jq/) and [curl](https://curl.haxx.se/docs/manpage.html)

```bash
sudo apt-get install jq curl
```

Once jq is installed, you will need to configure your Phillips Hue Bridge. There is an excellent resource called the [Phillips Hue API Getting Started](http://www.developers.meethue.com/documentation/getting-started) that describes this process in detail but I have also included a script that will do this automatically. Ensure that the [hue.sh](https://github.com/TampaHackerspace/amazon-dash/blob/master/etc/dash/hue.sh) script is marked as executable.

```bash
sudo chmod a+x /etc/dash/hue.sh
```

Now we are ready to configure the script to work with the Hue Bridge. This can either be done manually by editing the /etc/dash/hue.config script with the IP address of the hue bridge and the API key (see [Phillips Hue API Getting Started](http://www.developers.meethue.com/documentation/getting-started) for getting the key) or by running the autoconfig script after pressing the button on the Hue Bridge

```bash
sudo /etc/dash/hue.sh autoconfig
```

You will need to know which lights are to be controlled and reference them by a unique ID number. The [hue.sh](https://github.com/TampaHackerspace/amazon-dash/blob/master/etc/dash/hue.sh) script will once again help with that. (This feature is not yet complete)

```bash
/etc/dash/hue.sh show-lights
```
