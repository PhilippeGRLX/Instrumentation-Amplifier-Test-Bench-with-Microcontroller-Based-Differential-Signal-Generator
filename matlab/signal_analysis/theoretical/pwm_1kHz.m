clear; close all; clc;

%% Locate LUT file

%% Gives the directory of this current MATLAB file
clear; close all; clc;

%% Locate LUT file

script_dir = fileparts(mfilename('fullpath'));

if isempty(script_dir)
    script_dir = pwd;
end

filename = fullfile(script_dir, '..', '..', ...
    'firmware', 'pwm_signal_generator', ...
    'lookup_tables', 'f1kHz.h');

if ~isfile(filename)
    error('LUT file not found: %s', filename);
end
txt = fileread(filename);

%% Extract Sampling Frequency FS

% Timer2 Fast PWM, 8-bit, prescaler = 1
% Arduino clock: 16 MHz
% PWM frequency: 16 MHz / 256 = 62500 Hz
FS = 62500;

fprintf('PWM update frequency FS = %.0f Hz\n', FS);

%% Extract LUT values

% Extract everything between '{' and '}'
lut_text = regexp(txt, '\{(.*?)\}', 'tokens', 'once');

if isempty(lut_text)
    error('Could not locate LUT data in %s.', filename);
end

% Convert comma-separated values into a row vector
LUT = sscanf(lut_text{1}, '%d,').';
LUT = LUT(:).';   % force row vector

%% Signal parameters

N = length(LUT);
f0 = FS/N;

%% Figure 1 - Sinusoidal Lookup Table

signal = LUT;

t = (0:N-1) / FS;

figure;
stairs(t*1000, signal, 'LineWidth', 1.2);
grid on;

xlabel('Time [ms]');
ylabel('LUT Value (8-bit)');
title(sprintf('1 kHz Sinusoidal Lookup Table (f = %.2f Hz, N = %d, FS = %d Hz)', ...
    f0, N, FS));

xlim([0 1/f0] * 1000);
ylim([0 255]);

%% Figure 2 - PWM Signal

PWM_MAX = 255;

% Number of MATLAB samples used to draw one PWM period
samples_per_pwm_period = 200;

% Effective simulation sampling frequency
FS_sim = FS * samples_per_pwm_period;

% Duty cycle from LUT
duty = LUT / PWM_MAX;

% Repeat each LUT value over one PWM period
duty_expanded = repelem(duty, samples_per_pwm_period);

% Generate one normalized PWM carrier (0 → 1)
carrier_one_period = (0:samples_per_pwm_period-1) / samples_per_pwm_period;
carrier = repmat(carrier_one_period, 1, N);

% Generate PWM waveform
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
title(sprintf('PWM Signal Modulated by 1 kHz LUT (f_{PWM} = %.0f Hz)', FS));

legend('PWM signal', 'Sinusoidal LUT');

xlim([0 1/f0] * 1000);
ylim([-10 265]);

%% Figure 3 - FFT of Sinusoidal LUT

LUT_fft = fft(LUT);

Nfft = length(LUT_fft);

X_mag = abs(LUT_fft(1:floor(Nfft/2)+1));

f = (0:floor(Nfft/2))*FS/Nfft;

% Normalize with respect to the largest AC component
X_mag = X_mag / max(X_mag(2:end));

figure;
stem(f, X_mag, 'filled');
grid on;

xlabel('Frequency [Hz]');
ylabel('Normalized Magnitude');
title('Fast Fourier Transform (FFT) of Sinusoidal LUT');

xlim([0 5000]);
ylim([0 1.1]);

%% Figure 4 - FFT of PWM Signal

number_of_periods = 20;      % Improves frequency resolution

pwm_for_fft = repmat(pwm_signal, 1, number_of_periods);

PWM_fft = fft(pwm_for_fft);

Nfft_pwm = length(PWM_fft);

PWM_mag = abs(PWM_fft(1:floor(Nfft_pwm/2)+1));

f_pwm = (0:floor(Nfft_pwm/2)) * FS_sim / Nfft_pwm;

PWM_mag = PWM_mag / max(PWM_mag);
PWM_mag_dB = 20*log10(PWM_mag + eps);

figure;
plot(f_pwm, PWM_mag_dB, 'LineWidth', 1.2);
grid on;

xlabel('Frequency [Hz]');
ylabel('Normalized Magnitude [dB]');
title('Fast Fourier Transform (FFT) of PWM Signal');

xlim([0 100000]);
ylim([-100 5]);

%% Figure 5 - PWM FFT with 60 Hz band-pass filter overlay

w = 2*pi*f_pwm;
w(1) = eps;
s = 1j*w;

%% ------------------------------------------------------------------------
%% Filter component values (1 kHz signal path)
%% ------------------------------------------------------------------------

% High-pass filter
Rin_HP = 8.2e3;      % Ohm
Rf_HP  = 8.2e3;      % Ohm
Cin_HP = 1e-6;      % F

%% Sallen-Key low-pass filter - ideal design

% Design targets
fc_LP = 2e3;       % Hz
Q_LP  = 0.707;     % Butterworth
C_LP  = 10e-9;     % F

% Ideal design equations
w0 = 2*pi*fc_LP;

R_nom  = 1/(w0*C_LP);
RA_nom = R_nom;
RB_nom = (2 - 1/Q_LP)*RA_nom;

K = 1 + RB_nom/RA_nom;
a = 1/K;

% Ideal transfer function
H_lp = (a*K*w0^2) ./ ...
    (s.^2 + s.*(w0/Q_LP) + w0^2);

H_lp_dB = 20*log10(abs(H_lp));

%% Complete reconstruction filter

% High-pass transfer function
fc_HP = 1/(2*pi*Rin_HP*Cin_HP);

H_hp = (-Rf_HP*Cin_HP*s) ./ ...
    (1 + Rin_HP*Cin_HP*s);

% Complete 1 kHz reconstruction filter
H_filter = H_hp .* H_lp;
H_filter_dB = 20*log10(abs(H_filter));

fprintf('\n--- Ideal 1 kHz reconstruction filter ---\n');
fprintf('High-pass fc = %.1f Hz\n', fc_HP);
fprintf('Sallen-Key fc = %.1f Hz\n', fc_LP);
fprintf('Sallen-Key Q  = %.3f\n', Q_LP);
fprintf('R nominal     = %.0f ohm\n', R_nom);
fprintf('RA nominal    = %.0f ohm\n', RA_nom);
fprintf('RB nominal    = %.0f ohm\n', RB_nom);
fprintf('K ideal       = %.4f\n', K);
fprintf('a ideal       = %.4f\n', a);
fprintf('aK gain       = %.4f V/V\n', a*K);


figure;
plot(f_pwm, PWM_mag_dB, 'LineWidth', 1.2);
hold on;
plot(f_pwm, H_filter_dB, 'LineWidth', 1.8);
grid on;

xline(f0, ':', sprintf('Signal = %.1f Hz', f0));
xline(fc_LP, '--', sprintf('f_c = %.1f Hz', fc_LP));
xline(FS, ':', sprintf('f_{PWM} = %.0f Hz', FS));

xlabel('Frequency [Hz]');
ylabel('Normalized Magnitude [dB]');
title('PWM FFT with 1 kHz Reconstruction Filter Response Overlay');

legend('PWM FFT', 'Reconstruction filter response');

xlim([0 5000]);
ylim([-100 10]);