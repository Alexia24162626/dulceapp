import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dulceapp/theme/app_theme.dart';

class ClientShell extends StatelessWidget {
  final Widget child;
  const ClientShell({super.key, required this.child});

  int _indexActual(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/favoritos')) return 1;
    if (location.startsWith('/pedido')) return 2;
    if (location.startsWith('/mis-pedidos')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexActual(context);
    return Scaffold(
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
                context.go('/home');
                break;
              case 1:
                context.go('/favoritos');
                break;
              case 2:
                context.go('/pedido');
                break;
              case 3:
                context.go('/mis-pedidos');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Pedido',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Mis pedidos',
            ),
          ],
        ),
      ),
    );
  }
}