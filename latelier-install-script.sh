#!/bin/bash

parse_success () {
  if [ $1 -eq 0 ]; then
    echo " [INFO] $2 - OK"
  else
    echo " [ERROR] $3 - FAILURE"
  fi
}

           
# home 
cd /home/pi

# install node.js
NODE_MAJOR=20

sudo apt install -y ca-certificates curl gnupg &&
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/nodesource.gpg && 
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list &&
sudo apt -y update &&
sudo apt -y install nodejs &&
sudo apt -y install build-essential

OUT=$?
parse_success $OUT "installed node.js" "node.js installation failed"




sudo apt install -y cmake

OUT=$?
parse_success $OUT "installed cmake" "cmake installation failed"




# delete dirs magic-mirror & venv if exist

if [ -d "magic-mirror" ]; then
	echo " [INFO] Found magic-mirror directory - OK"
	rm -rf magic-mirror
	echo " [INFO] Deleted magic-mirror directory - OK"
fi


if [ -d "venv" ]; then
	echo " [INFO] Found magic-mirror directory - OK"
	rm -rf venv
	echo " [INFO] Deleted magic-mirror directory - OK"
fi



# créer un environnement virtuel python

python3 -m venv --system-site-packages ~/venv

OUT=$?
parse_success $OUT "created python virtual environment" "creating python virtual environment failed"






# - installer du dépôt officiel de MagicMirror
# - se rendre dans le répertoire `magic-mirror`
# - installer les dépendances node sur la base du package.json
#
#    /!\ Attention: éviter d"installer sur la base
#    d"un fichier package-lock.json rovenant d"un 
#    autre type d"appareil, les dépendances node
#    peuvent varier selon le type d"architecture 
#    système, Intel vs. ARM, par exemple

git clone https://github.com/MagicMirrorOrg/MagicMirror.git magic-mirror && 
	cd magic-mirror

OUT=$?
parse_success $OUT "installed MagicMirror" "installing MagicMirror failed"


npm i

OUT=$?
parse_success $OUT "installed MagicMirror node dependencies" "installing node dependencies failed"





# - installer du dépôt latelierco/magic-mirror,
# la branche latelier-complement-fix, ceci avant merge
# dans la branche `main` ( revue d"avant merge restant
# à faire aun 2024-08-26 )
#
# - copier les styles, les images, le fichier de
# configuration ( config.js ), etc.

git clone -b complement-fix https://github.com/latelierco/magic-mirror.git latelier-complement-fix && 
	cp latelier-complement-fix/css/custom.css css/ && \
	cp -R latelier-complement-fix/css/images/ css/ && \
	cp latelier-complement-fix/config/config.js config/

OUT=$?
parse_success $OUT "copied config files to Magic Mirror css and js directories" "copying config files to Magic Mirror css and js directories failed"





# écriture du fix dans le fichier js/main.js
# pour la gestion de plusieurs utilisateurs

sed -n "1,519p" js/main.js > js/main-start.js

OUT=$?
parse_success $OUT "sed 1" "sed 1 failed"

sed -n "520,743p" js/main.js > js/main-end.js

OUT=$?
parse_success $OUT "sed 2" "sed 2 failed"


cat js/main-start.js > js/main.js

OUT=$?
parse_success $OUT "js/main-start.js to js/main.js" "js/main-start.js to js/main.js failed"

cat << EOF >> js/main.js
 
			// L"Atelier fix
			else if (Array.isArray(className) === false) {
				searchClasses = [];
			}
	 
EOF

OUT=$?
parse_success $OUT "fix to js/main.js" "fix to js/main.js failed"



cat js/main-end.js >> js/main.js


OUT=$?
parse_success $OUT "js/main-end.js to js/main.js" "js/main-end.js to js/main.js failed"

rm js/main-start.js js/main-end.js

OUT=$?
parse_success $OUT "removed js/main-start.js and js/main-end.js" "removing js/main-start.js and js/main-end.js failed"



