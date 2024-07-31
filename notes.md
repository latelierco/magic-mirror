
# MagicMirror - L'Atelier

doc. versions :

	- 2024-07-31

---


## MagicMirror

### Install

repo address : https://github.com/tm-wong/MagicMirror/tree/upgrade-proposed-l_atelier

active branch : upgrade-proposed-l_atelier

```bash

	git clone git@github.com:tm-wong/MagicMirror.git
	git checkout upgrade-proposed-l_atelier
	npm install

```

### Run

```bash

	# in dev mode
	npm start dev

	# in plain mode
	npm start

```


---



## MMM-Face-Reco-DNN


### Install


#### Install the module

repo address : https://github.com/tm-wong/MMM-Face-Reco-DNN

active branch : upgrade-proposed-l_atelier


```bash


	git clone git@github.com:tm-wong/MMM-Face-Reco-DNN.git
	git checkout upgrade-proposed-l_atelier


```


Go to MMM-Face-Reco-DNN.js and copy configuration

```bash


	cd /home/pi/magic-mirror/modules/MMM-Face-Reco-DNN/


```


```JavaScript


	// in file MMM-Face-Reco-DNN/MMM-Face-Reco-DNN.js

	{
	    // Logout 15 seconds after user was not detecte anymore, if they will be detected between this 15
	    // Seconds, they delay will start again
	    logoutDelay: 15000,
	    // How many time the recognition starts, with a RasPi 3+ it would be good every 2 seconds
	    checkInterval: 2000,
	    // Module set used for when there is no face detected ie no one is in front of the camera
	    noFaceClass: 'noface',
	    // Module set used for when there is an unknown/unrecognised face detected
	    unknownClass: 'unknown',
	    ...
	}


```

And in MagicMirror configuration, paste and modify configuration for MMM-Face-Reco-DNN module as follows :

```bash


	cd /home/pi/MagicMirror


```


In file /home/pi/MagicMirror/config/config.js, add the MMM-Face-Reco-DNN module.

```JavaScript


	modules: [
		{
			module: "MMM-Face-Reco-DNN",
			config: {}
		},
		{
			module: "updatenotification",
			position: "top_bar"
		},
		...
	]


```

In the config object of MagicMirror config, paste the config code snippet taken from MMM-Face-Reco-DNN.js
and moify value for `logoutDelay` to `3000` modify value for `checkInterval` to `500` or `250`


```JavaScript


	{
	    // Logout 15 seconds after user was not detecte anymore, if they will be detected between this 15
	    // Seconds, they delay will start again
	    logoutDelay: 3000,
	    // How many time the recognition starts, with a RasPi 3+ it would be good every 2 seconds
	    checkInterval: 500,
	    // Module set used for when there is no face detected ie no one is in front of the camera
	    noFaceClass: 'noface',
	    // Module set used for when there is an unknown/unrecognised face detected
	    unknownClass: 'unknown',
	    ...
	}


```


#### Install the module dependencies


```bash


	# creating a python virtual environment
	python3 -m venv --system-site-packages ~/python-env

	# initialize python virtual environment
	source ~/python-env/bon/activate


	# install python dependencies

	## installing dlib on raspberry
	## doc. ref. : https://gist.github.com/ageitgey/629d75c1baac34dfa5ca2a1928a7aeaf

	sudo apt install cmake

	cd ~/
	mkdir dlib-build
	cd dlib-build

	git clone https://github.com/davisking/dlib.git dblib-build
	cd dblib-build
	mkdir build; cd build; cmake ..; cmake --build .
	cd ..
	python3 setup.py install

	pip install -r requirements.txt

	# this will install :
	# - opencv-python
	# - face_recognition
	# - pynput

	# run tools
	mkdir model dataset


```

---


### Configure Facial Recognition

```bash


	# init python environment
	source python-env/bin/activate

	# go to module directory
	cd /home/pi/magic-mirror/modules/mmm-face-reco-dnn

```


#### take user snapshots

```bash


	# run face photo capture
	# and take some 10 or 12 prtrait photo shots
	# 
	# - front (plain)
	# - a bit to the left
	# - a bit to the right
	# - a bit looking up
	# - a bit looking down
	# - a bit to the left looking up
	# - a bit to the right looking up
	# - a bit to the left looking up
	# - a bit to the right looking down
	# - etc. 
	# 
	# please note, command MUST be run with option `-u` or `--user`, like below :
	# 
	# a directory named after the `user` will be created
	# if it doesn't already exist and snapshots will be stored in it
	# 
	# the key to press to take a snapshot is the `space` bar

	python3 tools/takesPictures.py --user mickey_da_mouse


```


#### build encoding with pretrained model

```bash


	python3 tools/encode.py

	# or use node
	npm run encode


```


#### test faciale recognition

```bash


	python3 tools/recognition.py

	# for window monitoring of capture during recognition, use option `-o` or `--output`
	python3 tools/recognition.py --output 1

	# or use node
	npm run recognition


```

```bash


	# output should look like this :

	{"status": "loading encodings + face detector..."}
	{"status": "starting video stream..."}
	{"resolution": [1920, 1080]}
	{"processWidth": 500}
	{"login": {"names": ["mickey_da_mouse"]}}
	{"logout": {"names": ["mickey_da_mouse"]}}
	{"login": {"names": ["mickey_da_mouse"]}}
	...


```


---


### Run Magic Mirror

```bash


	cd /home/pi/MagiMirror

	# in dev mode
	npm start dev

	# in plain mode
	npm start


```
