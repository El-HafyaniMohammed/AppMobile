# Règles pour Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Règles pour les credentials
-keepclassmembers class com.google.android.gms.auth.api.credentials.** { *; }
-keep class com.google.android.gms.auth.api.credentials.** { *; }

# Règles pour Play Core
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }

# Règles pour Google Play Services Tasks
-keep class com.google.android.gms.tasks.** { *; }

# Règles pour Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Règles pour Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }

# Règles pour les plugins smart_auth
-keep class fman.ge.smart_auth.** { *; }