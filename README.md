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







