# App-for-heart-rate-monitoring-from-video-file
An application to monitor heart rate: Combines matlab GUI model with video processing &amp; theoretically backed Signal processing 
 
 
 My updated list of things to be aware for the operation of software:
 
1- video file names should not include blanks

2- Handbrakecli.exe must be in same folder as videos

3- To run app, Matlab work folder should be different than folder containing source code (simple_layout.m)

4- If running source code (simple_layout.m), videos and Handbrakecli.exe must be in same folder as source code

5- before re-doing Step 2 (converting part of a video to CFR), it is required to perform Step 3 (area cropping with the mouse), so that the temporary file "time_cropped_video.avi" is closed before being overwritten in Step 2.

 
