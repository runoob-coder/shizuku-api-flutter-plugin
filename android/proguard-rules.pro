# The Shizuku server instantiates the user service through reflection, so the class and its
# default constructor must survive shrinking/obfuscation.
-keep class com.noob_coder.shizuku_api.ShizukuUserService {
    <init>();
}
