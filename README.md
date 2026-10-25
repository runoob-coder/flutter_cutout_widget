# 🪟 Cutout

A mask-driven cutout widget for Flutter — punch a shape through content to reveal what is painted beneath it.

**English** · [简体中文](https://github.com/runoob-coder/flutter_cutout_widget/blob/master/README_CN.md)

[![Pub Version](https://img.shields.io/pub/v/cutout.svg)](https://pub.dev/packages/cutout)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter Demo](https://img.shields.io/badge/demo-Flutter-brightgreen.svg)](https://runoob-coder.github.io/flutter_cutout_widget/)
[![API Reference](https://img.shields.io/badge/API-Reference-0175C2.svg)](https://pub.dev/documentation/cutout/latest/)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/runoob-coder/flutter_cutout_widget)
[![CI](https://img.shields.io/github/actions/workflow/status/runoob-coder/flutter_cutout_widget/deploy_web.yml?label=CI)](https://github.com/runoob-coder/flutter_cutout_widget/actions/workflows/deploy_web.yml)
[![GitHub stars](https://img.shields.io/github/stars/runoob-coder/flutter_cutout_widget.svg?style=social)](https://github.com/runoob-coder/flutter_cutout_widget)

<div align="center">
  <a href="https://runoob-coder.github.io/flutter_cutout_widget/" target="_blank"><img width="400" alt="Cutout" src="https://raw.githubusercontent.com/runoob-coder/flutter_cutout_widget/master/screenshots/screenshot.png"></a>
</div>

## ✨ Features

- **Any widget as a mask** — icons, text, shapes, transparent images, or any composition of them.
- **Alpha aware** — the alpha channel of the mask decides how much content is erased, so anti-aliased edges produce soft cutouts.
- **Plain `Stack` layout** — `alignment`, `fit`, `textDirection` and `Positioned` children work exactly as they do in a `Stack`.
- **Only your own content is cut** — the content is isolated in an offscreen buffer, so whatever is painted *behind* the cutout is revealed untouched.

## 📦 Installation

```yaml
dependencies:
  cutout: ^1.0.3
```

```sh
flutter pub add cutout
```

Requires Dart 3.10+ / Flutter 3.38+.

## 🚀 Usage

`Cutout` takes two widgets: `maskChild` (the shape that is punched out) and `child` (the content that is punched through).

### ⭐ Icon mask

```dart
final iconMask = Cutout(
  alignment: Alignment.center,
  maskChild: const Icon(Icons.star, size: 50),
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
);
```

### 🔤 Text mask

```dart
final textMask = Cutout(
  alignment: Alignment.center,
  maskChild: const Text(
    'Cutout',
    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  ),
  child: Container(
    width: 200,
    height: 50,
    color: Colors.orange,
  ),
);
```

### 🧩 Composed mask (icon + text)

```dart
final composedMask = Cutout(
  alignment: Alignment.center,
  maskChild: const Row(
    // Must shrink-wrap, otherwise the row spans the whole stack.
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Cutout', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      Icon(Icons.auto_awesome, size: 30),
      Text('Widget', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    ],
  ),
  child: Container(
    width: 300,
    height: 50,
    color: Colors.green,
  ),
);
```

### 🖼 Cutout over a background image

```dart
final cutoutOverBackground = SizedBox(
  height: 120,
  child: Stack(
    alignment: Alignment.center,
    children: [
      // The background shows through the holes.
      Image.asset('assets/images/18-fractal-glass-hero-bg.jpg'),
      Cutout(
        alignment: Alignment.center,
        maskChild: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hello', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900)),
            FlutterLogo(size: 70),
            Text('World', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900)),
          ],
        ),
        child: Image.asset(
          'assets/images/01-colorful-smooth-gradient.jpg',
          fit: BoxFit.fill,
          width: double.infinity,
        ),
      ),
    ],
  ),
);
```

### 🎭 Transparent PNG as mask

```dart
final pngMask = Cutout(
  alignment: Alignment.center,
  // Use an image with an alpha channel (PNG, WebP, …).
  maskChild: Image.asset('assets/images/magic.png', height: 220),
  child: Image.asset('assets/images/16-fractal-glass-hero-gradients.jpg'),
);
```

### 🎬 Animating the hole

Animating the **layout** of the mask is safe — it does not push a composited layer:

```dart
double holeSize = 80; // call setState() to grow or shrink the hole

final animatedHole = Cutout(
  alignment: Alignment.center,
  maskChild: AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    width: holeSize,
    height: holeSize,
    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
  ),
  child: Image.asset('assets/images/22-iridescent-holographic.jpg'),
);
```

Rotating or translating the mask (`Transform`) works as well, as long as it does not have to composite.

## 📋 API

| Parameter | Type | Default | Description |
|---|---|---|---|
| `maskChild` | `Widget` | **required** | The shape that is punched out of `child`. Must not push a composited layer. |
| `child` | `Widget` | **required** | The content that gets punched through. |
| `alignment` | `AlignmentGeometry` | `Alignment.topStart` | How the mask and the content are aligned inside the stack. |
| `textDirection` | `TextDirection?` | `null` | Resolves `alignment`; defaults to the ambient `Directionality`. |
| `fit` | `StackFit` | `StackFit.loose` | How to size the non-positioned children. |
| `clip` | `Clip` | `Clip.hardEdge` | Whether overflowing content is clipped to the box. With `Clip.none` the internal buffers are grown to contain every child. |

Full API reference: [pub.dev/documentation/cutout](https://pub.dev/documentation/cutout/latest/).

## ⚙️ How it works

```
1. The content children are rasterized into an offscreen buffer (Canvas.saveLayer).
2. The mask is drawn into a second buffer, composited onto the first one with
   BlendMode.dstOut — opaque mask pixels erase the content underneath them.
3. The first buffer is composited back onto the canvas.
```

Step 2 is what makes the mask a *stencil*: it is never painted, it only removes pixels. Step 1 is what keeps the cutout local — without it, `dstOut` would punch through everything painted behind the widget as well.

## ⚠️ Limitations and gotchas

### ⛔ The mask must not push a composited layer

`Canvas.saveLayer` lives inside the current *recording*. A widget that pushes its own layer — `RepaintBoundary`, `Opacity` with an alpha below `255`, `FadeTransition` / `AnimatedOpacity`, `AnimatedSwitcher`, `BackdropFilter`, `ShaderMask`, … — ends that recording early and appends its layer next to the `dstOut` buffer.

For the **mask** this is fatal: the layer is composited *after* the buffer, so the mask becomes visible on top of the content instead of cutting through it. That cannot be repaired at this level of the pipeline — it would need engine support — so debug builds assert and point at the offending widget. The canvas bookkeeping stays balanced in that case, the cutout simply stops working.

```dart
// ❌ The mask escapes the dstOut buffer: it is painted on top of the content.
final maskedOpacity = Cutout(
  maskChild: Opacity(opacity: 0.5, child: const Icon(Icons.star)),
  child: Container(color: Colors.black54),
);

// ✅ Fade the whole cutout instead of the mask.
final fadedCutout = Opacity(
  opacity: 0.5,
  child: Cutout(
    maskChild: const Icon(Icons.star),
    child: Container(color: Colors.black54),
  ),
);
```

If a mask really has to be produced by a compositing widget, rasterize it first (`RepaintBoundary` + `toImage`, or ship it as an image asset) and hand the resulting image to `Cutout`.

### ✅ The content *may* push composited layers

Layers pushed by `child` are appended *before* the `dstOut` buffer, so they are erased correctly. Wrapping the content in a `RepaintBoundary` or an `Opacity` is fine:

```dart
// ✅ Works: composited content is still cut correctly.
final compositedContent = Cutout(
  maskChild: const Text('Hi', style: TextStyle(fontSize: 40)),
  child: RepaintBoundary(child: ExpensiveChart()),
);
```

### 📌 Other notes

- **The mask is a stencil, not a child you can see.** It only removes pixels, and it must not contain interactive widgets: a mask stays in the hit-test tree, so an invisible `GestureDetector`/`IconButton` inside `maskChild` would still receive taps.
- **Shrink-wrap composite masks.** A `Row`/`Column` mask spans the whole stack by default — pass `mainAxisSize: MainAxisSize.min` (or wrap it in `IntrinsicWidth`) so only the text and icons are punched out.
- **Overflow.** With `Clip.hardEdge` overflow is clipped to the box. With `Clip.none` the buffers grow to cover every child's layout box (including `Positioned` overflow), but content that paints outside its own layout box (`Transform`, `OverflowBox`, …) can still be clipped by the buffers.
- **Cost.** A cutout costs two `saveLayer` layers per paint, which forces a render-target switch on the GPU. Keep the cutout as small as the design allows, avoid a full-screen `Cutout` over an expensive background, and wrap static content in a `RepaintBoundary` so it can be cached instead of being re-rasterized into the buffer every frame.
- **Something must be behind it.** `Cutout` paints no background of its own; put it in a `Stack` (or over any other widget) so there is something to reveal.

## 🧪 Tests

The package ships a rendering test suite that rasterizes the widget and inspects the resulting pixels:

```sh
flutter test
```

It covers hole punching, alpha blending, `Stack` layout (`alignment`, `Positioned`, `Clip.none`), composited content, sibling isolation inside the same layer, and the mask assertion.

## 💛 Support

If `Cutout` helps you build better UIs, please consider supporting it — it only takes a few seconds and helps other Flutter developers discover the library.

- ⭐ [Star on GitHub](https://github.com/runoob-coder/flutter_cutout_widget)
- 👍 [Like on pub.dev](https://pub.dev/packages/cutout)


## [☕️ Buy Me a Coffee](https://www.noob-coder.com/buy-me-a-coffee)

|                                                                                   Buy Me a Coffee                                                                                   |                                                                                    Donate with PayPal                                                                                     |
|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| <a href="https://ko-fi.com/noob_coder" target="_blank"><img src="https://github.com/runoob-coder/runoob-coder/raw/main/public/kofi6.webp" alt="Buy Me a Coffee at ko-fi.com" /></a> | <a href="https://paypal.me/runoobcoder" target="_blank"><img src="https://github.com/runoob-coder/runoob-coder/raw/main/public/paypal-donate-button.avif" alt="Donate with PayPal" /></a> |
