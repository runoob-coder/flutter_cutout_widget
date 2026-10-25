## 1.0.3

* 🐛 **Fixed** unbalanced `saveLayer` — the content buffer was never popped, clipping everything painted after a `Cutout`.
* 🐛 **Fixed** `Clip.none` — buffers now grow to cover every child, so overflow is no longer cut away.
* ✨ **Added** debug assertion for masks that push a composited layer.
* ⚡️ **Perf** no buffers when there is nothing to cut.
* ✨ **Added** rendering test suite — 16 pixel-level tests.
* 📝 **Docs** rewritten English README, new Chinese `README_CN.md`.
* 🔧 Minor: `maskChild` / `child` exposed as fields, `createRenderObject` typed.

## 1.0.2

* 🐛 **Fixed** `include` list in pubspec.yaml — added `analysis_options.yaml`, `test/`, and full `example/` directory so dartdoc generates API reference on pub.dev.

## 1.0.1

* ✨ **Added** CI/CD workflow — auto-build & deploy Flutter web demo to GitHub Pages.
* ✨ **Added** live demo link on pub.dev & README.
* 📝 **Added** comprehensive bilingual README (EN/CN) with badges, API reference, support section.
* 🔧 **Changed** lowered environment constraints to `sdk: ^3.10.0` / `flutter: ">=3.38.0"` for broader compatibility.
* 💛 **Added** Ko-fi support link.

## 1.0.0

* 🎉 **`Cutout` widget** — punch a mask shape through content via `BlendMode.dstOut`.
* ✨ **Added** support for icons, text, images (transparent PNG), and composable Widgets masks.
* ⚠️ **Known limitation**: layer-pushing children (`AnimatedSwitcher`, `Opacity`, `FadeTransition`, etc.) escape the `saveLayer` buffer — engine-level fix required.
