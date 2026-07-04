clear; close all; clc;

%% Import oscilloscope CSV files

script_dir = fileparts(mfilename('fullpath'));

unfiltered_filename = fullfile(script_dir, '..', ...
    'data', 'PWM1kHz_unfiltered.csv');

%filtered_filename = fullfile(script_dir, '..', '..', '..', ...
%    'data', 'oscilloscope', 'PWM60Hz_filtered.csv');

unfiltered = import_siglent_csv(unfiltered_filename);
%filtered   = import_siglent_csv(filtered_filename);

fprintf("CSV imported successfully.\n");
fprintf("Channel : %s\n", unfiltered.channel);

%% Signal parameters

f0 = 976.56;       % Expected 1 kHz path sine frequency [Hz]
fPWM = 62500;      % Timer2 Fast PWM frequency [Hz]

%% Extract data

t_pwm = unfiltered.time; % from us in the .CSV
v_pwm = unfiltered.voltage; % Volts

%t_filt = filtered.time;
%v_filt = filtered.voltage;

%% Figure 1 - Measured unfiltered PWM signal

idx = 1:min(20000,length(v_pwm));

figure;
plot(t_pwm(idx)*1000, v_pwm(idx), 'LineWidth', 1.0);
grid on;

xlabel('Time [ms]');
ylabel('Voltage [V]');
title('Measured 1 kHz Unfiltered PWM Signal');

xlim([t_pwm(idx(1)) t_pwm(idx(end))]*1000);


%% Figure 2 - Measured unfiltered PWM signal - zoom

figure;
plot(t_pwm(idx)*1000, v_pwm(idx), 'LineWidth', 1.0);
grid on;

xlabel('Time [ms]');
ylabel('Voltage [V]');
title('Measured 1 kHz PWM Carrier - Zoom');

xlim([0 0.05]);      % 50 us 


%% Figure 3 - FFT of measured unfiltered PWM signal

N_fft = min(2^20, length(v_pwm));

v_fft = v_pwm(1:N_fft);
v_fft = v_fft - mean(v_fft);

w = hann(N_fft);

V_pwm_fft = fft(v_fft .* w);
%V_pwm_fft = fft(v_pwm);

V_pwm_mag = abs(V_pwm_fft(1:floor(N_fft/2)+1));

f_scope = (0:floor(N_fft/2)) * unfiltered.fs / N_fft;

V_pwm_mag = V_pwm_mag / max(V_pwm_mag);
V_pwm_mag_dB = 20*log10(V_pwm_mag + eps);

figure;
plot(f_scope, V_pwm_mag_dB, 'LineWidth', 1.2);
grid on;

xlabel('Frequency [Hz]');
ylabel('Normalized Magnitude [dB]');
title('FFT of Measured 1 kHz Unfiltered PWM Signal');

xline(60,'--','Ambient 60 Hz');
xline(f0,':',sprintf('Signal = %.1f Hz',f0));
xline(fPWM,':',sprintf('f_{PWM} = %.0f Hz',fPWM));

xlim([0 10000]);
ylim([-100 5]);

fprintf('\n----- Oscilloscope acquisition -----\n');
fprintf('Sampling frequency : %.3f MS/s\n', unfiltered.fs/1e6);
fprintf('Number of samples  : %d\n', N_fft);
fprintf('Observation time   : %.3f ms\n', ...
    (t_pwm(end)-t_pwm(1))*1000);
fprintf('Frequency resolution : %.2f Hz\n', ...
    unfiltered.fs/N_fft);