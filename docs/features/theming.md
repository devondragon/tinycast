# Theming

## Backdrop budget

While visible a backdrop must stay under 5% of one core and under 8 MB of extra resident memory, and
use no CPU while hidden. The proxy columns come from `Tests/backdrop-performance.swift`, which renders
`BackdropRenderer.draw` through `ImageRenderer` at the 750x475 palette size for 300 frames at 1/30 s
steps. `ImageRenderer` also rasterizes and reads back each frame (an empty canvas costs about 0.47 ms),
so the proxy is an upper bound on the draw cost. Proxy CPU is mean ms x 30 / 1000. The live columns come
from `Scripts/measure-backdrop.sh` against the running Debug app and are pending.

| Backdrop | Proxy ms/frame (mean, p95) | Proxy CPU at 30 fps | Live CPU open | Live CPU hidden | RSS delta | Machine | Date |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Tron grid, dark | 0.50, 0.54 | 1.5% | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Tron grid, light | 0.47, 0.53 | 1.4% | pending | pending | pending | Apple M4 Max | 2026-10-12 |
