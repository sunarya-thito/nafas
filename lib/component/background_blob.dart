import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nafas/app_data.dart';
import 'package:nafas/theme.dart';

class BackgroundBlob extends StatelessWidget {
  final Widget? child;
  const BackgroundBlob({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderBackgroundBlob(
      backgroundShader: NafasDataWidget.of(context)!.backgroundShader,
      child: child,
    );
  }
}

class ShaderBackgroundBlob extends StatefulWidget {
  final FragmentProgram backgroundShader;
  final Widget? child;

  const ShaderBackgroundBlob({
    Key? key,
    this.child,
    required this.backgroundShader,
  }) : super(key: key);

  @override
  State<ShaderBackgroundBlob> createState() => _ShaderBackgroundBlobState();
}

class _ShaderBackgroundBlobState extends State<ShaderBackgroundBlob>
    with SingleTickerProviderStateMixin {
  late FragmentShader _shader;

  final List<Blob> blobs = [
    Blob.randomize(),
    Blob.randomize(),
    Blob.randomize(),
  ];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _shader = widget.backgroundShader.fragmentShader();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(
      () {
        setState(() {
          for (int i = 0; i < 3; i++) {
            Blob blob = blobs[i];
            blob.rotation += blob.rotationSpeed;
            blob.rotation %= 360;
          }
        });
      },
    );
  }

  @override
  void didUpdateWidget(covariant ShaderBackgroundBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundShader != widget.backgroundShader) {
      _shader = widget.backgroundShader.fragmentShader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: widget.child,
      painter: BackgroundCustomPainter(
          _shader, [...blobs], context.theme.backgroundColor),
    );
  }
}

class Blob {
  double x = 0;
  double y = 0;
  double z = 0;
  Color color = Colors.white;
  double rotation = 0;
  double rotationSpeed = 0;

  Blob();

  factory Blob.randomize() {
    Random random = Random();
    Blob blob = Blob();
    blob.x = random.nextDouble();
    blob.y = random.nextDouble();
    blob.z = 0.1 + random.nextDouble() * 0.6;
    // blob colors are blue
    int r = kRedMin + random.nextInt(kRedMax - kRedMin);
    int g = kGreenMin + random.nextInt(kGreenMax - kGreenMin);
    int b = kBlueMin + random.nextInt(kBlueMax - kBlueMin);
    blob.color = Color.fromARGB(50, r, g, b);
    blob.rotationSpeed = 0.1 + random.nextDouble() * 0.2;
    return blob;
  }
}

// to create varies of blue colors, use these range of values
const int kRedMin = 0;
const int kRedMax = 20;
const int kGreenMin = 0;
const int kGreenMax = 20;
const int kBlueMin = 20;
const int kBlueMax = 50;

class BackgroundCustomPainter extends CustomPainter {
  final FragmentShader backgroundShader;
  final List<Blob> blobs;
  final Color backgroundColor;

  BackgroundCustomPainter(
      this.backgroundShader, this.blobs, this.backgroundColor);

  void updateValue(Canvas canvas, Size size, FragmentShader shader) {
    /*
    uniform vec2 resolution;
    uniform vec3 blobs[3];
    uniform vec3 colors[3];
     */
    backgroundShader.setFloat(0, size.width);
    backgroundShader.setFloat(1, size.height);

    int index = 2;
    for (int i = 0; i < 3; i++) {
      Blob blob = blobs[i];
      // backgroundShader.setFloat(index++, blob.x);
      // backgroundShader.setFloat(index++, blob.y);
      // backgroundShader.setFloat(index++, blob.z);
      // blob xyz are from 0 to 1 and is offset from the canvas center
      double rotation = blob.rotation * pi / 180;
      double x = blob.x;
      double y = blob.y;
      double z = blob.z;
      double rotatedX = x * cos(rotation) - y * sin(rotation);
      double rotatedY = x * sin(rotation) + y * cos(rotation);
      rotatedX = rotatedX * size.width / 2 + size.width / 2;
      rotatedY = rotatedY * size.height / 2 + size.height / 2;
      backgroundShader.setFloat(index++, rotatedX);
      backgroundShader.setFloat(index++, rotatedY);
      backgroundShader.setFloat(index++, blob.z);
    }
    for (int i = 0; i < 3; i++) {
      Blob blob = blobs[i];
      backgroundShader.setFloat(index++, blob.color.red / 255);
      backgroundShader.setFloat(index++, blob.color.green / 255);
      backgroundShader.setFloat(index++, blob.color.blue / 255);
    }
    backgroundShader.setFloat(index++, backgroundColor.red / 255);
    backgroundShader.setFloat(index++, backgroundColor.green / 255);
    backgroundShader.setFloat(index++, backgroundColor.blue / 255);
  }

  @override
  void paint(Canvas canvas, Size size) {
    updateValue(canvas, size, backgroundShader);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = backgroundShader,
    );
  }

  @override
  bool shouldRepaint(covariant BackgroundCustomPainter oldDelegate) {
    return true;
  }
}
