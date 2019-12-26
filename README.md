# spdMerlin - Automatic speedtest for AsusWRT Merlin - with graphs
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/1e0da6475e3047d59b35e258a18b78fc)](https://www.codacy.com/app/jackyaz/spdMerlin?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=jackyaz/spdMerlin&amp;utm_campaign=Badge_Grade)
[![Build Status](https://travis-ci.com/jackyaz/spdMerlin.svg?branch=master)](https://travis-ci.com/jackyaz/spdMerlin)

## v3.0.0
### Updated on 2019-12-26
## About
Run automated speedtests for your Internet on your router with graphs available on the Tools page of the WebUI.

spdMerlin is free to use under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0) (GPL 3.0).

spdMerlin uses [Speedtest CLI](https://www.speedtest.net/apps/cli)

spdMerlin includes the required licenses, which must be accepted on first run of Speedtest CLI.

This script began as a user-friendly installer for a personal project developed by [JGrana](https://www.snbforums.com/members/jgrana.20663/)

A swap file is required to ensure smooth operation of the script.

The speedtest is scheduled to run at 12 past and 42 past the hour, every hour, by default.

![Menu UI](https://puu.sh/ETs9A/767afcaf6c.png)

![Graph example](https://puu.sh/DQ8cX/612747873c.png)

### Supporting development
Love the script and want to support future development? Any and all donations gratefully received!
[**PayPal donation**](https://paypal.me/jackyaz21)

## Supported Models
### Models
All modes supported by [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/about). Models confirmed to work are below:
*   RT-AC68U
*   RT-AC86U
*   RT-AC3100

### Firmware versions
You must be running firmware no earlier than 384.XX [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/)

## Installation
Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```sh
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/jackyaz/spdMerlin/master/spdmerlin.sh" -o "/jffs/scripts/spdmerlin" && chmod 0755 /jffs/scripts/spdmerlin && /jffs/scripts/spdmerlin install
```

## Usage
To launch the spdMerlin menu after installation, use:
```sh
spdmerlin
```

If this does not work, you will need to use the full path:
```sh
/jffs/scripts/spdmerlin
```

## Updating
Launch spdmerlin and select option u

## Help
Please post about any issues and problems here: [spdMerlin on SNBForums](https://www.snbforums.com/threads/spdmerlin-automated-speedtests-with-graphs.55904/)

## FAQs
### I haven't used scripts before on AsusWRT-Merlin
If this is the first time you are using scripts, don't panic! In your router's WebUI, go to the Administration area of the left menu, and then the System tab. Set Enable JFFS custom scripts and configs to Yes.

Further reading about scripts is available here: [AsusWRT-Merlin User-scripts](https://github.com/RMerl/asuswrt-merlin/wiki/User-scripts)

![WebUI enable scripts](https://puu.sh/A3wnG/00a43283ed.png)
