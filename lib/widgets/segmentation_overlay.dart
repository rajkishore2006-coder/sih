import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:onion_quality_app/models/analysis_models.dart';

class SegmentationOverlayWidget extends StatefulWidget {
  final Uint8List? imageBytes;
  final List<OnionDetectionItem> detections;
  final ValueChanged<OnionDetectionItem?>? onSelectDetection;

  const SegmentationOverlayWidget({
    super.key,
    required this.detections,
    this.imageBytes,
    this.onSelectDetection,
  });

  @override
  State<SegmentationOverlayWidget> createState() =>
      _SegmentationOverlayWidgetState();
}

class _SegmentationOverlayWidgetState extends State<SegmentationOverlayWidget> {
  bool _showPolygons = true;
  bool _showBoundingBoxes = true;
  bool _showLabels = true;
  DefectType? _filterDefect;
  OnionDetectionItem? _selectedDetection;

  @override
  Widget build(BuildContext context) {
    final filteredDetections = _filterDefect == null
        ? widget.detections
        : widget.detections
            .where((d) => d.defectType == _filterDefect)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Controls Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text('Polygons', style: TextStyle(fontSize: 12)),
                selected: _showPolygons,
                onSelected: (val) => setState(() => _showPolygons = val),
              ),
              FilterChip(
                label: const Text('Boxes', style: TextStyle(fontSize: 12)),
                selected: _showBoundingBoxes,
                onSelected: (val) => setState(() => _showBoundingBoxes = val),
              ),
              FilterChip(
                label: const Text('Labels', style: TextStyle(fontSize: 12)),
                selected: _showLabels,
                onSelected: (val) => setState(() => _showLabels = val),
              ),
              DropdownButton<DefectType?>(
                value: _filterDefect,
                hint: const Text('Filter defect: All', style: TextStyle(fontSize: 12)),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<DefectType?>(
                    value: null,
                    child: Text('All Defects', style: TextStyle(fontSize: 12)),
                  ),
                  ...DefectType.values.map(
                    (d) => DropdownMenuItem<DefectType?>(
                      value: d,
                      child: Text(d.label, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _filterDefect = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Interactive Stage
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return GestureDetector(
                  onTapUp: (details) {
                    final normX = details.localPosition.dx / w;
                    final normY = details.localPosition.dy / h;

                    OnionDetectionItem? hit;
                    for (final d in filteredDetections) {
                      if (normX >= d.bbox.xmin &&
                          normX <= d.bbox.xmax &&
                          normY >= d.bbox.ymin &&
                          normY <= d.bbox.ymax) {
                        hit = d;
                        break;
                      }
                    }

                    setState(() => _selectedDetection = hit);
                    widget.onSelectDetection?.call(hit);
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base Image or Synthetic Onion Heap Canvas
                      widget.imageBytes != null
                          ? Image.memory(
                              widget.imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF6E2626),
                                    const Color(0xFF8B3A3A),
                                    const Color(0xFF4A1818),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 48,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Heap Image Sample Canvas (${widget.detections.length} visible onions)',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                      // Custom Painter for segmentation masks and bounding boxes
                      CustomPaint(
                        painter: _SegmentationPainter(
                          detections: filteredDetections,
                          selectedDetection: _selectedDetection,
                          showPolygons: _showPolygons,
                          showBoxes: _showBoundingBoxes,
                          showLabels: _showLabels,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Selected Bulb Details Card if clicked
        if (_selectedDetection != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.deepPurple.shade200),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getDefectColor(_selectedDetection!.defectType)
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: 16,
                    color: _getDefectColor(_selectedDetection!.defectType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onion #${_selectedDetection!.id}: ${_selectedDetection!.defectType.label}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Grade: ${_selectedDetection!.grade.label} • Est. Diameter: ${_selectedDetection!.estimatedDiameterMm} mm • Conf: ${(_selectedDetection!.confidence * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedDetection = null),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static Color _getDefectColor(DefectType defect) {
    switch (defect) {
      case DefectType.healthy:
        return const Color(0xFF16A34A); // Green
      case DefectType.damaged:
        return const Color(0xFFEA580C); // Orange
      case DefectType.rotten:
        return const Color(0xFFDC2626); // Red
      case DefectType.sprouted:
        return const Color(0xFFCA8A04); // Yellow/Amber
      case DefectType.undersized:
        return const Color(0xFF9333EA); // Purple
      case DefectType.unknown:
        return const Color(0xFF6B7280); // Gray
    }
  }
}

class _SegmentationPainter extends CustomPainter {
  final List<OnionDetectionItem> detections;
  final OnionDetectionItem? selectedDetection;
  final bool showPolygons;
  final bool showBoxes;
  final bool showLabels;

  _SegmentationPainter({
    required this.detections,
    required this.selectedDetection,
    required this.showPolygons,
    required this.showBoxes,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final det in detections) {
      final isSelected = selectedDetection?.id == det.id;
      final color = _SegmentationOverlayWidgetState._getDefectColor(det.defectType);

      // Draw Polygon Mask
      if (showPolygons && det.polygon.length >= 3) {
        final path = Path();
        for (int i = 0; i < det.polygon.length; i++) {
          final pt = det.polygon[i];
          final dx = pt.x * w;
          final dy = pt.y * h;
          if (i == 0) {
            path.moveTo(dx, dy);
          } else {
            path.lineTo(dx, dy);
          }
        }
        path.close();

        final fillPaint = Paint()
          ..color = color.withOpacity(isSelected ? 0.60 : 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        final strokePaint = Paint()
          ..color = isSelected ? Colors.white : color
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 1.5;
        canvas.drawPath(path, strokePaint);
      }

      // Draw Bounding Box
      final boxRect = Rect.fromLTRB(
        det.bbox.xmin * w,
        det.bbox.ymin * h,
        det.bbox.xmax * w,
        det.bbox.ymax * h,
      );

      if (showBoxes) {
        final boxPaint = Paint()
          ..color = isSelected ? Colors.amberAccent : color.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 1.0;
        canvas.drawRect(boxRect, boxPaint);
      }

      // Draw Label Badge
      if (showLabels) {
        final textSpan = TextSpan(
          text: '#${det.id} ${det.defectType.label}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final labelRect = Rect.fromLTWH(
          boxRect.left,
          (boxRect.top - 16).clamp(0.0, h - 16),
          textPainter.width + 6,
          15,
        );

        canvas.drawRect(
          labelRect,
          Paint()..color = Colors.black.withOpacity(0.75),
        );
        textPainter.paint(
          canvas,
          Offset(labelRect.left + 3, labelRect.top + 1),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentationPainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.selectedDetection != selectedDetection ||
        oldDelegate.showPolygons != showPolygons ||
        oldDelegate.showBoxes != showBoxes ||
        oldDelegate.showLabels != showLabels;
  }
}
