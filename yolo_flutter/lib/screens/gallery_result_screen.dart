import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../utils/trash_helper.dart';
import 'live_detection_screen.dart';

class _DetectedItem {
  final String label;
  final double confidence;
  final String category;
  _DetectedItem({
    required this.label,
    required this.confidence,
    required this.category,
  });
}

class GalleryResultScreen extends StatefulWidget {
  final String imagePath;
  const GalleryResultScreen({super.key, required this.imagePath});

  @override
  State<GalleryResultScreen> createState() => _GalleryResultScreenState();
}

class _GalleryResultScreenState extends State<GalleryResultScreen> {
  bool _isAnalyzing = true;
  List<_DetectedItem> _results = [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final List<_DetectedItem> detected = [];

      final yolo = YOLO(
        modelPath: 'assets/models/trashscan_v1_int8.tflite',
        task: YOLOTask.detect,
      );
      await yolo.loadModel();

      final imageBytes = await File(widget.imagePath).readAsBytes();
      final resultMap = await yolo.predict(imageBytes);

      // Debug — lihat format response di terminal
      debugPrint('=== YOLO PREDICT RESULT ===');
      debugPrint('Type: ${resultMap.runtimeType}');
      debugPrint('Keys: ${resultMap.keys.toList()}');
      debugPrint('Full result: $resultMap');
      debugPrint('===========================');

      // Coba berbagai kemungkinan format key
      List<dynamic> resultList = [];

      if (resultMap.containsKey('boxes')) {
        resultList = (resultMap['boxes'] as List<dynamic>?) ?? [];
        debugPrint('Menggunakan key: boxes, jumlah: ${resultList.length}');
      } else if (resultMap.containsKey('detections')) {
        resultList = (resultMap['detections'] as List<dynamic>?) ?? [];
        debugPrint('Menggunakan key: detections, jumlah: ${resultList.length}');
      } else if (resultMap.containsKey('results')) {
        resultList = (resultMap['results'] as List<dynamic>?) ?? [];
        debugPrint('Menggunakan key: results, jumlah: ${resultList.length}');
      } else {
        // Kalau tidak ada key yang cocok, coba langsung parse value pertama
        final firstValue = resultMap.values.firstOrNull;
        if (firstValue is List) {
          resultList = firstValue;
          debugPrint('Menggunakan value pertama, jumlah: ${resultList.length}');
        }
      }

      for (final r in resultList) {
        debugPrint('Item: $r | Type: ${r.runtimeType}');
        try {
          final item = r as Map<String, dynamic>;

          // Coba berbagai kemungkinan key untuk label
          final label = (item['label'] as String?) ??
              (item['class'] as String?) ??
              (item['className'] as String?) ??
              '';

          // Coba berbagai kemungkinan key untuk confidence
          final confidence = (item['confidence'] as num?)?.toDouble() ??
              (item['score'] as num?)?.toDouble() ??
              (item['prob'] as num?)?.toDouble() ??
              0.0;

          debugPrint('Label: $label | Confidence: $confidence');

          if (confidence >= 0.30 && label.isNotEmpty) {
            detected.add(_DetectedItem(
              label: label,
              confidence: confidence,
              category: getCategory(label),
            ));
          }
        } catch (e) {
          debugPrint('Error parsing item: $e');
          continue;
        }
      }

      detected.sort((a, b) => b.confidence.compareTo(a.confidence));

      // Hapus duplikat label
      final seen = <String>{};
      final unique = detected.where((d) => seen.add(d.label)).toList();

      debugPrint('Total hasil terdeteksi: ${unique.length}');

      if (mounted) {
        setState(() {
          _results = unique;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      debugPrint('ERROR _analyzeImage: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMsg = 'Gagal menganalisis: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F17),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Hasil Deteksi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Foto
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(widget.imagePath),
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 240,
                          decoration: BoxDecoration(
                            color: const Color(0xFF112A1C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: Colors.white24, size: 48),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Status analisis / hasil
                    if (_isAnalyzing)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF112A1C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          children: [
                            CircularProgressIndicator(
                                color: Color(0xFF3DBE7A)),
                            SizedBox(height: 16),
                            Text(
                              'Menganalisis gambar...',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Proses ini mungkin membutuhkan beberapa detik',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white24, fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    else if (_errorMsg != null)
                      _buildErrorCard()
                    else if (_results.isEmpty)
                      _buildNoResult()
                    else
                      _buildResults(),

                    const SizedBox(height: 20),

                    // Tombol live camera
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LiveDetectionScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A7D4F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_rounded, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Mulai Live Camera',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE85A5A).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              color: const Color(0xFFE85A5A).withValues(alpha: 0.7),
              size: 40),
          const SizedBox(height: 10),
          Text(
            _errorMsg ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF112A1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A7D4F).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              color: Colors.white.withValues(alpha: 0.3), size: 48),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada sampah terdeteksi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba foto dengan pencahayaan lebih baik, atau gunakan Live Camera untuk hasil lebih akurat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final top = _results.first;
    final topColor = getCategoryColor(top.category);
    final topBg = getCategoryBgColor(top.category);
    final topIcon = getCategoryIcon(top.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hasil utama
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF112A1C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: topColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: topColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        top.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: topColor.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(top.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: topColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: topBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: topColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(topIcon, color: topColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    top.category,
                    style: TextStyle(
                      color: topColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),
              const SizedBox(height: 12),
              Text(
                getLabelTips(top.label),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        // Objek lain
        if (_results.length > 1) ...[
          const SizedBox(height: 14),
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
          ..._results.skip(1).map((d) {
            final c = getCategoryColor(d.category);
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
                        border:
                            Border.all(color: c.withValues(alpha: 0.22)),
                      ),
                      child: Text(
                        d.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: c.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    d.category,
                    style: TextStyle(
                        fontSize: 11, color: c.withValues(alpha: 0.6)),
                  ),
                  const Spacer(),
                  Text(
                    '${(d.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: c,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}