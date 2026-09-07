import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../store/grooming_store.dart';
import '../../models/models.dart';
import '../colors.dart';
import '../../utils/copy.dart';

class StatsTab extends StatefulWidget {
  final String language;

  const StatsTab({super.key, required this.language});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  String? _selectedZoneId; // null means 'All Zones'
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final t = copy[widget.language]!;
    final store = context.watch<GroomingStore>();
    
    // Calculate available years from logs, default to current year
    final allShaveLogs = store.logs.where((l) => l.type == LogType.SHAVE).toList();
    final availableYears = <int>{DateTime.now().year};
    for (var log in allShaveLogs) {
      availableYears.add(DateTime.fromMillisecondsSinceEpoch(log.date).year);
    }
    final sortedYears = availableYears.toList()..sort((a, b) => b.compareTo(a));

    // Filter logs based on selection
    final filteredLogs = allShaveLogs.where((log) {
      final date = DateTime.fromMillisecondsSinceEpoch(log.date);
      if (date.year != _selectedYear) return false;
      if (_selectedZoneId != null && log.zoneId != _selectedZoneId) return false;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['statsTitle']!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        t['consistency']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.mutedForeground),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.foreground),
                          dropdownColor: AppColors.muted,
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedYear = newValue;
                              });
                            }
                          },
                          items: sortedYears.map<DropdownMenuItem<int>>((int year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${filteredLogs.length} ${t['sessions']}',
                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Zone Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(t['allZones']!, null),
                ...store.zones.map((zone) {
                  final name = zoneNames[zone.id]?[widget.language] ?? zone.name;
                  return _buildFilterChip(name, zone.id);
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          // Heatmap
          _Heatmap(logs: filteredLogs, year: _selectedYear),
          const SizedBox(height: 32),
          Text(
            t['recent']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (filteredLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Column(
                  children: [
                    const Icon(LucideIcons.scissors, size: 28, color: AppColors.mutedForeground),
                    const SizedBox(height: 12),
                    Text(t['noActivity']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(t['noActivityText']!, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredLogs.length > 20 ? 20 : filteredLogs.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
              itemBuilder: (context, index) {
                // sort filtered logs by date descending for the list
                final sortedFilteredLogs = List<GroomingLog>.from(filteredLogs)..sort((a, b) => b.date.compareTo(a.date));
                final log = sortedFilteredLogs[index];
                
                final tool = store.tools.where((t) => t.id == log.toolId).firstOrNull;
                final zone = log.zoneId != null ? store.zones.where((z) => z.id == log.zoneId).firstOrNull : null;
                
                final dateFormat = DateFormat('MMM d, h:mm a');
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.muted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          log.type == LogType.SHAVE ? LucideIcons.scissors : LucideIcons.refreshCw,
                          size: 16,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.type == LogType.SHAVE 
                                ? '${zoneNames[zone?.id]?[widget.language] ?? zone?.name ?? 'Zone'} ${t['shaved']}'
                                : t['bladeReplaced']!,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              tool?.name ?? '—',
                              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(log.date)),
                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? zoneId) {
    final isSelected = _selectedZoneId == zoneId;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedZoneId = selected ? zoneId : null;
          });
        },
        selectedColor: AppColors.foreground,
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.background : AppColors.foreground,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  final List<GroomingLog> logs;
  final int year;

  const _Heatmap({required this.logs, required this.year});

  @override
  Widget build(BuildContext context) {
    // Determine the days to display for the given year
    final isCurrentYear = year == DateTime.now().year;
    
    // End date is either today (if current year) or Dec 31 of the selected year
    final endDate = isCurrentYear 
        ? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
        : DateTime(year, 12, 31);
        
    // 52 weeks * 7 days = 364 days.
    const int totalDays = 364;
    
    final counts = <String, int>{};
    for (var log in logs) {
      final d = DateTime.fromMillisecondsSinceEpoch(log.date);
      final key = '${d.year}-${d.month}-${d.day}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final days = List.generate(totalDays, (index) {
      final date = endDate.subtract(Duration(days: (totalDays - 1) - index));
      final key = '${date.year}-${date.month}-${date.day}';
      return counts[key] ?? 0;
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Start at the right (most recent)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(52, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Column(
              children: List.generate(7, (dayIndex) {
                final index = weekIndex * 7 + dayIndex;
                final count = days[index];
                
                Color color;
                if (count == 0) {
                  color = AppColors.border; // heat-0
                } else if (count == 1) {
                  color = AppColors.coral.withValues(alpha: 0.4); // heat-1
                } else if (count == 2) {
                  color = AppColors.coral.withValues(alpha: 0.7); // heat-2
                } else {
                  color = AppColors.coral; // heat-3
                }
                
                return Container(
                  width: 14,
                  height: 14,
                  margin: EdgeInsets.only(bottom: dayIndex < 6 ? 4.0 : 0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
