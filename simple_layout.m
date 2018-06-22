
function varargout = simple_layout(varargin)
% SIMPLE_LAYOUT MATLAB code for simple_layout.fig
%      SIMPLE_LAYOUT, by itself, creates a new SIMPLE_LAYOUT or raises the existing
%      singleton*.
%
%      H = SIMPLE_LAYOUT returns the handle to a new SIMPLE_LAYOUT or the handle to
%      the existing singleton*.
%
%      SIMPLE_LAYOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMPLE_LAYOUT.M with the given input arguments.
%
%      SIMPLE_LAYOUT('Property','Value',...) creates a new SIMPLE_LAYOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simple_layout_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simple_layout_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simple_layout

% Last Modified by GUIDE v2.5 22-Jun-2018 13:56:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simple_layout_OpeningFcn, ...
                   'gui_OutputFcn',  @simple_layout_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before simple_layout is made visible.
function simple_layout_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simple_layout (see VARARGIN)

% Choose default command line output for simple_layout
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes simple_layout wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = simple_layout_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1

% --- Executes during object creation, after setting all properties.
function output1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bpm_sampling_period_Callback(hObject, eventdata, handles)
% hObject    handle to bpm_sampling_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bpm_sampling_period= str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of bpm_sampling_period as text
%        str2double(get(hObject,'String')) returns contents of bpm_sampling_period as a double


% --- Executes during object creation, after setting all properties.
function bpm_sampling_period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpm_sampling_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function bpm_h_Callback(hObject, eventdata, handles)
% hObject    handle to bpm_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bpm_h= str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of bpm_h as text
%        str2double(get(hObject,'String')) returns contents of bpm_h as a double


% --- Executes during object creation, after setting all properties.
function bpm_h_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpm_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function bpm_l_Callback(hObject, eventdata, handles)
% hObject    handle to bpm_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bpm_l= str2double(get(hObject,'String'));

% Hints: get(hObject,'String') returns contents of bpm_l as text
%        str2double(get(hObject,'String')) returns contents of bpm_l as a double


% --- Executes during object creation, after setting all properties.
function bpm_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpm_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%---------------------------------------------------------------------------------------------

% --- Executes on button press in video_select.
function video_select_Callback(hObject, eventdata, handles)
% hObject    handle to video_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName, FilePath] = uigetfile({'*.mp4';'*.avi';'*.mp3';'*.*'},...
    'Select the video to be Analyzed');
if isequal(FileName,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(FilePath, FileName)])
end
%ExPath=fullfile(FilePath, FileName)
%[filepath,name,ext] = fileparts(fullfile(FilePath, FileName))

set(handles.video_select,'String',fullfile(FilePath, FileName));  %only keep the name of the file + extension of file, assuming file is in same path

%see video for start and stop frame using Video Viewer app in MATLAB 
%Enter the start and stop frames in the dialog box appearing

% --- Executes on button press in video_viewer.
function video_viewer_Callback(hObject, eventdata, handles)

implay;
% Put the name of the video file to be analyzed
%or copy and rename the video file into thie current folder of this MATLAB
%file


% --- Executes on button press in crop_video.
function crop_video_Callback(hObject, eventdata, handles)

video_file=get(handles.video_select, 'String');
start_frame=get(handles.start_frame_select, 'String');  
stop_frame=get(handles.stop_frame_select, 'String');
L_user=get(handles.L_select, 'String');

start_frame_timestamp=video_cropping(video_file,start_frame,stop_frame,L_user);
set(handles.crop_video,'String',start_frame_timestamp);



function aquire_f_output_graphs_Callback(hObject, eventdata, handles)

start_frame_timestamp=get(handles.crop_video,'String');
start_frame=get(handles.start_frame_select, 'String');
brightness = acquire_1('final_video.avi');
%Next 3 lines just to get fps of video
video_file=get(handles.video_select, 'String');

%obj=VideoReader(video_file);

fps=30;    % DESIRED FPS from HANDBRAKE

%s_p=str2double(get(handles.bpm_sampling_period));
%bpm_h=str2double(get(handles.bpm_h));
%bpm_l=str2double(get(handles.bpm_l));
start_frame=get(handles.start_frame_select, 'String');  
stop_frame=get(handles.stop_frame_select, 'String');
L_frames=get(handles.L_select, 'String');
heart_beat=practise_process_1_only_fft(brightness,fps,L_frames,start_frame,stop_frame,start_frame_timestamp);
set(handles.output1,'string',heart_beat);

function output1_Callback(hObject, eventdata, handles)
% hObject    handle to output1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output1 as text
%        str2double(get(hObject,'String')) returns contents of output1 as a double


% --- Executes during object creation, after setting all properties.
function start_frame_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_frame_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function stop_frame_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stop_frame_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function L_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function start_frame_select_Callback(hObject, eventdata, handles)
% hObject    handle to start_frame_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start_frame_select as text
%        str2double(get(hObject,'String')) returns contents of start_frame_select as a double


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over L_select.

function stop_frame_select_Callback(hObject, eventdata, handles)
% hObject    handle to stop_frame_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stop_frame_select as text
%        str2double(get(hObject,'String')) returns contents of stop_frame_select as a double


function L_select_Callback(hObject, eventdata, handles)
% hObject    handle to L_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L_select as text
%        str2double(get(hObject,'String')) returns contents of L_select as a double


% --- Executes on button press in select_handbrake_folder.
function select_handbrake_folder_Callback(hObject, eventdata, handles)
% hObject    handle to select_handbrake_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in instruction_button.
function instruction_button_Callback(hObject, eventdata, handles)
% hObject    handle to instruction_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'1- Video file names should not include blanks' '2- Handbrakecli.exe must be in same folder as videos'...
    '3- To run app, Matlab work folder should be different than folder containing source code (simple_layout.m)'... 
    '4- If running source code (simple_layout.m), videos and Handbrakecli.exe must be in same folder as source code'...
    '5- Before re-doing Step 2 (converting part of a video to CFR), it is required to perform Step 3 (area cropping with the mouse), so that the temporary file "time_cropped_video.avi" is closed before being overwritten in Step 2.'},'Instruction List','help');


% --- Executes on key press with focus on instruction_button and none of its controls.
function instruction_button_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to instruction_button (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
