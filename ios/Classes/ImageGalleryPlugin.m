#import "ImageGalleryPlugin.h"
#import <image_gallery/image_gallery-Swift.h>

@implementation ImageGalleryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImageGalleryPlugin registerWithRegistrar:registrar];
}
@end
