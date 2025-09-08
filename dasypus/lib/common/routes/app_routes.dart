import 'package:dasypus/screens/auth/carregamento/CircularProgressIndicator.dart';
import 'package:dasypus/screens/auth/editar/usuario_editar.dart';
import 'package:dasypus/screens/home/cards/card_profile.dart';
import 'package:dasypus/screens/home/filho/home_filho.dart';
import 'package:dasypus/screens/home/group/categoria_profile.dart';
import 'package:dasypus/screens/auth/profile/child/profile_filho_screen.dart';
import 'package:dasypus/screens/auth/profile/all_childs/profiles_filhos_screen.dart';
import 'package:dasypus/screens/home/cards/register_card.dart';
import 'package:dasypus/screens/home/group/register_categoria.dart';
import 'package:dasypus/screens/home/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import '../../screens/auth/login/login_screen.dart';
import '../../screens/auth/register/register_parent/register_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/auth/profile/parent/profile_screen.dart';
import '../../screens/auth/register/register_child/register_screen_filho.dart';

// Definição das rotas usando Routefly
class AppRoutes {

  // splash page
  static const String splash = '/splash';
  // Rota principal
  static const String home = '/';

  // Rota de login
  static const String login = '/login';

  // Rota de cadastro
  static const String register = '/register';

  // Rota de dashboard
  static const String dashboard = '/dashboard';

  // Rota de perfil
  static const String profile = '/profile';

  // Rota de configurações
  static const String settings = '/settings';

  // Rota de cadastro de filho
  static const String registerFilho = '/registerFilho';

  //Rota de lista de filho
  static const String listeFilho = '/listeFilho';

  //Rota de Perfil de filho

  static const String profileFilho = '/profileFilho';

  //Rota de lista de categorias

  static const String listaCategoria = '/listaCategoria';

  //Rota de lista de card
  static const String listaCard = '/listaCard';

  // Rota de criação de categoria
  static const String criarCategoria = '/criarCategoria'; 

  // Rota de criação de card
  static const String registerCard = '/registerCard';

  // Rota de carregamento
  static const String loading = '/loading';

  //Rota de home filho
  static const String homeFilho = '/homeFilho';

  //Rota de atualização de perfil 
  static const String editarUsuario = '/editarUsuario';
  
  //Rota de atualização de categoria
  static const String editarCategoria = '/editarCategoria';

  // Configuração das rotas usando Routefly
  static final routes = {
    splash: (context) => const SplashScreen(),
    homeFilho: (context) => const HomeFilho(),
    loading: (context) => const LoadingScreen(),
    home: (context) => const LoginScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    dashboard: (context) => const DashboardScreen(),
    profile: (context) => const ProfileScreen(),
    registerFilho: (context) => const RegisterScreenFilho(),
    listeFilho: (context) => const ProfilesFilhosScreen(),
    profileFilho: (context) => const ProfileScreenFilho(),
    listaCategoria: (context) => const CategoriaProfileScreen(),
    listaCard: (context) => const CardProfileScreen(showAppBar: false,),
    criarCategoria: (context) => const CriarCategoriaPage(),
    registerCard: (context) => const CriarCardPage(),
    editarUsuario: (context) => const UsuarioEditar(),
    editarCategoria: (context) => const UsuarioEditar(),
    settings: (context) =>
        const Scaffold(body: Center(child: Text('Configurações'))),
  };

  // Método para navegar para uma rota
  static void navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  // Método para navegar e substituir a rota atual
  static void navigateToReplacement(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  // Método para navegar e limpar o stack de rotas
  static void navigateToAndClear(BuildContext context, String route) {
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  // Método para voltar
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
