import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../AppRoutes.dart';
import '../DataHolder.dart';
import '../insLib/BotBarStyle.dart';

class HomeView extends StatelessWidget {
  late BuildContext miContext;
  Dataholder dh = Dataholder.instance;

  HomeView({super.key});

  void cerrarSesion() {
    FirebaseAuth.instance.signOut();
    Navigator.popAndPushNamed(miContext, "/LoginView");
  }

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KJ STUDY'),
        actions: [
          IconButton(
            onPressed: cerrarSesion,
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF653431),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '学  ·  ESTUDIA A TU RITMO',
                        style: TextStyle(
                          color: Color(0xFFFFDAD4),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Un paso más en tu japonés.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Explora, practica y guarda lo que aprendes.',
                        style: TextStyle(color: Color(0xFFF5DBD5), height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Explorar',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Elige por dónde quieres empezar',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                _HomeOption(
                  icon: Icons.auto_stories_outlined,
                  title: 'Lecciones',
                  subtitle: 'Aprende kanji paso a paso',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.lecciones),
                ),
                _HomeOption(
                  icon: Icons.translate_rounded,
                  title: 'Vocabulario',
                  subtitle: 'Descubre nuevas palabras',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.vocabulario),
                ),
                _HomeOption(
                  icon: Icons.edit_note_rounded,
                  title: 'Test',
                  subtitle: 'Pon a prueba lo aprendido',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.test),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tu colección',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus recursos para seguir practicando',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                _HomeOption(
                  icon: Icons.style_outlined,
                  title: 'Mis kanjis',
                  subtitle: 'Consulta tus kanjis guardados',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.misKanjis),
                ),
                _HomeOption(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Mi vocabulario',
                  subtitle: 'Consulta tus palabras guardadas',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.miVocabulario),
                ),
                _HomeOption(
                  icon: Icons.collections_bookmark_outlined,
                  title: 'Listas personalizadas',
                  subtitle: 'Explora tus listas',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.vocabulario),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}

class _HomeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF8E8E4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF943D38)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
