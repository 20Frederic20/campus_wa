#!/bin/bash
echo "Mise à jour de l'icône..."

# 1. Génère les icônes
flutter pub run flutter_launcher_icons

# 2. Nettoie (optionnel)
flutter clean

# 3. Ajoute les fichiers générés
git add android/app/src/main/res/mipmap-*
git add ios/Runner/Assets.xcassets/AppIcon.appiconset/
git add pubspec.lock

echo "Icône mise à jour ! Commit avec : git commit -m 'chore: update app icon'"