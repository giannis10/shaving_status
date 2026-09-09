import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;
import '../../store/grooming_store.dart';
import '../../models/models.dart';
import '../colors.dart';
import '../../utils/copy.dart';
import 'body_map.dart';
import '../../services/updater_service.dart';
import '../../services/pwa_service.dart';
import 'package:flutter/foundation.dart';

class HomeTab extends StatefulWidget {
  final String language;

  const HomeTab({super.key, required this.language});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _bodySide = 'front'; // 'front' or 'back'
  bool _hasUpdate = false;
  String _releaseNotes = '';

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final result = await UpdaterService.checkForUpdates();
    if (result['hasUpdate'] == true && mounted) {
      setState(() {
        _hasUpdate = true;
        _releaseNotes = result['releaseNotes'];
      });
    }
  }

  Color _getToolColor(ToolColor color) {
    switch (color) {
      case ToolColor.lime: return AppColors.lime;
      case ToolColor.cyan: return AppColors.cyan;
      case ToolColor.coral: return AppColors.coral;
      case ToolColor.violet: return AppColors.violet;
    }
  }

  void _openZoneAction(Zone zone) {
    final t = copy[widget.language]!;
    final store = context.read<GroomingStore>();
    
    String selectedTool = store.tools.isNotEmpty ? store.tools.first.id : '';
    double hairLength = math.max(0.5, (zone.growthRateMmDay * zone.maxDaysThreshold * 2).round() / 2);
    TimingFeedback timingFeedback = TimingFeedback.RIGHT;
    bool againstTheGrain = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final zoneName = zoneNames[zone.id]?[widget.language] ?? zone.name;

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
                    '${t['log']} $zoneName — ${t['shave']}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t['chooseTool']!,
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  
                  // Tool Selection
                  SizedBox(
                    height: 180,
                    child: SingleChildScrollView(
                      child: Column(
                        children: store.tools.map((tool) {
                          final isSelected = selectedTool == tool.id;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ElevatedButton(
                              onPressed: () => setModalState(() => selectedTool = tool.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? AppColors.muted : Colors.transparent,
                                foregroundColor: AppColors.foreground,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(color: isSelected ? _getToolColor(tool.color) : AppColors.border),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(color: _getToolColor(tool.color), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(tool.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ),
                                  if (isSelected) const Icon(LucideIcons.check, size: 18) else const Icon(LucideIcons.chevronRight, size: 18),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Hair Length
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t['hairLength']!, style: const TextStyle(fontSize: 14)),
                      Text('${hairLength.toStringAsFixed(1)} mm', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: hairLength,
                    min: 0.5,
                    max: 15.0,
                    divisions: 29,
                    activeColor: AppColors.foreground,
                    inactiveColor: AppColors.border,
                    onChanged: (val) => setModalState(() => hairLength = val),
                  ),

                  const SizedBox(height: 16),

                  // Timing Feedback
                  Text(t['timing']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: TimingFeedback.values.map((v) {
                      final isSelected = timingFeedback == v;
                      final label = v == TimingFeedback.EARLY ? t['early']! : v == TimingFeedback.RIGHT ? t['right']! : t['late']!;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton(
                            onPressed: () => setModalState(() => timingFeedback = v),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected ? AppColors.foreground : Colors.transparent,
                              foregroundColor: isSelected ? AppColors.background : AppColors.foreground,
                              side: BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Against the grain
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        t['againstTheGrain']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      activeColor: AppColors.cyan,
                      value: againstTheGrain,
                      onChanged: (val) => setModalState(() => againstTheGrain = val),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recommendation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.4),
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['recommendation']!.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: AppColors.foreground, fontSize: 14),
                            children: [
                              TextSpan(text: '${t['nextIn']} '),
                              TextSpan(text: '${zone.maxDaysThreshold} ${t['days']}.', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(t['learning']!, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: selectedTool.isEmpty ? null : () {
                        store.logShave(zone.id, selectedTool, hairLength, timingFeedback, againstTheGrain: againstTheGrain);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.foreground,
                        foregroundColor: AppColors.background,
                        disabledBackgroundColor: AppColors.muted,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(t['confirm']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(t['cancel']!, style: const TextStyle(color: AppColors.mutedForeground)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = copy[widget.language]!;
    final store = context.watch<GroomingStore>();

    int groomingScore = 0;
    if (store.zones.isNotEmpty) {
      double total = 0;
      for (var zone in store.zones) {
        final elapsed = zone.lastShaved != null ? (DateTime.now().millisecondsSinceEpoch - zone.lastShaved!) / 86400000 : zone.maxDaysThreshold.toDouble();
        total += math.max(0, 100 - (elapsed / zone.maxDaysThreshold) * 100);
      }
      groomingScore = (total / store.zones.length).round();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ειδοποίηση Νέας Έκδοσης (Update Banner)
          if (_hasUpdate)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lime.withOpacity(0.1),
                border: Border.all(color: AppColors.lime.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.arrowUpCircle, color: AppColors.lime),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.language == 'el' ? 'Νέα Έκδοση Διαθέσιμη!' : 'New Update Available!',
                          style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.language == 'el' ? 'Κατέβασε την πιο πρόσφατη έκδοση.' : 'Download the latest version.',
                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                        ),
                        if (_releaseNotes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _releaseNotes,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => UpdaterService.launchUpdateUrl(),
                    style: TextButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: Colors.black),
                    child: Text(widget.language == 'el' ? 'Λήψη' : 'Update'),
                  ),
                ],
              ),
            ),

          // PWA Install Button (Μόνο στο Web)
          if (kIsWeb)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Αν είναι iOS Web (Safari), βγάλε ένα Dialog με οδηγίες
                  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
                  if (isIOS) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.background,
                        title: Text(widget.language == 'el' ? 'Εγκατάσταση στο iPhone' : 'Install on iPhone'),
                        content: Text(
                          widget.language == 'el' 
                            ? 'Για να εγκαταστήσεις το app, πάτα το κουμπί "Κοινοποίηση" (Share) στο κάτω μέρος του Safari και μετά επέλεξε "Προσθήκη στην οθόνη έναρξης" (Add to Home Screen).'
                            : 'To install the app, tap the "Share" button at the bottom of Safari and select "Add to Home Screen".'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx), 
                            child: const Text('OK', style: TextStyle(color: AppColors.cyan)),
                          )
                        ],
                      ),
                    );
                  } else {
                    // Αν είναι Chrome / Android / Desktop κλπ
                    installPwa();
                  }
                },
                icon: const Icon(LucideIcons.download),
                label: Text(widget.language == 'el' ? 'Εγκατάσταση App (Install)' : 'Install App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan.withOpacity(0.1),
                  foregroundColor: AppColors.cyan,
                  side: BorderSide(color: AppColors.cyan.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          // Blade Panel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border.withOpacity(0.7)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t['bladeLife']!.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: AppColors.mutedForeground),
                    ),
                    const Icon(LucideIcons.scissors, size: 16, color: AppColors.foreground),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ToolGauge(name: t['groomed']!, health: groomingScore, color: AppColors.coral, remainingText: t['bodyAverage']!),
                      ...store.tools.map((tool) {
                        final health = math.max(0, ((1 - tool.currentUses / tool.maxUses) * 100).round());
                        return _ToolGauge(
                          name: tool.name, 
                          health: health, 
                          color: _getToolColor(tool.color), 
                          remainingText: '${tool.maxUses - tool.currentUses} ${t['usesRemaining']}',
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Body Map Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['bodyMap']!.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 4),
                  Text(t['bodyQuestion']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const Icon(LucideIcons.sparkles, size: 20, color: AppColors.foreground),
            ],
          ),
          const SizedBox(height: 12),

          // Map Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _bodySide = 'front'),
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: _bodySide == 'front' ? AppColors.border : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(child: Text(t['front']!, style: const TextStyle(fontSize: 14))),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _bodySide = 'back'),
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: _bodySide == 'back' ? AppColors.border : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(child: Text(t['back']!, style: const TextStyle(fontSize: 14))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Body Map Stage
          Container(
            height: 374,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border.withOpacity(0.7)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: BodyMap(
                zones: store.zones,
                side: _bodySide,
                onZoneSelected: _openZoneAction,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.fresh, label: t['fresh']!),
              const SizedBox(width: 16),
              _LegendItem(color: AppColors.soon, label: t['soon']!),
              const SizedBox(width: 16),
              _LegendItem(color: AppColors.due, label: t['due']!),
            ],
          ),
          const SizedBox(height: 24), // padding for scroll
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
      ],
    );
  }
}

class _ToolGauge extends StatelessWidget {
  final String name;
  final int health;
  final Color color;
  final String remainingText;

  const _ToolGauge({required this.name, required this.health, required this.color, required this.remainingText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: CustomPaint(
              painter: _GaugePainter(health: health, color: color),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$health', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color)),
                    const Text('%', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(remainingText, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int health;
  final Color color;

  _GaugePainter({required this.health, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4; // stroke width / 2

    final trackPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * math.pi * (math.max(2, health) / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start from top
      sweepAngle,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.health != health || oldDelegate.color != color;
  }
}
