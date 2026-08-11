import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';

final class RepaintBoundaryStoryRenderer implements StoryImageRenderer {
  const RepaintBoundaryStoryRenderer(this.boundaryKey);

  final GlobalKey boundaryKey;

  @override
  Future<Uint8List> render(
    StoryComposition composition,
    StoryRenderConfig config,
  ) async {
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || boundary.debugNeedsPaint) {
      throw StateError('The Story preview is not ready to render.');
    }
    if ((boundary.size.width - config.logicalWidth).abs() > 0.01 ||
        (boundary.size.height - config.logicalHeight).abs() > 0.01) {
      throw StateError('The Story render surface has an unexpected size.');
    }
    final image = await boundary.toImage(pixelRatio: config.pixelRatio);
    try {
      if (image.width != config.outputWidth ||
          image.height != config.outputHeight) {
        throw StateError('The Story PNG has an unexpected resolution.');
      }
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('The Story PNG could not be encoded.');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }
}
