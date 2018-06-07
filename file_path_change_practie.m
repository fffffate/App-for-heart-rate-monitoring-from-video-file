[FileName, FilePath] = uigetfile({'*.mp4';'*.avi';'*.mp3';'*.*'},...
    'Select the video to be Analyzed');
if isequal(FileName,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(FilePath, FileName)])
end
FilePath
cd 'C:\Users\Rajshekhar\Documents\Project EVM\EVM_Matlab\Simplified Heart rate measure\Handbrake and Videos\'
cd (FilePath)