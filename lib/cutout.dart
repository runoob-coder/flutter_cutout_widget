import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A [RenderStack] subclass that punches the first child ([maskChild]) through
/// the remaining children, producing a cutout effect.
///
/// Drawing follows a [BlendMode.dstOut] technique:
/// 1. All content children are rasterized into an offscreen buffer.
/// 2. The mask child is drawn with dstOut, turning its opaque pixels into
///    transparent holes through the content.
/// 3. The buffer is composited back onto the canvas.
///
/// **Important**: content children that push their own composited layers
/// (e.g. [AnimatedSwitcher] via [FadeTransition] → [OpacityLayer]) will
/// have those layers composite *outside* the saveLayer buffer, defeating
/// the mask.  If you need cutout over such widgets, either avoid nesting
/// layer-pushing widgets inside [Cutout.child], or pre-composite those
/// widgets with [RepaintBoundary] before applying the cutout.
class RenderCutout extends RenderStack {
  RenderCutout({
    super.children,
    required super.alignment,
    required TextDirection super.textDirection,
    required super.fit,
    required Clip clip,
  }) : super(clipBehavior: clip);

  @override
  void paintStack(PaintingContext context, Offset offset) {
    final maskChild = firstChild;
    if (maskChild == null) {
      super.paintStack(context, offset);
      return;
    }

    final bounds = offset & size;

    /// 1. Capture all content children into an offscreen buffer.
    context.canvas.saveLayer(bounds, Paint());

    RenderBox? child = (maskChild.parentData as StackParentData?)?.nextSibling;
    while (child != null) {
      final data = child.parentData! as StackParentData;
      context.paintChild(child, offset + data.offset);
      child = data.nextSibling;
    }

    /// 2. Draw maskChild with dstOut – opaque mask pixels punch holes
    ///    through the content drawn in step 1.
    context.canvas.saveLayer(bounds, Paint()..blendMode = BlendMode.dstOut);
    context.paintChild(
      maskChild,
      offset + (maskChild.parentData! as StackParentData).offset,
    );

    /// 3. Composite the cutout result back onto the canvas.
    context.canvas.restore();
  }
}

/// Punches the [maskChild] shape out of [child] to create a cutout effect.
///
/// Opaque pixels of [maskChild] become transparent holes through [child],
/// revealing whatever is behind this widget.
///
/// ```dart
/// // A dark overlay with a star-shaped hole:
/// Cutout(
///   alignment: Alignment.center,
///   maskChild: const Icon(Icons.star, size: 80),
///   child: Container(color: Colors.black54, height: 100, width: 100),
/// )
/// ```
class Cutout extends Stack {
  Cutout({
    super.key,
    super.alignment,
    super.textDirection,
    super.fit,
    Clip clip = Clip.hardEdge,
    required Widget maskChild,
    required Widget child,
  }) : super(clipBehavior: clip, children: [maskChild, child]);

  @override
  RenderStack createRenderObject(context) {
    return RenderCutout(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
      clip: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCutout renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }
}
