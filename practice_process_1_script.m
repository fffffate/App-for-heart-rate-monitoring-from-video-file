clear all;
close all;
clc;

video='final_video.avi';

start_frame=1;

y_original=acquire_1(video); 

BPM_L = 40;
BPM_H = 80;
WINDOW_SECONDS = 6;
L = 6;
L_frames=201;   %used in the FIR filter
UPDATE_SECONDS=0.25  ;      %Time between two frames update (overlap time is difference of update seconds & total window seconds)
graph_update_speed=0.01;   %seconds

fps=30;

figure(1);
plot(y_original);
title('Signal before filtering')

[y_filtered,output_frame_indices] = bp_FIR_zero_phase_transients_removed_1(y_original,BPM_L,BPM_H,L_frames,fps,start_frame);

figure(3);
title('dummy')

window_length=round(WINDOW_SECONDS * fps);
update_length=round(UPDATE_SECONDS * fps);

window_start = 0;
total_windows=0;
window_start_dum=window_start;   %dummy var to calc total windows

disp(['length(y_filtered):' num2str(length(y_filtered))]);

%calculate total number of windows
while(window_start_dum < length(y_filtered)-window_length)
    total_windows=total_windows+1;
    window_start_dum= window_start_dum+update_length;
    end

disp(['total_windows: ' num2str(total_windows)]);

i=1;
while(i <= total_windows)
 win_start_array(i)=window_start;
 ynw = y_filtered(window_start+1:window_start+window_length); %for 1st 6 second  window
 window_start= window_start+update_length;  % window start pointer update
  
 segments(i,:)=i;         % for the 3 D plot, axis of segments
 
  
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
       x_scale_bpm = (Fs*(0:(Len/2))/Len)*60;      %points on x scale bpm
       x_scale_fft_array(i,:)=x_scale_bpm;     %store values for 3 d plot  
       [max_value, max_index] = max(P11);
       axis([0 max_index 0 max_value]);
       
       [pks, locs] = findpeaks(P11(index_range));
       [max_peak_v, max_peak_i] = max(pks);
       max_f_index = index_range(locs(max_peak_i));
       
       frequency_fft = max_f_index*Fs/Len ;      %in hz
       fft_bpm(i)=frequency_fft*60;     %convert to bpm from hz
       
       if(i==1)|| i==55 || i==110 || i==220
           figure(4);       %FFT plot only for 1st,55,110,220 windows
           hold on;
           title('FFT estimation for plot only for 1st,55,110,220 window segments')
           xlabel('Frequency (BPM)')
           ylabel('Amplitude')
           plot(x_scale_bpm,P11);
           xlim([40 200])
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
         %Auto correlation segment wise-------------------------------------

        Len_ynw=length(ynw);
        x2=[ynw,zeros(1,Len_ynw-1)];
        xc=fftshift(ifft(abs(fft(x2)).^2));
        l=-(Len_ynw-1):1:(Len_ynw-1);
        for counter=1:length(l)
        if(l(counter)<0)
           l_bpm(counter)=fix((fps/l(counter))*60);          %to account for the round off error
        else
            l_bpm(counter)=fix((fps/l(counter))*60);          %BPM = ( fps / Lags (samples) )  * 60
        end
        end
        
        xc2=xc./(Len_ynw-abs(l));
        Y_b_auto_corr_array(i,:)=xc;  
        Y_ub_auto_corr_array(i,:)=xc2;  
        x_scale_auto_corr_array(i,:)=l_bpm; 
           
          if i==1 || i==20 || i==40 || i==60
            figure(9)
            subplot(2,1,1)
            plot(l_bpm,xc)
            title('biased correlation estimation 1,20,40,60 segment')
            xlabel('lags (samples BPM)')
            xlim([-200 200]);
            hold on;
        %   findpeaks(xc,l,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents')
            subplot(2,1,2)
            plot(l_bpm,xc2)
            title('unbiased correlation estimation')
            xlabel('lags (samples')
            hold on;
     %       findpeaks(xc2,l)
        end
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
    ylim([40 100]);
    xlabel('Windows segments');
    ylabel('Heart rate (BPM)');
    hold off;    
    
    drawnow
    refresh
 %   pause(graph_update_speed);
 
 
     t_from_segments(i)=(WINDOW_SECONDS+(i*UPDATE_SECONDS))/2;
     i=i+1 ; %count variable

end  

disp(['total_windows after FFT,etc. loop: ' num2str(i)]);
disp(['start window time: ' num2str(t_from_segments(1))]);
disp(['end window time: ' num2str(t_from_segments(i-1))]);   

figure(11)
hold on;
title('Heart rate estimate variation over Time');
xlabel('Time in seconds');
ylabel('Heart rate (BPM)');
plot(t_from_segments,fft_bpm);
ylim([40 100]);
hold off;

figure(12)
hold on;
title('FFT estimate variation over segments');
xlabel('FFT (in BPM)');
zlabel('Amplitude');
ylabel('Segments');
xlim([40 100])
meshz(x_scale_fft_array,segments,Y_fft_array);
hold off;

figure(13);
hold on;
title('Auto corr (biased) estimate variation over segments');
xlabel('Lags BPM (in samples)');
zlabel('Amplitude');
ylabel('Segments');
xlim([-200 200]);
meshz(x_scale_auto_corr_array,segments,Y_b_auto_corr_array);
hold off;

disp(['FFT(with zero padding) based bpm:[segment wise]' num2str(round(mean(fft_bpm),1)) ' bpm']);

heart_beat= round(mean(fft_bpm),1);  %for the Auto corr heart beat value or peak