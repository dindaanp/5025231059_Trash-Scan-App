import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../utils/trash_helper.dart';

class LiveDetectionScreen extends StatefulWidget {
  const LiveDetectionScreen({super.key});

  @override
  State<LiveDetectionScreen> createState() => _LiveDetectionScreenState();
}

class _LiveDetectionScreenState extends State<LiveDetectionScreen> {
  List<YOLOResult> _detections = [];

  static const String _modelPath = 'assets/models/trashscan_v1_int8.tflite';

  List<YOLOResult> get _validDetections {
    final filtered = _detections
        .where((d) => d.confidence >= 0.35 && isTrashLabel(d.className))
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    // hapus duplikat label (ambil yang confidence tertinggi)
    final seen = <String>{};
    return filtered.where((d) => seen.add(d.className)).toList();
  }

  YOLOResult? get _topResult =>
      _validDetections.isNotEmpty ? _validDetections.first : null;

  String get _topCategory =>
      _topResult == null ? '-' : getCategory(_topResult!.className);

  String get _topLabel =>
      _topResult == null ? '-' : _topResult!.className;

  double get _topConfidence =>
      _topResult == null ? 0 : _topResult!.confidence;

  @override
  Widget build(BuildContext context) {
    final category = _topCategory;
    final color = getCategoryColor(category);
    final bgColor = getCategoryBgColor(category);
    final icon = getCategoryIcon(category);
    final hasResult = _topResult != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Kamera
          YOLOView(
            modelPath: _modelPath,
            task: YOLOTask.detect,
            confidenceThreshold: 0.35,
            iouThreshold: 0.45,
            lensFacing: LensFacing.back,
            showNativeUI: false,
            onResult: (results) {
              if (mounted) setState(() => _detections = results);
            },
            onPerformanceMetrics: (_) {},
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      // tombol kembali
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 17),
                        ),
                      ),
                      const SizedBox(width: 11),

                      // Status deteksi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasResult
                                  ? '${_validDetections.length} objek terdeteksi'
                                  : 'Mencari objek...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Arahkan kamera ke sampah',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Chip kategori (muncul otomatis saat ada deteksi)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: hasResult
                            ? Container(
                                key: ValueKey(category),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.45)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, color: color, size: 13),
                                    const SizedBox(width: 5),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.38,
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: const Color(0xF20D1F17),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
                border: Border(
                  top: BorderSide(
                    color: hasResult
                        ? color.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: hasResult
                  ? _buildResultCard(category, color, bgColor, icon)
                  : _buildEmptyCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.25), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Belum ada deteksi',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'Arahkan ke sampah plastik, kertas, organik, atau elektronik',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
      String category, Color color, Color bgColor, IconData icon) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + confidence
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    _topLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(_topConfidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Ikon + kategori
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                category,
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 10),

          // Tips
          Text(
            getLabelTips(_topLabel),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
                height: 1.55),
          ),

          // Objek lain (maks 3)
          if (_validDetections.length > 1) ...[
            const SizedBox(height: 12),
            Text(
              'Objek lain yang terdeteksi',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            ..._validDetections.skip(1).take(3).map((d) {
              final c = getCategoryColor(getCategory(d.className));
              final cat = getCategory(d.className);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                              color: c.withValues(alpha: 0.22)),
                        ),
                        child: Text(
                          d.className,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: c.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(cat,
                        style: TextStyle(
                            fontSize: 11,
                            color: c.withValues(alpha: 0.6))),
                    const Spacer(),
                    Text(
                      '${(d.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontSize: 11,
                          color: c,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}