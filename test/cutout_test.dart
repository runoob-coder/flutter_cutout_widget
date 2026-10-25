import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cutout/cutout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const Color _blue = Color(0xFF0000FF);
const Color _red = Color(0xFFFF0000);
const Color _green = Color(0xFF00FF00);
const Color _black = Color(0xFF000000);
const Color _translucentBlack = Color(0x8A000000);

/// Size of the rasterized test surface.
const int _side = 400;

/// Key of the [RepaintBoundary] every test is rendered into.
const ValueKey<String> _rootKey = ValueKey<String>('root');

void main() {
  group('cutout', () {
    testWidgets('punches a transparent hole through the content', (
      tester,
    ) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(maskChild: _box(40, _black), child: _box(200, _blue)),
      );

      // The box covers (100, 100) – (300, 300), the mask is centered on it.
      expect(image.colorAt(200, 200), const Color(0x00000000));
      expect(image.colorAt(110, 110), _blue);
      expect(image.colorAt(290, 290), _blue);
    });

    testWidgets('reveals what is painted behind the cutout', (tester) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          maskChild: _box(40, _black),
          child: _box(200, _blue),
          background: _box(200, _green),
        ),
      );

      // The hole lets the green background shine through the blue content.
      expect(image.colorAt(200, 200), _green);
      expect(image.colorAt(110, 110), _blue);
    });

    testWidgets('does not clip siblings painted after the cutout', (
      tester,
    ) async {
      final _Snapshot image = await _render(
        tester,
        Stack(
          children: <Widget>[
            // A 200x200 cutout anchored to the top left corner.
            Cutout(
              alignment: Alignment.center,
              maskChild: _box(40, _black),
              child: _box(200, _blue),
            ),
            const Positioned(
              left: 260,
              top: 260,
              child: SizedBox.square(
                dimension: 100,
                child: ColoredBox(color: _red),
              ),
            ),
          ],
        ),
      );

      // A leaked `saveLayer` would clip the sibling to the cutout bounds
      // (0, 0) – (200, 200), so it would never show up here.
      expect(image.colorAt(310, 310), _red);
      expect(image.colorAt(100, 100), const Color(0x00000000));
      expect(image.colorAt(10, 10), _blue);
    });

    testWidgets('does not clip siblings painted before the cutout', (
      tester,
    ) async {
      final _Snapshot image = await _render(
        tester,
        Stack(
          children: <Widget>[
            const Positioned(
              left: 260,
              top: 260,
              child: SizedBox.square(
                dimension: 100,
                child: ColoredBox(color: _red),
              ),
            ),
            Cutout(
              alignment: Alignment.center,
              maskChild: _box(40, _black),
              child: _box(200, _blue),
            ),
          ],
        ),
      );

      expect(image.colorAt(310, 310), _red);
      expect(image.colorAt(100, 100), const Color(0x00000000));
    });

    testWidgets('keeps overflowing content visible with Clip.none', (
      tester,
    ) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          clip: Clip.none,
          maskChild: _box(40, _black),
          // Overflows the 200x200 box by 50 logical pixels on both axes.
          child: const Positioned(
            left: -50,
            top: -50,
            child: SizedBox.square(
              dimension: 200,
              child: ColoredBox(color: _blue),
            ),
          ),
        ),
      );

      // (60, 60) is covered by the content but lies outside the cutout box,
      // which spans (100, 100) – (300, 300).
      expect(image.colorAt(60, 60), _blue);
      expect(image.colorAt(200, 200), const Color(0x00000000));
    });

    testWidgets('clips overflowing content with Clip.hardEdge', (tester) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          maskChild: _box(40, _black),
          child: const Positioned(
            left: -50,
            top: -50,
            child: SizedBox.square(
              dimension: 200,
              child: ColoredBox(color: _blue),
            ),
          ),
        ),
      );

      expect(image.colorAt(60, 60), const Color(0x00000000));
      expect(image.colorAt(110, 110), _blue);
      expect(image.colorAt(200, 200), const Color(0x00000000));
    });

    testWidgets('paints nothing when there is no content to cut', (
      tester,
    ) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          maskChild: _box(200, _black),
          child: const SizedBox.shrink(),
        ),
      );

      // The mask is a stencil: it must never end up being painted itself.
      expect(image.colorAt(200, 200), const Color(0x00000000));
      expect(image.colorAt(110, 110), const Color(0x00000000));
    });

    testWidgets('honours the alignment of the mask', (tester) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          alignment: Alignment.bottomRight,
          maskChild: _box(40, _black),
          child: _box(200, _blue),
        ),
      );

      // Bottom right of the box is (300, 300).
      expect(image.colorAt(280, 280), const Color(0x00000000));
      expect(image.colorAt(120, 120), _blue);
    });

    testWidgets('honours a Positioned mask', (tester) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          alignment: Alignment.topLeft,
          maskChild: const Positioned(
            left: 0,
            top: 0,
            child: SizedBox.square(
              dimension: 40,
              child: ColoredBox(color: _black),
            ),
          ),
          child: _box(200, _blue),
        ),
      );

      expect(image.colorAt(120, 120), const Color(0x00000000));
      expect(image.colorAt(200, 200), _blue);
    });

    testWidgets('erases proportionally to the alpha of the mask', (
      tester,
    ) async {
      const int maskAlpha = 0x8A;
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          maskChild: _box(40, _translucentBlack),
          child: _box(200, _blue),
        ),
      );

      // dstOut keeps `content * (1 - maskAlpha)`.
      const int expected = 255 - maskAlpha;
      expect(
        image.alphaAt(200, 200),
        inInclusiveRange(expected - 6, expected + 6),
      );
      expect(image.colorAt(110, 110), _blue);
    });

    testWidgets('works with a composited content child (RepaintBoundary)', (
      tester,
    ) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          maskChild: _box(40, _black),
          child: RepaintBoundary(child: _box(200, _blue)),
        ),
      );

      expect(image.colorAt(200, 200), const Color(0x00000000));
      expect(image.colorAt(110, 110), _blue);
    });

    testWidgets('works with a composited content child (Opacity)', (
      tester,
    ) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          maskChild: _box(40, _black),
          child: Opacity(opacity: 0.5, child: _box(200, _blue)),
        ),
      );

      expect(image.colorAt(200, 200), const Color(0x00000000));
      expect(image.alphaAt(110, 110), inInclusiveRange(120, 136));
    });

    testWidgets('keeps the content hit testable inside the hole', (
      tester,
    ) async {
      int taps = 0;
      await _pump(
        tester,
        _cutoutInBox(
          maskChild: _box(40, _black),
          child: GestureDetector(onTap: () => taps++, child: _box(200, _blue)),
        ),
      );

      await tester.tapAt(
        tester.getTopLeft(find.byKey(_rootKey)) + const Offset(200, 200),
      );
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('supports a mask that animates its size', (tester) async {
      await _pump(
        tester,
        _cutoutInBox(
          maskChild: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: _black),
          ),
          child: _box(200, _blue),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Growing/shrinking a mask only changes layout, it must not composite.
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports a transformed mask', (tester) async {
      final _Snapshot image = await _render(
        tester,
        _cutoutInBox(
          maskChild: Transform.rotate(angle: 0.3, child: _box(40, _black)),
          child: _box(200, _blue),
        ),
      );

      expect(image.colorAt(200, 200), const Color(0x00000000));
      expect(image.colorAt(110, 110), _blue);
    });

    testWidgets('asserts when the mask pushes a composited layer', (
      tester,
    ) async {
      await _pump(
        tester,
        _cutoutInBox(
          maskChild: RepaintBoundary(child: _box(40, _black)),
          child: _box(200, _blue),
        ),
      );

      expect(tester.takeException(), isA<AssertionError>());
    });
  });
}

