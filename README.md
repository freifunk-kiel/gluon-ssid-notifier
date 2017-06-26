ssid-notifier
============

A script to add an extra Offline SSID when there is no sufficient connection quality to the selected gateway. This SSID is generated from the nodes hostname with the first and last part of the nodename to allow observers to recognise which node is down.


### Install

Create a file "modules" with the following content in your <a href="http://gluon.readthedocs.io/en/latest/user/site.html#modules">site directory</a>:

    GLUON_SITE_FEEDS="ssidnotifier"
    PACKAGES_SSIDNOTIFIER_REPO=https://github.com/freifunk-kiel/gluon-ssid-notifier
    PACKAGES_SSIDNOTIFIER_COMMIT=1eff2701ebe0495d1894a1c4e59aebdce22f599a<--hier die aktuelle commit ID aus dem Repository eintragen
    PACKAGES_SSIDNOTIFIER_BRANCH=ssid-notifier

With this done you can add the package `gluon-ssid-notifier` to your `site.mk`


### Dependencies

Gluon 2017.1, based on lede.
