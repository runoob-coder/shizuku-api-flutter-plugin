## 1.0.1

- 📝 **Docs**: improved documentation links.

## 1.0.0

* `ShizukuApi` with four methods:
    * `pingBinder()` — check whether the Shizuku binder service is running.
    * `checkPermission()` — check whether the Shizuku permission has been granted to your app.
    * `requestPermission()` — show the Shizuku permission dialog and return the user's choice.
    * `runCommand(String command)` — execute a shell command as shell (ADB) identity and return its
      output.
* Shell command execution through a Shizuku **user service** (`Shizuku.UserServiceArgs` + the
  `IUserService` AIDL interface) instead of the deprecated `Shizuku.newProcess`. The service is
  instantiated by the Shizuku server in a dedicated process that already runs with shell (or root)
  identity.
* The user service is bound lazily on the first `runCommand()` call and reused afterwards; it is
  unbound in `onDetachedFromEngine`.
* `runCommand()` runs on a single-thread background executor, so the platform thread is never
  blocked by the (blocking) user service bind; the result is posted back to the main thread.
* `requestPermission()` short-circuits when Shizuku is pre-v11 (returns `false`), when the
  permission is already granted (returns `true`), or when the user previously chose "Don't ask
  again" (returns `false`). The result listener is removed once the request has been handled.
* Pre-bind guard rails: Shizuku must be running, the Shizuku API level must be 10 or above (user
  services are unsupported below that), and the permission must be granted. The bind has a 10-second
  timeout and is rolled back when it expires.
* Command output is returned as a single string with stderr merged into stdout.