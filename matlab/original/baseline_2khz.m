%% -------------------------------------------------------------------------
%   AM Transmitter-Receiver Simulation (NO TOOLBOXES REQUIRED)
%   Modulation : AM (DSB-WC) with adjustable modulation index
%   Demodulation: Envelope Detection with ZERO-PHASE RC LPF
% -------------------------------------------------------------------------

clc;
clear;
close all;

%% ====================== STEP 1: PARAMETERS ===============================
Fs = 10000;                 % Sampling frequency (Hz)
T  = 0.05;                  % Total simulation time (s)
t  = 0:1/Fs:T;              % Time vector (50 ms)
fc = 2000;                  % Carrier frequency (Hz)
fm = 100;                   % Message frequency (Hz)

%% ====================== STEP 2: SIGNAL GENERATION ========================
mu = 0.7;                   % Modulation index (0 < mu < 1 for under-modulation)
message = sin(2*pi*fm*t);   % Normalized baseband message in [-1, 1]
carrier = cos(2*pi*fc*t);   % High-frequency carrier (2 kHz)

%% ====================== STEP 3: AM MODULATION ============================
carrier_amp = 2;                            % Carrier amplitude (A_c)

% Envelope: A_c * (1 + mu * message), so:
% Vmax = A_c * (1 + mu),  Vmin = A_c * (1 - mu) > 0 when mu < 1
modulated = carrier_amp * (1 + mu * message) .* carrier;

%% ====================== STEP 4: ADD NOISE (Manual AWGN) ==================
SNR_dB = 30;                                % Desired RF SNR (dB)
signal_power = mean(modulated.^2);
SNR_linear  = 10^(SNR_dB/10);
noise_power = signal_power / SNR_linear;

noise = sqrt(noise_power) * randn(size(modulated));
modulated_noisy = modulated + noise;

%% ====================== STEP 5: ENVELOPE DEMODULATION (ZERO-PHASE) =======
% Step 1: Rectification (ideal diode)
rectified = abs(modulated_noisy);

% Step 2: RC low-pass filter (first-order), implemented forward-backward
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

demodulated = env_bwd;      % Zero-phase envelope

% Remove DC and normalize for comparison with original message
demodulated_ac   = demodulated - mean(demodulated);
demodulated_norm = demodulated_ac / max(abs(demodulated_ac));

%% ====================== STEP 6: TIME-DOMAIN PLOTS ========================
figure('Name','AM Transmitter-Receiver Simulation');

subplot(4,1,1);
plot(t, message, 'r', 'LineWidth', 1.2);
grid on; ylim([-1.2 1.2]);
title('Message Signal (100 Hz)', 'FontSize', 12);
xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,2);
plot(t, modulated, 'm' , 'LineWidth', 1.2);
grid on;
title(['AM Modulated Signal (DSB-WC, \mu = ', num2str(mu), ')'], 'FontSize', 12);
xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,3);
plot(t, modulated_noisy, 'LineWidth', 1.2);
grid on;
title(['Noisy AM Signal (SNR = ', num2str(SNR_dB), ' dB)'], 'FontSize', 12);
xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,4);
plot(t, demodulated_norm, 'r', 'LineWidth', 1.2); hold on;
plot(t, message, 'k--', 'LineWidth', 1.2);
grid on; ylim([-1.2 1.2]);
title('Demodulated Signal (Envelope Detection, Zero-Phase LPF)', 'FontSize', 12);
xlabel('Time (s)'); ylabel('Amplitude');
legend('Recovered message','Original message');

%% ====================== STEP 7: FREQUENCY SPECTRUM =======================
L = length(modulated);
f = Fs * (0:floor(L/2)) / L;    % Frequency axis (one-sided)

Y = fft(modulated);
P = abs(Y/L);
P1 = P(1:floor(L/2)+1);

figure('Name','Frequency Spectrum of AM Signal');
plot(f, P1, 'LineWidth', 1.2); grid on; xlim([1000 3000]);
title('Frequency Spectrum of AM Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude');

%% ====================== STEP 8: MANUAL SNR CALCULATION ===================
% RF-domain SNR (before demodulation)
signal_before = modulated;
noise_before  = modulated_noisy - modulated;
snr_before    = 10*log10(mean(signal_before.^2) / mean(noise_before.^2));

% Baseband SNR after demodulation
num = demodulated_norm * message.';            % cross-correlation term
den = demodulated_norm * demodulated_norm.';   % energy of recovered
k_opt = num / den;
recovered_scaled = k_opt * demodulated_norm;

noise_after = recovered_scaled - message;
snr_after   = 10*log10(mean(message.^2) / mean(noise_after.^2));

fprintf('Estimated SNR before demodulation (RF): %.2f dB\n', snr_before);
fprintf('Estimated SNR after demodulation  (BB): %.2f dB\n', snr_after);