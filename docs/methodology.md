# Methodology

## Signal model

The normalized message is `m(t) = sin(2*pi*fm*t)` and the modulated waveform is:

```text
s(t) = Ac * (1 + mu*m(t)) * cos(2*pi*fc*t)
r(t) = s(t) + n(t)
```

For the intended case `0 < mu < 1`, the envelope remains positive. Noise samples are generated with `randn` and scaled using the average clean AM power and target SNR. The realized finite-record noise power need not equal its expectation.

The clean AM spectrum contains a carrier at `fc` and sidebands at `fc - fm` and `fc + fm`. The main script uses a one-sided amplitude spectrum with appropriate doubling of positive-frequency bins. The 1,251-sample inclusive-endpoint record does not align these frequencies exactly with FFT bins, so leakage and bin spacing affect observed peaks. There is no window, zero padding, or noise spectrum analysis in this baseline.

## Receiver

The receiver first takes `abs(r)` and then applies a first-order RC recursion:

```text
alpha = Ts / (RC + Ts)
y[k] = alpha*x[k] + (1-alpha)*y[k-1]
RC = 1/(2*pi*fm)
```

A backward recursion follows the forward pass. The ideal forward-backward frequency response has magnitude equal to the squared magnitude of the one-pass response and no phase shift. The actual finite-record implementation initializes from endpoint values and does not pad the signal, so boundary transients remain. It is not identical to a padded `filtfilt` implementation.

The choice of cutoff near the message frequency attenuates the message as well as suppressing carrier ripple. Removing the mean and normalizing the peak makes a visual comparison possible but conceals absolute gain loss. Full-wave rectification plus smoothing is an approximate envelope recovery method, not a physically modeled peak-hold diode detector.

## Metrics

Input SNR is `10*log10(mean(s.^2)/mean((r-s).^2))`.

For the output metric, a least-squares gain maps the recovered normalized waveform toward the known message. The residual includes noise, filtering distortion, and boundary effects. The reported ratio is `10*log10(mean(message.^2)/mean(residual.^2))`. This reference-assisted evaluation step is not an operation a receiver can perform without access to the clean message.

The two ratios use different signals, bandwidths, and error definitions. A higher output value does not by itself establish a general SNR advantage. The supplied report's sample values have not been reproduced in MATLAB during this repository preparation.