# installation des modules pour l atelier
# ainsi que leurs dépendances node
# respectives

pushd modules && 
	git clone -b python-ready https://github.com/latelierco/magic-mirror-modules.git && 
	mv magic-mirror-modules/* .

OUT=$?
parse_success $OUT "installed L`Atelier / Magic Mirror modules" "installing L`Atelier / Magic Mirror modules failed"



pushd MMM-news-le-monde && 
	npm i && 
	popd

OUT=$?
parse_success $OUT "installed node dependencies for MMM-news-le-monde" "installing node dependencies for MMM-news-le-monde failed"


pushd MMM-generic-welcome && \
	npm i && \
	popd

OUT=$?
parse_success $OUT "installed node dependencies for MMM-generic-welcome" "installing node.js dependencies for MMM-Face-Reco-DNN failed"


pushd MMM-Face-Reco-DNN && \
	npm i

OUT=$?
parse_success $OUT "installed node.js dependencies for MMM-Face-Reco-DNN" "installing node.js dependencies for MMM-Face-Reco-DNN failed"



cp ~/ressources-for-magic-mirror/encodings.pickle ~/magic-mirror/modules/MMM-Face-Reco-DNN/model/

OUT=$?
parse_success $OUT "copied encoding.pickle to MMM-Face-Reco-DNN module" "copying encoding.pickle to MMM-Face-Reco-DNN module failed"




# activer cet environnemnt virtuel
source ~/venv/bin/activate

OUT=$?
parse_success $OUT "python3 env activated" "python3 env activating failed"

pip install -r requirements.txt

OUT=$?
parse_success $OUT "installed python dependencies for MMM-Face-Reco-DNN" "copying python dependencies for MMM-Face-Reco-DNN failed"

popd

deactivate

OUT=$?
parse_success $OUT "python3 env deactivated" "python3 env deactivating failed"



pushd MMM-idf-mobilite && 
	npm i && 
	popd

OUT=$?
parse_success $OUT "installed node.js dependencies for MMM-idf-mobilite" "copying installed node.js dependencies for MMM-idf-mobilite failed"












# installation du backoffice pour 
# la reconnaissance faciale et 
# pour la gestion des utilisateurs
# 
# ------------------------------------
# /!\ Attention: 
# Il faut noter que
# la capture d"image (photos d"utilisateurs)
# ne peut avoir lieu pendant que l"application
# MagicMirror est en cours de fonctionnement :
# la camera (webcam) de l"appareil se trouvant
# mobilisée pour un process ne peut être mobilisée
# pour un autre
# ------------------------------------

pushd MMM-Face-Reco-DNN && 
	git clone https://github.com/latelierco/magic-mirror-backoffice.git


OUT=$?
parse_success $OUT "installed MMM-Face-Reco-DNN backoffice" "installing MMM-Face-Reco-DNN backoffice failed"



pushd magic-mirror-backoffice && 
	npm i && 
	pushd http-service && 
	npm i


OUT=$?
parse_success $OUT "installed MMM-Face-Reco-DNN backoffice node.js dependencies" "installing MMM-Face-Reco-DNN backoffice node.js dependencies failed"



# Demander les fichiers de configuration
# pour firebase à l"admin pour ces modules.
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
#     du backoffice. de façon plus exacte, l"emplacement de fichier devrait être :
#     `/home/pi/magic-mirror/modules/MMM-Face-Reco-DNN/backoffice-magic-mirror/security/firebase-credentials.js`
#     selon l"emplacement de `magic-mirror`
#
#
#
#     par ailleurs, une copie de ces deux fichiers
#     a été placée sur le Drive de L"Atelier
#     dans le répertoire partagé `MIROIR CONNECTE/firebase-credentials`


# startup

cd /home/pi &&
cp magic-mirror/latelier-complement-fix/startup.sh . &&
crontab -l >/tmp/c1 &&
echo '@reboot /home/pi/startup.sh' >>/tmp/c1 &&
crontab /tmp/c1
