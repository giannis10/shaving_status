import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../store/grooming_store.dart';
import '../../models/models.dart';
import '../colors.dart';
import '../../utils/copy.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class GearTab extends StatefulWidget {
  final String language;

  const GearTab({super.key, required this.language});

  @override
  State<GearTab> createState() => _GearTabState();
}

class _GearTabState extends State<GearTab> {
  void _showAddEditTool(BuildContext context, {Tool? existingTool}) {
    final t = copy[widget.language]!;
    final store = context.read<GroomingStore>();
    
    String name = existingTool?.name ?? '';
    ToolType type = existingTool?.type ?? ToolType.razor;
    int maxUses = existingTool?.maxUses ?? 10;
    int color = existingTool?.color ?? 0xFF84cc16;

    final nameController = TextEditingController(text: name);
    final maxUsesController = TextEditingController(text: maxUses.toString());

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
                    existingTool != null ? t['editTool']! : t['addTool']!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t['setTool']!,
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  // Name Input
                  Text(t['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    onChanged: (val) => name = val,
                    decoration: InputDecoration(
                      hintText: t['toolPlaceholder'],
                      filled: true,
                      fillColor: AppColors.muted,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Max Uses Input
                  Text(t['maxUses']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: maxUsesController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => maxUses = int.tryParse(val) ?? 10,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.muted,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type Picker
                  Text(t['toolType']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => type = ToolType.razor),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: type == ToolType.razor ? AppColors.cyan.withOpacity(0.2) : AppColors.muted,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: type == ToolType.razor ? AppColors.cyan : Colors.transparent),
                            ),
                            child: Center(
                              child: Text(t['razor']!, style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: type == ToolType.razor ? AppColors.cyan : AppColors.foreground
                              )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => type = ToolType.trimmer),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: type == ToolType.trimmer ? AppColors.cyan.withOpacity(0.2) : AppColors.muted,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: type == ToolType.trimmer ? AppColors.cyan : Colors.transparent),
                            ),
                            child: Center(
                              child: Text(t['trimmer']!, style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: type == ToolType.trimmer ? AppColors.cyan : AppColors.foreground
                              )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Color Picker
                  Text(t['accent']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Pick a color!'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: Color(color),
                                      onColorChanged: (Color newColor) {
                                        setModalState(() => color = newColor.value);
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: const Text('Got it'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(color),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.palette, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Buttons
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.violet]),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (name.trim().isEmpty) return;
                        if (existingTool != null) {
                          store.updateTool(existingTool.id, name.trim(), type, maxUses, color);
                        } else {
                          store.addTool(name.trim(), type, maxUses, color);
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(existingTool != null ? t['save']! : t['add']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  if (existingTool != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton.icon(
                        onPressed: () {
                          // Note: In a real app we might want a confirm dialog here
                          store.deleteTool(existingTool.id);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(LucideIcons.trash2, color: AppColors.due, size: 18),
                        label: Text(t['deleteTool']!, style: const TextStyle(color: AppColors.due, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              store.reorderTools(oldIndex, newIndex);
            },
            children: [
              ...store.tools.map((tool) {
                final health = (1 - tool.currentUses / tool.maxUses).clamp(0.0, 1.0);
                final healthPercent = (health * 100).round();
                final toolColor = Color(tool.color);

                return Container(
                  key: ValueKey(tool.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 12),
                            child: Icon(LucideIcons.gripVertical, size: 20, color: AppColors.mutedForeground),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: toolColor, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tool.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      tool.type == ToolType.trimmer ? t['trimmer']! : t['razor']!,
                                      style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${tool.currentUses} ${t['of']} ${tool.maxUses} ${t['uses']}',
                                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$healthPercent',
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                              ),
                              const Text('%', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: health,
                          child: Container(
                            decoration: BoxDecoration(
                              color: toolColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => store.replaceBlade(tool.id),
                              icon: const Icon(LucideIcons.refreshCw, size: 16, color: AppColors.foreground),
                              label: Text(t['replaceBlade']!, style: const TextStyle(color: AppColors.foreground)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _showAddEditTool(context, existingTool: tool),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            child: const Icon(LucideIcons.pencil, size: 16, color: AppColors.foreground),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.violet]),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showAddEditTool(context),
              icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
              label: Text(t['addTool']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
