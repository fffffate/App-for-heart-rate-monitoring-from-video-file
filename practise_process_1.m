function heart_beat=process_1_callback_FIR(y, fps,L_user,start_frame,stop_frame)

y_original=y; 
%-------------------------
%Define dialog box 
prompt = {'Enter low cut off:[BPM]','Enter high cut off:[BPM]','Enter BPM Update rate (in seconds):', 'Window length'};
dlg_title = 'Input Parameters';
num_lines = 1;
defaultans = {'40','100','2','6'};
Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,Resize);
  
BPM_L = str2double(answer(1));
BPM_H = str2double(answer(2));
UPDATE_SECONDS = str2double(answer(3));  % [s]   %Time between two frames update (overlap time is difference of update seconds & total window seconds)
WINDOW_SECONDS=str2double(answer(4));  % 6 second window for estimating heart rate once
L_frames=str2num(L_user);      %Frames used in FIR filter design (201 frames)
       
start_frame=str2num(start_frame);

%-------------------------
%BPM_L = 40;
%BPM_H = 100;
%BPM_SAMPLING_PERIOD = 0.5; % [s] Time between heart rate estimations
%WINDOW_SECONDS = 6;
%L = 6;
%L_frames=201;   %used in the FIR filter

graph_update_speed=1;   %seconds


[y_filtered,output_frame_indices] = bp_FIR_zero_phase_transients_removed_1(y_original,BPM_L,BPM_H,L_frames,fps,start_frame);
%y = yf((fps * max(FILTER_STABILIZATION_TIME, CUT_START_SECONDS))+1:size(yf, 2));

% Some initializations and precalculations
%num_window_samples = round(WINDOW_SECONDS * fps);
%bpm_sampling_period_samples = round(BPM_SAMPLING_PERIOD * fps);
%num_bpm_samples = floor((length(y_filtered) - num_window_samples) / bpm_sampling_period_samples);
fl = BPM_L / 60; fh = BPM_H / 60;

window_length=round(WINDOW_SECONDS * fps);
update_length=round(UPDATE_SECONDS * fps);

window_start = 0;
i=1;
start_frame=min(output_frame_indices);
total_windows=0;
window_start_dum=window_start;   %dummy var to calc total windows

%calculate total number of windows
while(window_start_dum < length(y_filtered)-window_length)

    total_windows=total_windows+1;
    window_start_dum= window_start_dum+update_length;

end

