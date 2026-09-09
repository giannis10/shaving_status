import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
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
            
            const SizedBox(height: 32),
            _buildSectionHeader(t['dataManagement']!),
            const SizedBox(height: 16),

            // Data Management Tile
            Container(
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: const Icon(LucideIcons.database, color: AppColors.coral),
                title: Text(
                  t['dataManagement']!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  t['exportDataDesc']!,
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                ),
                onTap: () {
                  _showDataManagementSheet(context, store, t);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDataManagementSheet(BuildContext context, GroomingStore store, Map<String, String> t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t['dataManagement']!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Instructions Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.muted.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.info, color: AppColors.cyan, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t['dataInstructions']!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Export Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final data = await store.exportData();
                    Share.share(data, subject: 'Smooth Status Export');
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(LucideIcons.share2, size: 18),
                  label: Text(t['exportData']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.foreground,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Import Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showImportDialog(context, store, t);
                  },
                  icon: const Icon(LucideIcons.download, size: 18),
                  label: Text(t['importData']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.foreground,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showImportDialog(BuildContext context, GroomingStore store, Map<String, String> t) {
    final importController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(t['importData']!),
        content: TextField(
          controller: importController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: t['pasteData']!,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mutedForeground)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await store.importData(importController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? t['dataImported']! : t['invalidData']!),
                  backgroundColor: success ? AppColors.lime : AppColors.coral,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: Colors.black),
            child: const Text('Import'),
          ),
        ],
      ),
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
