# SOLIS reproducibility release checklist

## Ready in this package

- [x] Configuration-driven 25-address reconstruction pipeline
- [x] Dark, flat-field, address-gain, and address-shift correction
- [x] Serpentine 5 x 5 coordinate reassignment
- [x] Filtered and unfiltered TIFF output
- [x] QC CSV, metadata JSON, software versions, and SHA-256 provenance
- [x] Unit tests and explicitly synthetic software test
- [x] Representative-data metadata and manifest templates
- [x] Python environment specification and exact-version capture tool
- [x] V16/V13 script-to-figure audit
- [x] Historical placeholder scripts isolated from the release workflow

## Files the authors must supply from the original experiment

- [ ] `example_data/raw/cilia_representative_raw.tif`
- [ ] `example_data/raw/line_pair_270nm_raw.tif`
- [ ] `example_data/raw/probe_calibration_raw.tif`
- [ ] `example_data/calibration/dark_frame.tif`
- [ ] `example_data/calibration/flat_field.tif`
- [ ] `example_data/calibration/address_gains.csv`
- [ ] `example_data/calibration/address_shifts.csv`
- [ ] Companion JSON metadata and completed manifest rows

Recommended additions:

- [ ] one vehicle-control cilia sequence;
- [ ] one Dynarrestin-treated cilia sequence;
- [ ] one matched widefield sequence;
- [ ] unfiltered outputs used for the filtering ablation.

## Verification required after adding real data

- [ ] Confirm the actual DMD acquisition order. Do not assume serpentine.
- [ ] Confirm the camera-axis ordering and ROI dimensions.
- [ ] Run `validate_representative_data.py` successfully.
- [ ] Run reconstruction from a clean environment.
- [ ] Compare generated outputs numerically with archived processed outputs.
- [ ] Complete `docs/VALIDATION_REPORT.md`.
- [ ] Add every required final figure script and source-data table listed in
      `docs/SCRIPT_TO_FIGURE.md`.
- [ ] Capture exact Python, MATLAB, and driver versions.
- [ ] Update GitHub and create a new Zenodo version only after validation.
