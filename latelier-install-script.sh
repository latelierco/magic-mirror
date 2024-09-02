#!/bin/bash



# installer python sur le système

# sudo apt update && \
#   sudo apt install -y python3
# 
# python3 est déjà installé
# avec system update et upgrade
# 
# sudo apt update
# sudo apt upgrade

# install node.js
sudo apt install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt -y update
sudo apt -y install nodejs
sudo apt -y install build-essential

echo ' [INFO] installed node.js - OK'



sudo apt install -y cmake

echo ' [INFO] installed cmake - OK'



# delete dirs magic-mirror & venv if exist

if [ -d 'magic-mirror' ]; then
	echo ' [INFO] Found magic-mirror directory'
	rm -rf magic-mirror
	echo ' [INFO] Deleted magic-mirror directory'
fi


if [ -d 'venv' ]; then
	echo ' [INFO] Found magic-mirror directory'
	rm -rf venv
	echo ' [INFO] Deleted magic-mirror directory'
fi



# créer un environnement virtuel python

python3 -m venv --system-site-packages ~/venv

echo ' [INFO] created python virtual environment - OK'




# - installer du dépôt officiel de MagicMirror
# - se rendre dans le répertoire `magic-mirror`
# - installer les dépendances node sur la base du package.json
#
#    /!\ Attention: éviter d'installer sur la base
#    d'un fichier package-lock.json rovenant d'un 
#    autre type d'appareil, les dépendances node
#    peuvent varier selon le type d'architecture 
#    système, Intel vs. ARM, par exemple

git clone https://github.com/MagicMirrorOrg/MagicMirror.git magic-mirror && 
	cd magic-mirror

echo ' [INFO] installed MagicMirror - OK'

npm i

echo ' [INFO] installed MagicMirror node dependencies - OK'



# - installer du dépôt latelierco/magic-mirror,
# la branche latelier-complement-fix, ceci avant merge
# dans la branche `main` ( revue d'avant merge restant
# à faire aun 2024-08-26 )
#
# - copier les styles, les images, le fichier de
# configuration ( config.js ), etc.

git clone -b complement-fix https://github.com/latelierco/magic-mirror.git latelier-complement-fix && 
	cp -R latelier-complement-fix/css/custom.css 
	latelier-complement-fix/css/images 
	css/ && 
	cp latelier-complement-fix/config/config.js config/

echo ' [INFO] copied config files to Magic Mirror css and js directories - OK'


# écriture du fix dans le fichier js/main.js
# pour la gestion de plusieurs utilisateurs

sed -n '1,519p' js/main.js > js/main-start.js
sed -n '520,743p' js/main.js > js/main-end.js

cat js/main-start.js > js/main.js

cat << EOF >> js/main.js
 
			// L'Atelier fix
			else if (Array.isArray(className) === false) {
				searchClasses = [];
			}
	 
EOF

cat js/main-end.js >> js/main.js
rm js/main-start.js js/main-end.js

echo ' [INFO] copied fix to js/main.js - OK'



# installation des modules pour l atelier
# ainsi que leurs dépendances node
# respectives

pushd modules && 
	git clone -b python-ready https://github.com/latelierco/magic-mirror-modules.git && 
	mv magic-mirror-modules/* .

echo " [INFO] installed L'Atelier / Magic Mirror modules - OK"


pushd MMM-news-le-monde && 
	npm i && 
	popd

echo " [INFO] installed node dependencies for MMM-news-le-monde - OK"


popd && 
	pushd MMM-generic-welcome && 
	npm i



popd && 
	pushd MMM-Face-Reco-DNN && 
	npm i

echo ' [INFO] installed node.js dependencies for MMM-Face-Reco-DNN - OK'


cp ~/ressources-for-magic-mirror/encodings.pickle ~/magic-mirror/modules/MMM-Face-Reco-DNN/model/

echo ' [INFO] copied encoding.pickle to MMM-Face-Reco-DNN module - OK'


# activer cet environnemnt virtuel
source ~/venv/bin/activate

pip install -r requirements.txt && popd

deactivate

echo ' [INFO] installed python dependencies for MMM-Face-Reco-DNN - OK'



pushd MMM-idf-mobilite && 
	npm i && 
	popd

echo ' [INFO] installed node.js dependencies for MMM-idf-mobilite - OK'











# installation du backoffice pour 
# la reconnaissance faciale et 
# pour la gestion des utilisateurs
# 
# ------------------------------------
# /!\ Attention: 
# Il faut noter que
# la capture d'image (photos d'utilisateurs)
# ne peut avoir lieu pendant que l'application
# MagicMirror est en cours de fonctionnement :
# la camera (webcam) de l'appareil se trouvant
# mobilisée pour un process ne peut être mobilisée
# pour un autre
# ------------------------------------

pushd MMM-Face-Reco-DNN && 
	git clone https://github.com/latelierco/magic-mirror-backoffice.git

echo ' [INFO] installed MMM-Face-Reco-DNN backoffice - OK'


pushd magic-mirror-backoffice && 
	npm i && 
	pushd http-service && 
	npm i

echo ' [INFO] installed MMM-Face-Reco-DNN backoffice node.js dependencies - OK'





# Demander les fichiers de configuration
# pour firebase à l'admin pour ces modules.
# 
# Il en existe deux :
#
#   - un  pour le service node.js du mocule MMM-idf-mobilite
#     un répertoire nommé `security` doit être créé à la racine 
#     du module. le fichier `connected-mirror-91cb7-firebase-adminsdk-eh3n0-536f9aa3ae.json`
#     pourra y être placé, une fois remis par un admin
#
#   - un autre fichier, `firebase-credentials.js`, devra être placé
#     dans un répertoire nommé `security` situé à la racine du répertoire 
#     du backoffice. de façon plus exacte, l'emplacement de fichier devrait être :
#     `/home/pi/magic-mirror/modules/MMM-Face-Reco-DNN/backoffice-magic-mirror/security/firebase-credentials.js`
#     selon l'emplacement de `magic-mirror`
#
#
#
#     par ailleurs, une copie de ces deux fichiers
#     a été placée sur le Drive de L'Atelier
#     dans le répertoire partagé `MIROIR CONNECTE/firebase-credentials`