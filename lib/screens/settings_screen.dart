
import 'package:flutter/material.dart';
import 'package:guardianx/services/voice_preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  bool _voiceEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences =
          await VoicePreferencesService.loadPreferences();

      if (!mounted) return;

      setState(() {
        _selectedLanguage =
            preferences['preferredVoiceLanguage'] as String;
        _voiceEnabled = preferences['voiceEnabled'] as bool;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('Could not load preferences: $e', isError: true);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      await VoicePreferencesService.savePreferences(
        language: _selectedLanguage,
        voiceEnabled: _voiceEnabled,
      );

      if (!mounted) return;
      _showMessage('Voice preferences saved successfully.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not save preferences: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _testVoice() async {
    try {
      await VoicePreferencesService.speakEmergencyPrompt(
        'This is a GuardianX voice test. Your emergency voice '
        'assistance is enabled.',
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Voice test failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const ListTile(
                  leading: Icon(Icons.record_voice_over,
                      color: Colors.red),
                  title: Text(
                    'AI Voice Assistance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Customize spoken emergency instructions',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                SwitchListTile(
                  value: _voiceEnabled,
                  activeThumbColor: Colors.red,
                  secondary: const Icon(
                    Icons.volume_up,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Spoken Instructions',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Allow GuardianX to speak emergency prompts',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onChanged: (value) {
                    setState(() => _voiceEnabled = value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedLanguage,
                    dropdownColor: Colors.grey.shade900,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Preferred Voice Language',
                      labelStyle:
                          const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.language,
                        color: Colors.red,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: VoicePreferencesService.supportedLanguages
                        .keys
                        .map(
                          (language) => DropdownMenuItem<String>(
                            value: language,
                            child: Text(language),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: _voiceEnabled ? _testVoice : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test Voice'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _savePreferences,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSaving ? 'Saving...' : 'Save Preferences',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white24,
                  height: 32,
                ),
                _buildSetting(
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'View your citizen profile',
                  onTap: () {},
                ),
                _buildSetting(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Notification preferences',
                  onTap: () {},
                ),
                _buildSetting(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  subtitle: 'Privacy and account security',
                  onTap: () {},
                ),
                _buildSetting(
                  icon: Icons.info,
                  title: 'About GuardianX',
                  subtitle: 'About this application',
                  onTap: () {},
                ),
                _buildSetting(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help with GuardianX',
                  onTap: () {},
                ),
              ],
            ),
    );
  }

  Widget _buildSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}

