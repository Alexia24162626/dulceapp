import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:dulceapp/theme/app_theme.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/providers/postre_provider.dart';
import 'package:dulceapp/providers/pedido_provider.dart';
import 'package:dulceapp/providers/favoritos_provider.dart';
import 'package:dulceapp/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error Firebase: $e');
  }
  runApp(const DulceApp());
}

class DulceApp extends StatelessWidget {
  const DulceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostreProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.createRouter(context);
          return MaterialApp.router(
            title: 'DulceApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}