import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A [RenderStack] that punches its first child — the *mask* — through all the
/// remaining children, creating a cutout.
///
/// The mask is never painted: it only describes the shape erased from the
/// content. See [Cutout] for the full behaviour, the mask requirements and the
/// cost of a cutout.
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
    final RenderBox? maskChild = firstChild;
    if (maskChild == null) {
      super.paintStack(context, offset);
      return;
    }

    // Nothing to cut through: the mask is a stencil, painting it would show it.
    final RenderBox? firstContentChild = childAfter(maskChild);
    if (firstContentChild == null) {
      return;
    }

    final Rect bounds = _bufferBounds(offset);
    if (bounds.isEmpty) {
      return;
    }

    assert(
      _canPaintWithoutLayer(maskChild),
      'Cutout.maskChild must not push a composited layer, but $maskChild does.\n'
      'Layers pushed by the mask (RepaintBoundary, Opacity, FadeTransition, '
      'ClipRect, BackdropFilter, animated widgets, …) become siblings of the '
      'dstOut buffer that performs the cutout, so the mask ends up painted on '
      'top of the content instead of cutting through it.\n'
      'Use a mask that paints in a single pass (icon, text, shape, image with '
      'an alpha channel, plain composite of those), or pre-render the mask '
      'widget into an image before handing it to Cutout.',
    );

    // 1. Isolate the content in an offscreen buffer so the cutout stays local —
    //    without it dstOut would also erase whatever is painted behind us.
    final Canvas contentCanvas = context.canvas;
    contentCanvas.saveLayer(bounds, Paint());

    RenderBox? child = firstContentChild;
    while (child != null) {
      final StackParentData childParentData =
          child.parentData! as StackParentData;
      context.paintChild(child, offset + childParentData.offset);
      child = childAfter(child);
    }

    // 2. Erase the mask shape: dstOut keeps the destination only where the
    //    mask is transparent.
    final Canvas maskCanvas = context.canvas;
    maskCanvas.saveLayer(bounds, Paint()..blendMode = BlendMode.dstOut);
    context.paintChild(
      maskChild,
      offset + (maskChild.parentData! as StackParentData).offset,
    );

    // 3. Painting the mask may have ended the current recording — and with it
    //    every buffer saved on it — in which case the context hands out a brand
    //    new canvas and `restore` is a no-op. Comparing canvas identity keeps
    //    save/restore balanced on the canvas that owns them; an unbalanced
    //    `saveLayer` would clip everything painted later to `bounds`.
    final Canvas canvas = context.canvas;
    canvas.restore();
    if (identical(canvas, contentCanvas)) {
      // The content buffer is still open on this very canvas – pop it too.
      canvas.restore();
    }
  }

  /// Whether [child] can be painted without pushing a composited layer.
  bool _canPaintWithoutLayer(RenderBox child) =>
      !child.isRepaintBoundary && !child.needsCompositing;

  /// The area the offscreen buffers have to cover.
  ///
  /// Usually this is simply the box of this render object, because
  /// [RenderStack] clips overflowing children to it when [clipBehavior] is
  /// anything but [Clip.none]. With [Clip.none] overflow is meant to stay
  /// visible, so the buffers are grown to contain every child.
  Rect _bufferBounds(Offset offset) {
    final Rect box = offset & size;
    if (clipBehavior != Clip.none) {
      return box;
    }
    Rect bounds = box;
    RenderBox? child = firstChild;
    while (child != null) {
      final StackParentData childParentData =
          child.parentData! as StackParentData;
      bounds = bounds.expandToInclude(childParentData.offset & child.size);
      child = childAfter(child);
    }
    return bounds;
  }
}

/// Punches the shape of [maskChild] out of [child], revealing whatever is
/// painted behind this widget.
///
/// Opaque pixels of [maskChild] become transparent holes; the alpha channel of
/// the mask decides how much of the content is erased, so anti-aliased edges
/// give soft cutouts.
///
/// ```dart
/// // A dark overlay with a star-shaped hole:
/// Cutout(
///   alignment: Alignment.center,
///   maskChild: const Icon(Icons.star, size: 80),
///   child: Container(color: Colors.black54, height: 100, width: 100),
/// )
/// ```
///
/// ## Picking a mask
///
/// * Icons, text, shapes and any composition of them work out of the box.
/// * Images work when they carry an alpha channel (a transparent `PNG`).
/// * The mask is positioned and sized by the usual [Stack] rules, so
///   [alignment], [fit] and [Positioned] behave as expected. A `Row`/`Column`
///   mask has to shrink-wrap its children — use `MainAxisSize.min`.
///
/// ## Limitations
///
/// * **The mask must not push a composited layer.** Wrapping it in a
///   [RepaintBoundary], [Opacity] (with an alpha below `255`),
///   [FadeTransition], [BackdropFilter], an animated widget, … turns the mask
///   into a sibling of the `dstOut` buffer, which paints it *on top of* the
///   content instead of cutting through it. Debug builds assert on this.
/// * **Content children may push layers.** Their layers are appended before the
///   `dstOut` buffer, so the cutout keeps working — but note that the content is
///   re-rasterized whenever this widget repaints, so wrapping heavy, static
///   content in a [RepaintBoundary] is a good idea.
/// * **The mask stays in the hit-test tree.** Avoid interactive widgets
///   (buttons, gesture detectors) inside `maskChild`.
/// * The cutout costs two `Canvas.saveLayer` layers per paint. Keep it as small
///   as the design allows — a full-screen `Cutout` over an expensive background
///   is the worst case.
class Cutout extends Stack {
  /// Creates a widget that punches the shape of [maskChild] through [child].
  Cutout({
    super.key,
    super.alignment,
    super.textDirection,
    super.fit,
    Clip clip = Clip.hardEdge,
    required this.maskChild,
    required this.child,
  }) : super(clipBehavior: clip, children: [maskChild, child]);

  /// The shape that is punched out of [child].
  ///
  /// Must be paintable in a single pass, see the limitations above.
  final Widget maskChild;

  /// The content that gets punched through.
  final Widget child;

  @override
  RenderStack createRenderObject(BuildContext context) {
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
