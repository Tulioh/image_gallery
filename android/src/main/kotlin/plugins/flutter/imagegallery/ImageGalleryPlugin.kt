package plugins.flutter.imagegallery

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.provider.MediaStore
import android.net.Uri
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.SparseArray
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.ThreadLocalRandom

class ImageGalleryPlugin constructor(private val registrar: Registrar) : MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {

    private val permissionsCallback = SparseArray<Result>()

    companion object {
        /** Plugin registration.  */
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "image_gallery")
            val plugin = ImageGalleryPlugin(registrar)
            registrar.addRequestPermissionsResultListener(plugin)
            channel.setMethodCallHandler(plugin)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getImagesFromGallery") {
            requestPermissionIfNecessaryAndFetchImages(result)
        } else {
            result.notImplemented()
        }
    }

    private fun requestPermissionIfNecessaryAndFetchImages(result: Result) {
        if (VERSION.SDK_INT >= VERSION_CODES.M) {
            if (registrar.activity().checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                getImagesFromGallery(result)
            } else {
                val requestCode = ThreadLocalRandom.current().nextInt(1, 1000)
                permissionsCallback.append(requestCode, result)
                registrar.activity().requestPermissions(arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE), requestCode)
            }
        } else {
            getImagesFromGallery(result)
        }
    }

    private fun getImagesFromGallery(result: Result) {
        val projection = arrayOf(MediaStore.MediaColumns.DATA,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME)

        val uri: Uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val orderBy = MediaStore.Images.Media.DATE_TAKEN
        val cursor = registrar.activeContext().contentResolver.query(uri, projection, null, null, "$orderBy DESC")

        val columnIndexData = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
        var absolutePathOfImage: String?
        val images = mutableListOf<String>()

        while (cursor.moveToNext()) {
            absolutePathOfImage = cursor.getString(columnIndexData)
            images.add(absolutePathOfImage)
        }

        cursor.close()

        result.success(images)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>?, grantResults: IntArray?): Boolean {
        if (permissionsCallback.get(requestCode) != null) {
            val result = permissionsCallback[requestCode]!!
            if (grantResults != null && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                getImagesFromGallery(result)
                permissionsCallback.remove(requestCode)
            } else {
                result.error("Permission denied", "User declined READ_EXTERNAL_STORAGE permission", null)
            }
        }

        return true
    }
}
