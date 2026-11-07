# AM Communication Simulation

**Simulation and Analysis of Noise-Affected AM Communication with Envelope Detection**

A MATLAB simulation of an amplitude-modulated transmitter, an additive white Gaussian noise channel, and an envelope-detection receiver. The implementation uses base MATLAB functions and manually implements noise generation and RC filtering, without Communications Toolbox or Signal Processing Toolbox.

Prepared for **EEE-3602 · Communication Theory Sessional**, Department of EEE, International Islamic University Chittagong (IIUC).

## What the simulation does

- Generates a sinusoidal message and a carrier.
- Applies double-sideband AM with a transmitted carrier (DSB-WC).
- Adds Gaussian noise at a chosen target RF SNR.
- Recovers the message with full-wave rectification and a forward-backward RC low-pass filter.
- Displays time-domain signals and the AM spectrum, then calculates input SNR and reference-based output error.

The receiver is an **offline simulation**: its backward filtering pass requires future samples. It is not a real-time hardware implementation.

## Run in MATLAB

1. Download this repository using **Code → Download ZIP**, then extract it, or clone it:

   ```bash
   git clone https://github.com/ykimran/AM-Communication-Simulation.git
   ```

2. Open the extracted repository folder in MATLAB.
3. Run this command in the MATLAB Command Window:

   ```matlab
   run('matlab/am_simulation.m')
   ```

Alternatively, open `matlab/am_simulation.m` in the Editor and select **Run**. The script clears workspace variables and closes existing figures when it starts.

No additional toolbox or package installation is required by the code. A specific minimum MATLAB release has not been established. GNU Octave compatibility has not been tested.

## Default parameters

The main script follows the parameter set shown in the supplied report.

| Parameter | Value |
| --- | --- |
| Sampling frequency | 25,000 Hz |
| Simulation duration | 0.05 s, inclusive endpoint |
| Message frequency | 100 Hz |
| Carrier frequency | 3,000 Hz |
| Carrier amplitude | 2 |
| Modulation index | 0.7 |
| Target input RF SNR | 10 dB |
| RC time constant | `1 / (2*pi*fm)` |
| Random seed | `0`, Twister, added for repeatability |

Edit the parameter block near the top of the script to experiment. Keep the sampling frequency above twice the upper AM sideband frequency and use a nonzero modulation index below 1 for the intended under-modulated case. Parameter changes can invalidate fixed plot titles, axis limits, and filter assumptions; update those together.

## Output

The script displays two figures and prints the measured input SNR and output signal-to-error ratio. It also creates:

| File | Contents |
| --- | --- |
| `results/waveforms.png` | Message, clean AM, noisy AM, and recovered message |
| `results/spectrum.png` | One-sided amplitude spectrum of the clean AM signal |
| `results/simulation.mat` | Signal arrays, parameters, spectrum, and evaluation values |

The same output filenames are overwritten on later runs. Generated results are excluded from Git. The main script's fixed random seed makes repeated runs reproducible in a given MATLAB environment; the original scripts use unseeded random noise.

## Project files

| Path | Purpose |
| --- | --- |
| [matlab/am_simulation.m](matlab/am_simulation.m) | Organized report-based entry point with saved outputs |
| [matlab/original/report_3khz.m](matlab/original/report_3khz.m) | Unmodified supplied script: 25 kHz sampling, 3 kHz carrier, 10 dB target SNR |
| [matlab/original/baseline_2khz.m](matlab/original/baseline_2khz.m) | Unmodified supplied script: 10 kHz sampling, 2 kHz carrier, 30 dB target SNR |
| [docs/methodology.md](docs/methodology.md) | Equations, filtering details, and measurement caveats |
| [docs/provenance.md](docs/provenance.md) | Source mapping, changes, and validation status |

## Reading the results

Input RF SNR measures the known clean AM waveform against the generated channel noise. Finite random samples mean its measured value will differ from the target.

The output metric compares the recovered waveform with the known clean message after least-squares amplitude scaling. It includes noise, waveform distortion, and finite-record boundary effects. It should not be treated as a directly comparable RF SNR measurement or proof of a guaranteed receiver SNR improvement.

The [supplied report](docs/source/Report.pdf) contains historical result figures. They have not been rerun here, and the original report's numerical claims are retained as source material rather than independently verified findings. The new seeded script and corrected spectrum scaling can produce different results and plots.

## Limitations and next steps

This project uses a single-tone message and ideal oscillators. It does not include frequency drift, fading, a physical diode model, or hardware measurements. Over-modulation can cause envelope distortion. The forward-backward filter changes the magnitude response and introduces boundary transients on finite records.

Potential extensions include comparing causal and offline receivers, sweeping SNR and modulation index, coherent demodulation, higher-order filters, and hardware validation. These are not implemented features.

## Validation and reuse

The files and equations were reviewed during repository preparation. MATLAB and Octave were unavailable, so execution, figure export, and toolbox independence have not been runtime-verified. No new experimental measurements or benchmark claims are included.

No open-source license has been selected. Confirm reuse permissions before redistributing the supplied academic materials.

## Project report

[Download the supplied technical report](docs/source/Report.pdf), published unchanged with explicit confirmation on 7 November 2026. Approval forms, cover sheets, and desktop screenshots remain excluded.
