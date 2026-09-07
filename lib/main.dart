import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'store/grooming_store.dart';
import 'ui/colors.dart';
import 'ui/tabs/home_tab.dart';
import 'ui/tabs/gear_tab.dart';
import 'ui/tabs/stats_tab.dart';
import 'ui/tabs/settings_tab.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/copy.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroomingStore()),
      ],
      child: const GroomingApp(),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class GroomingApp extends StatefulWidget {
  const GroomingApp({super.key});

  @override
  State<GroomingApp> createState() => _GroomingAppState();
}

class _GroomingAppState extends State<GroomingApp> {
  int _currentIndex = 0;
  String _language = 'en';
  String? _userName;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'en';
      _userName = prefs.getString('userName');
      _isLoaded = true;
    });
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      _language = lang;
    });
  }

  Future<void> _setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    setState(() {
      _userName = name;
    });
  }

  Widget _buildOnboarding(Map<String, String> t) {
    String tempName = '';
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.user, size: 64, color: AppColors.cyan),
            const SizedBox(height: 24),
            Text(
              t['enterName']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              onChanged: (val) => tempName = val,
              decoration: InputDecoration(
                hintText: t['enterName'],
                filled: true,
                fillColor: AppColors.muted,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.violet]),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (tempName.trim().isNotEmpty) {
                    _setName(tempName.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(t['saveName']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const Center(child: CircularProgressIndicator());
    final t = copy[_language]!;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smooth Status',
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          background: AppColors.background,
          surface: AppColors.background,
          primary: AppColors.foreground,
        ),
        fontFamily: 'Inter', // Default fallback, Flutter handles sans-serif well
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.foreground),
          bodyMedium: TextStyle(color: AppColors.foreground),
        ),
      ),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: _userName == null ? _buildOnboarding(t) : Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.5, -0.8),
              radius: 1.5,
              colors: [
                Color(0xFF1A1A2E), // Subtle dark purple/blue glow
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${t['welcome']!} $_userName",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentIndex == 0
                                ? t['homeTitle']!
                                : _currentIndex == 1
                                    ? t['gearTitle']!
                                    : _currentIndex == 2
                                        ? t['statsTitle']!
                                        : (t['settingsTitle'] ?? 'Settings'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse('https://linktr.ee/Giannis.Tsimpouris');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: const Text(
                        "Dev G.T",
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.globe, color: AppColors.foreground),
                      color: AppColors.muted,
                      position: PopupMenuPosition.under,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onSelected: (String lang) {
                        _setLanguage(lang);
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'en',
                          child: Row(
                            children: [
                              const Text('English', style: TextStyle(color: AppColors.foreground)),
                              if (_language == 'en') ...[
                                const Spacer(),
                                const Icon(LucideIcons.check, size: 16, color: AppColors.foreground),
                              ]
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'el',
                          child: Row(
                            children: [
                              const Text('Ελληνικά', style: TextStyle(color: AppColors.foreground)),
                              if (_language == 'el') ...[
                                const Spacer(),
                                const Icon(LucideIcons.check, size: 16, color: AppColors.foreground),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Consumer<GroomingStore>(
                  builder: (context, store, child) {
                    if (!store.isReady) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.mutedForeground));
                    }
                    return IndexedStack(
                      index: _currentIndex,
                      children: [
                        HomeTab(language: _language),
                        GearTab(language: _language),
                        StatsTab(language: _language),
                        SettingsTab(language: _language),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ),
        extendBody: true, // For blur effect
        bottomNavigationBar: _userName == null ? null : _FloatingNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icons = [LucideIcons.home, LucideIcons.scissors, LucideIcons.barChart3, LucideIcons.settings];
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 48, right: 48),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.nav, // Semi-transparent dark
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0x1AFFFFFF)), // Subtle light border
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / icons.length;
                  return Stack(
                    children: [
                      // Active Indicator Glow
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        left: currentIndex * itemWidth,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withValues(alpha: 0.6),
                                  blurRadius: 24,
                                  spreadRadius: 8,
                                ),
                              ],
                              gradient: const LinearGradient(
                                colors: [AppColors.cyan, AppColors.violet],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Icons
                      Row(
                        children: List.generate(icons.length, (index) {
                          final isActive = index == currentIndex;
                          return SizedBox(
                            width: itemWidth,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(index),
                              child: Center(
                                child: AnimatedScale(
                                  scale: isActive ? 1.3 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    icons[index],
                                    color: isActive ? AppColors.foreground : AppColors.mutedForeground,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

