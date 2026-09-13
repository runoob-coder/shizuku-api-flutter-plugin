package com.noob_coder.shizuku_api

import android.content.ComponentName
import android.content.Context
import android.content.ServiceConnection
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.IBinder
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

import rikka.shizuku.Shizuku

/**
 * Executes shell commands through a Shizuku user service.
 *
 * [Shizuku.newProcess] is deprecated, [ShizukuUserService] is the supported replacement: the
 * Shizuku server instantiates it inside a dedicated process that already runs with shell (or
 * root) identity, so the commands executed there need no further privilege escalation.
 */
class ShizukuShell(private val mContext: Context) {

    /** The bound user service, null while not connected. */
    @Volatile
    private var mService: IUserService? = null

    /** True between [Shizuku.bindUserService] and [destroy]. */
    @Volatile
    private var mBound = false

    /** Released once [onServiceConnected] is called, awaited by [execCommands]. */
    private var mConnected = CountDownLatch(1)

    private val mUserServiceArgs = Shizuku.UserServiceArgs(
        ComponentName(mContext.packageName, ShizukuUserService::class.java.name)
    )
        .daemon(false)
        .tag(SERVICE_TAG)
        .processNameSuffix(PROCESS_NAME_SUFFIX)
        .debuggable(isDebuggable())
        .version(appVersionCode())

    private val mServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            // Ignore a binder that arrives after destroy() or after a bind timeout.
            if (mBound && binder != null && binder.pingBinder()) {
                mService = IUserService.Stub.asInterface(binder)
            }
            mConnected.countDown()
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            mService = null
        }
    }

    /**
     * @return true when the user service is connected and ready to run commands
     */
    fun isBusy(): Boolean {
        return mService != null
    }

    /**
     * Run a shell command, the user service is bound on first use and then reused.
     *
     * @param command shell command to run
     * @return the output of the command
     */
    fun execCommands(command: String?): String {
        val outputBuilder = StringBuilder()
        try {
            if (command.isNullOrEmpty()) {
                throw IllegalArgumentException("Command cannot be null or empty")
            }

            outputBuilder.append(requireUserService().exec(command))
        } catch (e: IllegalArgumentException) {
            outputBuilder.append("Error: ").append(e.message)
        } catch (e: SecurityException) {
            outputBuilder.append("Error: ").append(e.message)
        } catch (e: Exception) {
            outputBuilder.append("Unexpected error: ").append(e.message)
            e.printStackTrace()
        }
        return outputBuilder.toString().trim()
    }

    /**
     * Unbind the user service, Shizuku then destroys the process running it.
     */
    fun destroy() {
        if (!mBound) {
            return
        }
        mBound = false
        mService = null
        try {
            Shizuku.unbindUserService(mUserServiceArgs, mServiceConnection, true)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * Bind the user service on first use, the existing connection is reused afterwards.
     */
    @Synchronized
    private fun requireUserService(): IUserService {
        mService?.let { return it }

        if (!Shizuku.pingBinder()) {
            throw IllegalStateException("Shizuku is not running")
        }
        if (Shizuku.isPreV11() || Shizuku.getVersion() < MIN_SHIZUKU_API_VERSION) {
            throw IllegalStateException(
                "Shizuku API $MIN_SHIZUKU_API_VERSION or above is required for user services"
            )
        }
        if (Shizuku.checkSelfPermission() != PackageManager.PERMISSION_GRANTED) {
            throw SecurityException("Shizuku permission is not granted")
        }

        mConnected = CountDownLatch(1)
        mBound = true
        try {
            Shizuku.bindUserService(mUserServiceArgs, mServiceConnection)
        } catch (e: Exception) {
            mBound = false
            throw e
        }

        // onServiceConnected is called from a binder thread of this process, waiting here does
        // not block Shizuku, so it is safe as long as this is not the platform thread.
        if (!mConnected.await(BIND_TIMEOUT_SECONDS, TimeUnit.SECONDS)) {
            // Do not leave a pending connection behind when the service never showed up.
            destroy()
            throw IllegalStateException("Timed out while binding the Shizuku user service")
        }

        return mService ?: throw IllegalStateException("Failed to bind the Shizuku user service")
    }

    private fun isDebuggable(): Boolean {
        return (mContext.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    /**
     * The user service is restarted by Shizuku when the version of the app changed.
     */
    @Suppress("DEPRECATION")
    private fun appVersionCode(): Int {
        return try {
            val packageInfo = mContext.packageManager.getPackageInfo(mContext.packageName, 0)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode.toInt()
            } else {
                @Suppress("DEPRECATION")
                packageInfo.versionCode
            }
        } catch (e: Exception) {
            1
        }
    }

    private companion object {
        /** [Shizuku.bindUserService] requires the Shizuku API level 10. */
        const val MIN_SHIZUKU_API_VERSION = 10
        const val BIND_TIMEOUT_SECONDS = 10L
        const val SERVICE_TAG = "shizuku_api"
        const val PROCESS_NAME_SUFFIX = "shizuku_api"
    }
}
