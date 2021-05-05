# Jellyfin pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/jellyfin.svg)](https://dash.yunohost.org/appci/app/jellyfin) ![](https://ci-apps.yunohost.org/ci/badges/jellyfin.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/jellyfin.maintain.svg)  
[![Installer Jellyfin avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=jellyfin)

*[Read this readme in english.](./README.md)*

> *Ce package vous permet d'installer Jellyfin rapidement et simplement sur un serveur YunoHost.  
Si vous n'avez pas YunoHost, consultez [le guide](https://yunohost.org/#/install) pour apprendre comment l'installer.*

## Vue d'ensemble
Jellyfin vous permet de collecter, gérer et diffuser vos médias. Exécutez le serveur Jellyfin sur votre système et accédez au principal système de divertissement à logiciel libre.

**Version incluse :** 10.7.2

## Captures d'écran

![](https://jellyfin.org/images/screenshots/movie_full.png)

## Démo

* [Démo officielle](https://demo.jellyfin.org/)

## Configuration

Comment configurer cette application : via le panneau d'administration.

## Documentation

 * Documentation officielle : https://jellyfin.org/docs/
 * Documentation YunoHost : Si une documentation spécifique est nécessaire, n'hésitez pas à contribuer.

## Caractéristiques spécifiques YunoHost

#### Support multi-utilisateur

* L'authentification LDAP et HTTP est-elle prise en charge ? **Oui**
* L'application peut-elle être utilisée par plusieurs utilisateurs ? **Oui**

#### Architectures supportées

* x86-64 - [![Build Status](https://ci-apps.yunohost.org/ci/logs/jellyfin%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/jellyfin/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/jellyfin%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/jellyfin/)

## Limitations

* Limitations connues.

## Informations additionnelles

* Autres informations que vous souhaitez ajouter sur cette application.

## Liens

 * Signaler un bug : https://github.com/YunoHost-Apps/jellyfin_ynh/issues
 * Site de l'application : https://jellyfin.org/
 * Dépôt de l'application principale : https://github.com/jellyfin/jellyfin
 * Site web YunoHost : https://yunohost.org/

---

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing --debug
ou
sudo yunohost app upgrade jellyfin -u https://github.com/YunoHost-Apps/jellyfin_ynh/tree/testing --debug
```
