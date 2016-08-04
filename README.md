ssid-notifier
============

Script to add an extra Offline SSID when there is no sufficient connection quality to the selected gateway. This SSID is generated from the nodes hostname with the first and last part of the nodename to allow observers to recognise which node is down

### Install

Create a file "modules" with the following content in your <a href="http://gluon.readthedocs.io/en/v2016.1.5/user/site.html#modules">site directory</a>:

GLUON_SITE_FEEDS="ssidnotifier"<br>
PACKAGES_SSIDNOTIFIER_REPO=https://github.com/freifunk-kiel/gluon-ssid-notifier<br>
PACKAGES_SSIDNOTIFIER_COMMIT=0123456789abcdef0123456789abcdef01234567<--hier die aktuelle commit ID aus dem Repository eintragen<br>
PACKAGES_SSIDNOTIFIER_BRANCH=ssid-notifier<br>

With this done you can add the package `gluon-ssid-notifier` to your `site.mk`

### Dependencies

Gluon 2016.1, based on openwrt chaos-calmer
