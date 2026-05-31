import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/theme/app_theme.dart';

class OwnerShell extends StatelessWidget {
  final Widget child;
  const OwnerShell({super.key, required this.child});

  int _indexActual(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/owner/productos')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexActual(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del dueño'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              await auth.cerrarSesion();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.morado.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) {
            switch (i) {
              case 0:
                context.go('/owner');
                break;
              case 1:
                context.go('/owner/productos');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cake_outlined),
              activeIcon: Icon(Icons.cake),
              label: 'Productos',
            ),
          ],
        ),
      ),
    );
  }
}