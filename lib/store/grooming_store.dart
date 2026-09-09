import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/notification_service.dart';

const String _storageKey = 'grooming-studio-v1';

class GroomingStore extends ChangeNotifier {
  List<Tool> _tools = [];
  List<Zone> _zones = [];
  List<GroomingLog> _logs = [];
  bool _ready = false;

  bool _notificationsEnabled = true;
  int _notificationHour = 9;
  int _notificationMinute = 0;
  bool _useAverageTime = false;

  List<Tool> get tools => _tools;
  List<Zone> get zones => _zones;
  List<GroomingLog> get logs => _logs;
  bool get isReady => _ready;

  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationHour => _notificationHour;
  int get notificationMinute => _notificationMinute;
  bool get useAverageTime => _useAverageTime;

  GroomingStore() {
    _init();
  }

  Future<void> _init() async {
    _tools = [];
    _zones = [
      Zone(id: 'scalp', name: 'Scalp', maxDaysThreshold: 5, growthRateMmDay: 0.35, learningSamples: 0),
      Zone(id: 'face', name: 'Face', maxDaysThreshold: 3, growthRateMmDay: 0.4, learningSamples: 0),
      Zone(id: 'neck', name: 'Neck', maxDaysThreshold: 4, growthRateMmDay: 0.35, learningSamples: 0),
      Zone(id: 'armpits', name: 'Armpits', maxDaysThreshold: 7, growthRateMmDay: 0.3, learningSamples: 0),
      Zone(id: 'chest', name: 'Chest', maxDaysThreshold: 7, growthRateMmDay: 0.28, learningSamples: 0),
      Zone(id: 'abdomen', name: 'Abdomen', maxDaysThreshold: 7, growthRateMmDay: 0.28, learningSamples: 0),
      Zone(id: 'arms', name: 'Arms', maxDaysThreshold: 10, growthRateMmDay: 0.25, learningSamples: 0),
      Zone(id: 'hands', name: 'Hands', maxDaysThreshold: 14, growthRateMmDay: 0.22, learningSamples: 0),
      Zone(id: 'groin', name: 'Groin', maxDaysThreshold: 7, growthRateMmDay: 0.32, learningSamples: 0),
      Zone(id: 'genitals', name: 'Genitals', maxDaysThreshold: 7, growthRateMmDay: 0.3, learningSamples: 0),
      Zone(id: 'legs', name: 'Legs', maxDaysThreshold: 14, growthRateMmDay: 0.23, learningSamples: 0),
      Zone(id: 'feet', name: 'Feet', maxDaysThreshold: 14, growthRateMmDay: 0.2, learningSamples: 0),
      Zone(id: 'back', name: 'Back', maxDaysThreshold: 10, growthRateMmDay: 0.25, learningSamples: 0),
      Zone(id: 'buttocks', name: 'Buttocks', maxDaysThreshold: 10, growthRateMmDay: 0.25, learningSamples: 0),
      Zone(id: 'anus', name: 'Anus', maxDaysThreshold: 7, growthRateMmDay: 0.28, learningSamples: 0),
    ];
    _logs = [];

    try {
      await NotificationService().init();
      await NotificationService().requestPermissions();

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final Map<String, dynamic> parsed = jsonDecode(saved);
        if (parsed.containsKey('tools')) {
          _tools = (parsed['tools'] as List).map((e) => Tool.fromJson(e)).toList();
        }
        if (parsed.containsKey('zones')) {
          final savedZonesList = (parsed['zones'] as List).map((e) => Zone.fromJson(e)).toList();
          final savedZonesMap = {for (var z in savedZonesList) z.id: z};
          
          _zones = _zones.map((zone) {
            final savedZone = savedZonesMap[zone.id];
            if (savedZone != null) {
              return savedZone;
            }
            return zone;
          }).toList();
        }
        if (parsed.containsKey('logs')) {
          _logs = (parsed['logs'] as List).map((e) => GroomingLog.fromJson(e)).toList();
        }
        if (parsed.containsKey('settings')) {
          final s = parsed['settings'];
          _notificationsEnabled = s['notificationsEnabled'] ?? true;
          _notificationHour = s['notificationHour'] ?? 9;
          _notificationMinute = s['notificationMinute'] ?? 0;
          _useAverageTime = s['useAverageTime'] ?? false;
        }
      }
    } catch (e) {
      // Keep safe defaults if malformed
      debugPrint('Error loading state: $e');
    }

