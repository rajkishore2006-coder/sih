import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlCtrl;
  late TextEditingController _inspectorNameCtrl;
  late TextEditingController _inspectorIdCtrl;

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    _urlCtrl = TextEditingController(text: storage.getApiBaseUrl());
    _inspectorNameCtrl = TextEditingController(text: storage.getSavedInspectorName() ?? 'Dr. V. K. Deshmukh');
    _inspectorIdCtrl = TextEditingController(text: storage.getSavedInspectorId() ?? 'INS-MH-704');
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final locService = context.watch<LocalizationService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Configuration')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Selection
          const Text('Language / भाषा / மொழி', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Card(
            child: Column(
              children: LocalizationService.supportedLocales.map((locale) {
                return RadioListTile<String>(
                  title: Text(locService.getLanguageName(locale.languageCode)),
                  subtitle: Text(
                    locale.languageCode == 'en'
                        ? 'English (Default)'
                        : locale.languageCode == 'hi'
                            ? 'हिन्दी (Hindi Mandi Standard)'
                            : 'தமிழ் (Tamil APMC)',
                    style: const TextStyle(fontSize: 11, color: OnionSureColors.textMuted),
                  ),
                  value: locale.languageCode,
                  groupValue: locService.currentLocale.languageCode,
                  activeColor: OnionSureColors.primaryGreen,
                  onChanged: (val) {
                    if (val != null) {
                      locService.changeLocale(val);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Inspector Profile
          const Text('APMC Inspector Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _inspectorNameCtrl,
                    decoration: const InputDecoration(labelText: 'Authorized Inspector Name', prefixIcon: Icon(Icons.person_outline)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inspectorIdCtrl,
                    decoration: const InputDecoration(labelText: 'Mandi Badge / License ID', prefixIcon: Icon(Icons.badge_outlined)),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () async {
                      await storage.saveInspectorProfile(
                        _inspectorIdCtrl.text.trim(),
                        _inspectorNameCtrl.text.trim(),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inspector profile saved!')),
                        );
                      }
                    },
                    child: const Text('Update Profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // FastAPI Backend URL
          const Text('FastAPI Vision Service Connection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _urlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'FastAPI Base URL',
                      prefixIcon: Icon(Icons.dns_outlined),
                      helperText: 'e.g., http://10.0.2.2:8000 (Android Emulator) or http://192.168.1.X:8000',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reuses endpoint: POST /api/analyze-heap with confidence thresholding and defect segmentation.',
                    style: TextStyle(fontSize: 11, color: OnionSureColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () async {
                      await storage.setApiBaseUrl(_urlCtrl.text.trim());
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backend endpoint updated')),
                        );
                      }
                    },
                    child: const Text('Save Endpoint URL'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
