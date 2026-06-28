clear; close all; clc;

%% Locate LUT file

%% Gives the directory of this current MATLAB file
script_dir = fileparts(mfilename('fullpath'));
%disp(script_dir)

    % Find file relative to current matlab file directory 
filename = fullfile(script_dir, '..', '..', ...
    'firmware', 'pwm_signal_generator', ...
    'lookup_tables', 'f1kHz.h');

%disp(filename)

%% Read file

txt = fileread(filename);

%% Extract Sampling Frequency fs

FS_match = regexp(txt, '#define\s+FS\s+(\d+)', 'tokens', 'once');
FS = str2double(FS_match{1});

%% Extract LUT only between { }

lut_text = regexp(txt, '\{(.*?)\}', 'tokens', 'once');

LUT = sscanf(lut_text{1}, '%d,');
LUT = LUT(:).';   % force row vector

%% Signal parameters

N = length(LUT);
f0 = FS/N;

%% Figure 1 - Sinusoidal envelope (LUT)

signal = LUT;

t = (0:length(signal)-1)/FS;

figure;
stairs(t*1000, signal, 'LineWidth', 1.2);
grid on;

xlabel('Time [ms]');
ylabel('Look Up Table Value (0-1023)');
title(sprintf('Sinusoidal Envelope - LUT 1kHz Hz - %.3f Hz, N = %d, FS = %d Hz', f0, N, FS));

xlim([0 1/f0]*1000);
ylim([0 1023]);

%% Figure 2 - PWM carrier modulated by LUT

PWM_MAX = 1023;

% Number of points used to draw one PWM period in Matlab
samples_per_pwm_period = 2*261;

% Effective simulation sampling frequency
FS_sim = FS * samples_per_pwm_period;

% Duty cycle from LUT
duty = LUT / PWM_MAX;

% Repeat each LUT value over one PWM period
duty_expanded = repelem(duty, samples_per_pwm_period);

% Create normalized PWM carrier from 0 to 1
carrier_one_period = (0:samples_per_pwm_period-1) / samples_per_pwm_period;
carrier = repmat(carrier_one_period, 1, length(LUT));

% Generate PWM signal
pwm_signal = carrier < duty_expanded;

% Time vector
t_pwm = (0:length(pwm_signal)-1) / FS_sim;

figure;
stairs(t_pwm*1000, pwm_signal * PWM_MAX, 'LineWidth', 1.0);
hold on;
plot(t*1000, LUT, 'LineWidth', 1.5);
grid on;

xlabel('Time [ms]');
ylabel('Amplitude');
title(sprintf('PWM Signal Modulated by 60 Hz LUT - f_{PWM} = %d Hz', FS));

legend('PWM signal', 'Sinusoidal LUT envelope');

xlim([0 16]);      % zoom on first 3 ms
ylim([-50 1075]);

%% Figure 3 - FFT of sinusoidal LUT

LUT_fft = fft(LUT);

Nfft = length(LUT_fft);

X_mag = abs(LUT_fft(1:floor(Nfft/2)+1));

f = (0:floor(Nfft/2))*FS/Nfft;

% Normalize for readability
X_mag = X_mag / max(X_mag);

figure;
stem(f, X_mag, 'filled');
grid on;

xlabel('Frequency [Hz]');
ylabel('Normalized Magnitude (linear)');
title('Fast Fourier Transform (FFT) of Sinusoidal LUT');

xlim([0 500]);
ylim([0 1.1]);

%% Figure 4 - FFT of PWM signal

number_of_periods = 20; % For better resolution

pwm_for_fft = repmat(pwm_signal, 1, number_of_periods);

PWM_fft = fft(pwm_for_fft);

Nfft_pwm = length(PWM_fft);

PWM_mag = abs(PWM_fft(1:floor(Nfft_pwm/2)+1));

f_pwm = (0:floor(Nfft_pwm/2))*FS_sim/Nfft_pwm;

PWM_mag = PWM_mag / max(PWM_mag);
PWM_mag_dB = 20*log10(PWM_mag + eps);

figure;
plot(f_pwm, PWM_mag_dB, 'LineWidth', 1.2);
grid on;

xlim([0 1000]);

xlabel('Frequency [Hz]');
ylabel('Normalized Magnitude [dB]');
title('Fast Fourier Transform (FFT) of PWM Signal');

%% Figure 5 - PWM FFT with 60 Hz band-pass filter overlay

w = 2*pi*f_pwm;
w(1) = eps;

%% ------------------------------------------------------------------------
%% Filter component values (60 Hz signal path)
%% ------------------------------------------------------------------------

% High-pass filter
Rin_HP = 8.2e3;      % Ohm
Rf_HP  = 8.2e3;        % Ohm
Cin_HP = 1e-6;       % F

% Low-pass filter
Rin_LP = 100e3;      % Ohm
Rf_LP  = 100e3;      % Ohm
Cf_LP  = 10e-9;      % F

%% Derived cutoff frequencies

fc_HP = 1/(2*pi*Rin_HP*Cin_HP);
fc_LP = 1/(2*pi*Rf_LP*Cf_LP);

%% Transfer functions

s = 1j*w;

H_hp = (-Rf_HP*Cin_HP*s) ./ (1 + Rin_HP*Cin_HP*s);

H_lp = (-Rf_LP/Rin_LP) ./ (1 + Rf_LP*Cf_LP*s);

H_bp = H_hp .* H_lp;

H_bp_dB = 20*log10(abs(H_bp));

figure;
plot(f_pwm, PWM_mag_dB, 'LineWidth', 1.2);
hold on;
plot(f_pwm, H_bp_dB, 'LineWidth', 1.8);
grid on;

xline(fc_HP, '--', '19 Hz');
xline(fc_LP, '--', '164 Hz');
xline(f0, ':', sprintf('%.1f Hz', f0));
xline(FS, ':', sprintf('f_{PWM} = %.0f Hz', FS));

xlabel('Frequency [Hz]');
ylabel('Normalized Magnitude [dB]');
title('PWM FFT with 60 Hz Filter Response Overlay');

legend('PWM FFT', '60 Hz filter response');

%xlim([0 1000]); %toggle for zoomed version
xlim([0 20000]);
ylim([-100 5]);