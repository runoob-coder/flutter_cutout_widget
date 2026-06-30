import 'package:cutout/cutout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ios-27-gray-brown-pink-dark.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: MaterialApp(title: 'Flutter Demo', home: const ExamplePage()),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Cutout Widget Demo',
          style: TextStyle(fontWeight: .bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          /// Cutout using Icon / 使用Icon镂空
          Cutout(
            alignment: .center,
            maskChild: const Icon(
              CupertinoIcons.star,
              fontWeight: .bold,
              size: 50,
            ),
            child: Container(
              width: 100,
              height: 100,
              color: CupertinoColors.activeBlue,
            ),
          ),

          const SizedBox(height: 8),

          /// Cutout using Text / 使用Text镂空
          Cutout(
            alignment: .center,
            maskChild: const Text(
              'Cutout',
              style: TextStyle(fontSize: 30, fontWeight: .bold),
            ),
            child: Container(
              width: 200,
              height: 50,
              color: CupertinoColors.activeOrange,
            ),
          ),

          const SizedBox(height: 8),

          /// Cutout using Icon and Text / 使用Icon和Text镂空
          Cutout(
            alignment: .center,
            maskChild: const Row(
              spacing: 8,
              // mainAxisSize must be min / 约束必须为 min
              mainAxisSize: .min,
              children: [
                Text(
                  'Cutout',
                  style: TextStyle(fontSize: 30, fontWeight: .bold),
                ),
                Icon(CupertinoIcons.wand_stars, fontWeight: .bold, size: 30),
                Text(
                  'Widget',
                  style: TextStyle(fontSize: 30, fontWeight: .bold),
                ),
              ],
            ),
            child: Container(
              width: 300,
              height: 50,
              color: CupertinoColors.activeGreen,
              alignment: .center,
              child: Container(
                width: 100,
                color: CupertinoColors.destructiveRed,
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// Cutout with image background / 镂空图片
          SizedBox(
            height: 120,
            child: Stack(
              alignment: .center,
              children: [
                Image.asset('assets/images/18-fractal-glass-hero-bg.jpg'),
                Cutout(
                  alignment: .center,
                  maskChild: const DefaultTextStyle(
                    style: TextStyle(fontSize: 56, fontWeight: .w900),
                    child: Row(
                      // mainAxisSize must be min / 约束必须为 min
                      mainAxisSize: .min,
                      children: [
                        Text('Hello'),
                        FlutterLogo(size: 70),
                        Text('World'),
                      ],
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/01-colorful-smooth-gradient.jpg',
                    fit: .fill,
                    width: .infinity,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 120,
            child: Cutout(
              alignment: .center,
              maskChild: const DefaultTextStyle(
                style: TextStyle(fontSize: 70, fontWeight: .w800),
                child: Row(
                  // mainAxisSize must be min / 约束必须为 min
                  mainAxisSize: .min,
                  children: [Text('拜问'), FlutterLogo(size: 80), Text('八荒')],
                ),
              ),
              child: Image.asset(
                'assets/images/18-fractal-glass-hero-bg.jpg',
                fit: .fill,
                width: .infinity,
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// Cutout using image as mask / 使用图片进行镂空
          Cutout(
            alignment: .center,
            // Please use an image with transparency / 请使用透明度图
            maskChild: Image.asset('assets/images/magic.png', height: 220),
            child: Image.asset(
              'assets/images/16-fractal-glass-hero-gradients.jpg',
            ),
          ),

          const SizedBox(height: 8),

          Cutout(
            alignment: .center,
            // Please use an image with transparency / 请使用透明度图
            maskChild: Image.asset('assets/images/pikachu.png', height: 300),
            child: Image.asset('assets/images/22-iridescent-holographic.jpg'),
          ),

          const SizedBox(height: 8),

          /// Broken cutout demo: AnimatedSwitcher pushes its own composited
          /// layers (FadeTransition → OpacityLayer), which composite *outside*
          /// the saveLayer buffer and defeat the mask.
          /// Fix: either avoid nesting layer-pushing widgets inside [Cutout.child],
          /// or wrap them with a [RepaintBoundary] before applying the cutout.
          /// ---
          /// 镂空失效示例：AnimatedSwitcher 会推送自己的合成层
          /// (FadeTransition → OpacityLayer)，这些层在 saveLayer 缓冲区*外部*
          /// 合成，导致 mask 失效。
          /// 修复方式：避免在 [Cutout.child] 中嵌套会推送层的组件，
          /// 或在应用镂空前用 [RepaintBoundary] 包裹这些组件。
          Cutout(
            alignment: .center,
            maskChild: const Text(
              'Broken: AnimatedSwitcher',
              style: TextStyle(fontSize: 24, fontWeight: .bold),
            ),
            child: AnimatedSwitcher(
              duration: .zero,
              child: Container(
                height: 60,
                color: CupertinoColors.destructiveRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
