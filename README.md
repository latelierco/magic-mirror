# Projet Miroir Connecté


## Raspberry System


### Matériel 

Raspberry Pi5


### Operating System

Raspberry OS - Debian Bookworm


### Utility install

- vim
- sublimetext, si nécessaire


## Installation du dispositif Miroir Connecté


### script d'installation

Un script d'installation permet, à date (2024-09), d'installer le dispositif dans son ensemble. Celui-ci est situé à la racine de ce dépôt et se nomme `latelier-install-script.sh`.

Il y est question d'exécuter les choses suivantes;

- installation de Node.js (v20.x)
- installation de cmake (pour le build de Dlib, voir plus bas)
- création de l'environnement virtuel de python3, déjà présent, quant à lui, et livré (v3.9 ou v3.10) avec Raspberry OS
- clone du dépôt MagicMirror v2.28.0
- clone du dépôt latelierco/magic-mirror, qui contient les fichiers de configuration et fixes prévus pour le bon fonctionnement tel qu'envisagé pour L'Atelier
	- installation et application de ces configurations et fixes
- clone du dépôt contenant les modules MagicMirror prévus pour le projet Miroir Connecté de L'Atelier, il y en a 4 à date (2024-09) qui sont les suivants :

 - MMM-news-le-monde
 - MMM-idf-mobilite
 - MMM-generic-welcome
 - MMM-Face-Reco-DNN
 	- magic-mirror-backoffice

- installation du script de démarrage du miroir connecté


### Démarrage du miroir connecté

La mémoire du système Raspberry étant soumise à quelqu'épreuves au cours de l'exécution, nos avons pris le parti de rebooter l'appareil toutes les 3 heures. Une instruction dans crontab super utilisateur a été configurée de la façon suivante :

```shell
sudo crontab -e
```

```
0 */3 * * * sudo reboot
```

Le démarrage de l'application, quant à lui, est inscrit dans la crontab de l'utilisateur `pi` de la façon qui suit :

```shell
crontab -e
```

```
@reboot /home/pi/startup.sh
```

Le script `startup.sh` étant responsable du lancement de l'application.


## Les modules exemples


Deux modules ont été mis en place à titre d'exemple pour d'intégration avec le dispositif

### Le module de news, contenu générique (MMM-news-le-monde)

Il s'agit d'un affichage de brèves d'actualité en fil continu sur la base d'un flux RSS : https://www.lemonde.fr/rss/en_continu.xml.


### Le module Ile de France mobilités, contenu personnalisé (MMM-idf-mobilité)

Un module qui retourne le calcul de l'itinéraire vers `home` de l'utilisateur par rapport à l'emplacement des locaux de L'Atelier.

Ce calcul, à ce stade, ne concerne que les trajets en Ile de France (Ile de France Mobilités)

Le point d'entrée principal est le suivant :

https://prim.iledefrance-mobilites.fr/marketplace/v2/navitia/


Ce dernier est construit sur la base de l'application Navitia (doc. ref. : https://doc.navitia.io/#getting-started)


## Les modules essentiels


D'autres modules essentiels ont été intégrés de façon à mettre le dispositif en valeur :


### (MMM-hello-user)

Un module qui affiche `Bonjour < user >`.


### (MMM-generic-welcome)

Un module qui affiche du contenu administré depuis le backoffice du miroir connecté.


### (MMM-Face-Reco-DNN)

Le module de reconnaissance faciale à proprement parler. Il repose sur l'utilisation de scripts python :
- `recognition.py` qui effectue le travail de reconnaissance faciale en temps réel
- `encode.py` qui effectue le build du modèle pour le parsing des visages, ce script est appelé à chaque fois que l'on sauvegarde les photos d'un utilisateur depuis le backoffice.

Le modèle de calcul est un fichier binaire qui est consulté par le script `recognition.py` lorsqu'un visage est détecté. C'est dans celui-ci que sont stockés les `landscapes` des visages de chaque utilisateur enregistré.

