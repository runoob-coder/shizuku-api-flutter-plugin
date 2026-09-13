package com.noob_coder.shizuku_api

import android.content.Context
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import rikka.shizuku.Shizuku
import java.util.concurrent.Executors

/**
 * ShizukuApiPlugin
 */
class ShizukuApiPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var mApplicationContext: Context? = null
    @Volatile
    private var mShizukuShell: ShizukuShell? = null

    /** Binding the user service blocks until Shizuku answers, so it never runs on the platform
     * thread, the result is posted back to it once the command is done. */
    private val mExecutor = Executors.newSingleThreadExecutor()
    private val mMainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "shizuku_api")
        channel.setMethodCallHandler(this)
        mApplicationContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "requestPermission" -> {
                val requestCode = call.argument<Int>("requestCode") ?: 0
                requestPermissionAsync(requestCode, result)
            }
            "runCommand" -> {
                runCommand(call.argument<String>("command"), result)
            }
            "pingBinder" -> {
                result.success(isBinderRunning())
            }
            "checkPermission" -> {
                val isGranted = Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
                result.success(isGranted)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Run a command using Shizuku.
     *
     * The Shizuku user service is bound on the first call and reused afterwards, it is only
     * released from [onDetachedFromEngine].
     *
     * @param command Shell Command to run
     * @param result result that sent back to flutter
     */
    private fun runCommand(command: String?, result: Result) {
        val context = mApplicationContext
        if (context == null) {
            result.error("illegal_state", "Plugin is not attached to a Flutter engine.", null)
            return
        }

        mExecutor.execute {
            val shizukuShell = mShizukuShell ?: ShizukuShell(context).also { mShizukuShell = it }
            val output = shizukuShell.execCommands(command)
            mMainHandler.post { result.success(output) }
        }
    }

    /**
     * Check if Shizuku is running.
     *
     * @return true if Shizuku is running, false if not
     */
    private fun isBinderRunning(): Boolean {
        return Shizuku.pingBinder()
    }


    /**
     * Request Shizuku permission.
     * @param code Request code
     * @param result result that sent back to flutter
     */
    private fun requestPermissionAsync(code: Int, result: Result) {
        if (Shizuku.isPreV11()) {
            // Pre-v11 is unsupported
            result.success(false)
            return
        }

        if (Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED) {
            // Permission already granted
            result.success(true)
            return
        }

        if (Shizuku.shouldShowRequestPermissionRationale()) {
            // User denied permission and chose "Don't ask again"
            result.success(false)
            return
        }

        // Request permission and listen for results
        // fix for https://github.com/santhosh-D-subramani/Shizuku-Plugin/issues/2
        Shizuku.addRequestPermissionResultListener(object : Shizuku.OnRequestPermissionResultListener {
            override fun onRequestPermissionResult(requestCode: Int, grantResult: Int) {
                if (requestCode == code) {
                    // Cleaning up listener once result is handled
                    Shizuku.removeRequestPermissionResultListener(this)
                    val isGranted = grantResult == PackageManager.PERMISSION_GRANTED
                    result.success(isGranted)
                }
            }
        })

        Shizuku.requestPermission(code)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        mExecutor.execute {
            mShizukuShell?.destroy()
            mShizukuShell = null
        }
        // Graceful shutdown, the queued unbind above still runs.
        mExecutor.shutdown()
        mApplicationContext = null
    }
}
