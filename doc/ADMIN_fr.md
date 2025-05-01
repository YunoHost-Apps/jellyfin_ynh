* L'app repose sur le serveur LDAP de YunoHost pour gérer les connexions:
  * Les utilisateurs standards doivent avoir la permission `main` ;
  * Les utilisateurs doivent avoir la permission `admin` pour pouvoir accéder au panneau d'administration.

* L'app a accès aux dossiers multimédia de YunoHost:
indiquez un des dossiers de `/home/yunohost.multimedia/share` comme source lors du paramétrage de vos bibliothèques.

* L'app a ses ports de découverte (1900 et 7359) ouverts par défaut.
Ils aident les clients Jellyfin à détecter le serveur s'il est sur le même réseau.
***Cependant***, si votre serveur n'a qu'une connexion directe aux Internets (comme un VPS), vous devriez fermer ces deux ports et `Ignorer` les avertissements correspondants affichés par le Diagnostic.
