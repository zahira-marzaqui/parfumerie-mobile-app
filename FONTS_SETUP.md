# Configuration des polices Google Fonts

## Instructions pour ajouter les polices

### Option 1 : Utiliser google_fonts (Recommandé - Plus simple)

1. Ajoutez la dépendance dans `pubspec.yaml` :

```yaml
dependencies:
  google_fonts: ^6.1.0
```

2. Exécutez `flutter pub get`

3. Modifiez `lib/core/theme/app_theme.dart` pour utiliser `GoogleFonts` :

```dart
import 'package:google_fonts/google_fonts.dart';

// Remplacez les fontFamily par :
fontFamily: GoogleFonts.playfairDisplay().fontFamily,
// ou
fontFamily: GoogleFonts.inter().fontFamily,
```

### Option 2 : Télécharger les polices manuellement

1. Téléchargez les polices depuis Google Fonts :
   - Playfair Display : https://fonts.google.com/specimen/Playfair+Display
   - Inter : https://fonts.google.com/specimen/Inter

2. Créez le dossier `fonts/` à la racine du projet

3. Placez les fichiers .ttf dans `fonts/` :
   - PlayfairDisplay-Regular.ttf
   - PlayfairDisplay-SemiBold.ttf (600)
   - PlayfairDisplay-Bold.ttf (700)
   - Inter-Light.ttf (300)
   - Inter-Regular.ttf (400)
   - Inter-Medium.ttf (500)
   - Inter-SemiBold.ttf (600)
   - Inter-Bold.ttf (700)

4. Le `pubspec.yaml` est déjà configuré pour utiliser ces polices

## Polices alternatives

Si vous préférez d'autres polices de luxe :
- **Cinzel** : https://fonts.google.com/specimen/Cinzel
- **Libre Baskerville** : https://fonts.google.com/specimen/Libre+Baskerville
- **Montserrat** : https://fonts.google.com/specimen/Montserrat (pour le texte)
- **Poppins** : https://fonts.google.com/specimen/Poppins (pour le texte)
