import os
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator
from matplotlib.lines import Line2D

# ── NC journal style (Arial, +4pt vs original) ──────────────────────────────
plt.rcParams.update({
    'font.family':        'sans-serif',
    'font.sans-serif':    ['Arial', 'Liberation Sans', 'DejaVu Sans'],
    'font.size':          11,
    'axes.linewidth':     0.9,
    'axes.labelsize':     11,
    'axes.labelpad':      1.5,
    'xtick.labelsize':    10.5,
    'ytick.labelsize':    10.5,
    'xtick.major.width':  0.9,
    'ytick.major.width':  0.9,
    'xtick.minor.width':  0.6,
    'ytick.minor.width':  0.6,
    'xtick.major.size':   3.5,
    'ytick.major.size':   3.5,
    'xtick.minor.size':   2.0,
    'ytick.minor.size':   2.0,
    'xtick.direction':    'out',
    'ytick.direction':    'out',
    'legend.fontsize':    10,
    'legend.frameon':     False,
    'pdf.fonttype':       42,
    'ps.fonttype':        42,
    'figure.dpi':         300,
})

BLUE = '#2166AC'
GRAY = '#888888'

# ── Optical parameters ──────────────────────────────────────────────────────
NA       = 0.75
lam_um   = 0.530
xi_c_wf  = 2 * NA / lam_um            # widefield incoherent cutoff: 2.83 μm⁻¹

xi = np.linspace(0, 5.2, 2000)

def incoherent_otf(xi, xi_c):
    """Standard incoherent (Airy) OTF: (2/π)[arccos u - u·sqrt(1-u^2)], u = ξ/ξ_c."""
    u = np.clip(xi / xi_c, 0, 1)
    return (2 / np.pi) * (np.arccos(u) - u * np.sqrt(np.maximum(1 - u**2, 0)))

# ── Widefield MTF ───────────────────────────────────────────────────────────
mtf_wf = incoherent_otf(xi, xi_c_wf)

# ── SOLIS MTF (effective-NA model) ──────────────────────────────────────────
# Anchored so the 10 % MTF threshold coincides with the experimentally
# demonstrated 5×5 label-free resolution of 253 nm (USAF target, Fig. 2d).
# incoherent_otf(u_10) = 0.10  →  u_10 ≈ 0.806,  giving NA_eff ≈ 1.30.
xi_solis_res = 1 / 0.253                # 3.95 μm⁻¹  (253 nm, 5×5 demonstrated resolution)
u_10pct      = 0.806                    # numerical root of incoherent_otf = 0.10
xi_c_solis   = xi_solis_res / u_10pct   # ≈ 4.90 μm⁻¹  ⇔  NA_eff ≈ 1.30

mtf_solis = incoherent_otf(xi, xi_c_solis)

# Reference frequencies and theoretical MTF values
xi_rayleigh           = 1 / 0.431       # 2.32 μm⁻¹  (widefield Rayleigh limit, 0.61 λ/NA)
mtf_wf_at_rayleigh    = incoherent_otf(np.array([xi_rayleigh]), xi_c_wf)[0]     # ≈ 0.089
mtf_solis_at_rayleigh = incoherent_otf(np.array([xi_rayleigh]), xi_c_solis)[0]  # ≈ 0.421

# ── Experimental sample points (PLACEHOLDER — replace with measurements) ────
# Acquisition: slanted-edge MTF from chromium-on-quartz edge target,
# n ≥ 5 acquisitions per spatial frequency. Error bars = ±1 SEM.
# (Placeholder values follow the model curves; SOLIS crosses 10 % MTF at 253 nm.)
xi_samp_wf     = np.array([0.5,  1.0,  1.5,  2.0,  2.32, 2.5 ])
mtf_samp_wf    = np.array([0.79, 0.54, 0.37, 0.17, 0.09, 0.05])   # ← REPLACE
err_samp_wf    = np.array([0.030,0.025,0.022,0.020,0.018,0.018])  # ← REPLACE

xi_samp_solis  = np.array([0.5,  1.0,  1.5,  2.0,  2.32, 2.5,  3.0,  3.5,  3.95, 4.0 ])
mtf_samp_solis = np.array([0.85, 0.73, 0.60, 0.48, 0.40, 0.36, 0.25, 0.16, 0.10, 0.085]) # ← REPLACE
err_samp_solis = np.array([0.035,0.030,0.028,0.025,0.022,0.022,0.020,0.018,0.018,0.016]) # ← REPLACE

# ── Figure ──────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(174/25.4, 80/25.4))
fig.subplots_adjust(left=0.10, right=0.96, top=0.83, bottom=0.16)

# Super-oscillatory access region: between widefield and SOLIS cutoffs
ax.axvspan(xi_c_wf, xi_c_solis, color=BLUE, alpha=0.08, zorder=1)
ax.text(xi_c_wf + 0.05, 0.73,
        'Super-oscillatory\naccess region',
        color=BLUE, fontsize=9.5, va='top', style='italic')

