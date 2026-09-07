enum ToolColor { lime, cyan, coral, violet }

class Tool {
  final String id;
  final String name;
  final int maxUses;
  final int currentUses;
  final ToolColor color;

  Tool({
    required this.id,
    required this.name,
    required this.maxUses,
    required this.currentUses,
    required this.color,
  });

  Tool copyWith({
    String? id,
    String? name,
    int? maxUses,
    int? currentUses,
    ToolColor? color,
  }) {
    return Tool(
      id: id ?? this.id,
      name: name ?? this.name,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      color: color ?? this.color,
    );
  }

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      maxUses: json['maxUses'] as int,
      currentUses: json['currentUses'] as int,
      color: ToolColor.values.firstWhere((e) => e.name == json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'maxUses': maxUses,
      'currentUses': currentUses,
      'color': color.name,
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

  GroomingLog({
    required this.id,
    required this.type,
    required this.date,
    this.zoneId,
    required this.toolId,
    this.hairLengthMm,
    this.timingFeedback,
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
    };
  }
}
