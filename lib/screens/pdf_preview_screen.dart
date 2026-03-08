import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Tam ekran PDF önizleme: tek sayfa gösterilir, altta önceki/sonraki ile geçiş; zoom/pan tek sayfada rahat çalışır.
class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({
    super.key,
    required this.bytes,
    this.filename,
  });

  final Uint8List bytes;
  final String? filename;

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  final TransformationController _transformationController =
      TransformationController();
  int _currentPageIndex = 0;
  int _pageCount = 0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoomForNewPage() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PDF önizleme'),
        actions: [
          if (widget.filename != null && widget.filename!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                await Printing.sharePdf(
                    bytes: widget.bytes, filename: widget.filename!);
              },
              tooltip: 'Kaydet / Paylaş',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final vw = constraints.maxWidth;
                final vh = constraints.maxHeight;
                return InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  child: SizedBox(
                    width: vw,
                    height: vh,
                    child: Container(
                      color: Colors.white,
                      child: PdfPreview.builder(
                        build: (format) => Future.value(widget.bytes),
                        initialPageFormat: PdfPageFormat.a4.landscape,
                        allowSharing: false,
                        allowPrinting: false,
                        useActions: false,
                        scrollViewDecoration: const BoxDecoration(color: Colors.white),
                        pdfPreviewPageDecoration: const BoxDecoration(color: Colors.white),
                        pagesBuilder: (context, pages) {
                          if (pages.isEmpty) {
                            return const Center(child: Text('Sayfa yok'));
                          }
                          if (_pageCount != pages.length) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _pageCount = pages.length;
                                  _currentPageIndex =
                                      _currentPageIndex.clamp(0, pages.length - 1);
                                });
                              }
                            });
                          }
                          final index =
                              _currentPageIndex.clamp(0, pages.length - 1);
                          final page = pages[index];
                          final w = page.width.toDouble();
                          final h = page.height.toDouble();
                          return Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: w,
                                height: h,
                                child: _PdfPageImage(page: page),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _PageNavBar(
            currentIndex: _currentPageIndex,
            pageCount: _pageCount,
            onPrevious: () {
              if (_currentPageIndex > 0) {
                setState(() => _currentPageIndex--);
                _resetZoomForNewPage();
              }
            },
            onNext: () {
              if (_currentPageIndex < _pageCount - 1) {
                setState(() => _currentPageIndex++);
                _resetZoomForNewPage();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PageNavBar extends StatelessWidget {
  const _PageNavBar({
    required this.currentIndex,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentIndex;
  final int pageCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 4,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filled(
                onPressed: currentIndex > 0 ? onPrevious : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Önceki sayfa',
              ),
              Text(
                pageCount > 0
                    ? '${currentIndex + 1} / $pageCount'
                    : '—',
                style: theme.textTheme.titleMedium,
              ),
              IconButton.filled(
                onPressed: currentIndex < pageCount - 1 ? onNext : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Sonraki sayfa',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfPageImage extends StatelessWidget {
  const _PdfPageImage({required this.page});

  final PdfPreviewPageData page;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: page.image,
      width: page.width.toDouble(),
      height: page.height.toDouble(),
      fit: BoxFit.contain,
    );
  }
}
