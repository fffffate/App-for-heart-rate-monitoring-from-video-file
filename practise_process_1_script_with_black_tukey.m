clear all;
clc;

video='final_video.avi';

start_frame=1;

y_original=acquire_1(video); 

BPM_L = 40;
BPM_H = 100;
BPM_SAMPLING_PERIOD = 0.15; % [s] Time between heart rate estimations
WINDOW_SECONDS = 6;
L = 6;
L_frames=201;   %used in the FIR filter
UPDATE_SECONDS=0.25  ;      %Time between two frames update (overlap time is difference of update seconds & total window seconds)
graph_update_speed=0.01;   %seconds

fps=30;

[y_filtered,output_frame_indices] = bp_FIR_zero_phase_transients_removed_1(y_original,BPM_L,BPM_H,L_frames,fps,start_frame);
%y = yf((fps * max(FILTER_STABILIZATION_TIME, CUT_START_SECONDS))+1:size(yf, 2));

% Some initializations and precalculations
num_window_samples = round(WINDOW_SECONDS * fps);
bpm_sampling_period_samples = round(BPM_SAMPLING_PERIOD * fps);
num_bpm_samples = floor((length(y_filtered) - num_window_samples) / bpm_sampling_period_samples);

window_length=round(WINDOW_SECONDS * fps);
update_length=round(UPDATE_SECONDS * fps);

window_start = 0;
i=1;

total_windows=0;
window_start_dum=window_start;   %dummy var to calc total windows

%calculate total number of windows
while(window_start_dum < length(y_filtered)-window_length)
    total_windows=total_windows+1;
    window_start_dum= window_start_dum+update_length;
end

