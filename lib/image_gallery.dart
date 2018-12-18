import 'dart:async';

import 'package:flutter/services.dart';

class ImageGallery {
  static const MethodChannel _channel = const MethodChannel('image_gallery');

  static Future<List<String>> get imagesFromGallery async {
    final result = await _channel.invokeMethod('getImagesFromGallery');
    final images = <String>[];
    result.forEach((image) {
      images.add(image);
    });
    return images;
  }
}