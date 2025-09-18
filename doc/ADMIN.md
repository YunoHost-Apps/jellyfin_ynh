# Connection

The app relies on YunoHost's LDAP server for users to log in:
  * Standard users need the `main` permission;
  * Users with the `admin` permission will have access to the administration panel.

# Multimedia folders

The app can access YunoHost's multimedia directories. These directories are shared with other applications to facilitate files upload and management.

If you want to use them, choose one of the subfolders in `/home/yunohost.multimedia/share` upon configuration of your libraries.

# Opening ports for local usage

__APP__ has its discovery ports (1900 and 7359) closed by default. These are used to offer automatic discovery of your Jellyfin instance to any compatible client connected on the same network (your local network).
To take advantage of this feature, you *can* open ports 1900 and 7359 **UDP** if your server is hosted at home, on your local network (in other words, not a VPS).