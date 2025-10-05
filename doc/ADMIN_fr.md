# Connexion

L'app repose sur le serveur LDAP de YunoHost pour gérer les connexions:
  * Les utilisateurs standards doivent avoir la permission `main` ;
  * Les utilisateurs doivent avoir la permission `admin` pour pouvoir accéder au panneau d'administration.

# Dossiers multimédias

L'app a accès aux dossiers multimédia de YunoHost. Ces dossiers sont partagés avec d'autres applications pour faciliter l'ajout de fichiers et leur gestion.

Si vous souhaitez les utiliser, indiquez un des sous-dossiers de `/home/yunohost.multimedia/share` comme source lors du paramétrage de vos bibliothèques.


# Ouverture des ports pour une utilisation locale

__APP__ a ses ports de découverte (1900 et 7359) fermés par défaut. Ceux-ci servent à proposer la découverte automatique de votre instance Jellyfin à tout client compatible connecté sur le même réseau (votre réseau local).

Pour pouvoir bénéficier de cette fonctionnalité, vous *pouvez* ouvrir les ports 1900 et 7359 **UDP** si vous êtes sur votre serveur est hébergé chez vous, sur votre réseau local (autrement dit, pas un VPS).