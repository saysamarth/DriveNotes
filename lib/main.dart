import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drivenotes/views/auth/login_screen.dart';
import 'package:drivenotes/views/inner/home_screen.dart';
import 'package:drivenotes/views/splash_screen.dart';
import 'package:drivenotes/controller/provider/auth_provider.dart';
import 'package:drivenotes/controller/provider/theme_provider.dart';
import 'package:drivenotes/constants/app_theme.dart';
import 'package:drivenotes/constants/globals.dart';

final GlobalKey<NavigatorState> globalNavigatorKeyy = globalNavigatorKey;
final splashCompletedProvider = StateProvider<bool>((ref) => false);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    final router = GoRouter(
      navigatorKey: globalNavigatorKeyy,
      refreshListenable: RouterNotifier(ref),
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const SplashScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          },
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
      ],

      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isLoggedIn = authState.isAuthenticated;
        final isSplash = state.matchedLocation == '/splash';
        final isLoggingIn = state.matchedLocation == '/login';
        final splashCompleted = ref.read(splashCompletedProvider);

        if (isSplash && !splashCompleted) return null;

        if (isSplash && splashCompleted) {
          return isLoggedIn ? '/' : '/login';
        }
        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/';
        
        return null;
      },
    );

    return MaterialApp.router(
      title: 'DriveNotes',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class RouterNotifier extends ChangeNotifier {
  final WidgetRef _ref;
  
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    _ref.listen<bool>(splashCompletedProvider, (_, __) => notifyListeners());
  }
}
