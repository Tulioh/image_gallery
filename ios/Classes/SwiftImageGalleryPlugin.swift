import Flutter
import UIKit
import Photos

public class SwiftImageGalleryPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "image_gallery", binaryMessenger: registrar.messenger())
        let instance = SwiftImageGalleryPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            result(self.fetchPhotos())
        case .restricted, .denied:
            returnError(result: result)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        result(self.fetchPhotos())
                    }
                case .restricted, .denied, .notDetermined:
                    self.returnError(result: result)
                }
            }
        }
    }
    
    private func returnError(result: @escaping FlutterResult) {
        result(FlutterError(code: "0",
                            message: "Photo access permission denied",
                            details: nil))
    }

    private func fetchPhotos() -> Array<String> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assetsFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = false
        imageRequestOptions.isSynchronous = true
        imageRequestOptions.deliveryMode = .fastFormat
        imageRequestOptions.resizeMode = .fast
        
        var imagesPath = Array<String>()
        
        assetsFetchResult.enumerateObjects({asset, _, _ in
            PHImageManager.default().requestImageData(for: asset, options: imageRequestOptions, resultHandler: { (imagedata, dataUTI, orientation, info) in
                if let info = info, info.keys.contains(NSString(string: "PHImageFileURLKey")), let path = info[NSString(string: "PHImageFileURLKey")] as? NSURL, let pathValue = path.relativePath {
                    imagesPath.append(pathValue)
                }
            })
        })
        
        return imagesPath
    }
}