/// Wraps [child] in a 200x200 cutout box centred on the test surface.
Widget _cutoutInBox({
  required Widget maskChild,
  required Widget child,
  AlignmentGeometry alignment = Alignment.center,
  Clip clip = Clip.hardEdge,
  Widget? background,
}) {
  final Widget cutout = SizedBox.square(
    dimension: 200,
    child: Cutout(
      clip: clip,
      alignment: alignment,
      maskChild: maskChild,
      child: child,
    ),
  );
  return Center(
    child: background == null
        ? cutout
        : SizedBox.square(
            dimension: 200,
            child: Stack(children: <Widget>[background, cutout]),
          ),
  );
}

Widget _box(double size, Color color) => SizedBox.square(
  dimension: size,
  child: ColoredBox(color: color),
);

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: _rootKey,
          child: SizedBox.square(dimension: _side.toDouble(), child: child),
        ),
      ),
    ),
  );
}

/// Pumps [child] and returns the rasterized pixels of the test surface.
Future<_Snapshot> _render(WidgetTester tester, Widget child) async {
  await _pump(tester, child);

  final RenderRepaintBoundary boundary = tester
      .renderObject<RenderRepaintBoundary>(find.byKey(_rootKey));
  late Uint8List bytes;
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage();
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    bytes = data!.buffer.asUint8List();
    image.dispose();
  });
  return _Snapshot(bytes);
}

/// Raw premultiplied RGBA pixels of the test surface.
class _Snapshot {
  _Snapshot(this._bytes);

  final Uint8List _bytes;

  /// The alpha of the pixel at ([x], [y]), in test surface coordinates.
  int alphaAt(int x, int y) => _bytes[(y * _side + x) * 4 + 3];

  /// The colour of the pixel at ([x], [y]), in test surface coordinates.
  Color colorAt(int x, int y) {
    final int index = (y * _side + x) * 4;
    return Color.fromARGB(
      _bytes[index + 3],
      _bytes[index],
      _bytes[index + 1],
      _bytes[index + 2],
    );
  }
}
