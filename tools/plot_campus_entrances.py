"""Render a local top-down diagnostic from a Studio-exported entrance list."""
import json
import sys

import matplotlib.pyplot as plt
from matplotlib.patches import Polygon

data = json.load(open(sys.argv[1], encoding="utf-8"))
fig, ax = plt.subplots(figsize=(15, 10))
for building in data:
    ax.add_patch(Polygon(building["corners"], facecolor="#e2e8e4", edgecolor="#687775", alpha=.7))
    x, z = building["pos"]
    dx, dz = building["dir"]
    ax.arrow(x, z, dx*18, dz*18, head_width=5, head_length=6, color="#bd3434", length_includes_head=True)
    ax.text(x, z, building["id"], fontsize=7, color="#13334b", ha="center", va="bottom")
ax.autoscale_view()
ax.set_aspect("equal")
ax.grid(alpha=.15)
fig.tight_layout()
fig.savefig(sys.argv[2], dpi=150)