# Theoretical curves
ax.plot(xi, mtf_wf,    color=GRAY, lw=1.4, ls='-', zorder=3)
ax.plot(xi, mtf_solis, color=BLUE, lw=1.8, ls='-', zorder=4)

# Vertical reference lines at conventional Rayleigh limit and SOLIS limit
ax.axvline(xi_rayleigh,  color=GRAY, lw=1.0, ls='--', zorder=2)
ax.axvline(xi_solis_res, color=BLUE, lw=1.0, ls='--', zorder=2)

# 10 % MTF resolution criterion
ax.axhline(0.10, color='#aaaaaa', lw=0.7, ls=':', zorder=2)
ax.text(5.12, 0.115, '10% MTF',
        ha='right', va='bottom', fontsize=9.5, color='#888888')

# Reference-line labels (rotated, sitting on the lines)
ax.text(xi_rayleigh  + 0.08, 0.55, '431 nm',
        rotation=90, ha='left', va='center', fontsize=9.5, color=GRAY)
ax.text(xi_solis_res + 0.08, 0.55, '253 nm',
        rotation=90, ha='left', va='center', fontsize=9.5, color=BLUE)

# Experimental sample points with error bars (hollow markers)
ax.errorbar(xi_samp_wf, mtf_samp_wf, yerr=err_samp_wf,
            fmt='o', color=GRAY, ms=4.5, capsize=2.5, lw=0.9,
            mfc='white', mec=GRAY, zorder=5)
ax.errorbar(xi_samp_solis, mtf_samp_solis, yerr=err_samp_solis,
            fmt='o', color=BLUE, ms=4.5, capsize=2.5, lw=0.9,
            mfc='white', mec=BLUE, zorder=6)

# Optical parameters (lower-left)
ax.text(0.04, 0.015, 'NA = 0.75,  λ = 530 nm',
        transform=ax.transAxes, ha='left', va='bottom',
        fontsize=9.5, color='#333333')

# Axes
ax.set_xlim(0, 5.8)
ax.set_ylim(0, 1.05)
ax.set_xlabel(r'Spatial frequency ($\mathregular{\mu m^{-1}}$)')
ax.set_ylabel('MTF')
ax.xaxis.set_major_locator(MultipleLocator(2))
ax.xaxis.set_minor_locator(MultipleLocator(0.5))
ax.yaxis.set_major_locator(MultipleLocator(0.5))
ax.yaxis.set_minor_locator(MultipleLocator(0.1))
ax.spines[['top', 'right']].set_visible(False)

# Custom legend: line + marker per curve
legend_elements = [
    Line2D([0], [0], color=GRAY, lw=1.4, marker='o', markersize=5.5,
           mfc='white', mec=GRAY, label='Widefield'),
    Line2D([0], [0], color=BLUE, lw=1.8, marker='o', markersize=5.5,
           mfc='white', mec=BLUE, label='SOLIS'),
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

# Secondary x-axis: spatial period (nm)
ax2 = ax.twiny()
ax2.set_xlim(ax.get_xlim())
tick_nm   = [200, 250, 300, 400, 500, 700, 1000]
tick_ximu = [1000/p for p in tick_nm]
valid     = [(t, p) for t, p in zip(tick_ximu, tick_nm) if 0 < t <= 5.2]
ax2.set_xticks([t for t, _ in valid])
ax2.set_xticklabels([f'{p}' for _, p in valid])
ax2.set_xlabel('Spatial period (nm)', labelpad=2)
ax2.tick_params(axis='x', direction='out', length=3.5, width=0.9)
ax2.spines['right'].set_visible(False)
ax2.spines['left'].set_visible(False)
ax2.spines['bottom'].set_visible(False)
ax2.spines['top'].set_linewidth(0.9)

# ── Save (next to this script — cross-platform) ─────────────────────────────
out_dir = os.path.dirname(os.path.abspath(__file__))
out_png = os.path.join(out_dir, 'SOLIS_MTF_fig.png')
out_pdf = os.path.join(out_dir, 'SOLIS_MTF_fig.pdf')
fig.savefig(out_png, dpi=500, bbox_inches='tight')
fig.savefig(out_pdf, dpi=500, bbox_inches='tight')
plt.close()
print(f"widefield MTF at Rayleigh (2.32/um) = {mtf_wf_at_rayleigh:.3f}")
print(f"SOLIS MTF at Rayleigh (2.32/um)     = {mtf_solis_at_rayleigh:.3f}")
print(f"SOLIS 10% MTF at {xi_solis_res:.2f}/um  = {1000/xi_solis_res:.0f} nm; NA_eff = {xi_c_solis*lam_um/2:.2f}")
print("Saved:", out_png)
