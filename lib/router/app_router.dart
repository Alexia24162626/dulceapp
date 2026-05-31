import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/screens/auth/splash_screen.dart';
import 'package:dulceapp/screens/auth/login_screen.dart';
import 'package:dulceapp/screens/auth/register_screen.dart';
import 'package:dulceapp/screens/client/client_shell.dart';
import 'package:dulceapp/screens/client/home_screen.dart';
import 'package:dulceapp/screens/client/detalle_postre_screen.dart';
import 'package:dulceapp/screens/client/favoritos_screen.dart';
import 'package:dulceapp/screens/client/pedido_screen.dart';
import 'package:dulceapp/screens/client/mis_pedidos_screen.dart';
import 'package:dulceapp/screens/owner/owner_shell.dart';
import 'package:dulceapp/screens/owner/panel_dueno_screen.dart';
import 'package:dulceapp/screens/owner/gestion_productos_screen.dart';
import 'package:dulceapp/screens/owner/agregar_postre_screen.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        final isLoggedIn = auth.usuario != null;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/splash';

        if (!isLoggedIn && !isAuthRoute) return '/login';
        if (isLoggedIn && state.matchedLocation == '/splash') {
          final rol = auth.usuario?.rol ?? 'cliente';
          return rol == 'dueno' ? '/owner' : '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Rutas del dueño SIN shell (pantallas completas)
        GoRoute(
          path: '/agregar-postre',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            return AgregarPostreScreen(postreId: id);
          },
        ),

        // Shell del cliente
        ShellRoute(
          builder: (context, state, child) => ClientShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/postre/:id',
              builder: (context, state) => DetallePostreScreen(
                postreId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/favoritos',
              builder: (context, state) => const FavoritosScreen(),
            ),
            GoRoute(
              path: '/pedido',
              builder: (context, state) => const PedidoScreen(),
            ),
            GoRoute(
              path: '/mis-pedidos',
              builder: (context, state) => const MisPedidosScreen(),
            ),
          ],
        ),

        // Shell del dueño
        ShellRoute(
          builder: (context, state, child) => OwnerShell(child: child),
          routes: [
            GoRoute(
              path: '/owner',
              builder: (context, state) => const PanelDuenoScreen(),
            ),
            GoRoute(
              path: '/owner/productos',
              builder: (context, state) => const GestionProductosScreen(),
            ),
          ],
        ),
      ],
    );
  }
}