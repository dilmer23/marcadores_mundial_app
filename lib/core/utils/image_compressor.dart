import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageCompressor {
  static const int _maxWidth = 1200;
  static const int _maxHeight = 1200;
  static const int _quality = 80;

  static Uint8List compress(Uint8List original) {
    final image = img.decodeImage(original);
    if (image == null) return original;

    img.Image target = image;
    if (image.width > _maxWidth || image.height > _maxHeight) {
      target = img.copyResize(image,
          width: image.width > _maxWidth ? _maxWidth : null,
          height: image.height > _maxHeight ? _maxHeight : null);
    }

    return Uint8List.fromList(img.encodeJpg(target, quality: _quality));
  }
}