Enfin, le fichier `haarcascade_frontalface_default.xml` sert, quant à lui, de modèle de calcul pour la détection faciale, étape qui précède la reconnaissance.


## Firebase / firestore db

La documentation sur firestore est foisonnante et donc ici uniquement quelques détails sur la configuration actuelle.

Firestore dépend de règles d'accès pour la lecture et l'écriture en base. À date (2024-09), ces règles sont les suivantes :

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // This rule allows anyone with your Firestore database reference to view, edit,
    // and delete all data in your Firestore database. It is useful for getting
    // started, but it is configured to expire after 30 days because it
    // leaves your app open to attackers. At that time, all client
    // requests to your Firestore database will be denied.
    //
    // Make sure to write security rules for your app before that time, or else
    // all client requests to your Firestore database will be denied until you Update
    // your rules
    //
    match /{document=**} {
     allow read, write, delete: if request.auth != null;
    }
    match /{document=**} {
      allow read : if request.time < timestamp.date(2200, 8, 31);
    }
  }
}
```

Celles-ci permettent de lire toute donnée de façon universelle (jusqu'en l'an 2200, après lequel, je ne peux garantir être joignable par téléphone). En revanche, les opérations d'écriture, `write` et `delete` ne sont permises que si l'utilisateur est authentifié.

Les règles firestore pourront, à terme, être très largement étoffées, ceci de façon à garantir la normalité du modèle de données et affiner les permissions d'accès.




## TODOs


/!\ Attention :

Des scripts de lancement du backoffice sont encore à prévoir. Ils peuvent être inscrits dans la crontab de l'utilisateur `pi` tout comme le script de lancement.

Leur contenu pourra ressembler à quelque chose comme ce qui suit :

pour le front de ce backoffice :

```shell
cd /home/pi/magic-mirror/modules/MMM-Face-Reco-DNN/magic-mirror-backoffice/ && npx http-server -c-1 dist/
```

pour le service noe associé :

```shell
cd /home/pi/magic-mirror/modules/MMM-Face-Reco-DNN/magic-mirror-backoffice/http-service && npm start
```



/!\ Attention :

Il conviendra peut-être d'apporter des modifications à la configuration de ce service (tout comme au dispositif) MagicMirror pour les logs soient inscrits dans le répertoire /var/log/magic-mirror (répertoire à créer)


/!\ Attention :

Les dépôts magic-mirror.git, magic-mirror-modules.git et magic-mirror-backoffice.git sont en version de développement (`dev`) et donc, ne sont ni taggés, ni mergés dans `main` pour release, puisqu'il conviendra sans doute d'apporter au projet quelques retouches avant de passer en version v1.0.0.


/!\ Attention :

Le module dépend dépend d'un node_helper pour son accès à Firebase (firestore database) ce qui, après réflexion est une erreur de conception, dans la mesure où nous aurions pu d'une part nous contenter d'une implémantation front, et d'une autre, mettre en oeuvre une implémentation front qui prend en charge les modifications de contenu en temps réél tel que le permet Firebase/firestore (doc ref. : https://firebase.google.com/docs/firestore/query-data/listen).


/!\ Attention :

Le répertoire `dataset` contient les répertoires où sont stockées les photos des utilisateurs du miroir connecté qui servent de dataset pour le build de calcul de la reconnaissance faciale. Or, il conviendra certainement à terme, que ces répertoires soient nommés sur la base d'un ID Firebase ou d'un uuid plut^ot qu'un slug du prénom de l'utilisateur (`Jean-Pierre` --> `jean-pierre`, `François` --> `francois`, caractères latin vers caractère ASCII).

Le problème se pose notamment lorsque l'on met à jour le prénom de l'utilisateur, si un utilisateur `Elizabeth`, par exemple, préfère être appelé `Betty`, l'application ne saurait plus dans quel répertoire trouver ses images.

Un fix rapide consisterait à commenter la mise à jour du slug lorsqu'est mis à jour son prénom. Mais à terme, un véritable ID, hash ou identifiant unique nous parait être la meilleure solution (pour les homonymes, notamment).


## Autres point à noter


/!\ Attention :

Le dispositif MagicMirror est prévu pour fonctionner avec des modules. Pour chacun d'entre eux une configuration dans le fichier qui porte le même nom que le module lui-même.

Cependant, un autre snippet de configuration est à placer dans le fichier de configuration principal MagicMirror, `config/config.js`. La configuration dont tient compte MagicMirror est donc cette dernière.

Il peut être prévu de factoriser ces choses, ceci pour les rendre plus simples à exploiter.


/!\ Attention:

Le dispositif de reconnaissance faciale est un merge de deux projets, l'un pour la reconnaissance faciale à proprement parler et l'autre pour la gestion multi-utilisateurs.

Pour chacun des autres modules, il nous fait inscrire dans le fichier de configuration principal, `config/config.js`, les classes correspondantes au type d'affichage souhaité :

- `noface`, pour le cas où aucun visage n'est détecté
- `unknow`, pour le cas où des visages sont détectés mais pas reconnus
- `know`, pour le cas où des visages sont détectés et reconnus
- `default`, affichage quoique soit la situation
- `everyone`, affichage qu'importe qui est détecté
- `always`, affichage à tout moment
- utilisateur spécifique _< nom, slug ou ID utilisateur >_, la dénomination choisie pour le nom de l'utilisateur spécifique, qu'il s'agisse d'un slug ou bien d'un hash ou ID unique

La documentation de référence pour cette configuration se trouve sur le dépôt suivant :

https://github.com/nischi/MMM-Face-Reco-DNN



## Annexes


### Emplacements de module sur MagicMirror

doc. ref. : https://forum.magicmirror.builders/topic/286/regions


Le fichier `magic-mirror-postions-and-regions.png` fait une représentation des différentes zones d'affichage sur le miroir.

On peut y voir les zones suivantes :
- `top_bar` et `bottom_bar` en gris clair
- `top_left` et `bottom_left` en rouge
- `top_center` et `bottom_center` en bleu
- `top_right` et `bottom_right` en vert
- `upper_third` en jaune
- `middle_center` en bleu cyan
- `lower_third` en magenta




### Calculateur Ile-de-France Mobilités - Messages Info Trafic (v2)

doc. ref. : https://prim.iledefrance-mobilites.fr/apis/idfm-navitia-line_reports-v2

Example query :

```shell
curl -i -H 'apiKey: < _api key_ > ' \
'https://prim.iledefrance-mobilites.fr/marketplace/v2/navitia/journeys?from=< _longitude_ >;< _latitude_ > &max_duration=< max duration >'
```


```shell
curl -i -H 'apiKey: xyz' 'https://prim.iledefrance-mobilites.fr/marketplace/v2/navitia/journeys?from=2.3157235656261714;48.95300712760794&max_duration=2000'

curl -X 'GET' \
  'https://prim.iledefrance-mobilites.fr/marketplace/v2/navitia/journeys?from=2.3425639124365905%3B48.86061050382764&to=2.315689371572526%3B48.95302396272498&datetime=20240802T1100&datetime_represents=departure&max_nb_transfers=2&max_duration_to_pt=600&data_freshness=realtime&max_duration=4500' \
  -H 'apiKey: xyz' \
  -H 'accept: application/json'

curl -X 'GET' \
  'https://prim.iledefrance-mobilites.fr/marketplace/v2/navitia/disruptions' \
  -H 'apiKey: xyz' \
  -H 'accept: application/json'

curl -X GET \
	'https://prim.iledefrance-mobilites.fr/marketplace/v2/navitia/disruptions/0001be24-508a-11ef-a8d9-0a58a9feac02' \
	-H 'apiKey: xyz' \
	-H 'accept: application/json'
```
