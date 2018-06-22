function y = acquire(video_file)

if ischar(video_file),
    display(['Loading file ' video_file]);
    v = VideoReader(video_file);
else
    v = video_file;
end

numFrames = v.NumberOfFrames;

display(['Total frames: ' num2str(numFrames)]);
Resize='on';
%Choose color plane 
prompt = {'Enter 1/2/3 for Color Plane : 1. RED 2.GREEN 3.BLUE'};
dlg_title = 'Color Plane (RGB) choice';
num_lines = 1;
defaultans = {'2'};

answer = inputdlg(prompt,dlg_title,num_lines,defaultans,Resize);
  
color_ch = str2double(answer(1));

y = zeros(1, numFrames);
for i=1:numFrames,
    display(['Processing ' num2str(i) '/' num2str(numFrames)]);
    frame = read(v, i);
    
    if color_ch==1
        colorPlane = frame(:, :, 1);
    elseif color_ch==2
        colorPlane = frame(:, :, 2);
    elseif color_ch==3
        colorPlane = frame(:, :, 3);
    end
    
    y(i) = sum(sum(colorPlane)) / (size(frame, 1) * size(frame, 2));   
end

display('Signal acquired.');
display(' ');
display(['Sampling rate is ' num2str(v.FrameRate) '. You can now run process(your_signal_variable, ' num2str(v.FrameRate) ')']);

end

