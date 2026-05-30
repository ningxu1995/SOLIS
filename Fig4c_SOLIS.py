import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# ==========================================
# 1. 全局视觉排版规范 (Nature Methods Standard)
# ==========================================
plt.rcParams.update({
    'font.family': 'sans-serif',
    'font.sans-serif': ['Arial', 'Helvetica'],
    'axes.linewidth': 1.2,
    'pdf.fonttype': 42,
    'ps.fonttype': 42,
    'figure.facecolor': 'white',
    'axes.facecolor': 'white'
})

# 专属莫兰迪配色体系
COLOR_WF = '#B3B3B3'  # 淡灰色 (Widefield 基准)
COLOR_SOLIS = '#c281b1'  # 莫兰迪暖紫 (SOLIS)

# ==========================================
# 2. 数据读取与物理尺度强映射
# ==========================================
PHYSICAL_FOV_UM = 300.0


def load_scale_and_normalize(filepath):
    """
    读取 225 点的原始数据，严格进行 [0, 1] 归一化并线性映射至 0 ~ 750 μm
    """
    try:
        df = pd.read_csv(filepath)
        y_val = pd.to_numeric(df.iloc[:, 1], errors='coerce').fillna(0).values
        y_norm = (y_val - np.min(y_val)) / (np.max(y_val) - np.min(y_val) + 1e-12)

        # 建立均匀空间坐标
        x_scaled = np.linspace(0, PHYSICAL_FOV_UM, len(y_norm))
        return x_scaled, y_norm
    except Exception as e:
        print(f"读取 {filepath} 时出错: {e}")
        return np.array([]), np.array([])


print("正在执行物理尺度重映射与归一化...")
x_wf, y_wf = load_scale_and_normalize("L1-vertical-3um-wf.csv")
x_solis, y_solis = load_scale_and_normalize("L1-vertical-3um-sr.csv")

# ==========================================
# 3. 图表绘制与曲线加粗
# ==========================================
fig, ax = plt.subplots(figsize=(5.8, 4.9), dpi=600)

# 绘制 Widefield 曲线 (线宽加粗至 3.5)
if len(x_wf) > 0:
    ax.plot(x_wf, y_wf, color=COLOR_WF, linewidth=3.5, alpha=0.8, label='Widefield', zorder=1)

# 绘制 SOLIS 核心曲线 (线宽加粗至 3.5，实现高反差视觉)
if len(x_solis) > 0:
    ax.plot(x_solis, y_solis, color=COLOR_SOLIS, linewidth=3.5, label='SOLIS', zorder=2)

# ==========================================
# 4. 坐标轴格式化与图例上移
# ==========================================
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# 锁定指定的刻度范围
ax.set_xticks([0, 50, 100, 150, 200, 250, 300])
ax.set_xlim(0, 300)

ax.set_yticks([0.0, 0.5, 1.0])
ax.set_ylim(-0.03, 1.05)

# 【核心修改 1】：刻度数字字号放大 3 号 (15 -> 18)
ax.tick_params(axis='both', direction='in', length=4, labelsize=19)

# 【核心修改 2】：坐标轴标签字号放大 3 号 (19 -> 22)
ax.set_xlabel(r'Position $x$ (nm)', fontsize=20, labelpad=6)
ax.set_ylabel('Intensity (a.u.)', fontsize=20, labelpad=6)

# 图例设置保持不变
ax.legend(frameon=False, loc='lower right', bbox_to_anchor=(1.08, 0.80), fontsize=14, handlelength=1.8)

# ==========================================
# 5. 图像保存
# ==========================================
plt.tight_layout()
plt.savefig("SOLIS_vs_WF_Profile.pdf", format='pdf', bbox_inches='tight', dpi=600)
plt.savefig("SOLIS_vs_WF_Profile.png", format='png', bbox_inches='tight', dpi=600)

print("✅ 排版微调已全部落实！坐标轴文字及刻度已整体放大 3 号。")