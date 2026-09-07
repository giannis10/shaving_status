import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '../../models/models.dart';
import '../colors.dart';

class BodyMapPaths {
  static final silhouette = parseSvgPathData("M120 7C100 7 91 23 92 45c1 17 8 31 17 38l-3 12-23 8c-13 5-20 15-24 31l-16 67c-3 13 2 24 12 27l21 1 4 38-5 97c-1 15 8 22 22 19l23-8 23 8c14 3 23-4 22-19l-5-97 4-38 21-1c10-3 15-14 12-27l-16-67c-4-16-11-26-24-31l-23-8-3-12c9-7 16-21 17-38 1-22-8-38-28-38Z");
  static final detail = parseSvgPathData("M120 105V214M96 176Q120 183 144 176M102 316Q108 322 113 316M138 316Q132 322 127 316");

  static final Map<String, Path> frontZones = {
    'scalp': parseSvgPathData("M93 42 Q94 8 120 7 Q146 8 147 42 Q135 31 120 31 Q105 31 93 42Z"),
    'face': parseSvgPathData("M94 44 Q120 27 146 44 L143 63 Q138 81 120 85 Q102 81 97 63Z"),
    'neck': parseSvgPathData("M108 85 Q120 90 132 85 L136 103 Q120 110 104 103Z"),
    'chest': parseSvgPathData("M83 105 Q120 92 157 105 L154 153 Q136 161 120 153 Q104 161 86 153Z"),
    'armpits': parseSvgPathData("M81 109Q69 116 72 139L85 146L89 111Z M159 109Q171 116 168 139L155 146L151 111Z"),
    'abdomen': parseSvgPathData("M87 158 Q120 166 153 158 L149 210 Q136 222 120 217 Q104 222 91 210Z"),
    'arms': parseSvgPathData("M72 110Q61 113 57 129L42 190Q39 202 51 206Q60 207 64 194L82 137Z M168 110Q179 113 183 129L198 190Q201 202 189 206Q180 207 176 194L158 137Z"),
    'hands': parseSvgPathData("M41 205Q31 218 40 232Q48 241 57 230L61 214Q57 205 41 205Z M199 205Q209 218 200 232Q192 241 183 230L179 214Q183 205 199 205Z"),
    'groin': parseSvgPathData("M91 216 Q120 225 149 216 L155 244 Q136 254 120 249 Q104 254 85 244Z"),
    'genitals': parseSvgPathData("M105 246 Q120 238 135 246 L132 270 Q120 281 108 270Z"),
    'legs': parseSvgPathData("M84 273 Q101 268 117 276 L113 352 Q111 371 96 371 Q82 369 83 350Z M123 276 Q139 268 156 273 L157 350 Q158 369 144 371 Q129 371 127 352Z"),
    'feet': parseSvgPathData("M83 351 L113 351 L114 377 Q95 386 77 378Z M127 351 L157 351 L163 378 Q145 386 126 377Z"),
  };

  static final Map<String, Path> backZones = {
    'scalp': parseSvgPathData("M93 42 Q94 8 120 7 Q146 8 147 42 Q135 31 120 31 Q105 31 93 42Z"),
    'neck': parseSvgPathData("M107 84 Q120 90 133 84 L138 104 Q120 111 102 104Z"),
    'back': parseSvgPathData("M82 106 Q120 91 158 106 L153 210 Q138 222 120 217 Q102 222 87 210Z"),
    'arms': parseSvgPathData("M72 110Q61 113 57 129L42 190Q39 202 51 206Q60 207 64 194L82 137Z M168 110Q179 113 183 129L198 190Q201 202 189 206Q180 207 176 194L158 137Z"),
    'hands': parseSvgPathData("M41 205Q31 218 40 232Q48 241 57 230L61 214Q57 205 41 205Z M199 205Q209 218 200 232Q192 241 183 230L179 214Q183 205 199 205Z"),
    'buttocks': parseSvgPathData("M85 221 Q103 212 118 226 L116 272 Q94 280 84 257Z M122 226 Q137 212 155 221 L156 257 Q146 280 124 272Z"),
    'anus': parseSvgPathData("M113 252Q120 245 127 252L126 266Q120 272 114 266Z"),
    'legs': parseSvgPathData("M84 273 Q101 268 117 276 L113 352 Q111 371 96 371 Q82 369 83 350Z M123 276 Q139 268 156 273 L157 350 Q158 369 144 371 Q129 371 127 352Z"),
    'feet': parseSvgPathData("M83 351 L113 351 L114 377 Q95 386 77 378Z M127 351 L157 351 L163 378 Q145 386 126 377Z"),
  };
}

class BodyMap extends StatelessWidget {
  final List<Zone> zones;
  final String side;
  final Function(Zone) onZoneSelected;

  const BodyMap({
    super.key,
    required this.zones,
    required this.side,
    required this.onZoneSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The original SVG viewBox is "0 0 240 390".
        const double svgWidth = 240;
        const double svgHeight = 390;
        
        // Calculate scale to fit width/height
        final double scale = (constraints.maxWidth / svgWidth).clamp(0.0, constraints.maxHeight / svgHeight);
        
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: svgWidth,
            height: svgHeight,
            child: CustomPaint(
              painter: _BodyMapPainter(
                zones: zones,
                side: side,
              ),
              child: _HitTestZones(
                zones: zones,
                side: side,
                onZoneSelected: onZoneSelected,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BodyMapPainter extends CustomPainter {
  final List<Zone> zones;
  final String side;

  _BodyMapPainter({required this.zones, required this.side});

  Color _getFreshnessColor(Zone? item) {
    if (item == null || item.lastShaved == null) return AppColors.due;
    final ratio = (DateTime.now().millisecondsSinceEpoch - item.lastShaved!) / 86400000 / item.maxDaysThreshold;
    return ratio < 0.55 ? AppColors.fresh : ratio < 0.9 ? AppColors.soon : AppColors.due;
  }

  void _drawPath(Canvas canvas, Path path, String zoneId) {
    final zone = zones.where((z) => z.id == zoneId).firstOrNull;
    final color = _getFreshnessColor(zone);
    
    final paintFill = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    
    final paintStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Base silhouette
    final basePaint = Paint()
      ..color = AppColors.muted
      ..style = PaintingStyle.fill;
    canvas.drawPath(BodyMapPaths.silhouette, basePaint);

    final pathsToDraw = side == 'front' ? BodyMapPaths.frontZones : BodyMapPaths.backZones;

    for (final entry in pathsToDraw.entries) {
      _drawPath(canvas, entry.value, entry.key);
    }

    // Detail lines
    final detailPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(BodyMapPaths.detail, detailPaint);
  }

  @override
  bool shouldRepaint(covariant _BodyMapPainter oldDelegate) {
    return true; 
  }
}

class _HitTestZones extends StatelessWidget {
  final List<Zone> zones;
  final String side;
  final Function(Zone) onZoneSelected;

  const _HitTestZones({required this.zones, required this.side, required this.onZoneSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final pos = details.localPosition;
        
        final hitAreas = side == 'front' ? BodyMapPaths.frontZones : BodyMapPaths.backZones;

        for (final entry in hitAreas.entries) {
          if (entry.value.contains(pos)) {
            final zone = zones.where((z) => z.id == entry.key).firstOrNull;
            if (zone != null) {
              onZoneSelected(zone);
              return;
            }
          }
        }
      },
    );
  }
}
