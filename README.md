# SOLIS microscopy: code and representative data

This repository accompanies the manuscript **“Spatiotemporally decoupled
super-oscillatory microscopy enables label-free reconstruction of human
ciliary waveforms.”**

The manuscript is currently under peer review. The repository may be updated
in response to editorial or reviewer comments. Please use the archived release
associated with the manuscript version being evaluated.

SOLIS combines a static multilevel diffractive optical element for spatial
probe compression with digital micromirror device addressing. The software in
this repository reconstructs one coordinate-reassigned map from each 25-frame
acquisition cycle and provides analysis/source-data locations for the main and
supplementary figures.

## Repository status

This peer-review snapshot includes the coordinate-reassignment reconstruction
pipeline, environment files, representative-data specification, currently
available figure scripts and source data, and a script-to-figure audit.
Representative experimental raw sequences and several final per-figure
analysis scripts still need to be added before the repository can be described
as a complete reproduction package. See
[`docs/SCRIPT_TO_FIGURE.md`](docs/SCRIPT_TO_FIGURE.md).

Historical scripts containing illustrative, interpolated, or explicit
placeholder values are retained only for provenance in `legacy/` and are
excluded from the peer-review reproduction workflow. They do not generate the
current manuscript figures.

## Structure

```text
src/solis_reconstruction/       Auditable coordinate-reassignment package
scripts/reconstruct_sequence.py Command-line reconstruction without installation
scripts/validate_representative_data.py
config/                         Example reconstruction configuration
example_data/raw/               De-identified representative camera sequences
example_data/calibration/       Dark, flat, gain, and registration calibration
example_data/processed/         Generated outputs; not raw data
python/                         Current validated figure-analysis scripts
source_data/                    Experimental processed data and simulation outputs
matlab/                         Historical DOE/DMD code pending final verification
docs/                           Pipeline, figure map, and validation report
legacy/                         Historical files excluded from reproduction
```

## Installation

Using Conda:

```bash
conda env create -f environment.yml
conda activate solis-reproduction
```

Using `venv` and pip:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e .
```

The manuscript analysis used Python 3.13. Core dependencies are NumPy, SciPy,
tifffile, pandas, Matplotlib, Seaborn, and openpyxl. The historical GitHub
materials report MATLAB R2021b or later with the Image Processing Toolbox and
Signal Processing Toolbox. The retained MATLAB scripts have not yet been
revalidated against the current manuscript and are therefore kept under
`matlab/legacy/`.

## Reconstruct a representative sequence

Add original camera data and calibration files as described in
[`example_data/README.md`](example_data/README.md), then update
`config/reconstruction.example.json` with the actual paths and acquisition
order.

```bash
solis-reconstruct --config config/reconstruction.example.json
```

The pipeline performs:

1. background subtraction;
2. detector flat-field correction;
3. address-specific gain correction;
4. optional measured registration shifts;
5. deterministic 5 x 5 coordinate reassignment to the 87 nm grid;
6. optional Gaussian filtering at sigma = 0.6 reconstructed pixels.

It writes filtered and unfiltered TIFF stacks, per-cycle QC, and a metadata JSON
containing the complete configuration, software versions, and SHA-256 hashes.
It does not use deconvolution, regularisation, learning-based restoration, or
synthesis of unmeasured structure.

Detailed documentation is provided in
[`docs/RECONSTRUCTION_PIPELINE.md`](docs/RECONSTRUCTION_PIPELINE.md).

Exact dependency capture for the archival release is described in
[`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md).

## Representative raw data

Experimental raw sequences must be original camera counts and must not be
normalized, filtered, interpolated, or reconstructed before deposit. At least
one label-free cilia sequence, one line-pair sequence, probe calibration, dark
frame, flat field, address gains, and address shifts should be included. A
control and Dynarrestin-treated sequence are recommended.

Validate the deposit with:

```bash
python scripts/validate_representative_data.py \
  --manifest example_data/representative_sequences_manifest.csv
```

Synthetic software-test data, if generated, remain in a separate directory and
are never treated as experimental source data.

## Tests

```bash
python -m unittest discover -s tests -v
```

## Figure and source-data map

The current manuscript/SI map, missing items, and release criteria are listed
in [`docs/SCRIPT_TO_FIGURE.md`](docs/SCRIPT_TO_FIGURE.md). Every final plotting
script should read deposited source data; experimental values must not be
embedded as constants in figure code.

The audit and integration decisions for the author-supplied Fig. 3c, Fig. 6d,
and Supplementary Fig. 7 files are recorded in
[`docs/INCOMING_FIGURE_FILES_AUDIT.md`](docs/INCOMING_FIGURE_FILES_AUDIT.md).

## Data and code availability

The peer-review repository will be updated as the manuscript and source-data
deposit are finalised. The archival record is associated with Zenodo DOI
`10.5281/zenodo.20464998`. The final public release will be issued after all
required source data, scripts, and representative raw sequences have been
added and the validation report is complete.

## Provenance of the earlier GitHub deposit

The earlier GitHub snapshot was checked against this package. Its TIFF,
historical Python scripts, MATLAB files, phase file, and MIT license are already
retained here as byte-identical copies. The earlier README is not carried
forward because it used previous manuscript titles, figure numbering, and
publication-status language. No superseded figure output has been added to the
current workflow.

## License

Code is released under the MIT License; see [`LICENSE`](LICENSE).

## Contact

- Ning Xu: `nxu@mail.tsinghua.edu.cn`, `ningxu1995@163.com`
