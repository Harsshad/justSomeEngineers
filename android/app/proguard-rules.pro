# Jitsi Meet SDK
-keep class org.jitsi.meet.** { *; }
-keep class org.jitsi.meet.sdk.** { *; }

# WebRTC
-keep class org.webrtc.** { *; }
-dontwarn org.chromium.build.BuildHooksAndroid

# Required for React Native components used internally by Jitsi Meet SDK
-keepclassmembers class * { @com.facebook.react.uimanager.annotations.ReactProp <methods>; }
-keepclassmembers class * { @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>; }
-keep,includedescriptorclasses class com.facebook.react.bridge.** { *; }

# Prevent stripping native methods
-keepclassmembers,includedescriptorclasses class * { native <methods>; }

# Avoid warnings for dependencies used by Jitsi Meet
-dontwarn com.facebook.react.**
-dontwarn com.google.appengine.**
-dontwarn javax.servlet.**
-dontwarn okio.**
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn java.nio.file.*
