#!/bin/bash



# installer python sur le système

sudo apt update && \
  sudo apt install -y python3


# créer un environnement virtuel python

python3 -m venv --system-site-packages ~/my-python-env


# activer cet environnemnt virtuel
source ~/my-python-env/bin/activate




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
  cd magic-mirror &&
  npm i



# - installer du dépôt latelierco/magic-mirror,
# la branche latelier-complement-fix, ceci avant merge
# dans la branche `main` ( revue d'avant merge restant
# à faire aun 2024-08-26 )
#
# - copier les styles, les images, le fichier de
# configuration ( config.js ), etc.

git clone -b complement-fix git@github.com:latelierco/magic-mirror.git latelier-complement-fix &&
  cp -R latelier-complement-fix/css/custom.css \
  latelier-complement-fix/css/images \
  css/ && \
  cp latelier-complement-fix/config/config.js config/



# écriture du fix dans le fichier js/main.js
# pour la gestion de plusieurs utilisateurs

head -n 519 js/main.js > js/main-new.js && \
  cat << EOF >> js/main-new.js
  
      // L'Atelier fix
      else if (Array.isArray(className) === false) {
        searchClasses = [];
      }
  
EOF

tail -n 520 js/main.js >> js/main-new.js && \
  mv js/main-new.js js/main.js



# installation des modules pour l atelier
# ainsi que leurs dépendances node
# respectives

pushd modules && \
  git clone -b repo-structure-evol https://github.com/latelierco/magic-mirror-modules.git && \
  mv magic-mirror-modules/* .


pushd MMM-Face-Reco-DNN && \
  npm i && \
  popd


pushd MMM-idf-mobilite && \
  npm i && \
  popd



# installation des modules pour l atelier

pushd modules && \
  git clone -b repo-structure-evol https://github.com/latelierco/magic-mirror-modules.git && \
  mv magic-mirror-modules/* .




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

pushd MMM-Face-Reco-DNN && \
  git clone https://github.com/latelierco/magic-mirror-backoffice.git


pushd magic-mirror-backoffice && \
  npm i && \
  pushd http-service && \
  npm i



# retour au répertoire de racine
# de l'application

popd && \
  popd && \
  popd && \
  popd


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
