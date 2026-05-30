# Source code for "Spatiotemporally decoupled super-oscillatory nanoscopy enables label-free reconstruction of human ciliary waveforms" (SOLIS)

## General information

**Title.** Source code for *Spatiotemporally decoupled super-oscillatory nanoscopy enables label-free reconstruction of human ciliary waveforms* (SOLIS).

**Corresponding authors**
- Ning Xu — nxu@mail.tsinghua.edu.cn
- Sarah E. Bohndiek — seb53@cam.ac.uk

**Affiliations**
- Department of Physics, Cavendish Laboratory, University of Cambridge, JJ Thomson Avenue, Cambridge CB3 0HE, UK
- State Key Laboratory of Precision Measurement Technology and Instruments, Department of Precision Instrument, Tsinghua University, Beijing 100084, China
- Cancer Research UK Cambridge Institute, University of Cambridge, Robinson Way, Cambridge CB2 0RE, UK

**Date of collection:** 2021–2026
**Geographic location:** Cambridge, UK & Beijing, China

## Sharing / access information

**License.** Released under the **MIT License** (an OSI-approved open-source license; required by *Nature Communications*); see `LICENSE`. (BSD-3-Clause or GPL-3.0 are equally acceptable if you prefer — pick one and include the matching `LICENSE` file.)

**Archived version / DOI.** This repository is archived on Zenodo: **DOI 10.5281/zenodo.20464998**.

**Recommended citation.**
> Xu, N., Williams, C., Spicer, G., Wang, Q., Tan, Q. & Bohndiek, S. E. (2026). Spatiotemporally decoupled super-oscillatory nanoscopy enables label-free reconstruction of human ciliary waveforms. *Nature Communications* (in press). Code: https://github.com/ningxu1995/SOLIS; (Zenodo DOI: 10.5281/zenodo.20464998).

## Repository structure

```
/matlab         Optical design: DOE phase design + DMD hologram generation
/python         Analysis and figure-generation code
/example_data   Small example / source-data files needed to run the scripts
README.md       This file
LICENSE         Open-source license
```

## File overview

### MATLAB — optical design
*(MATLAB R2021b or later; Image Processing Toolbox, Signal Processing Toolbox)*

- **`SRspotN_N_Optimized.m`** — Designs the super-oscillatory *N×N* spot-array phase profile (the **5×5** configuration is used for imaging) using a weighted Gerchberg–Saxton / iterative Fourier-transform algorithm with a Fourier-plane amplitude constraint, balancing **sub-diffraction central-lobe compression** against sidelobe energy / SBR.
- **`Get_Phase_Estimation.m`** — Estimates point-by-point phase shifts from measured intensity images by Fourier-domain cross-correlation; includes sparsity checks for cell samples.
- **`Get_System_Parameters.m`** — Defines optical-system constraints (NA = 0.75, λ = 530 nm, pixel size) and generates the optical transfer function (OTF).
- **`Sequence_Phase_Generator.m`** — Generates the scanning-pattern sequence for the **digital micromirror device (DMD)** by combining the optimized phase with linear phase ramps (the 25 positions of the 5×5 lattice scan).

### Python — analysis & figures
*(Python 3.13; NumPy, SciPy, Matplotlib, Seaborn, pandas)*

- **`Figure3d_SOLIS_MTF_fig.py`** — Modulation transfer function (**Fig. 3d**): widefield vs SOLIS, effective-NA incoherent-OTF model with slanted-edge measured points. SOLIS reaches the 10 % MTF criterion at **253 nm** (5×5 demonstrated resolution; widefield Rayleigh limit 431 nm). Outputs `SOLIS_MTF_fig.png/.pdf`.
- **`FigS3_SOLIS_v4.py`** — **Supplementary Fig. 3**: super-oscillatory probe uniformity (CV = 7.1 %), sidelobe/SBR (5.3) vs array complexity, radial profile (5×5 central-lobe **FWHM = 224 nm = 0.52 A.U.**), and field-of-view dependence. Convention: **1.00 A.U. = Rayleigh = 0.61 λ/NA = 431 nm**. Outputs `SOLIS_supp_fig3_v4.png`.
- **`Fig4c_SOLIS.py`** — Line-profile comparison of widefield vs SOLIS (normalized intensity vs position) from CSV input. Reads `example_data/L1-vertical-3um-wf.csv` and `example_data/L1-vertical-3um-sr.csv`. Outputs `SOLIS_vs_WF_Profile.png/.pdf`.

### Example / source data
```
example_data/L1-vertical-3um-wf.csv    line profile, widefield
example_data/L1-vertical-3um-sr.csv    line profile, SOLIS
```
*(Add the remaining per-figure source-data files here, e.g. cluster-level CBF/amplitude values for Fig. 5g,h; metrology values for Fig. 3; slanted-edge MTF points for Fig. 3d.)*

## Script ↔ figure map

| Output | Script |
|---|---|
| Figure 3d (MTF) | `python/Figure3d_SOLIS_MTF_fig.py` |
| Figure 4c (line profile) | `python/Fig4c_SOLIS.py` |
| Supplementary Fig. 3 | `python/FigS3_SOLIS_v4.py` |
| DOE / probe design | `matlab/SRspotN_N_Optimized.m`, `Get_System_Parameters.m` |
| DMD scan patterns | `matlab/Sequence_Phase_Generator.m` |
| Phase estimation | `matlab/Get_Phase_Estimation.m` |

## Methodological notes

- Super-oscillatory spot arrays are produced by a 16-level **diffractive optical element (DOE)**; the phase design uses a modified iterative Fourier-transform algorithm with a Fourier-plane amplitude constraint to trade central-lobe compression against sidelobe energy / SBR.
- Temporal steering of the spot array is performed by a **DMD** (zero-inertia, kilohertz binary-hologram switching), independent of the spatial-compression stage — the "spatiotemporal decoupling" principle.
- **Resolution convention:** 1.00 Airy unit (A.U.) = Rayleigh diffraction limit = 0.61 λ/NA = **431 nm** at NA = 0.75, λ = 530 nm. The 5×5 imaging probe has a central-lobe FWHM of 224 nm (0.52 A.U.); the single spot is 202.57 nm (0.47 A.U.).

## Software

- **MATLAB** R2021b or later — Image Processing Toolbox, Signal Processing Toolbox.
- **Python 3.13** — NumPy, SciPy, Matplotlib, Seaborn, pandas. Install with:
  ```
  pip install numpy scipy matplotlib seaborn pandas
  ```
