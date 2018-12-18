# image_gallery

A Flutter plugin to fetch images from user gallery on Android and iOS.

## Usage

To use this plugin, add `image_gallery` as a [dependency in your `pubspec.yaml` file](https://flutter.io/platform-plugins/).

Make sure you add the following permissions to your Android Manifest:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

On iOS, make sure to set `NSContactsUsageDescription` in the `Info.plist` file

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires photo library access to function properly.</string>
```

## Example

``` dart
// Import package
import 'package:image_gallery/image_gallery.dart';

// Fetch images from gallery
final images = await ImageGallery.imagesFromGallery;

```

## Todo

- [ ] Filter
- [ ] Sort