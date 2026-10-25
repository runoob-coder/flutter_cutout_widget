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
          // Icon mask
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

          // Text mask
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

          // Icon + text mask
          Cutout(
            alignment: .center,
            maskChild: const Row(
              spacing: 8,
              // must shrink-wrap, otherwise the row covers the whole stack
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

          // Cutout over a background image
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

          // Image mask: the mask must carry an alpha channel
          Cutout(
            alignment: .center,
            maskChild: Image.asset('assets/images/magic.png', height: 220),
            child: Image.asset(
              'assets/images/16-fractal-glass-hero-gradients.jpg',
            ),
          ),

          const SizedBox(height: 8),

          Cutout(
            alignment: .center,
            maskChild: Image.asset('assets/images/pikachu.png', height: 300),
            child: Image.asset('assets/images/22-iridescent-holographic.jpg'),
          ),

          const SizedBox(height: 8),

          // Composited *content* is fine: its layers sit below the dstOut
          // buffer. A composited *mask* would escape that buffer instead.
          Cutout(
            alignment: .center,
            maskChild: const Text(
              'Composited content',
              style: TextStyle(fontSize: 24, fontWeight: .bold),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
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
