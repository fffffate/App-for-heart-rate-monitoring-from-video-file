function heart_beat=process_1_callback_FIR(y, fps,L_frames,start_frame,stop_frame,start_frame_timestamp)

set(simple_layout, 'HandleVisibility', 'off');
close all;
set(simple_layout, 'HandleVisibility', 'on');

y_original=y; 
%-------------------------
%Define dialog box 
prompt = {'Enter low cut off:[BPM]','Enter high cut off:[BPM]','Enter BPM Update rate (in seconds):', 'Window length (in seconds)'};
dlg_title = 'Input Parameters';
num_lines = 1;
defaultans = {'40','80','0.25','6'};
Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,Resize);

BPM_L = str2double(answer(1));
BPM_H = str2double(answer(2));
UPDATE_SECONDS = str2double(answer(3));  % [s]   %Time between two frames update (overlap time is difference of update seconds & total window seconds)
WINDOW_SECONDS=str2double(answer(4));  % 6 second window for estimating heart rate once
%L_frames=str2double(answer(5));      %Frames used in FIR filter design (201 frames)
L_frames=str2num(L_frames);
start_frame=str2num(start_frame);
start_frame_timestamp=str2num(start_frame_timestamp)

figure(1);
plot(y_original);
title('Signal before filtering')

[y_filtered,output_frame_indices] = bp_FIR_zero_phase_transients_removed_1(y_original,BPM_L,BPM_H,L_frames,fps,start_frame);

figure(3);
title('dummy')

window_length=round(WINDOW_SECONDS * fps);
update_length=round(UPDATE_SECONDS * fps);
graph_update_speed=0.10;   %seconds

window_start = 0;
total_windows=0;
window_start_dum=window_start;   %dummy var to calc total windows

disp(['Length of filtered signal(frames):' num2str(length(y_filtered))]);

%calculate total number of windows
while(window_start_dum < length(y_filtered)-window_length)
    total_windows=total_windows+1;
    window_start_dum= window_start_dum+update_length;
end
disp(['Total_windows: ' num2str(total_windows)]);

i=1;
while(i <= total_windows)
 
 ynw = y_filtered(window_start+1:window_start+window_length); %for 1st 6 second  window
 window_start= window_start+update_length;  % window start pointer update
  
 segments(i,:)=i;         % for the 3 D plot, axis of segments
 
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
       
       %FFT plot only for 1,20,40,60.. segments 
       if i==1 ||(mod(i,20)==0)     % Every 20 segments i=1,20,40,60..
           figure(4);       
           hold on;
           title('FFT estimation for 1,20,40,60.. segments')
           xlabel('Frequency (BPM)')
           plot(x_scale_bpm,P11);
           xlim([0 200]);
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
           
        if i==1 ||(mod(i,20)==0)     % Every 20 segments i=1,20,40,60..
            figure(5)
            subplot(2,1,1)
            plot(l_bpm,xc)
            title('biased correlation estimation 1,20,40,60.. segments')
            xlabel('lags BPM (samples)')
            xlim([-180 180]);
            hold on;
      %      findpeaks(xc,l_bpm,'MinPeakDistance',15,'MinPeakProminence',0.05,'Annotate','extents')
            subplot(2,1,2)
            plot(l_bpm,xc2)
            title('unbiased correlation estimation 1,20,40,60.. segments')
            xlabel('lags (BPM)(samples)')
            xlim([-180 180]);
            hold on;
       %     findpeaks(xc2,l_bpm)
        end
        
        %---------------------------------------------------------
        
    %  t_from_segments(i)=(WINDOW_SECONDS+(i*UPDATE_SECONDS))/2;
        
    figure(6);
     
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
    pause(graph_update_speed);
    
     t_from_segments(i)=((WINDOW_SECONDS+(i*UPDATE_SECONDS))/2)+start_frame_timestamp;
     i=i+1 ; %count variable

end  

disp(['Total_windows after FFT loop: ' num2str(i)]);
disp(['Start window time (mid): ' num2str(t_from_segments(1))]);
disp(['End window time (mid): ' num2str(t_from_segments(i-1))]);

figure(7)
hold on;
title('Heart rate estimate variation over Time');
xlabel('Time in seconds');
ylabel('Heart rate (BPM)');
plot(t_from_segments,fft_bpm);
ylim([40 100]);
hold off;

figure(8);
hold on;
title('FFT estimate variation over segments');
xlabel('FFT (BPM)');
zlabel('Amplitude');
ylabel('Segments');
meshz(x_scale_fft_array,segments,Y_fft_array);
xlim([0 100]);
hold off;

figure(9);
hold on;
title('Auto corr(unbiased) estimate variation over segments');
xlabel('Lags BPM (in samples)');
zlabel('Amplitude');
ylabel('Segments');
xlim([-200 200]);
meshz(x_scale_auto_corr_array,segments,Y_b_auto_corr_array);
hold off;

disp(['FFT(with zero padding) based bpm:[segment wise]' num2str(round(mean(fft_bpm),1)) ' bpm']);

heart_beat= round(mean(fft_bpm),1);  %for the Auto corr heart beat value or peak
end