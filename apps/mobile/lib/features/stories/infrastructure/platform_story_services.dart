import 'package:image_picker/image_picker.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:share_plus/share_plus.dart';

final class ImagePickerStoryMediaPicker implements StoryMediaPicker {
  ImagePickerStoryMediaPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<StoryMedia?> chooseImage() async {
    final selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected == null) return null;
    return StoryMedia(
      id: 'story-photo:${DateTime.now().toUtc().microsecondsSinceEpoch}',
      label: 'Selected photo',
      kind: StoryMediaKind.image,
      localPath: selected.path,
      privacyClassification: PrivacyClassification.personal,
    );
  }
}

final class SharePlusStoryShareService implements StoryShareService {
  const SharePlusStoryShareService();

  @override
  Future<StoryShareOutcome> sharePng(
    TemporaryStoryFile file, {
    required String shareTitle,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        title: shareTitle,
      ),
    );
    return switch (result.status) {
      ShareResultStatus.success => StoryShareOutcome.shared,
      ShareResultStatus.dismissed => StoryShareOutcome.dismissed,
      ShareResultStatus.unavailable => StoryShareOutcome.unavailable,
    };
  }
}
