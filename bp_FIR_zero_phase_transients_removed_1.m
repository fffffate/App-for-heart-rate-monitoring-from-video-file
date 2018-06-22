function [y,output_frame_indices]= bp_FIR_zero_phase_transients_removed_1(x,bpm_low,bpm_high,L,fps,start_frame)
%function [y] = bp_FIR_zero_phase_transients_removed(x,bpm_low,bpm_high,L,fps,first_frame_index)

%fps=30;
%bpm_low=40;
%bpm_high=100;
%L=201; % assumed odd, FIR number of coefficients, order = L-1
%first_frame_index=1; % as shown in Video Player 
%N=1801;
%x=1-abs((-(N-1)/2:1:(N-1)/2))/((N-1)/2); % dummy input signal, with a clear maximum in the signal to help verifying alignment with output
                              % signal would be replaced with input pixel signal (or signal from average of several pixels over selected area)

% design of bandpass filter using modulation of a lowpass filter prototype

w1=2*pi*bpm_low/60/fps; % bandpass ideal low cutoff freq., in rad/sample
w2=2*pi*bpm_high/60/fps; % bandpass ideal high cutoff freq., in rad/sample
wc=(w1+w2)/2;  % center frequency, to be used for lowpass filter modulation later
wp=(w2-w1)/2; % low pass filter ideal cutoff freq, in rad./sample
if floor(L/2)*2 == L  % make sure L is odd
    L=L+1;
end
n=-(L-1)/2:1:(L-1)/2;
h=sin(wp*n)./(pi*n);
h((L+1)/2)=wp/pi;
%h=h.*blackman(L).';
h=h.*hamming(L).';
h=h.*cos(wc*n);

% zero-phase filtering of signal using FIR linear phase filter, with FFT processing for efficiency, and transients removed

%y=conv(x,h); % convolution, replace by equivalent FFT computation for more efficiency, with FFT power of 2 
N=length(x);
NFFT=2^ceil(log(N+L-1)/log(2));   %min. FFT size N+L-1, then next power of 2
X=fft([x,zeros(1,NFFT-N)]);
H=fft([h,zeros(1,NFFT-L)]);
Y=X.*H;
y=real(ifft(Y));                  % 0 <= n <= N+L-2  
                                  % samples without transients:  L-1 <= n <= N-1
y=y(L:N);  % remove 2L-2 transient samples by cutting L-1 samples at the beginning and at the end 
x=x(L-(L-1)/2:N-(L-1)/2); % corresponding samples in x, considering group delay (L-1)/2  

output_frame_indices=(L-1:1:N-1)-(L-1)/2; % time axis in frames, assuming that 1st frame is frame #1
for i=1:length(output_frame_indices)
    output_frame_indices(i)=output_frame_indices(i)+start_frame;
end

figure(2);
plot(y);
title('Signal after filtering');
xlabel('frames');

end  

%removed the overall segments auto corr plot : not needed as we dont
%calculate auto corr overall;
%end
