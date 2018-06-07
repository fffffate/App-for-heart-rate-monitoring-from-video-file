function handbrake_CLI_matlab(input_video)
%input_video='vid_002.mp4';
start_frame=1;
stop_frame=600;
transcoded_segment_of_input_video='time_cropped_video.avi';
fps=30.0;  % desired constant frame per second rate (CFR)

stop_frame=max(stop_frame,start_frame);

s=sprintf('cd C:\Users\Rajshekhar\Documents\Project EVM\EVM_Matlab\Simplified Heart rate measure\For Presentation');
system(s);
s=sprintf('del "%s"',transcoded_segment_of_input_video);
system(s);
s=sprintf('HandBrakeCLI.exe -i %s --start-at frame:%d  --stop-at frame:%d -e x264 --encoder-preset veryfast -q 10 --cfr -r %d -o %s', input_video, start_frame, stop_frame-start_frame+1,fps,transcoded_segment_of_input_video);
system(s);

obj=VideoReader(transcoded_segment_of_input_video);
for k=1:obj.NumberOfFrames
  mov(k).cdata = read(obj, k);
end
%write each frame from mov array into video with start stop frames
%specified

%point to the start frame for image cropping tool to work
k=start_frame;
I=mov(k).cdata;

vidObj_crop = VideoWriter('final_video.avi');
open(vidObj_crop);
% Give the user to make the rectangle on the image to Crop image starting 
[J, rect] = imcrop(I);

%Apply the same rectangle to rest of the frames of the whole video 
for k=start_frame:stop_frame
  I = read(obj, k);
  cropped_img = imcrop(I, rect);
  writeVideo(vidObj_crop,cropped_img);
end

close(vidObj_crop);