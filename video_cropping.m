function start_frame_timestamp=video_cropping(video_file,start_frame_u,stop_frame_u,L_user)

start_frame_user = str2double(start_frame_u);
stop_frame_user = str2double(stop_frame_u);
L = str2double(L_user);

[filepath,name,ext] = fileparts(video_file)
input_video=strcat(name,ext)
transcoded_segment_of_input_video='time_cropped_video.avi';
fps=30.0  % desired constant frame per second rate (CFR)
cd (filepath)
cd
obj=VideoReader(video_file);

%To get start frame time stamp speciied by user from whole of the video (before taking 100 frames before & after the start,stop frames)
for k=1:obj.NumberOfFrames
  if(k==start_frame_user)
      %start frame time stamp for user time 
       start_frame_timestamp= obj.CurrentTime;
  end
end

%change the start frame to capture 100 frames before and after the strat,
%stop frames specified by the user
start_frame = max (start_frame_user - (L-1)/2, 1)
stop_frame = min (stop_frame_user + (L-1)/2, obj.NumberOfFrames )
stop_frame=max(stop_frame,start_frame);

%put the file path(after 'cd ') where HnadbrakeeCLI.exe is located \\ the
%videos should also be located/copied to the same path
s=sprintf('cd %s',filepath);
system(s);
%delete the previous version of cropped video
s=sprintf('del "%s"',transcoded_segment_of_input_video);
system(s);    
if(start_frame==1)
    s=sprintf('HandBrakeCLI.exe -i %s --start-at frame:%d  --stop-at frame:%d -e x264 --encoder-preset veryfast -q 10 --cfr -r %d -o %s', input_video, start_frame, stop_frame-start_frame+1, fps,transcoded_segment_of_input_video);
    system(s);
else
    s=sprintf('HandBrakeCLI.exe -i %s --start-at frame:%d  --stop-at frame:%d -e x264 --encoder-preset veryfast -q 10 --cfr -r %d -o %s', input_video, start_frame, stop_frame-start_frame, fps,transcoded_segment_of_input_video);
    system(s);
end

obj=VideoReader(transcoded_segment_of_input_video);
display(['total frames: time cropped video : ' num2str(obj.NumberOfFrames)]); 

for k=1:obj.NumberOfFrames
  if(k==start_frame)
      %start frame time stamp for user time 
       start_frame_timestamp= obj.CurrentTime;
  end
mov(k).cdata = read(obj, k);
end
%write each frame from mov array into video with start stop frames
%specified

%point to the start frame of transcoded(time-cropped)video for image cropping tool to work
k=1;
I=mov(k).cdata;

vidObj_crop = VideoWriter('final_video.avi');
open(vidObj_crop);
% Give the user to make the rectangle on the image to Crop image starting 
[J, rect] = imcrop(I);

%Apply the same rectangle to rest of the frames of the whole video 
for k=1:obj.NumberOfFrames   %it reads one frame more
  I = read(obj, k);
  cropped_img = imcrop(I, rect);
  writeVideo(vidObj_crop,cropped_img);
  display(['frames cropped: ' num2str(k)]);
end

close(vidObj_crop);

obj_1=VideoReader('final_video.avi');
display(['total frames: ROI cropped video : ' num2str(obj_1.NumberOfFrames)]); 
