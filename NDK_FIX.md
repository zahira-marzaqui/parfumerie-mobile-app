# Solution au problème NDK Android

## Problème
L'erreur `ld.lld: error: unknown file type` indique que le NDK version 27.0.12077973 est corrompu ou incompatible.

## Solutions

### Solution 1 : Réinstaller le NDK via Android Studio (Recommandé)

1. Ouvrez **Android Studio**
2. Allez dans **Tools > SDK Manager**
3. Onglet **SDK Tools**
4. Décochez **NDK (Side by side)** version 27.0.12077973
5. Cliquez **Apply** pour désinstaller
6. Cochez une version stable du NDK (par exemple **25.2.9519653** ou **26.1.10909125**)
7. Cliquez **Apply** pour installer
8. Relancez `flutter run`

### Solution 2 : Spécifier une version de NDK dans build.gradle.kts

Si vous avez installé une version stable du NDK, modifiez `android/app/build.gradle.kts` :

```kotlin
android {
    namespace = "com.example.parfumerie_mobile_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "25.2.9519653" // Remplacez par votre version installée
    // ...
}
```

### Solution 3 : Nettoyer et réessayer

Parfois, un simple nettoyage résout le problème :

```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

### Solution 4 : Utiliser un émulateur x86_64 au lieu d'arm64

Si vous utilisez un émulateur, créez-en un avec l'architecture x86_64 qui ne nécessite pas le NDK arm64 :

1. Ouvrez **Android Studio > AVD Manager**
2. Créez un nouvel émulateur
3. Choisissez une image système **x86_64** (par exemple, **x86_64 Images**)

## Vérification

Pour vérifier les versions de NDK installées :

```bash
dir "C:\Users\AD\AppData\Local\Android\Sdk\ndk"
```

Ou via Android Studio : **Tools > SDK Manager > SDK Tools > NDK (Side by side)**
