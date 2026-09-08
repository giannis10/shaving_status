import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../store/grooming_store.dart';
import '../colors.dart';
import '../../utils/copy.dart';

class SettingsTab extends StatelessWidget {
  final String language;

  const SettingsTab({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final t = copy[language]!;

    return Consumer<GroomingStore>(
      builder: (context, store, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader(t['settingsTitle']!),
            const SizedBox(height: 16),
            
            // Enable/Disable Notifications
            Container(
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SwitchListTile(
                title: Text(
                  t['notifications']!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  t['notificationsDesc']!,
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                ),
                activeColor: AppColors.cyan,
                value: store.notificationsEnabled,
                onChanged: (val) {
                  store.updateSettings(notificationsEnabled: val);
                },
                secondary: const Icon(LucideIcons.bellRing, color: AppColors.foreground),
              ),
            ),
            
            if (store.notificationsEnabled) ...[
              const SizedBox(height: 16),
              
              // Use Average Time
              Container(
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  title: Text(
                    t['averageTime']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    t['averageTimeDesc']!,
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                  ),
                  activeColor: AppColors.cyan,
                  value: store.useAverageTime,
                  onChanged: (val) {
                    store.updateSettings(useAverageTime: val);
                  },
                  secondary: const Icon(LucideIcons.brainCircuit, color: AppColors.foreground),
                ),
              ),

              if (!store.useAverageTime) ...[
                const SizedBox(height: 16),
                
                // Fixed Time Picker
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    leading: const Icon(LucideIcons.clock, color: AppColors.foreground),
                    title: Text(
                      t['notificationTime']!,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${store.notificationHour.toString().padLeft(2, '0')}:${store.notificationMinute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: store.notificationHour, minute: store.notificationMinute),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.cyan,
                                onPrimary: Colors.black,
                                surface: AppColors.muted,
                                onSurface: AppColors.foreground,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        store.updateSettings(notificationHour: picked.hour, notificationMinute: picked.minute);
                      }
                    },
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.mutedForeground,
      ),
    );
  }
}
