clear all;
clc;

video='final_video.avi';

start_frame=1;

y_original=acquire_1(video); 

BPM_L = 40;
BPM_H = 100;
BPM_SAMPLING_PERIOD = 0.5; % [s] Time between heart rate estimations
WINDOW_SECONDS = 10;
L = 6;
L_frames=201;   %used in the FIR filter
UPDATE_SECONDS=0.05  ;      %Time between two frames update (overlap time is difference of update seconds & total window seconds)
graph_update_speed=0.01;   %seconds

fps=30;

[y_filtered,output_frame_indices] = bp_FIR_zero_phase_transients_removed_1(y_original,BPM_L,BPM_H,L_frames,fps,start_frame);
%y = yf((fps * max(FILTER_STABILIZATION_TIME, CUT_START_SECONDS))+1:size(yf, 2));

window_length=round(WINDOW_SECONDS * fps);
update_length=round(UPDATE_SECONDS * fps);
graph_update_speed=0.10;   %seconds

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
       ynw_win(i,:)=ynw;     %store window value of ynw
       final_data_plot=ynw;
       final_data_plot=final_data_plot-mean(final_data_plot);
       
       Fs = fps;            % Sampling frequency                    
       T = 1/Fs;             % Sampling period       
       Len = 5000;             % Length of signal (for zero padding also in the signal)
       fl = BPM_L / 60; fh = BPM_H / 60;
       index_range=floor(fl*Len/Fs)+1:ceil(fh*Len/Fs)+1;
       Y_fft=fft(final_data_plot,Len);
 %      Y_fft_array(i,:)=Y_fft;
       P2 = abs(Y_fft/Len);
       P11 = P2(1:Len/2+1);
       P11(2:end-1) = 2*P11(2:end-1);
       Y_fft_array(i,:)=P11;             %store values for 3 d plot
       x_scale_fft = Fs*(0:(Len/2))/Len;      %points on x scale 0 - L/2
       x_scale_fft_array(i,:)=x_scale_fft;     %store values for 3 d plot  
       [max_value, max_index] = max(P11);
       axis([0 max_index 0 max_value]);
       
       [pks, locs] = findpeaks(P11(index_range));
       [max_peak_v, max_peak_i] = max(pks);
       max_f_index = index_range(locs(max_peak_i));
       
       frequency_fft = max_f_index*Fs/Len ;      %in hz
       fft_bpm(i)=frequency_fft*60;     %convert to bpm from hz
       
       if(i==2)
           figure(4);       %FFT plot only for 1st window
           hold on;
           title('FFT estimation for 1st segment')
           xlabel('Frequency (hertz)')
           plot(x_scale_fft,P11);
           hold off;
       end
       
       if (i>7)
           if(abs(mean(fft_bpm(i-6:i-1))-fft_bpm(i))>=std(fft_bpm))
               fft_bpm(i)=mean(fft_bpm(i-6:i));
           end
                      
       if(abs(fft_bpm(i-1)-fft_bpm(i)))>=5
           fft_bpm(i)=mean(fft_bpm(i-1:i));
       end
       end
       hold off;
        
       
        %----------------------------------------------------
    
        
      t_from_segments(i)=(WINDOW_SECONDS+(i*UPDATE_SECONDS))/2;
        
    figure(10);
    
    title('Heart rate estimate variation over different window segments');
    hold on;
    plot([1:i], fft_bpm(1:i),'g');
    hold on;
  %  plot([1:i], peak_detect_bpm(1:i),'b');
    hold on;
 %   plot([1:i], auto_corr_1st_peak_bpm(1:i),'m');
 %   hold on;
  %  plot([1:i], auto_corr_bpm_unbiased(1:i),'b');
    hold on;
 %   plot([1:i], fft_bpm_tukey(1:i),'r');
    hold on;
    legend('Heart Rate wrt timed segments' );
    xlim([0 total_windows+1])            % use length(orig_y)/fps*WINDOW_SECONDS+5 here
    ylim([40 140]);
    xlabel('Windows segments');
    ylabel('Heart rate (BPM)');
    hold off;    
    
    drawnow
    refresh
    pause(graph_update_speed);
    
     t_from_segments(i)=(WINDOW_SECONDS+(i*UPDATE_SECONDS))/2;
     i=i+1 ; %count variable
     window_start= window_start+update_length;  % window start pointer update
end  

figure(11)
hold on;
title('Heart rate estimate variation over Time');
xlabel('Time in seconds');
ylabel('Heart rate (BPM)');
plot(t_from_segments,fft_bpm);
ylim([40 140]);
hold off;

figure(12)
hold on;
title('FFT estimate variation over segments');
xlabel('FFT (in Hz)');
zlabel('Amplitude');
ylabel('Segments');
waterfall(Y_fft_array);
%xlim([min(x_scale_fft) max(x_scale_fft)]);
hold off;

figure(13);
s = spectrogram(y_filtered,hann(window_length),window_length-update_length,Len);
spectrogram(y_filtered,'yaxis')

disp(['FFT(with zero padding) based bpm:[segment wise]' num2str(round(mean(fft_bpm),1)) ' bpm']);

heart_beat= round(mean(fft_bpm),1);  %for the Auto corr heart beat value or peak