ssid-notifier
============

Script to add an extra SSID when there is no suffic sufficient connection to the selected Gateway.

It is quite basic, it just checks the Quality of the Connection and decides if a change of the SSID is necessary.

Create a file "modules" with the following content in your <a href="https://github.com/ffac/site/tree/offline-ssid"> site directory:</a>

GLUON_SITE_FEEDS="ssidnotifier"<br>
PACKAGES_SSIDNOTIFIER_REPO=https://github.com/rubo77/gluon-ssid-changer<br>
PACKAGES_SSIDNOTIFIER_COMMIT=671cb66fe191c02d76ace426caab170a312cd480<br>
PACKAGES_SSIDNOTIFIER_BRANCH=ssid-notifier<br>

With this done you can add the package gluon-ssid-notifier to your site.mk

This branch of the skript contains the the ssid-notifier version for the current master based on openwrt chaos-calmer upcoming 2016.1
