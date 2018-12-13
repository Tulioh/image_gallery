package plugins.flutter.imagegallery

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.provider.MediaStore
import android.net.Uri

class ImageGalleryPlugin constructor(private val context: Context) : MethodCallHandler {

    companion object {
        /** Plugin registration.  */
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "image_gallery")
            channel.setMethodCallHandler(ImageGalleryPlugin(registrar.activeContext()))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getImagesFromGallery") {
            result.success(getImagesFromGallery())
        } else {
            result.notImplemented()
        }
    }

    private fun getImagesFromGallery(): Map<String, List<String>> {
        val projection = arrayOf(MediaStore.MediaColumns.DATA,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME)

        val uri: Uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val orderBy = MediaStore.Images.Media.DATE_TAKEN
        val cursor = context.contentResolver.query(uri, projection, null, null, "$orderBy DESC")

        val columnIndexData = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
        val columnIndexFolderName = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)
        var absolutePathOfImage: String?
        var folderName: String?
        val images = mutableMapOf<String, MutableList<String>>()

        while (cursor.moveToNext()) {
            folderName = cursor.getString(columnIndexFolderName)
            absolutePathOfImage = cursor.getString(columnIndexData)
            if (images[folderName] == null) {
                images[folderName] = mutableListOf<String>()
            }
            images.get(folderName)?.add(absolutePathOfImage)
        }

        cursor.close()

        return images
    }
}
