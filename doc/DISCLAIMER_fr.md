* L'app repose sur le serveur LDAP de YunoHost pour gérer les connexions:
  * Les utilisateurs standards doivent avoir la permission `main` ;
  * Les utilisateurs doivent avoir la permission `admin` pour pouvoir accéder au panneau d'administration.

* L'app a accès aux dossiers multimédia de YunoHost:
indiquez un des dossiers de `/home/yunohost.multimedia/share` comme source lors du paramétrage de vos bibliothèques.

* À partir de la version 10.7.5~ynh2, vous pouvez demander l'ouverture des ports de découverte (1900 et 7359).
Ils facilitent la mise en place de votre système multimédia entre les clients et le serveur.
  * Si vous mettez à jour vers cette version et les suivantes, mettez `discovery: '1'` dans `/etc/yunohost/apps/jellyfin/settings.yml`
si vous voulez que la mise à jour les ouvre pour vous.