while(window_start < length(y_filtered)-window_length)
 w_dummy(i) =window_start+window_length;
 ynw = y_filtered(window_start+1:window_start+window_length); %for 1st 6 second  window
 frame_numbers=start_frame+1:start_frame+length(ynw);   %for x axis 
 
 
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
       
       if (i>7)
           if(abs(mean(fft_bpm(i-6:i-1))-fft_bpm(i))>=std(fft_bpm))
               fft_bpm(i)=mean(fft_bpm(i-6:i));
           end
                      
       if(abs(fft_bpm(i-1)-fft_bpm(i)))>=5
           fft_bpm(i)=mean(fft_bpm(i-1:i));
       end
       end
       hold off;
        
       
 %Auto correlation segment wise-------------------------------------

        Len_ynw=length(ynw);
        x2=[ynw,zeros(1,Len_ynw-1)];
        xc=fftshift(ifft(abs(fft(x2)).^2));
        l=-(Len_ynw-1):1:(Len_ynw-1);
        
        xc2=xc./(Len_ynw-abs(l));
        if i==1 || i==55 || i==110 || i==220
            figure(1)
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
         
       index=floor(length(xc)/2)+1:length(xc);
       [pks, locs] = findpeaks(xc(index));
       [max_peak_v, max_peak_i] = max(pks);    % get the 2nd highest peak of auto corr graph
       max_f_index = locs(max_peak_i);
       figure(20)
       if(mod(i,2)==0)
       findpeaks(xc(index))
       hold on;
       end
       auto_corr_peak = fps/max_f_index ;      %in hz % convert the scale on x axis 
       if (auto_corr_peak*60>BPM_H || auto_corr_peak*60<BPM_L)
           auto_corr_1st_peak_bpm(i)=auto_corr_1st_peak_bpm(i-1);
       else
           auto_corr_1st_peak_bpm(i)=auto_corr_peak*60;     %convert to bpm from hz
       end
    
       %----STD DEV Error probability correction in experiment 
       % For auto_corr_1st_peak_bpm
       
       if (i>7)
        if(abs(mean(auto_corr_1st_peak_bpm(i-6:i-1))-auto_corr_1st_peak_bpm(i))>=std(auto_corr_1st_peak_bpm))
               auto_corr_1st_peak_bpm(i)=mean(auto_corr_1st_peak_bpm(i-6:i));
        end
                      
        if(abs(auto_corr_1st_peak_bpm(i-1)-auto_corr_1st_peak_bpm(i)))>=5
           auto_corr_1st_peak_bpm(i)=mean(auto_corr_1st_peak_bpm(i-1:i));
        end
       end
       
       %-- STD DEV For auto_corr_bpm_biased
       if (i>7)
        if(abs(mean(auto_corr_bpm_biased(i-6:i-1))-auto_corr_bpm_biased(i))>=std(auto_corr_bpm_biased))
               auto_corr_bpm_biased(i)=mean(auto_corr_bpm_biased(i-6:i));
        end
                      
        if(abs(auto_corr_bpm_biased(i-1)-auto_corr_bpm_biased(i)))>=5
           auto_corr_bpm_biased(i)=mean(auto_corr_bpm_biased(i-1:i));
        end
       end
       
        %----------------------------------------------------
        
  %Auto correlation BLACKMAN TUKEY window wise-------------------------------------       
 %find the blackman tukey by 
 %1.apply -30,30 window on xc (auto-corr) sample 
 %2.find fft then find highest freq.
            
            len_auto_corr=length(xc);
            tukey_win_len=60;    % -30 to +30 sample size window
            tukey_update_len=40;   %overlap of 20 samples
            tukey_win_start=window_start;
            j=1;    %counter for saving fft of all tukey segments
            fft_bpm_tukey_segments_add=0;
            
            while(tukey_win_start<len_auto_corr-tukey_win_len)
                 y_tukey_win = xc(tukey_win_start+1:tukey_win_start+tukey_win_len); %from the 360 sample auto corr window [xc], extract 60 sample with overlap of 20 samples
                 tukey_win_start= tukey_win_start+tukey_update_len;
               %  y_tukey_win_ham=y_tukey_win.*hamming(tukey_win_len);
                 y_tukey_win_ham=y_tukey_win;    %no hamming window
                 %perform FFT on ham window 
          
                   %y_tukey_win_ham;
                   
                   Fs = fps;            % Sampling frequency                    
                   T = 1/Fs;             % Sampling period       
                   Len = 5000;             % Length of signal (for zero padding also in the signal)
                   fl = BPM_L / 60; fh = BPM_H / 60;
                   index_range=floor(fl*Len/Fs)+1:ceil(fh*Len/Fs)+1;
                   Y_fft_tukey=fft(y_tukey_win_ham,Len);
                   P2 = abs(Y_fft_tukey/Len);
                   P11 = P2(1:Len/2+1);
                   P11(2:end-1) = 2*P11(2:end-1);
                   x_scale_fft = Fs*(0:(Len/2))/Len;      %points on x scale 0 - L/2
                   [max_value, max_index] = max(P11);
                   axis([0 max_index 0 max_value]);
                                                   
                   if i==1 
                        figure(15);       %FFT plot only for 1st window of tukey
                        hold on;
                        title('FFT estimation for 1st segment of tukey')
                        xlabel('Frequency (hertz)')
                        plot(x_scale_fft,P11);
                        hold off;
                   end
                   [pks, locs] = findpeaks(P11(index_range));
                   [max_peak_v, max_peak_i] = max(pks);
                   max_f_index = index_range(locs(max_peak_i));

                   freq_fft_tukey = max_f_index*Fs/Len     %in hz
                   if isempty(freq_fft_tukey)
                        fft_bpm_tukey_segments(j)=fft_bpm_tukey_segments(j-1);
                   else
                        fft_bpm_tukey_segments(j)=freq_fft_tukey*60     %convert to bpm from hz
                        j=j+1
                   end
                   hold off;                                             
            end
 
       fft_bpm_tukey(i)=mean(fft_bpm_tukey_segments);
         
 %Peak detection segment wise---------------------------------------
       if i==1                                   %plot only for 1st window
            figure(5);
            hold on;
            title('Peak detection for 1st segment')
            xlabel('Frames')
            xlim([min(frame_numbers) max(frame_numbers)]);
            hold on;
            plot(frame_numbers,ynw);
            [pks,locs_peaks,w,p]=findpeaks(ynw,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents');
            %hold on;
            findpeaks(ynw,frame_numbers,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents')
            hold off;
       end
       [pks,locs_peaks,w,p]=findpeaks(ynw,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents');
        meanPeaks_dist=mean(diff(locs_peaks));
        heart_rate=meanPeaks_dist/fps;
        peak_detect_bpm(i)=heart_rate*60;
       
    figure(10);
     
    
    title('Heart rate estimate variation over different window segments');
    hold on;
    plot([1:i], fft_bpm(1:i),'g');
    hold on;
  %  plot([1:i], peak_detect_bpm(1:i),'b');
    hold on;
    plot([1:i], auto_corr_1st_peak_bpm(1:i),'m');
    hold on;
  %  plot([1:i], auto_corr_bpm_unbiased(1:i),'b');
    hold on;
 %   plot([1:i], fft_bpm_tukey(1:i),'r');
    hold on;
    legend('FFT','Auto corr(1st peak based)', 'Auto corr(unbaised)');
    xlim([0 total_windows+1])            % use length(orig_y)/fps*WINDOW_SECONDS+5 here
    ylim([BPM_L BPM_H]);
    xlabel('Windows segments');
    ylabel('Heart rate (BPM)');
    hold off;    
    
    drawnow
    refresh
    pause(graph_update_speed);
    
     
     i=i+1 ; %count variable
     window_start= window_start+update_length;  % window start pointer update
end  

%{
figure(20);
threshold=10 ; %filter out spikes with +/- 10BPM difference
f = fit(fft_bpm,[1 i],'lowess');
plot(f);
hold on;
%plot(fit(peak_detect_bpm),'lowess');
hold on;
%plot(fit(auto_corr_bpm_biased),'lowess');
hold off;
%}
 
%-Peak detect heart rate estimation for whole signal-------

figure(6);
xlim([min(output_frame_indices) max(output_frame_indices)]);
plot(output_frame_indices,y_filtered)
hold on;
title('Peak detection whole video signal')
xlabel('Frames');
ylabel('Amplitude');
[pks,locs_peaks,w,p]=findpeaks(y_filtered,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents');
findpeaks(y_filtered,output_frame_indices,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents')

meanPeaks_dist_whole_signal=mean(diff(locs_peaks));
heart_rate=meanPeaks_dist_whole_signal/fps;
peak_detect_bpm_whole_signal=heart_rate*60;

%Display final mean values of HR estimate -------------------------
%disp(['Auto correlation(biased)  based bpm:[segment wise]' num2str(mean(auto_corr_bpm_biased)) ' bpm']);
disp(['Auto correlation(unbiased)  based bpm:[segment wise]' num2str(round(mean(auto_corr_bpm_unbiased),1)) ' bpm']);
%disp(['Peak detection  based bpm: [segment wise]' num2str(mean(peak_detect_bpm)) ' bpm']);
disp(['FFT(with zero padding) based bpm:[segment wise]' num2str(round(mean(fft_bpm),1)) ' bpm']);
disp(['Auto-corr tukey method) based bpm:[segment wise]' num2str(round(mean(fft_bpm_tukey),1)) ' bpm']);

heart_beat= round(mean(fft_bpm),1);  %for the Auto corr heart beat value or peak
