import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ListIndictor extends Decoration {
  final Color color;
  final ui.Image image;
  final double transX;
  final double transY;

  ListIndictor(
      {this.image, this.transX, this.transY, this.color = Colors.white});

  @override
  BoxPainter createBoxPainter([onChanged]) {
    return _ListIndictorPainter(
        image: image, transX: transX, transY: transY, color: color);
  }
}

class _ListIndictorPainter extends BoxPainter {
  final Color color;
  final ui.Image image;
  final double transX;
  final double transY;
  static const int width = 60; //indicator width
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (image == null) {
      return;
    }
    final Paint paint = Paint();
    paint.color = this.color;
    paint.style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(transX, transY);
    canvas.drawImage(image, offset, paint);
    canvas.restore();
  }

  _ListIndictorPainter(
      {this.image, this.transX, this.transY, this.color = Colors.black});
}
