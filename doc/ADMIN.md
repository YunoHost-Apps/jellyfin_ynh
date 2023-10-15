* The app relies on YunoHost's LDAP server for users to log in:
  * Standard users need the `main` permission;
  * Users with the `admin` permission will have access to the administration panel.

* The app can access YunoHost's multimedia directories:
  
  Choose one of the folders in `/home/yunohost.multimedia/share` upon configuration of your libraries.

* Starting version 10.7.5~ynh2, you can ask for the discovery ports (1900 and 7359) to be opened.

  They ease the setting up of your media center between clients and server.
  * If you are upgrading to this version and above, set `discovery: '1'` in `/etc/yunohost/apps/jellyfin/settings.yml` if you want the upgrade to open them for you.
