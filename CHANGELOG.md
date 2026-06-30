## 1.0.0

* `Cutout` widget — punch a mask shape through content via `BlendMode.dstOut`.
* Supports icons, text, images (transparent PNG), and composable Widgets masks.
* Known limitation: layer-pushing children (`AnimatedSwitcher`, `Opacity`, `FadeTransition`, etc.) escape the `saveLayer` buffer — engine-level fix required.
