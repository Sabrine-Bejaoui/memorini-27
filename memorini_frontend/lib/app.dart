import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'core/constants/colors.dart';
import 'features/home/home_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/products/products_page.dart';
import 'features/cart/cart_page.dart';
import 'features/orders/orders_page.dart';
import 'features/admin/admin_dashboard_page.dart';
import 'features/home/custom_order_page.dart';

class MemoriniApp extends StatelessWidget {
  const MemoriniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.burgundy,
          primary: AppColors.burgundy,
          secondary: AppColors.gold,
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.softBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.softBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.burgundy),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/products': (context) => const ProductsPage(),
        '/cart': (context) => const CartPage(),
        '/orders': (context) => const OrdersPage(),
        '/admin': (context) => const AdminDashboardPage(),
        '/custom-order': (context) => const CustomOrderPage(),
      },
    );
  }
}