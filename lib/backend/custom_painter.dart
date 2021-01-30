import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

import 'package:sickles_nhs_app/backend/size_config.dart';

class TabIndicationPainter extends CustomPainter {
  Paint painter;
  final double dxTarget;
  final double dxEntry;
  final double radius;
  final double dy;

  final PageController pageController;

  TabIndicationPainter({
    this.dxTarget = 110.0,
    this.dxEntry = 35.0,
    this.radius = 21.0,
    this.dy = 25, this.pageController}) : super(repaint: pageController) {
      painter = new Paint()
      ..color = Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    }

    @override
    void paint(Canvas canvas, Size size) {
      final pos = pageController.position;
      double fullExtent = (pos.maxScrollExtent - pos.minScrollExtent + pos.viewportDimension);
      fullExtent = SizeConfig.blockSizeHorizontal * 330;
  
      double pageOffset = pos.extentBefore / fullExtent;
      
      bool left2right = dxEntry < dxTarget;
      Offset entry = new Offset(left2right ? dxEntry: dxTarget, dy);
      Offset target = new Offset(left2right ? dxTarget: dxEntry, dy);

      Path path = new Path();
      path.addArc(Rect.fromCircle(center: entry, radius: radius), 0.5 * pi, 1 * pi);
      path.addRect(new Rect.fromLTRB(entry.dx, dy - radius, target.dx, dy + radius));
      path.addArc(new Rect.fromCircle(center: target, radius: radius), 1.5 * pi, 1 * pi);

      canvas.translate(size.width * pageOffset, 0);
      canvas.drawShadow(path, Color(0xFFfbab66), 3, true);
      canvas.drawPath(path, painter);
    }

    @override
    bool shouldRepaint(TabIndicationPainter oldDelegate) => true;
}