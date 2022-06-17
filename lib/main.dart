import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shader Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Shader Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  FragmentProgram? fragmentProgram;
  Ticker? ticker;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final spirv = await rootBundle.load('shaders/glowing_ring.frag');
      fragmentProgram = await FragmentProgram.compile(spirv: spirv.buffer);
      setState(() {});
    });

    ticker = createTicker((_) {
      setState(() {});
    })
      ..start();
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => fragmentProgram != null
              ? CustomPaint(
                  painter: ShaderPaint(fragmentProgram!),
                  child: Center(
                    child: SizedBox(
                      width: constraints.biggest.shortestSide * 0.4,
                      height: constraints.biggest.shortestSide * 0.4,
                      child: const FlutterLogo(),
                    ),
                  ),
                )
              : const Text('読み込み中...'),
        ),
      ),
    );
  }
}

class ShaderPaint extends CustomPainter {
  ShaderPaint(this.fragProgram);

  final FragmentProgram fragProgram;

  @override
  void paint(Canvas canvas, Size size) {
    var time = (DateTime.now().millisecondsSinceEpoch % 3000) / 3000.0;

    final shader = fragProgram.shader(
      floatUniforms: Float32List.fromList([
        (0.7 * pi) + (sin(pi * time) * (0.3 * pi)),
        size.width,
        size.height,
      ]),
    );

    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
