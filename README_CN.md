# 🪟 Cutout

蒙版镂空组件 —— 将指定形状从内容中挖除，透出底层背景。

[English](README.md) · **简体中文**

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

## ✨ 特性

- **任意组件做蒙版** —— 图标、文字、形状、带透明度的图片，或它们的任意组合。
- **感知透明度** —— 蒙版的 alpha 通道决定挖除程度，因此抗锯齿边缘会得到柔和的镂空。
- **完全遵循 `Stack` 布局** —— `alignment`、`fit`、`textDirection` 与 `Positioned` 子节点行为与 `Stack` 完全一致。
- **只挖除自身内容** —— 内容被隔离在离屏缓冲区中，因此组件*背后*绘制的内容会被完整透出。

## 📦 安装

```yaml
dependencies:
  cutout: ^1.0.3
```

```sh
flutter pub add cutout
```

需要 Dart 3.10+ / Flutter 3.38+。

## 🚀 使用

`Cutout` 接收两个组件：`maskChild`（被挖除的形状）与 `child`（被挖穿的内容）。

### ⭐ 使用图标镂空

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

### 🔤 使用文字镂空

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

### 🧩 组合蒙版（图标 + 文字）

```dart
final composedMask = Cutout(
  alignment: Alignment.center,
  maskChild: const Row(
    // 必须收缩包裹，否则撑满整个 Stack。
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

### 🖼 在背景图上镂空

```dart
final cutoutOverBackground = SizedBox(
  height: 120,
  child: Stack(
    alignment: Alignment.center,
    children: [
      // 底层背景透过镂空区域显示。
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

### 🎭 使用透明 PNG 做蒙版

```dart
final pngMask = Cutout(
  alignment: Alignment.center,
  // 请使用带 alpha 通道的图片（PNG、WebP 等）。
  maskChild: Image.asset('assets/images/magic.png', height: 220),
  child: Image.asset('assets/images/16-fractal-glass-hero-gradients.jpg'),
);
```

### 🎬 让镂空动起来

对蒙版的**布局**做动画是安全的 —— 不会推送合成层：

```dart
double holeSize = 80; // 调用 setState() 放大或缩小镂空

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

旋转或平移蒙版（`Transform`）同样可行，只要它不需要合成。

## 📋 API

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `maskChild` | `Widget` | **必填** | 从 `child` 中挖除的形状。不可推送合成层。 |
| `child` | `Widget` | **必填** | 被镂空的内容。 |
| `alignment` | `AlignmentGeometry` | `Alignment.topStart` | 蒙版与内容在 Stack 中的对齐方式。 |
| `textDirection` | `TextDirection?` | `null` | 用于解析 `alignment`，默认取环境中的 `Directionality`。 |
| `fit` | `StackFit` | `StackFit.loose` | 非定位子节点的尺寸约束方式。 |
| `clip` | `Clip` | `Clip.hardEdge` | 溢出内容是否裁剪到盒子范围内。`Clip.none` 时内部缓冲区会扩大到覆盖所有子节点。 |

完整 API 文档：[pub.dev/documentation/cutout](https://pub.dev/documentation/cutout/latest/)。

## ⚙️ 原理

```
1. 内容子组件光栅化到离屏缓冲区（Canvas.saveLayer）。
2. 蒙版绘制到第二个缓冲区，以 BlendMode.dstOut 合成到第一个缓冲区上 ——
   蒙版不透明的像素会擦除其下的内容。
3. 第一个缓冲区合成回画布。
```

第 2 步让蒙版成为一个*模板*：它自身从不被绘制，只负责擦除像素。第 1 步则保证镂空是局部的 —— 否则 `dstOut` 会把组件背后绘制的所有内容一起挖穿。

## ⚠️ 限制与注意事项

### ⛔ 蒙版不可推送合成层

`Canvas.saveLayer` 存在于当前这次*录制*中。任何推送自身图层的组件 —— `RepaintBoundary`、alpha 小于 `255` 的 `Opacity`、`FadeTransition` / `AnimatedOpacity`、`AnimatedSwitcher`、`BackdropFilter`、`ShaderMask` 等 —— 都会提前结束该录制，并把图层追加到 `dstOut` 缓冲区旁边。

对**蒙版**而言这是致命的：该图层在缓冲区*之后*合成，于是蒙版被画在内容之上，而不是挖穿内容。这一点无法在本层修复 —— 需要引擎支持 —— 因此 debug 模式下会触发断言并指出出问题的组件。此时画布的 save/restore 依然是平衡的，只是镂空失效。

```dart
// ❌ 蒙版逃逸出 dstOut 缓冲区，被画在内容之上。
final maskedOpacity = Cutout(
  maskChild: Opacity(opacity: 0.5, child: const Icon(Icons.star)),
  child: Container(color: Colors.black54),
);

// ✅ 改为对整个 Cutout 做淡入淡出。
final fadedCutout = Opacity(
  opacity: 0.5,
  child: Cutout(
    maskChild: const Icon(Icons.star),
    child: Container(color: Colors.black54),
  ),
);
```

如果蒙版确实必须由会推送图层的组件生成，请先将其栅格化为图片（`RepaintBoundary` + `toImage`，或直接提供图片资源），再把图片交给 `Cutout`。

### ✅ 内容**可以**推送合成层

`child` 推送的图层会追加在 `dstOut` 缓冲区*之前*，因此会被正确擦除。用 `RepaintBoundary` 或 `Opacity` 包裹内容没有问题：

```dart
// ✅ 可行：合成层内容依然会被正确镂空。
final compositedContent = Cutout(
  maskChild: const Text('Hi', style: TextStyle(fontSize: 40)),
  child: RepaintBoundary(child: ExpensiveChart()),
);
```

### 📌 其他注意事项

- **蒙版是模板，不是可见子节点。** 它只擦除像素，且仍然留在命中测试树中 —— 因此不要在 `maskChild` 里放可交互组件，否则不可见的 `GestureDetector` / `IconButton` 仍会接收点击。
- **组合蒙版需要收缩包裹。** `Row` / `Column` 默认会撑满整个 Stack，请传 `mainAxisSize: MainAxisSize.min`（或用 `IntrinsicWidth` 包裹），这样只有文字和图标被挖除。
- **溢出。** `Clip.hardEdge` 下溢出内容会被裁剪到盒子范围内；`Clip.none` 下内部缓冲区会扩大到覆盖每个子节点的布局盒子（包括 `Positioned` 造成的溢出），但**在自己布局盒子之外绘制**的内容（`Transform`、`OverflowBox` 等）仍可能被缓冲区裁剪。
- **开销。** 每次绘制需要两层 `saveLayer`，会强制 GPU 切换渲染目标。请在设计允许的范围内尽量减小镂空区域，避免用全屏 `Cutout` 覆盖昂贵的背景，并用 `RepaintBoundary` 包裹静态内容以复用缓存，避免每帧重新光栅化。
- **背后必须有东西。** `Cutout` 自身不绘制背景，请把它放进 `Stack`（或其它组件之上），以便有内容可以透出。

## 🧪 测试

包内附带渲染测试套件：将组件光栅化后逐像素校验：

```sh
flutter test
```

覆盖镂空、alpha 混合、`Stack` 布局（`alignment`、`Positioned`、`Clip.none`）、合成层内容、同图层内相邻组件的隔离，以及蒙版断言。

## 💛 支持

如果 `Cutout` 帮助了你，请考虑支持它 —— 只需几秒，就能帮助更多 Flutter 开发者发现此库。

- ⭐ [GitHub 上点星](https://github.com/runoob-coder/flutter_cutout_widget)
- 👍 [pub.dev 上点赞](https://pub.dev/packages/cutout)

## [☕️ 请我喝奶茶](https://www.noob-coder.com/buy-me-a-coffee)

<table>
<thead>
<tr>
    <th style="text-align:center;">赞赏码 WeChat</th>
    <th style="text-align:center;">支付宝 Alipay</th>
</tr>
</thead>
<tbody>
<tr>
    <td width="50%"><img src="https://raw.githubusercontent.com/runoob-coder/runoob-coder/main/public/appreciate.avif" alt="赞赏码WeChat" /></td>
    <td width="50%"><img src="https://raw.githubusercontent.com/runoob-coder/runoob-coder/main/public/alipay.avif" alt="支付宝Alipay" /></td>
  </tr>
</tbody>
</table>