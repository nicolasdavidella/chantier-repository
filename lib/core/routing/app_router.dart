import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/entreprise_details_screen.dart';
import '../../features/auth/presentation/screens/entreprise_certification_form_screen.dart';
import '../../features/client/dashboard/presentation/client_dashboard_screen.dart';
import '../../features/client/create_project/presentation/project_creation_wizard.dart';
import '../../features/ia_assistant/presentation/screens/ia_project_chat_screen.dart';
import '../../features/client/project_detail/presentation/screens/project_detail_screen.dart';
import '../../features/client/search_entreprises/presentation/screens/entreprise_profile_screen.dart';
import '../../features/client/search_entreprises/presentation/screens/compare_entreprises_screen.dart';
import '../../features/showcase/presentation/showcase_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/client/dashboard/presentation/client_reclamation_screen.dart';
import '../../data/models/entreprise_model.dart';
import '../../data/models/project_model.dart';
import '../../features/entreprise/dashboard/presentation/screens/entreprise_dashboard_screen.dart';
import '../../features/entreprise/dashboard/presentation/screens/project_planning_screen.dart';
import '../../features/entreprise/dashboard/presentation/screens/mes_chantiers_screen.dart';
import '../../features/entreprise/dashboard/presentation/screens/equipe_screen.dart';
import '../../features/entreprise/dashboard/presentation/screens/documents_reports_screen.dart';
import '../../features/entreprise/dashboard/presentation/screens/entreprise_profil_screen.dart';
import '../../features/entreprise/project_management/presentation/screens/entreprise_project_detail_screen.dart';
import '../../features/entreprise/offres/presentation/screens/offres_screen.dart';
import '../../features/entreprise/offres/presentation/screens/offre_detail_screen.dart';
import '../../features/entreprise/offres/providers/offres_provider.dart'; // Added for ProjectDiffusion
import '../../features/entreprise/devis/presentation/screens/devis_screen.dart';
import '../../features/admin/presentation/screens/admin_shell_screen.dart';
import '../../features/admin/presentation/screens/admin_login_screen.dart';
import '../../features/chat/presentation/screens/conversations_list_screen.dart';
import '../../features/chat/presentation/screens/chat_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';
      final isAdminLoggingIn = state.matchedLocation == '/admin_login';
      final isRoleSelection = state.matchedLocation == '/role_selection';
      final isSignup = state.matchedLocation == '/signup';
      final isPhoneAuth = state.matchedLocation == '/phone_auth';
      final isForgotPassword = state.matchedLocation == '/forgot_password';
      final isShowcase = state.matchedLocation == '/showcase';

      final isAuthScreen = isLoggingIn || isAdminLoggingIn || isRoleSelection || isSignup || isPhoneAuth || isForgotPassword;

      if (authState.isLoading || authState.hasError) return null;

      final isAuthenticated = authState.value != null;

      // Utilisateur non connecté : on le bloque sur les écrans d'auth
      if (!isAuthenticated) {
        return isAuthScreen || isSplash ? null : '/login';
      }

      // Utilisateur connecté qui essaie d'aller sur login/signup : on le ramène au splash qui dispatche
      if (isAuthenticated && (isLoggingIn || isAdminLoggingIn || isRoleSelection || isSignup || isPhoneAuth)) {
        return '/splash';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithTransition(const SplashScreen(), state),
      ),

      GoRoute(
        path: '/showcase',
        name: 'showcase',
        pageBuilder: (context, state) => _buildPageWithTransition(const ShowcaseScreen(), state),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(const LoginScreen(), state),
      ),
      GoRoute(
        path: '/role_selection',
        name: 'role_selection',
        pageBuilder: (context, state) => _buildPageWithTransition(const RoleSelectionScreen(), state),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'client';
          return _buildPageWithTransition(SignupScreen(role: role), state);
        },
      ),
      GoRoute(
        path: '/phone_auth',
        name: 'phone_auth',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/forgot_password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/entreprise_details',
        name: 'entreprise_details',
        builder: (context, state) {
          final userId = state.extra as String?;
          return EntrepriseDetailsScreen(userId: userId ?? '');
        },
      ),
      GoRoute(
        path: '/entreprise_certification',
        name: 'entreprise_certification',
        builder: (context, state) {
          final entrepriseId = state.extra as String;
          return EntrepriseCertificationFormScreen(entrepriseId: entrepriseId);
        },
      ),
      // Dashboards - place holders
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminShellScreen(),
      ),
      GoRoute(
        path: '/admin_login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/chef_chantier',
        builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Chef de chantier'))),
      ),
      GoRoute(
        path: '/entreprise',
        name: 'entreprise_dashboard',
        builder: (context, state) => const EntrepriseDashboardScreen(),
        routes: [
          GoRoute(
            path: 'project_detail',
            name: 'entreprise_project_detail',
            pageBuilder: (context, state) => _buildPageWithTransition(EntrepriseProjectDetailScreen(project: state.extra as ProjectModel), state),
          ),
          GoRoute(
            path: 'project_planning',
            name: 'project_planning',
            pageBuilder: (context, state) => _buildPageWithTransition(const ProjectPlanningScreen(), state),
          ),
          GoRoute(
            path: 'task_management',
            name: 'task_management',
            pageBuilder: (context, state) => _buildPageWithTransition(const MesChantierScreen(), state),
          ),
          GoRoute(
            path: 'documents_reports',
            name: 'documents_reports',
            pageBuilder: (context, state) => _buildPageWithTransition(const RapportsScreen(), state),
          ),
          GoRoute(
            path: 'devis',
            name: 'entreprise_devis',
            pageBuilder: (context, state) => _buildPageWithTransition(const DevisScreen(), state),
          ),
          GoRoute(
            path: 'mes_chantiers',
            name: 'mes_chantiers',
            pageBuilder: (context, state) => _buildPageWithTransition(const MesChantierScreen(), state),
          ),
          GoRoute(
            path: 'equipe',
            name: 'equipe',
            pageBuilder: (context, state) => _buildPageWithTransition(const EquipeScreen(), state),
          ),
          GoRoute(
            path: 'profil',
            name: 'entreprise_profil',
            pageBuilder: (context, state) => _buildPageWithTransition(const EntrepriseProfilScreen(), state),
          ),
          GoRoute(
            path: 'offres',
            name: 'offres',
            pageBuilder: (context, state) => _buildPageWithTransition(const OffresScreen(), state),
            routes: [
              GoRoute(
                path: 'detail',
                name: 'offre_detail',
                pageBuilder: (context, state) => _buildPageWithTransition(OffreDetailScreen(diffusion: state.extra as ProjectDiffusion), state),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/client',
        name: 'client_dashboard',
        builder: (context, state) => const ClientDashboardScreen(),
        routes: [
          GoRoute(
            path: 'project_detail',
            name: 'client_project_detail',
            pageBuilder: (context, state) => _buildPageWithTransition(ProjectDetailScreen(project: state.extra as ProjectModel), state),
          ),
          GoRoute(
            path: 'create_project',
            name: 'create_project',
            pageBuilder: (context, state) => _buildPageWithTransition(const ProjectCreationWizardScreen(), state),
          ),
          GoRoute(
            path: 'entreprise_profile',
            name: 'entreprise_profile',
            pageBuilder: (context, state) => _buildPageWithTransition(EntrepriseProfileScreen(entreprise: state.extra as EntrepriseModel), state),
          ),
          GoRoute(
            path: 'compare_entreprises',
            name: 'compare_entreprises',
            pageBuilder: (context, state) => _buildPageWithTransition(const CompareEntreprisesScreen(), state),
          ),
          GoRoute(
            path: 'ia_chat',
            name: 'client_ia_chat',
            pageBuilder: (context, state) => _buildPageWithTransition(const IaProjectChatScreen(), state),
          ),
          GoRoute(
            path: 'reclamation',
            name: 'client_reclamation',
            pageBuilder: (context, state) => _buildPageWithTransition(const ClientReclamationScreen(), state),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithTransition(const ProfileScreen(), state),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) => _buildPageWithTransition(const ConversationsListScreen(), state),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'chat_detail',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return _buildPageWithTransition(
                ChatDetailScreen(
                  conversationId: extra['conversationId'] as String? ?? '',
                  otherUserName: extra['otherUserName'] as String? ?? 'Discussion',
                ),
                state,
              );
            },
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage _buildPageWithTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
  );
}
