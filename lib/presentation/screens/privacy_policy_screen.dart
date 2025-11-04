import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Politique de Confidentialité'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dernière mise à jour : 04 novembre 2025',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '1. Collecte des informations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous collectons les informations que vous nous fournissez lors de la création de votre compte, '
              'lorsque vous utilisez nos services ou communiquez avec nous. Ces informations peuvent inclure :\n\n'
              '• Vos informations personnelles (nom, prénom, adresse email)\n'
              '• Les informations sur votre établissement scolaire\n'
              '• Les données d\'utilisation de l\'application\n'
              '• Les informations de localisation (si vous activez cette fonctionnalité)',
            ),
            const SizedBox(height: 24),
            const Text(
              '2. Utilisation des informations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les informations que nous recueillons peuvent être utilisées pour :\n\n'
              '• Personnaliser votre expérience utilisateur\n'
              '• Améliorer notre application\n'
              '• Vous envoyer des notifications importantes\n'
              '• Vous fournir un support client\n'
              '• Détecter et prévenir les activités frauduleuses',
            ),
            const SizedBox(height: 24),
            const Text(
              '3. Protection des informations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous mettons en œuvre une variété de mesures de sécurité pour préserver la sécurité de vos informations personnelles. '
              'Nous utilisons un chiffrement de pointe pour protéger les informations sensibles transmises en ligne.',
            ),
            const SizedBox(height: 24),
            const Text(
              '4. Partage des informations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous ne vendons, n\'échangeons et ne transférons pas vos informations personnelles à des tiers. '
              'Cela ne comprend pas les tiers de confiance qui nous aident à exploiter notre application, '
              'à mener nos activités ou à vous fournir un service, tant que ces parties conviennent de garder ces informations confidentielles.',
            ),
            const SizedBox(height: 24),
            const Text(
              '5. Vos droits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous avez le droit de :\n\n'
              '• Accéder à vos données personnelles\n'
              '• Demander la rectification de vos données\n'
              '• Demander la suppression de vos données\n'
              '• Vous opposer au traitement de vos données\n\n'
              'Pour exercer ces droits, veuillez nous contacter à l\'adresse contact@campus-wa.com',
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => context.go('/settings'),
                child: const Text('Retour aux paramètres'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}