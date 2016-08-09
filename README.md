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
3. Get MAC address of button on network. I have not yet written a script for this so looking on the wireless router pages is a good start.


## Operation
The scripts can be run in user mode and should be for testing. In order to do so ensure that you set the executable flags...
```bash
sudo ln -s /usr/sbin/dash-button-listen /etc/dash/
sudo chmod a+x /usr/sbin/dash-button-listen
sudo chmod a+x /etc/dash/arp-detected.sh
sudo chmod a+x /etc/dash/dash-add.sh
sudo chmod a+x /etc/dash/mac-00112233445566.d/10-log-result.sh
```

Once you have a MAC address then add a config folder using:

```bash
cd /etc/dash
sudo ./dash-add.sh 00:22:33:55:11:F3
```

You can execute the dash listener in interactive mode as follows:

```bash
cd /etc/dash
sudo ./dash-button-listen
```

Click the preconfigured button and you should see feedback with the MAC address and the scripts executed. If you wish to add to a button's actions then add a script under the mac-<MAC_ADDRESS>.d folder and mark that script as executable using

```bash
sudo cp script-name.sh /etc/dash/mac-MAC_ADDRESS>.d/20-script-name.#!/bin/sh
sudo chmod a+x /etc/dash/mac-MAC_ADDRESS>.d/20-script-name.#!/bin/sh

```

TODO: Create a script that will detect Dash Buttons and autoconfigure them.
