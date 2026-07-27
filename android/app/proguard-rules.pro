# Flutter Proguard Rules

# Keep all classes in the model package to prevent R8 from obfuscating JSON fields
-keep class com.cametech.playon.model.** { *; }
-keep class com.playon.app.model.** { *; }

# Keep specific models for safety
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep members of models
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Standard Flutter/Firebase rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Razorpay Proguard Rules
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/*
