import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/auth/presentation/screens/screens.dart';
import 'package:mindsave/config/router/app_router_notifier.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/screens/screens.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/screens/screens.dart';
import 'package:mindsave/home/presentation/screens/screens.dart';
import 'package:mindsave/registro_estado_animo/presentation/screens/screens.dart';
import '../../auth/presentation/providers/auth_provider.dart';

List<String> noAuthRequiredPaths = [
  "/login",
  "/register",
  "/forgot-password",
  "/successful-register",
];

bool isNotAuthRequired(String path) {
  if (noAuthRequiredPaths.contains(path)) return true;
  return false;
}

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.watch(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: "/splash",

    refreshListenable: goRouterNotifier,

    redirect: (BuildContext context, GoRouterState state) {
      final isGoingTo = state.matchedLocation;
      final AuthStatus authStatus = goRouterNotifier.authStatus;

      if (isGoingTo == "/splash" && authStatus == AuthStatus.checking) {
        return null;
      }

      if (authStatus == AuthStatus.notAuthenticated) {
        if (isNotAuthRequired(isGoingTo)) return null;
        return "/login";
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == "/splash" || isNotAuthRequired(isGoingTo)) {
          return "/home";
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: "/splash",
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),

      GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: "/register",
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: "/successful-register",
        builder: (context, state) => const SuccessfulRegisterScreen(),
      ),

      GoRoute(
        path: "/forgot-password",
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(path: "/home", builder: (context, state) => const HomeScreen()),

      GoRoute(
        path: "/registros",
        builder: (context, state) => const RegistrosScreen(),
      ),

      GoRoute(
        path: "/modules",
        builder: (context, state) => const ModulesScreen(),
      ),

      GoRoute(
        path: "/testBreveEstadoAnimo/0",
        builder: (context, state) {
          return TestBreveEstadoAnimoCreateScreen();
        },
      ),

      GoRoute(
        path: "/testBreveEstadoAnimo/1",
        builder: (context, state) {
          return TestBreveEstadoAnimoDailyResultsScreen();
        },
      ),

      GoRoute(
        path: "/testBreveEstadoAnimo/2",
        builder: (context, state) {
          return TestBreveEstadoAnimoYearResultsScreen();
        },
      ),

      GoRoute(
        path: "/testBreveEstadoAnimo/3",
        builder: (context, state) {
          return TestBreveEstadoAnimoDetailsYearResultsScreen();
        },
      ),

      GoRoute(
        path: "/registroEstadoAnimo/0",
        builder: (context, state) {
          return RegistroEstadoAnimoCreateScreen();
        },
      ),

      GoRoute(
        path: "/registroEstadoAnimo/1",
        builder: (context, state) {
          return RegistroEstadoAnimoPendingViewScreen();
        },
      ),

      GoRoute(
        path: "/registroEstadoAnimo/2",
        builder: (context, state) {
          return RegistroEstadoAnimoCompleteViewScreen();
        },
      ),

      GoRoute(
        path: "/registroEstadoAnimo/3/:idRegistro",
        builder: (context, state) {
          final registerId = state.pathParameters['idRegistro'] ?? "0";
          return RegistroEstadoAnimoPendingViewStep4Screen(
            idRegistroEstadoAnimo: registerId,
          );
        },
      ),

      GoRoute(
        path: "/registroEstadoAnimo/4/:idRegistro",
        builder: (context, state) {
          final registerId = state.pathParameters['idRegistro'] ?? "0";
          return RegistroEstadoAnimoPendingViewStep5Screen(
            idRegistroEstadoAnimo: registerId,
          );
        },
      ),

      GoRoute(
        path: "/registroEstadoAnimo/5/:idRegistro",
        builder: (context, state) {
          final registerId = state.pathParameters['idRegistro'] ?? "0";
          return RegistroEstadoAnimoPendingViewStep6Screen(
            idRegistroEstadoAnimo: registerId,
          );
        },
      ),

      GoRoute(
        path: "/registroEstadoAnimo/6/:idRegistro",
        builder: (context, state) {
          final registerId = state.pathParameters['idRegistro'] ?? "0";
          return RegistroEstadoAnimoPendingViewStep1To3Screen(
            idRegistroEstadoAnimo: registerId,
          );
        },
      ),

      GoRoute(
        path: "/registroEstadoAnimo/7/:idRegistro",
        builder: (context, state) {
          final registerId = state.pathParameters['idRegistro'] ?? "0";
          return RegistroEstadoAnimoCompleteViewDetailsScreen(
            idRegistroEstadoAnimo: registerId,
          );
        },
      ),

      GoRoute(
        path: "/externalizacionVoces/0",
        builder: (context, state) {
          return ExternalizacionVocesInitialScreen();
        },
      ),

      GoRoute(
        path: "/externalizacionVoces/chat/:idChat",
        builder: (context, state) {
          final chatId = state.pathParameters['idChat'] ?? "";
          return ExternalizacionVocesChatScreen(idChat: chatId);
        },
      ),
    ],
  );
});
