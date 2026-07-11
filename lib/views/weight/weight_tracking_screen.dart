import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snacktrack/models/weight_entry_model.dart';
import '../../../controllers/weight_controller.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeightController>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeightController>();
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1629)
          : const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Weight Tracking'),
        backgroundColor: isDark
            ? const Color(0xFF0F1629)
            : const Color(0xFFF4F4F4),
        elevation: 0,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controller.loadHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryHeader(controller: controller),
                    const SizedBox(height: 20),
                    if (controller.history.length >= 2)
                      _buildChart(controller, scheme)
                    else
                      _EmptyChartHint(),
                    const SizedBox(height: 20),
                    Text(
                      'HISTORY',
                      style: tt.labelSmall?.copyWith(
                        letterSpacing: 1.5,
                        color: scheme.onSurface.withAlpha(100),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.history.map(
                      (entry) => _WeightEntryTile(
                        entry: entry,
                        onDelete: () => controller.deleteEntry(entry.id),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogWeightDialog(context, controller),
        backgroundColor: scheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Weight',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildChart(
      WeightController controller, ColorScheme scheme) {
    final values = controller.history
        .reversed
        .map((e) => e.weightKg)
        .toList();
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 16, 16, 16),
        child: SizedBox(
          height: 200,
          child: CustomPaint(
            size: Size.infinite,
            painter: _WeightLinePainter(
              values: values,
              lineColor: scheme.primary,
              fillColor: scheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogWeightDialog(
      BuildContext context, WeightController controller) {
    double weight = controller.latestWeight?.weightKg ?? 70;
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: Theme.of(ctx).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Log Weight',
                style: tt.headlineMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${weight.toStringAsFixed(1)} kg',
                  style: tt.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    color: scheme.primary,
                  ),
                ),
                Slider(
                  value: weight,
                  min: 30,
                  max: 200,
                  divisions: 340,
                  label: '${weight.toStringAsFixed(1)} kg',
                  onChanged: (v) => setState(() => weight = v),
                ),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Notes (optional)',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.logWeight(
                    weight,
                    notes: notesCtrl.text.isNotEmpty
                        ? notesCtrl.text
                        : null,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final WeightController controller;
  const _SummaryHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final latest = controller.latestWeight;
    final change = controller.weightChangeLastWeek;
    final trend = controller.trendDirection;

    Color trendColor;
    IconData trendIcon;
    switch (trend) {
      case 'down':
        trendColor = Colors.green;
        trendIcon = Icons.trending_down;
      case 'up':
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
      default:
        trendColor = scheme.onSurface.withAlpha(100);
        trendIcon = Icons.trending_flat;
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT WEIGHT',
                  style: tt.labelSmall?.copyWith(
                    color: scheme.onSurface.withAlpha(100),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      latest != null
                          ? latest.weightKg.toStringAsFixed(1)
                          : '–',
                      style: tt.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 38,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('kg', style: tt.bodyMedium),
                    ),
                  ],
                ),
                if (latest != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${latest.loggedAt.day}/${latest.loggedAt.month}',
                      style: tt.labelSmall?.copyWith(
                        color: scheme.onSurface.withAlpha(80),
                      ),
                    ),
                  ),
              ],
            ),
            if (change != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: trendColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: trendColor.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, color: trendColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                      style: tt.labelLarge?.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChartHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.monitor_weight_outlined,
                size: 48, color: scheme.onSurface.withAlpha(60)),
            const SizedBox(height: 12),
            Text(
              'Log at least 2 entries to see your trend chart',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: scheme.onSurface.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightEntryTile extends StatelessWidget {
  final WeightEntry entry;
  final VoidCallback onDelete;

  const _WeightEntryTile({
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text(
                'Are you sure you want to delete this weight entry?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.weightKg.toStringAsFixed(1)} kg',
                  style: tt.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Text(
                    entry.notes!,
                    style: tt.bodySmall?.copyWith(
                      color: scheme.onSurface.withAlpha(120),
                    ),
                  ),
              ],
            ),
            Text(
              _formatDate(entry.loggedAt),
              style: tt.labelSmall?.copyWith(
                color: scheme.onSurface.withAlpha(120),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) {
      return 'Today, ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}';
    }
    if (diff == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Weight Line Chart Painter ──────────────────────────────────────────────

class _WeightLinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  _WeightLinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final min = values.reduce((a, b) => a < b ? a : b) - 2;
    final max = values.reduce((a, b) => a > b ? a : b) + 2;
    final range = (max - min).clamp(1.0, double.infinity);

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - min) / range) * size.height;
      points.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor.withAlpha(80), fillColor.withAlpha(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(points.first.dx, size.height);
    for (final p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }

    final labelStyle = TextStyle(color: lineColor.withAlpha(120), fontSize: 10);
    for (var i = 0; i <= 4; i++) {
      final val = min + (range * i / 4);
      final y = size.height - (i / 4) * size.height;
      final tp = TextPainter(
        text: TextSpan(
          text: val.toStringAsFixed(1),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(4, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLinePainter old) =>
      old.values != values;
}