    _ready = true;
    notifyListeners();
  }

  Future<void> _saveState() async {
    if (!_ready) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateMap = {
        'tools': _tools.map((e) => e.toJson()).toList(),
        'zones': _zones.map((e) => e.toJson()).toList(),
        'logs': _logs.map((e) => e.toJson()).toList(),
        'settings': {
          'notificationsEnabled': _notificationsEnabled,
          'notificationHour': _notificationHour,
          'notificationMinute': _notificationMinute,
          'useAverageTime': _useAverageTime,
        }
      };
      await prefs.setString(_storageKey, jsonEncode(stateMap));
    } catch (e) {
      debugPrint('Error saving state: $e');
    }
  }

  String _makeId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecondsSinceEpoch}';
  }

  void logShave(String zoneId, String toolId, double hairLengthMm, TimingFeedback timingFeedback, {bool againstTheGrain = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Update Zones
    _zones = _zones.map((zone) {
      if (zone.id == zoneId) {
        final elapsedDays = zone.lastShaved != null 
            ? ((now - zone.lastShaved!) / 86400000).clamp(0.5, double.infinity)
            : 0.0;
        final measuredRate = elapsedDays > 0 ? hairLengthMm / elapsedDays : zone.growthRateMmDay;
        
        // Timing feedback adjusts the base duration
        final feedbackFactor = timingFeedback == TimingFeedback.EARLY ? 1.12 : (timingFeedback == TimingFeedback.LATE ? 0.88 : 1.0);
        
        // "Against the grain" means shave is closer, lasts ~25% longer before growth is annoying
        final methodFactor = againstTheGrain ? 1.25 : 1.0;
        
        // Trimmer factor: Trimmer leaves some hair behind (e.g. 0.5mm), so the annoying threshold is reached ~15-20% faster.
        final usedTool = _tools.firstWhere((t) => t.id == toolId, orElse: () => Tool(id: '', name: '', maxUses: 1, currentUses: 0, color: 0xFF06b6d4));
        final toolFactor = usedTool.type == ToolType.trimmer ? 0.85 : 1.0;

        final updatedZone = zone.copyWith(
          lastShaved: now,
          growthRateMmDay: zone.learningSamples == 0 ? measuredRate : zone.growthRateMmDay * 0.7 + measuredRate * 0.3,
          maxDaysThreshold: (((elapsedDays > 0 ? elapsedDays : zone.maxDaysThreshold) * feedbackFactor * toolFactor) * methodFactor).round().clamp(1, 9999),
          learningSamples: zone.learningSamples + 1,
        );
        
        if (_notificationsEnabled) {
          int hour = _notificationHour;
          int min = _notificationMinute;

          if (_useAverageTime) {
            final shaveLogs = _logs.where((l) => l.type == LogType.SHAVE).toList();
            if (shaveLogs.isNotEmpty) {
              int totalMins = 0;
              for (var l in shaveLogs) {
                final dt = DateTime.fromMillisecondsSinceEpoch(l.date);
                totalMins += dt.hour * 60 + dt.minute;
              }
              final avg = totalMins ~/ shaveLogs.length;
              hour = avg ~/ 60;
              min = avg % 60;
            }
          }

          NotificationService().scheduleShaveReminder(
            zone: updatedZone, 
            title: "Ώρα για ξύρισμα!", 
            body: "Η περιοχή '\${updatedZone.name}' χρειάζεται περιποίηση.",
            hour: hour,
            minute: min,
          );
        }
        
        return updatedZone;
      }
      return zone;
    }).toList();

    // Update Tools
    _tools = _tools.map((tool) {
      if (tool.id == toolId) {
        return tool.copyWith(currentUses: (tool.currentUses + 1).clamp(0, tool.maxUses));
      }
      return tool;
    }).toList();

    // Add Log
    final log = GroomingLog(
      id: _makeId(),
      type: LogType.SHAVE,
      date: now,
      zoneId: zoneId,
      toolId: toolId,
      hairLengthMm: hairLengthMm,
      timingFeedback: timingFeedback,
      againstTheGrain: againstTheGrain,
    );
    _logs.insert(0, log);

    _saveState();
    notifyListeners();
  }

  void replaceBlade(String toolId) {
    _tools = _tools.map((tool) {
      if (tool.id == toolId) {
        return tool.copyWith(currentUses: 0);
      }
      return tool;
    }).toList();

    final log = GroomingLog(
      id: _makeId(),
      type: LogType.BLADE_REPLACEMENT,
      date: DateTime.now().millisecondsSinceEpoch,
      toolId: toolId,
    );
    _logs.insert(0, log);

    _saveState();
    notifyListeners();
  }

  void addTool(String name, ToolType type, int maxUses, int color) {
    final tool = Tool(
      id: _makeId(),
      name: name,
      type: type,
      maxUses: maxUses,
      currentUses: 0,
      color: color,
    );
    _tools.add(tool);
    
    _saveState();
    notifyListeners();
  }

  void updateTool(String toolId, String name, ToolType type, int maxUses, int color) {
    _tools = _tools.map((tool) {
      if (tool.id == toolId) {
        return tool.copyWith(
          name: name,
          type: type,
          maxUses: maxUses,
          color: color,
          currentUses: tool.currentUses > maxUses ? maxUses : tool.currentUses, // clamp
        );
      }
      return tool;
    }).toList();

    _saveState();
    notifyListeners();
  }

  void deleteTool(String toolId) {
    _tools.removeWhere((tool) => tool.id == toolId);
    
    _saveState();
    notifyListeners();
  }

  void reorderTools(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Tool item = _tools.removeAt(oldIndex);
    _tools.insert(newIndex, item);
    _saveState();
    notifyListeners();
  }

  void updateSettings({
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
    bool? useAverageTime,
  }) {
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
    if (notificationHour != null) _notificationHour = notificationHour;
    if (notificationMinute != null) _notificationMinute = notificationMinute;
    if (useAverageTime != null) _useAverageTime = useAverageTime;

    _saveState();
    notifyListeners();
  }

  Future<String> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final stateMap = {
      'tools': _tools.map((e) => e.toJson()).toList(),
      'zones': _zones.map((e) => e.toJson()).toList(),
      'logs': _logs.map((e) => e.toJson()).toList(),
      'settings': {
        'notificationsEnabled': _notificationsEnabled,
        'notificationHour': _notificationHour,
        'notificationMinute': _notificationMinute,
        'useAverageTime': _useAverageTime,
      },
      'userName': prefs.getString('userName'),
      'language': prefs.getString('language'),
    };
    return jsonEncode(stateMap);
  }

  Future<bool> importData(String jsonString) async {
    try {
      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      
      // Basic validation
      if (!parsed.containsKey('tools') || !parsed.containsKey('zones') || !parsed.containsKey('logs')) {
        return false;
      }

      _tools = (parsed['tools'] as List).map((e) => Tool.fromJson(e)).toList();
      _zones = (parsed['zones'] as List).map((e) => Zone.fromJson(e)).toList();
      _logs = (parsed['logs'] as List).map((e) => GroomingLog.fromJson(e)).toList();
      
      if (parsed.containsKey('settings')) {
        final s = parsed['settings'];
        _notificationsEnabled = s['notificationsEnabled'] ?? true;
        _notificationHour = s['notificationHour'] ?? 9;
        _notificationMinute = s['notificationMinute'] ?? 0;
        _useAverageTime = s['useAverageTime'] ?? false;
      }

      final prefs = await SharedPreferences.getInstance();
      if (parsed.containsKey('userName') && parsed['userName'] != null) {
        await prefs.setString('userName', parsed['userName']);
      }
      if (parsed.containsKey('language') && parsed['language'] != null) {
        await prefs.setString('language', parsed['language']);
      }

      _saveState();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Import Error: $e');
      return false;
    }
  }
}
