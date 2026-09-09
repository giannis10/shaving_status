enum ToolType { razor, trimmer }

class Tool {
  final String id;
  final String name;
  final ToolType type;
  final int maxUses;
  final int currentUses;
  final int color; // A Hex integer (e.g., 0xFF84cc16)

  Tool({
    required this.id,
    required this.name,
    this.type = ToolType.razor,
    required this.maxUses,
    required this.currentUses,
    required this.color,
  });

  Tool copyWith({
    String? id,
    String? name,
    ToolType? type,
    int? maxUses,
    int? currentUses,
    int? color,
  }) {
    return Tool(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      color: color ?? this.color,
    );
  }

  factory Tool.fromJson(Map<String, dynamic> json) {
    int parsedColor;
    if (json['color'] is int) {
      parsedColor = json['color'];
    } else if (json['color'] is String) {
      switch (json['color']) {
        case 'cyan': parsedColor = 0xFF06b6d4; break;
        case 'coral': parsedColor = 0xFFf43f5e; break;
        case 'violet': parsedColor = 0xFF8b5cf6; break;
        case 'lime':
        default: parsedColor = 0xFF84cc16; break;
      }
    } else {
      parsedColor = 0xFF84cc16;
    }

    return Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] != null 
          ? ToolType.values.firstWhere((e) => e.name == json['type'], orElse: () => ToolType.razor)
          : ToolType.razor,
      maxUses: json['maxUses'] as int,
      currentUses: json['currentUses'] as int,
      color: parsedColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'maxUses': maxUses,
      'currentUses': currentUses,
      'color': color,
    };
  }
}

enum TimingFeedback { EARLY, RIGHT, LATE }

class Zone {
  final String id;
  final String name;
  final int maxDaysThreshold;
  final int? lastShaved; // Unix timestamp in ms
  final double growthRateMmDay;
  final int learningSamples;

  Zone({
    required this.id,
    required this.name,
    required this.maxDaysThreshold,
    this.lastShaved,
    required this.growthRateMmDay,
    required this.learningSamples,
  });

  Zone copyWith({
    String? id,
    String? name,
    int? maxDaysThreshold,
    int? lastShaved, // Optional nullable field needs careful copyWith, but we'll use a hack or just replace it
    double? growthRateMmDay,
    int? learningSamples,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      maxDaysThreshold: maxDaysThreshold ?? this.maxDaysThreshold,
      lastShaved: lastShaved ?? this.lastShaved, // This doesn't allow setting to null if it was non-null, but we never set lastShaved to null in the logic
      growthRateMmDay: growthRateMmDay ?? this.growthRateMmDay,
      learningSamples: learningSamples ?? this.learningSamples,
    );
  }

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      maxDaysThreshold: json['maxDaysThreshold'] as int,
      lastShaved: json['lastShaved'] as int?,
      growthRateMmDay: (json['growthRateMmDay'] as num).toDouble(),
      learningSamples: json['learningSamples'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'maxDaysThreshold': maxDaysThreshold,
      'lastShaved': lastShaved,
      'growthRateMmDay': growthRateMmDay,
      'learningSamples': learningSamples,
    };
  }
}

enum LogType { SHAVE, BLADE_REPLACEMENT }

class GroomingLog {
  final String id;
  final LogType type;
  final int date; // Unix timestamp in ms
  final String? zoneId;
  final String toolId;
  final double? hairLengthMm;
  final TimingFeedback? timingFeedback;
  final bool? againstTheGrain;

  GroomingLog({
    required this.id,
    required this.type,
    required this.date,
    this.zoneId,
    required this.toolId,
    this.hairLengthMm,
    this.timingFeedback,
    this.againstTheGrain,
  });

  factory GroomingLog.fromJson(Map<String, dynamic> json) {
    return GroomingLog(
      id: json['id'] as String,
      type: LogType.values.firstWhere((e) => e.name == json['type']),
      date: json['date'] as int,
      zoneId: json['zoneId'] as String?,
      toolId: json['toolId'] as String,
      hairLengthMm: (json['hairLengthMm'] as num?)?.toDouble(),
      timingFeedback: json['timingFeedback'] != null 
          ? TimingFeedback.values.firstWhere((e) => e.name == json['timingFeedback']) 
          : null,
      againstTheGrain: json['againstTheGrain'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date,
      'zoneId': zoneId,
      'toolId': toolId,
      'hairLengthMm': hairLengthMm,
      'timingFeedback': timingFeedback?.name,
      'againstTheGrain': againstTheGrain,
    };
  }
}
