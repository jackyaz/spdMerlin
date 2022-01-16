# spdMerlin
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/1e0da6475e3047d59b35e258a18b78fc)](https://www.codacy.com/app/jackyaz/spdMerlin?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=jackyaz/spdMerlin&amp;utm_campaign=Badge_Grade)
![Shellcheck](https://github.com/jackyaz/spdMerlin/actions/workflows/shellcheck.yml/badge.svg)

## v4.4.5
### Updated on 2022-01-16
## About
spdMerlin is an internet speedtest and monitoring tool for AsusWRT Merlin with charts for daily, weekly and monthly summaries. It tracks download/upload bandwidth as well as latency, jitter and packet loss.

spdMerlin is free to use under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0) (GPL 3.0).

spdMerlin uses [Speedtest CLI](https://www.speedtest.net/apps/cli) and includes the required licenses, which must be accepted on install of spdMerlin.
As of spdMerlin v4.4.0 the Asus built-in Ookla speedtest binary is used to run the speedtests.

A swap file is required, you can set one up easily by using amtm, which is built into the router.

This script began as a user-friendly installer for a personal project developed by [JGrana](https://www.snbforums.com/members/jgrana.20663/)

### Supporting development
Love the script and want to support future development? Any and all donations gratefully received!

| [![paypal](https://www.paypalobjects.com/en_GB/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=47UTYVRBDKSTL) <br /><br /> [**PayPal donation**](https://www.paypal.com/donate/?hosted_button_id=47UTYVRBDKSTL) | [![paypal](https://puu.sh/IAhtp/3788f3a473.png)](https://www.paypal.com/donate/?hosted_button_id=47UTYVRBDKSTL) |
| :----: | --- |

## Supported firmware versions
You must be running firmware Merlin 384.15/384.13_4 or Fork 43E5 (or later) [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/)

## Installation
Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```sh
/usr/sbin/curl -fsL --retry 3 "https://jackyaz.io/spdMerlin/master/install/spdmerlin.sh" -o /jffs/scripts/spdmerlin && chmod 0755 /jffs/scripts/spdmerlin && /jffs/scripts/spdmerlin install
```

## Usage
### WebUI
spdMerlin can be configured via the WebUI, in the Addons section.

### Command Line
To launch the spdMerlin menu after installation, use:
```sh
spdmerlin
```

If this does not work, you will need to use the full path:
```sh
/jffs/scripts/spdmerlin
```

## Screenshots

![WebUI](https://puu.sh/HSYTU/ed2d2157eb.png)

![CLI](https://puu.sh/HSYRK/aca960d9fb.png)

## Help
Please post about any issues and problems here: [spdMerlin on SNBForums](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=19)

### Scarf Gateway
Installs and updates for this addon are redirected via the [Scarf Gateway](https://about.scarf.sh/scarf-gateway) by [Scarf](https://about.scarf.sh/about). This allows me to gather data on the number of new installations of my addons, how often users check for updates and more. This is purely for my use to actually see some usage data from my addons so that I can see the value provided by my continued work. It does not mean I am going to start charging to use my addons. My addons have been, are, and will always be completely free to use.

Please refer to Scarf's [Privacy Policy](https://about.scarf.sh/privacy) for more information about the data that is collected and how it is processed.