while(window_start < length(y_filtered)-window_length)
 
 ynw = y_filtered(window_start+1:window_start+window_length); %for 1st 6 second  window
 
 window_start= window_start+update_length;
 
       %FFT analysis segment wise-----------------------------------------
       final_data_plot=ynw;
       final_data_plot=final_data_plot-mean(final_data_plot);
       Fs = fps;            % Sampling frequency                    
       T = 1/Fs;             % Sampling period       
       Len = 5000;             % Length of signal (for zero padding also in the signal)
       fl = BPM_L / 60; fh = BPM_H / 60;
       index_range=floor(fl*Len/Fs)+1:ceil(fh*Len/Fs)+1;
       Y_fft=fft(final_data_plot,Len);
       P2 = abs(Y_fft/Len);
       P11 = P2(1:Len/2+1);
       P11(2:end-1) = 2*P11(2:end-1);
       x_scale_fft = Fs*(0:(Len/2))/Len;      %points on x scale 0 - L/2
       
       [max_value, max_index] = max(P11);
       axis([0 max_index 0 max_value]);
       if i==1
            figure(4);       %FFT plot only for 1st window
            hold on;
            title('FFT estimation for 1st segment')
            xlabel('Frequency (hertz)')
            plot(x_scale_fft,P11);
            hold off;
       end
       [pks, locs] = findpeaks(P11(index_range));
       [max_peak_v, max_peak_i] = max(pks);
       max_f_index = index_range(locs(max_peak_i));
       
       frequency_fft = max_f_index*Fs/Len ;      %in hz
       fft_bpm(i)=frequency_fft*60;     %convert to bpm from hz
       hold off;
        
       
 %Auto correlation segment wise-------------------------------------

        Len=length(ynw);
        x2=[ynw,zeros(1,Len-1)];
        xc=fftshift(ifft(abs(fft(x2)).^2));
        l=-(Len-1):1:(Len-1);
       
        xc2=xc./(Len-abs(l));
        if i==1
            figure(7)
            subplot(2,1,1)
            plot(l,xc)
            title('biased correlation estimation 1st segment')
            xlabel('lags (samples)')
            hold on;
            findpeaks(xc,l,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents')
            subplot(2,1,2)
            plot(l,xc2)
            title('unbiased correlation estimation')
            xlabel('lags (samples')
            hold on;
            findpeaks(xc2,l)
        end
        [pksh,lcsh_b] = findpeaks(xc,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents');
         auto_corr_bpm_biased(i) = (mean(diff(lcsh_b))/fps)*60 ;  %calculate auto corr biased for this segment
         [pksh,lcsh_ub] = findpeaks(xc2);
         auto_corr_bpm_unbiased(i) = (mean(diff(lcsh_ub))/fps)*60 ;  %calculate auto corr unbaised for this segment
        
 %Peak detection segment wise---------------------------------------
   
       [pks,locs_peaks,w,p]=findpeaks(ynw,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents');
        meanPeaks_dist=mean(diff(locs_peaks));
        heart_rate=meanPeaks_dist/fps;
        peak_detect_bpm(i)=heart_rate*60;
       
    figure(10);
        
    title('Heart rate estimate variation over different window segments');
    hold on;
    plot([1:i], fft_bpm(1:i),'g','LineWidth', 2);
    hold on;
    plot([1:i], peak_detect_bpm(1:i),'r','LineWidth', 2);
    hold on;
    plot([1:i], auto_corr_bpm_biased(1:i),'b','LineWidth', 2);
    hold on;
    plot([1:i], auto_corr_bpm_unbiased(1:i),'y','LineWidth', 2);
    hold on;
    legend('FFT','Peak detection','Auto_corr (biased)', 'Auto corr(unbaised)');
    xlim([0 total_windows+1])            % use length(orig_y)/fps*WINDOW_SECONDS+5 here
    ylim([BPM_L BPM_H]);
    xlabel('Windows segments');
    ylabel('Heart rate (BPM)');
    hold off;    
    
    drawnow
    refresh
    pause(graph_update_speed);
    
     
     i=i+1 ; %count variable
end  

 
%-Peak detect heart rate estimation for whole signal-------

figure(6);
xlim([min(output_frame_indices) max(output_frame_indices)]);
plot(output_frame_indices,y_filtered)
hold on;
title('Peak detection whole video signal')
xlabel('Frames');
ylabel('Amplitude');
[pks,locs_peaks,w,p]=findpeaks(y_filtered,output_frame_indices,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents');
findpeaks(y_filtered,output_frame_indices,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents')

meanPeaks_dist_whole_signal=mean(diff(locs_peaks));
heart_rate=meanPeaks_dist_whole_signal/fps;
peak_detect_bpm_whole_signal=heart_rate*60

%Display final mean values of HR estimate -------------------------
disp(['Auto correlation(biased)  based bpm:[segment wise]' num2str(mean(auto_corr_bpm_biased)) ' bpm']);
disp(['Auto correlation(unbiased)  based bpm:[segment wise]' num2str(mean(auto_corr_bpm_unbiased)) ' bpm']);
disp(['Peak detection  based bpm: [segment wise]' num2str(mean(peak_detect_bpm)) ' bpm']);
disp(['FFT(with zero padding) based bpm:[segment wise]' num2str(mean(fft_bpm)) ' bpm']);

heart_beat= mean(fft_bpm);  %for the Auto corr heart beat value or peak
