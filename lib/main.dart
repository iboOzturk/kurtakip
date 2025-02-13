import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/live_rates_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/settings_screen.dart';
import 'controllers/portfolio_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SharedPreferences'ı başlat
  final prefs = await SharedPreferences.getInstance();
  

  Get.put(StorageService(prefs));
  
  // PortfolioController'ı kaydet
  Get.put(PortfolioController());
  
  // Controller'ları başlat
  Get.put(ThemeController(prefs));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kur Takip',
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: Get.find<ThemeController>().isDarkMode 
          ? ThemeMode.dark 
          : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Rx<int> _selectedIndex = 0.obs;
  final PortfolioController _portfolioController = Get.find();

  @override
  void initState() {
    super.initState();
    ever(_selectedIndex, (index) {
      if (index == 1) {
        _portfolioController.updateRates();
      }
    });
  }

  final List<Widget> _screens = [
    const LiveRatesScreen(),
    const PortfolioScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _screens[_selectedIndex.value]),
        bottomNavigationBar: Obx(() => NavigationBar(
      selectedIndex: _selectedIndex.value,
      onDestinationSelected: (index) {
        _selectedIndex.value = index;
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.currency_exchange),
          label: 'Canlı Kurlar',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Portföyüm',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Ayarlar',
        ),
      ],
    )),
    );
  }
}