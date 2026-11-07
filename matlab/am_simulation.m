%% AM communication simulation: report parameter set
% Uses base MATLAB only. See docs/methodology.md for finite-record limits.
% Adapted from the supplied project; original scripts are retained separately.
clc; clear; close all;
rng(0, 'twister');          % Reproducible noise for this organized version
project_root = fileparts(fileparts(mfilename('fullpath')));
output_dir = fullfile(project_root, 'results');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end

%% ====================== STEP 1: PARAMETERS ===============================
Fs = 25000;                 % Sampling frequency (Hz)
T  = 0.05;                  % Total simulation time (s)
t  = 0:1/Fs:T;              % Time vector (50 ms)
fc = 3000;                  % Carrier frequency (Hz)
fm = 100;                   % Message frequency (Hz)

%% ====================== STEP 2: SIGNAL GENERATION ========================
mu = 0.7;                   % Modulation index (0 < mu < 1 for under-modulation)
message = sin(2*pi*fm*t);   % Normalized baseband message in [-1, 1]
carrier = cos(2*pi*fc*t);   % High-frequency carrier (3 kHz)

%% ====================== STEP 3: AM MODULATION ============================
carrier_amp = 2;                            % Carrier amplitude (A_c)

% Envelope: A_c * (1 + mu * message), so:
% Vmax = A_c * (1 + mu),  Vmin = A_c * (1 - mu) > 0 when mu < 1
modulated = carrier_amp * (1 + mu * message) .* carrier;

%% ====================== STEP 4: ADD NOISE (Manual AWGN) ==================
SNR_dB = 10;                                % Desired RF SNR (dB)
signal_power = mean(modulated.^2);
SNR_linear  = 10^(SNR_dB/10);
noise_power = signal_power / SNR_linear;

noise = sqrt(noise_power) * randn(size(modulated));
modulated_noisy = modulated + noise;

%% ====================== STEP 5: ENVELOPE DEMODULATION (ZERO-PHASE) =======
% Step 1: Rectification (ideal diode)
rectified = abs(modulated_noisy);

% Step 2: RC low-pass filter (first-order), applied forward and backward.
% This offline operation reduces phase delay but has finite-record edge transients.
RC = 1/(2*pi*fm);           % RC time constant (cutoff ~ fm)
Ts = 1/Fs;                  % Sampling period
alpha = Ts / (RC + Ts);     % Discretization: y[n]=alpha*x[n]+(1-alpha)*y[n-1]

% ---- Forward pass ----
env_fwd = zeros(size(rectified));
env_fwd(1) = rectified(1);
for k = 2:length(rectified)
    env_fwd(k) = alpha * rectified(k) + (1 - alpha) * env_fwd(k-1);
end

% ---- Backward pass (to cancel phase delay) ----
env_bwd = zeros(size(rectified));
env_bwd(end) = env_fwd(end);
for k = length(rectified)-1:-1:1
    env_bwd(k) = alpha * env_fwd(k) + (1 - alpha) * env_bwd(k+1);
end

demodulated = env_bwd;      % Forward-backward envelope (edge transients remain)

% Remove DC and normalize for comparison with original message
demodulated_ac   = demodulated - mean(demodulated);
peak = max(abs(demodulated_ac));
if peak <= eps
    error('Recovered AC signal is too small to normalize.');
end
demodulated_norm = demodulated_ac / peak;

%% ====================== STEP 6: TIME-DOMAIN PLOTS ========================
waveform_figure = figure('Name','AM Transmitter-Receiver Simulation');

subplot(4,1,1);
plot(t, message, 'Color', [0.8 0 0], 'LineWidth', 1.6);
grid on; ylim([-1.2 1.2]);
title('Message Signal (100 Hz)', 'FontSize', 11);
xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,2);
plot(t, modulated, 'Color', [0.40 0.23 0.72], 'LineWidth', 1.4);
grid on; ylim([-4 4]);
title(['AM Modulated Signal (DSB-WC, \mu = ', num2str(mu), ')'], 'FontSize', 11);
xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,3);
plot(t, modulated_noisy, 'LineWidth', 1.4);
grid on; ylim([-4 4.2]);
title(['Noisy AM Signal (SNR = ', num2str(SNR_dB), ' dB)'], 'FontSize', 11);
xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,4);
plot(t, demodulated_norm,'Color', [0 0.5 0], 'LineWidth', 1.6); hold on;
plot(t, message, 'Color', [0.8 0 0], 'LineStyle', '--', 'LineWidth', 1.6);
grid on; ylim([-1.2 1.2]);
title('Recovered Message (Offline Forward-Backward RC Filter)', 'FontSize', 11);
xlabel('Time (s)'); ylabel('Amplitude');
legend('Recovered message','Original message');

%% ====================== STEP 7: FREQUENCY SPECTRUM =======================
L = length(modulated);
f = Fs * (0:floor(L/2)) / L;    % Frequency axis (one-sided)

Y = fft(modulated);
P = abs(Y/L);
P1 = P(1:floor(L/2)+1);
% Correct one-sided amplitude scaling, preserving DC and even-length Nyquist.
if rem(L, 2) == 0
    P1(2:end-1) = 2 * P1(2:end-1);
else
    P1(2:end) = 2 * P1(2:end);
end

spectrum_figure = figure('Name','Frequency Spectrum of AM Signal');
plot(f, P1, 'LineWidth', 1.5); grid on; xlim([2500 3500]);
title('Frequency Spectrum of AM Signal');
xlabel('Frequency (Hz)'); ylabel('One-sided amplitude');

%% ====================== STEP 8: MANUAL SNR CALCULATION ===================
% RF-domain SNR (before demodulation)
signal_before = modulated;
noise_before  = modulated_noisy - modulated;
snr_before    = 10*log10(mean(signal_before.^2) / mean(noise_before.^2));

% Reference-based output signal-to-error ratio, including noise and distortion.
% Least-squares scaling uses the known clean message; this is evaluation only.
num = demodulated_norm * message.';            % cross-correlation term
den = demodulated_norm * demodulated_norm.';   % energy of recovered
k_opt = num / den;
recovered_scaled = k_opt * demodulated_norm;

noise_after = recovered_scaled - message;
snr_after   = 10*log10(mean(message.^2) / mean(noise_after.^2));

fprintf('Measured input RF SNR: %.2f dB\n', snr_before);
fprintf('Output signal-to-error ratio (reference scaled): %.2f dB\n', snr_after);
%% ====================== STEP 9: SAVE OUTPUTS =============================
print(waveform_figure, fullfile(output_dir, 'waveforms.png'), '-dpng', '-r150');
print(spectrum_figure, fullfile(output_dir, 'spectrum.png'), '-dpng', '-r150');
save(fullfile(output_dir, 'simulation.mat'), 'Fs', 'T', 'fc', 'fm', 'mu', ...
    'carrier_amp', 'SNR_dB', 't', 'message', 'modulated', 'modulated_noisy', ...
    'demodulated_norm', 'recovered_scaled', 'snr_before', 'snr_after', 'f', 'P1');
fprintf('Saved figures and simulation data to: %s\n', output_dir);
