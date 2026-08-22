import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/presentation/memory_media_gallery.dart';

final class MemoryGalleryPage extends StatelessWidget {
  const MemoryGalleryPage({required this.memoryId, super.key});

  final String memoryId;

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Photos')),
    body: MemoryMediaGallery(memoryId: memoryId),
  );
}
