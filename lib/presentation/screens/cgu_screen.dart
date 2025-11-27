import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CguScreen extends StatelessWidget {
  const CguScreen({super.key});

  // Ton texte exact (remplace Campus WA si besoin)
  static const String _cguText = '''
Conditions Générales d'Utilisation (CGU) de l'application Campus WA
Dernière mise à jour : 04 novembre 2025

1. Objet
Les présentes CGU définissent les modalités d’utilisation de l’application Campus WA, accessible sur iOS et Android.

2. Acceptation des CGU
En utilisant l’Application, vous acceptez pleinement ces CGU. Sinon → désinstallez-la.

3. Description du service
Campus WA vous permet de :
• Visualiser amphithéâtres & universités sur une carte
• Voir votre position en temps réel
• Obtenir l’itinéraire vers la salle la plus proche

4. Collecte et utilisation des données
• Données de localisation : collectées UNIQUEMENT quand l’app est ouverte.
• Aucune donnée n’est vendue ni partagée.
• Consentement : en continuant, vous acceptez.

5. Technologies utilisées
GPS + OpenStreetMap. Pas de cookie, pas de pub.

6. Vos responsabilités
• Respectez la loi
• Ne piratez pas l’app
• Mettez à jour régulièrement

7. Nos responsabilités
On fait tout pour que ça marche.
Pas responsable si : maintenance, coupure réseau, apocalypse zombie.

8. Propriété intellectuelle
Tout le code, design, logo © Campus WA 2025.

9. Modifications
On peut changer les CGU. Vous serez notifié au prochain lancement.

Contact : contact@campuswa.com
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CGU'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copier',
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: _cguText));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('CGU copiées !')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre stylé
            Text(
              'Conditions Générales d’Utilisation',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Campus WA • 04 novembre 2025',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 32),

            // Texte CGU mis en forme
            const SelectableText(
              _cguText,
              style: TextStyle(height: 1.6, fontSize: 15),
            ),

            const SizedBox(height: 40),

            // Bouton "J’accepte"
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('J’accepte les CGU'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 20),
            const Center(
              child: TextButton(
                child: Text('Refuser → quitter l’app'),
                onPressed: SystemNavigator.pop, // ferme l’app
              ),
            ),
          ],
        ),
      ),
    );
  }
}
