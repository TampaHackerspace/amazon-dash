# amazon-dash
Debian linux utils and scripts to manage amazon dash buttons

1. Configure Dash buttons
2. Get Dash Button MAC Address(s)
3. Create the configuration directory and add scripts
4. Start service

## Configure Dash Buttons
 You will need: A smartphone, the Amazon App installed, the password to the wireless network. A tutorial: https://davekz.com/hacking-amazon-dash-buttons/

1. Ensure that your smartphone is currently connected to the target wireless network
2. Open Smartphone Amazon App
  1. Select Menu
  2. Your Account
  3. Under Dash Devices select "Set Up New Device"
  4. Follow instructions but do NOT select a product
  5. Disable Dash notifications on your phone
    1. Amazon App > Menu > Notifications > Dash Button Updates

##Installation
I have not made much of an installer for this but the stuff needs to be copied to the proper locations.

```bash
git clone git@github.com:TampaHackerspace/amazon-dash.git
cd amazon_dash
sudo cp -r etc/dash /etc
sudo cp etc/init.d/dash-button /etc/init.d
sudo cp -r usr/sbin/* /usr/sbin
sudo ln -s /usr/sbin/dash-button-listen /etc/dash/
sudo /etc/init.d/dash-button start

```

## Operation
The scripts can be run in user mode and should be for testing. In order to do so ensure that you set the executable flags...
```bash
sudo ln -s /usr/sbin/dash-button-listen /etc/dash/
sudo chmod a+x /usr/sbin/dash-button-listen
sudo chmod a+x /etc/dash/arp-detected.sh
sudo chmod a+x /etc/dash/dash-add.sh
sudo chmod a+x /etc/dash/mac-skeleton.d/10-log-result.sh
```

To get the MAC address for a particular Dash button using the worker script. This will detect Dash buttons from known MAC address prefixes from a MAC address search: http://www.adminsub.net/mac-address-finder/amazon
```bash
cd /etc/dash
sudo ./dash-button-listen detect
```
The script will execute and you should click the pre-configured button. A prompt will ask if you wish to create a config folder for that MAC address and you can add scripts to the new config file in /etc/dash/mac-<address>.d directory


To manually add a Dash MAC address use:

```bash
cd /etc/dash
sudo ./dash-add.sh 00:22:33:55:11:F3
```

You can execute the dash listener in interactive mode as follows:

```bash
cd /etc/dash
sudo ./dash-button-listen
```

Click the preconfigured Dash button and you should see feedback with the MAC address and the scripts executed. If you wish to add to a button's actions then add a script under the mac-<MAC_ADDRESS>.d folder and mark that script as executable using

```bash
sudo cp script-name.sh /etc/dash/mac-<MAC_ADDRESS>.d/20-script-name.sh
sudo chmod a+x /etc/dash/mac-<MAC_ADDRESS>.d/20-script-name.sh

```

If you wish to extend the default actions that each button gets then modify the /etc/dash/mac-skeleton.d directory scripts


Last Update: 201608090201 by bald-kevin
