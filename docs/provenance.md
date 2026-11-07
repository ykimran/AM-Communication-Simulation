# Sources and changes

Prepared from the supplied `Project-20261107T115247Z-1-001.zip`.

## Source mapping

| Repository file | Source |
| --- | --- |
| `matlab/original/baseline_2khz.m` | Supplied MATLAB script with 10 kHz sampling, 2 kHz carrier, and 30 dB noise target |
| `matlab/original/report_3khz.m` | Supplied MATLAB script with 25 kHz sampling, 3 kHz carrier, and 10 dB noise target |
| `matlab/am_simulation.m` | Newly organized adaptation of the 3 kHz script |

The two original script files are byte-for-byte copies with descriptive filenames. The original ZIP is unchanged. A report copy with student ID headers removed and metadata cleared was prepared but is not included in the public repository pending publication confirmation. Its equations, figures, code listings, and historical claims were otherwise preserved.

Cover sheets, approval paperwork, duplicate Word/code documents, scans, and unreviewed desktop screenshots are not included. The technical report already contains the core result figures. Old and revised approval paperwork are administrative source material, not additional experiments.

## Adaptation changes

- Added a fixed random seed for reproducibility.
- Corrected the stale 2 kHz carrier comment in the 3 kHz version.
- Replaced hex color strings with numeric RGB values and removed a redundant conflicting color specification.
- Added a guard against normalization of a vanishing recovered waveform.
- Corrected positive-frequency scaling for the one-sided amplitude spectrum.
- Clarified the reference-based output error metric and offline filtering limitations.
- Added automatic PNG figure export and MAT data output under `results/`.

The default signal model, inclusive time vector, modulation parameters, target noise level, rectifier, and filter recursion are retained. MATLAB's `rng` implementation is used, and historical report results are not asserted to match the seeded adaptation.

## Validation status

Original file hashes were checked against the supplied archive. The redacted report was reopened, checked for remaining student ID text, and visually reviewed across all nine pages. Source structure and parameter differences were reviewed.

Neither MATLAB nor Octave was installed in the preparation environment. No claim is made that the scripts were executed here. Figure export, MATLAB release compatibility, and signal results must be verified in a MATLAB environment. No historical result or new metric was invented.
