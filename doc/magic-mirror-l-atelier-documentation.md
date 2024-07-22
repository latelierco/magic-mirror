# Magic Mirror Doc


numpy==1.26.4

pip install "numpy<1.26.4" --force-reinstall
pip install opencv-contrib-python

sudo apt install qtwayland5

sudo apt install libxcb-xinerama0
sudo apt install qt6-wayland


model = cv2.face.LBPHFaceRecognizer_create(threshold=thresh)

recognizer = cv2.face.LBPHFaceRecognizer_create()

recognizer = cv2.face.LBPHFaceRecognizer_create()

export FACE_USERS=theo

MMM-Facial-Recognition-OCV3



## Magic Mirror - Positions

doc. ref.: https://forum.magicmirror.builders/topic/286/regions

image : magic-mirror-postions-and-regions.png

```

	In case one wants to know where the various regions are. Missing are the fullscreen_below and fullscreen_above as those cover the whole screen, one under everything else and the other above.

		- top_bar and bottom_bar are light gray
		- top_left and bottom_left are red
		- top_center and bottom_center are blue
		- top_right and bottom_right are green
		- upper_third is yellow
		- middle_center is cyan
		- lower_third is magenta

	All these regions will resize as needed.

```