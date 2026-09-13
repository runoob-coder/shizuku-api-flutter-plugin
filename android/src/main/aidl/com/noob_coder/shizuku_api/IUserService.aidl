// IUserService.aidl
package com.noob_coder.shizuku_api;

/**
 * Interface of the Shizuku user service.
 *
 * The implementation, [com.noob_coder.shizuku_api.ShizukuUserService], is instantiated by the
 * Shizuku server inside a dedicated process that already runs with shell (or root) identity.
 */
interface IUserService {
    /**
     * Reserved by the Shizuku server, called when the service has to be destroyed.
     * The transaction id MUST stay 16777114.
     */
    void destroy() = 16777114;

    /**
     * Run a shell command inside the user service process.
     */
    String exec(String command) = 1;

    /**
     * Ask the user service to terminate its own process.
     */
    void exit() = 2;
}
