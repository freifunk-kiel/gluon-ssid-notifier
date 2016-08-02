ssid-notifier
============

Script to add an extra SSID when there is no suffic sufficient connection to the selected Gateway.

It is quite basic, it just checks the Quality of the Connection and decides if a change of the SSID is necessary.

Create a file "modules" with the following content in your <a href="https://github.com/ffac/site/tree/offline-ssid"> site directory:</a>

GLUON_SITE_FEEDS="ssidnotifier"<br>
PACKAGES_SSIDNOTIFIER_REPO=https://github.com/ffac/gluon-ssid-notifier.git<br>
PACKAGES_SSIDNOTIFIER_COMMIT=cc650fa8432c9f368e36cd60b7b1217b34d60c38<br>
PACKAGES_SSIDNOTIFIER_BRANCH=chaos-calmer<br>

With this done you can add the package gluon-ssid-notifier to your site.mk

This branch of the skript contains the the ssid-notifier version for the current master based on openwrt chaos-calmer (upcoming 2016.1)
