# ProGuard rules for Google ML Kit to prevent R8 from stripping language builder classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
