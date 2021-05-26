# Jellyfin pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/jellyfin.svg)](https://dash.yunohost.org/appci/app/jellyfin) ![](https://ci-apps.yunohost.org/ci/badges/jellyfin.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/jellyfin.maintain.svg)  
[![Installer Jellyfin avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=jellyfin)

*[Read this readme in english.](./README.md)*
*[Lire ce readme en français.](./README_fr.md)*

> *This package allows you to install Jellyfin quickly and simply on a YunoHost server.
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Vue d'ensemble

Système multimédia qui gère et diffuse vos médias.

**Version incluse:** 10.7.5~ynh2

**Démo :** https://demo.jellyfin.org/stable/web/index.html

## Captures d'écran

![](./doc/screenshots/jellyfin.png)

## Avertissements / informations importantes

* L'app repose sur le serveur LDAP de YunoHost pour gérer les connexions:
  * Les utilisateurs standards doivent avoir la permission `main` ;
  * Les utilisateurs doivent avoir la permission `admin` pour pouvoir accéder au panneau d'administration.

* À partir de la version 10.7.5~ynh2, vous pouvez demander l'ouverture des ports de découverte (1900 et 7359).
Ils facilitent la mise en place de votre système multimédia entre les clients et le serveur.
  * Si vous mettez à jour vers cette version et les suivantes, mettez `discovery: '1'` dans `/etc/yunohost/apps/jellyfin/settings.yml`
si vous voulez que la mise à jour les ouvre pour vous.

## Documentations et ressources

* Site officiel de l'app : https://jellyfin.org
* Documentation officielle utilisateur : https://jellyfin.org/docs/
* Dépôt de code officiel de l'app :  https://github.com/jellyfin/jellyfin
* Documentation YunoHost pour cette app : https://yunohost.org/app_jellyfin
* Signaler un bug: https://github.com/YunoHost-Apps/jellyfin_ynh/issues

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing --debug
or
sudo yunohost app upgrade jellyfin -u https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications:** https://yunohost.org/packaging_apps