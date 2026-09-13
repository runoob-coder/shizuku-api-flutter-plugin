package com.noob_coder.shizuku_api

import android.os.RemoteException
import android.util.Log
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import kotlin.system.exitProcess

/**
 * Runs **inside the process created by the Shizuku server**, which already has shell (or root)
 * identity, therefore the commands started from here are privileged.
 *
 * The Shizuku server instantiates this class itself (through the class loader of the app that
 * declares [rikka.shizuku.Shizuku.UserServiceArgs]), so the class name and a usable constructor
 * must stay available.
 */
class ShizukuUserService : IUserService.Stub() {

    /**
     * Run a shell command and return its combined output.
     */
    @Throws(RemoteException::class)
    override fun exec(command: String): String {
        val outputBuilder = StringBuilder()
        var process: Process? = null
        try {
            process = ProcessBuilder("sh", "-c", command)
                .directory(File(WORKING_DIRECTORY))
                .redirectErrorStream(true)
                .start()

            BufferedReader(InputStreamReader(process.inputStream)).use { reader ->
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    outputBuilder.append(line).append("\n")
                }
            }

            process.waitFor()
        } catch (e: Exception) {
            outputBuilder.append("Unexpected error: ").append(e.message)
            Log.e(TAG, "Failed to run command: $command", e)
        } finally {
            process?.destroy()
        }
        return outputBuilder.toString().trim()
    }

    /**
     * Reserved destroy method, Shizuku calls it when the service has to be removed.
     */
    override fun destroy() {
        Log.i(TAG, "destroy")
        exitProcess(0)
    }

    override fun exit() {
        destroy()
    }

    private companion object {
        const val TAG = "ShizukuUserService"
        const val WORKING_DIRECTORY = "/"
    }
}
