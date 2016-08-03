ssid-notifier
============

Script to add an extra Offline SSID when there is no sufficient connection quality to the selected gateway. This SSID is generated from the nodes hostname with the first and last part of the nodename to allow observers to recognise which node is down

### Install

Create a file "modules" with the following content in your <a href="https://github.com/ffac/site/tree/offline-ssid"> site directory:</a>

GLUON_SITE_FEEDS="ssidnotifier"<br>
PACKAGES_SSIDNOTIFIER_REPO=https://github.com/rubo77/gluon-ssid-changer<br>
PACKAGES_SSIDNOTIFIER_COMMIT=84691ba0b6fd70bbe44230e3e922584e37a90fcc<br>
PACKAGES_SSIDNOTIFIER_BRANCH=ssid-notifier<br>

With this done you can add the package `gluon-ssid-notifier` to your `site.mk`

### Dependencies

based on openwrt chaos-calmer, Gluon 2016.1
