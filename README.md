Exemplar
========

An iOS project for implementing Object Removal by Exemplar-based Inpainting

#BACKGROUND
****

This project is based on an algorithm for removing large, unwanted objects from digital images. This technique was proposed in [*Object Removal by Exemplar-Based Inpainting*](http://research.microsoft.com/pubs/67273/criminisi_cvpr2003.pdf) by A. Criminisi, P.Perez and K.Toyama, back in 2003.

You may also check [this explanation](http://pages.cs.wisc.edu/~yhong/yhong_report.pdf) for a little less mathematically involved description of the algorithm.

There are quite a few implementations of Exemplar-based Inpainting available on the web, some of which are:

* [A Matlab based implementation of inpainting](http://www.cc.gatech.edu/~sooraj/inpainting/)
* [A Qt based implementation (and a pretty heavy source code)](http://www.kitware.com/source/home/post/49)
* [Another Qt based implementation](https://github.com/fooble/Inpaint)
 
I'm sure there are many others, but most of them seem to be Matlab or Qt based. I've found no implementation of Exemplar-based Inpainting targeted for a mobile device, perhaps because of the heavy computation involved, which often lengthens the inpainting process to 3 - 4 minutes or more for a 3 MegaPixel image. 

While this would surely be unacceptable for most mobile users, there are optimizations applicable on the original algorithm which can speed up the inpainting process considerably.

The objective of this project is to implement an optimized version of 'Object Removal by Exemplar-based Inpainting', which can be used on at least 4/5 MegaPixel images with a run time of less than a minute (on iPhone 5 and higher).

There are still some bugs to be fixed on the slow implementation of this algorithm (which is *very* slow, at the moment). While I'm working on it, I'd appreciate your contribution in optimizing or bug-fixing this code.

****

##How to run the code:

Download the code as a zip file or use: `git clone https://github.com/agnivsen/Exemplar.git`

Run the code using XCODE 5.0.

Make sure you have openCV installed and the binaries are being linked properly. If you donot have openCV installed in your mac, [check this](http://docs.opencv.org/doc/tutorials/introduction/ios_install/ios_install.html  "OpenCV's Documentation for installation with iOS").

****

##How to run the code from the front end (a walk through the screenshots)

###1. Start the application

<img src="https://github.com/agnivsen/Exemplar/blob/master/ScreenShots/SS1.png?raw=true" width="200px" height="320px" />

###2. Load the image

<img src="https://github.com/agnivsen/Exemplar/blob/master/ScreenShots/SS2.png?raw=true" width="200px" height="320px" />

###3. Go into the Exemplar link

<img src="https://github.com/agnivsen/Exemplar/blob/master/ScreenShots/SS3.png?raw=true" width="200px" height="320px" />

###4. Select the exemplar tab

<img src="https://github.com/agnivsen/Exemplar/blob/master/ScreenShots/SS4.jpg?raw=true" width="200px" height="320px" />

###5. Drag and select the region you want to remove.

<img src="https://github.com/agnivsen/Exemplar/blob/master/ScreenShots/SS5.jpg?raw=true" width="200px" height="320px" />

(Do not mark the region very close to the image boundary. Boundary check not yet implemented)

###5. Wait for the process to complete (which may take quite a while)

<img src="https://github.com/agnivsen/Exemplar/blob/master/ScreenShots/SS6.jpg?raw=true" width="200px" height="320px" />


<img src="https://github.com/agnivsen/Exemplar/blob/master/ScreenShots/SS7.JPG?raw=true" width="200px" height="320px" />
*This image is definitely not perfect. Working on fixing the final image quality*

