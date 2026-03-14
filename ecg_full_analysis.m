clc
clear
close all

%% PARAMETERS
fs = 360;
filename = 'data/mit-bih-arrhythmia-database-1.0.0/234.dat';

%% LOAD ECG SIGNAL
fid = fopen(filename,'r');
data = fread(fid,[2, inf],'int16');
fclose(fid);

ecg = data(1,:);

%% SELECT FIRST 10 SECONDS
duration = 10;
samples = fs * duration;

ecg_segment = ecg(1:samples);
t = (0:samples-1)/fs;

%% FILTER ECG (0.5 – 40 Hz)
low = 0.5/(fs/2);
high = 40/(fs/2);

[b,a] = butter(4,[low high],'bandpass');
filtered_ecg = filtfilt(b,a,ecg_segment);

%% R-PEAK DETECTION
[peaks,locs] = findpeaks(filtered_ecg,...
    'MinPeakHeight',1000,...
    'MinPeakDistance',0.6*fs);

%% RR INTERVAL
RR = diff(locs)/fs;

%% HEART RATE
HR = 60./RR;
avgHR = mean(HR);

%% HRV
HRV = std(RR);

%% PEAK AMPLITUDE FEATURES
meanPeak = mean(peaks);
maxPeak = max(peaks);
minPeak = min(peaks);

%% DIAGNOSIS
if avgHR < 60
    status = "Bradycardia";
elseif avgHR > 100
    status = "Tachycardia";
elseif HRV > 0.25
    status = "Possible Arrhythmia";
else
    status = "Normal ECG";
end

%% PRINT RESULTS
fprintf("\n------ ECG REPORT ------\n")
fprintf("Average HR: %.2f BPM\n",avgHR)
fprintf("HRV: %.3f sec\n",HRV)
fprintf("Mean RR Interval: %.3f sec\n",mean(RR))
fprintf("Mean R Peak Amplitude: %.2f\n",meanPeak)
fprintf("Max R Peak Amplitude: %.2f\n",maxPeak)
fprintf("Min R Peak Amplitude: %.2f\n",minPeak)
fprintf("Diagnosis: %s\n",status)
fprintf("------------------------\n")

%% PLOTS (ALL IN ONE WINDOW)

figure('Name','ECG Analysis Dashboard','NumberTitle','off')

% Raw ECG
subplot(3,2,1)
plot(t,ecg_segment)
title('Raw ECG Signal')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

% Filtered ECG
subplot(3,2,2)
plot(t,filtered_ecg)
title('Filtered ECG')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

% R Peak Detection
subplot(3,2,3)
plot(t,filtered_ecg)
hold on
plot(locs/fs,peaks,'ro')
title('Detected R Peaks')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

% RR Intervals
subplot(3,2,4)
plot(RR,'o-')
title('RR Intervals')
xlabel('Beat Number')
ylabel('Seconds')
grid on

% Heart Rate Variation
subplot(3,2,5)
plot(HR,'o-')
title('Heart Rate Variation')
xlabel('Beat Number')
ylabel('BPM')
grid on

% Text summary
subplot(3,2,6)
axis off
text(0.1,0.7,['Heart Rate: ' num2str(avgHR,'%.2f') ' BPM'],'FontSize',12)
text(0.1,0.5,['HRV: ' num2str(HRV,'%.3f') ' sec'],'FontSize',12)
text(0.1,0.3,['Diagnosis: ' char(status)],'FontSize',12)
