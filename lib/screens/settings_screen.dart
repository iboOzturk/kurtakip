import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Görünüm'),
          Obx(
            () => SwitchListTile(
              title: const Text('Karanlık Mod'),
              subtitle: const Text('Uygulamanın temasını değiştir'),
              value: themeController.isDarkMode,
              onChanged: (value) => themeController.toggleTheme(),
              secondary: Icon(
                themeController.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Uygulama Bilgileri'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versiyon'),
            subtitle: Text(_packageInfo?.version ?? 'Yükleniyor...'),
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text('Build Numarası'),
            subtitle: Text(_packageInfo?.buildNumber ?? 'Yükleniyor...'),
          ),
          const Divider(),
          const _SectionHeader(title: 'İletişim'),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Geri Bildirim Gönder'),
            subtitle: const Text('Görüş ve önerilerinizi bizimle paylaşın'),
            onTap: () {
              // E-posta uygulamasını aç
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Uygulamayı Değerlendir'),
            subtitle: const Text('Play Store\'da puanla'),
            onTap: () {
              // Play Store sayfasını aç
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Yasal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Gizlilik Politikası'),
            onTap: () {
              // Gizlilik politikası sayfasını aç
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Kullanım Koşulları'),
            onTap: () {
              // Kullanım koşulları sayfasını aç
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Açık Kaynak Lisansları'),
            onTap: () {
              showLicensePage(context: context);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
} 