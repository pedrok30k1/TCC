import 'dart:async';

import 'package:dasypus/common/constants/app_colors.dart';
import 'package:dasypus/common/constants/app_text_styles.dart';
import 'package:dasypus/common/routes/app_routes.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
      super.initState();
      init(); 
  }

  Timer init(){
    return Timer(
      Duration(seconds: 2), 
      () {
        navigateToOnboarding();
      }
    );
  }

  void navigateToOnboarding(){
    Navigator.pushReplacementNamed(
      context, 
      AppRoutes.login
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.blueGradient,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dasypus', 
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.surface),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}