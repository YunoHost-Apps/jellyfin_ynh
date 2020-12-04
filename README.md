# Jellyfin for YunoHost

[![Integration level](https://dash.yunohost.org/integration/jellyfin.svg)](https://dash.yunohost.org/appci/app/jellyfin) ![](https://ci-apps.yunohost.org/ci/badges/jellyfin.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/jellyfin.maintain.svg)  
[![Install Jellyfin with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=jellyfin)

> *This package allows you to install Jellyfin quickly and simply on a YunoHost server.  
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Overview
Jellyfin enables you to collect, manage, and stream your media. Run the Jellyfin server on your system and gain access to the leading free-software entertainment system, bells and whistles included.

**Shipped version:** 10.6.4

## Screenshots

![](https://jellyfin.org/images/screenshots/movie_full.png)

## Demo

* [Official demo](Link to a demo site for this app.)

## Configuration

How to configure this app: From an admin panel, a plain file with SSH, or any other way.

## Documentation

 * Official documentation: Link to the official documentation of this app
 * YunoHost documentation: If specific documentation is needed, feel free to contribute.

## YunoHost specific features

#### Multi-user support

 * Are LDAP and HTTP auth supported? **No**
 * Can the app be used by multiple users? **Yes**

#### Supported architectures

* x86-64 - [![Build Status](https://ci-apps.yunohost.org/ci/logs/jellyfin%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/jellyfin/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/jellyfin%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/jellyfin/)

## Limitations

* Any known limitations.

## Additional information

* Other info you would like to add about this app.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/jellyfin_ynh/issues
 * App website: https://jellyfin.org/
 * Upstream app repository: https://github.com/jellyfin/jellyfin
 * YunoHost website: https://yunohost.org/

---

## Developer info

Please send your pull request to the [testing branch](https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing --debug
or
sudo yunohost app upgrade jellyfin -u https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing --debug
```
