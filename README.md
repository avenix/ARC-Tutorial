# Tutorial on Activity Recognition with Matlab

This tutorial implements the Activity Recognition Chain in Matlab.
![Activity Recognition Chain](images/ARC.png)

## Application
In this example application, we analyse the gait of a cow to detect lameness. We use a sample data set of a healthy cow and another data set from a lame cow. The code I provide segments the individual strides using a peak detector and trains a machine learning classifier to classify between normal and abnormal strides. 

## Setup
* install Matlab
* `git clone git@github.com:avenix/ARC-Tutorial.git`
* in Matlab, `addpath(genpath('./'))`
* in Matlab, run `main.m`.
* this code uses the mRMR library for feature selection. If you get an error 'estpab function not found', then you need to:
```
cd libraries/mRMR_0.9/mi/
mex -setup C++ 
makeosmex
```

	
*Note: if set a breakpoint and run the code line by line, then you can see the runtime values by hovering the mouse on top of the variables.*

## References
You will find more information on Andreas Bulling's article: https://dl.acm.org/citation.cfm?id=2499621
and a few example applications:
1. https://www.mdpi.com/2414-4088/2/2/27
2. https://dl.acm.org/citation.cfm?id=3267267

## Contact
Juan Haladjian
haladjia@in.tum.de
