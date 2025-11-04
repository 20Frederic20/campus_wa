import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Centre d\'aide'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // _buildSectionHeader('Questions fréquentes'),
          // _buildHelpItem(
          //   context,
          //   title: 'Comment créer un compte ?',
          //   onTap: () => _showHelpDialog(
          //     context,
          //     title: 'Création de compte',
          //     content: 'Pour créer un compte, suivez ces étapes :\n\n1. Cliquez sur "S\'inscrire" sur l\'écran d\'accueil\n2. Remplissez le formulaire avec vos informations\n3. Validez votre adresse email\n4. Connectez-vous avec vos identifiants',
          //   ),
          // ),
          // _buildHelpItem(
          //   context,
          //   title: 'Comment réinitialiser mon mot de passe ?',
          //   onTap: () => _showHelpDialog(
          //     context,
          //     title: 'Réinitialisation du mot de passe',
          //     content: 'Si vous avez oublié votre mot de passe :\n\n1. Cliquez sur "Mot de passe oublié" sur l\'écran de connexion\n2. Entrez votre adresse email\n3. Suivez le lien reçu par email pour réinitialiser votre mot de passe',
          //   ),
          // ),
          _buildHelpItem(
            context,
            title: 'Comment contacter le support ?',
            onTap: () => _showHelpDialog(
              context,
              title: 'Contacter le support',
              content: 'Vous pouvez nous contacter :\n\n• Par email : support@campus-wa.com\n• Via le formulaire de contact dans l\'application\n• Par téléphone au 01 23 45 67 89 (du lundi au vendredi, 9h-18h)',
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Guides d\'utilisation'),
          _buildHelpItem(
            context,
            title: 'Guide de prise en main',
            onTap: () => context.go('/help/guide'),
          ),
          _buildHelpItem(
            context,
            title: 'Fonctionnalités avancées',
            onTap: () => context.go('/help/advanced'),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Support technique'),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Envoyer un email'),
            onTap: () => _launchEmail(context),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Appeler le support'),
            onTap: () => _callSupport(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showHelpDialog(BuildContext context, {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _launchEmail(BuildContext context) {
    // Implémentez la logique pour ouvrir le client email
    _showHelpDialog(
      context,
      title: 'Envoyer un email',
      content: 'Ouvrir votre application email avec l\'adresse support@campus-wa.com ?',
    );
  }

  void _callSupport(BuildContext context) {
    // Implémentez la logique pour passer un appel
    _showHelpDialog(
      context,
      title: 'Appeler le support',
      content: 'Composer le 01 23 45 67 89 ?',
    );
  }
}