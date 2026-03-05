import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_tokens.dart';
import '../../l10n/strings.dart';

class PdfViewerView extends StatefulWidget {
  final String url;
  final String? fileName;

  const PdfViewerView({
    super.key,
    required this.url,
    this.fileName,
  });

  @override
  State<PdfViewerView> createState() => _PdfViewerViewState();
}

class _PdfViewerViewState extends State<PdfViewerView> {
  final PdfViewerController _controller = PdfViewerController();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: SizeTokens.iconSM,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.fileName ?? l10n.pdfViewerTitle,
          style: TextStyle(
            fontSize: SizeTokens.fontMD,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!_isLoading && !_hasError) ...[
            IconButton(
              icon: Icon(
                Icons.zoom_in_rounded,
                size: SizeTokens.iconSM,
                color: AppTheme.textPrimary,
              ),
              tooltip: l10n.pdfViewerZoomIn,
              onPressed: () => _controller.zoomLevel = (_controller.zoomLevel + 0.25).clamp(1.0, 3.0),
            ),
            IconButton(
              icon: Icon(
                Icons.zoom_out_rounded,
                size: SizeTokens.iconSM,
                color: AppTheme.textPrimary,
              ),
              tooltip: l10n.pdfViewerZoomOut,
              onPressed: () => _controller.zoomLevel = (_controller.zoomLevel - 0.25).clamp(1.0, 3.0),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            SfPdfViewer.network(
              widget.url,
              controller: _controller,
              onDocumentLoaded: (_) {
                if (mounted) setState(() => _isLoading = false);
              },
              onDocumentLoadFailed: (_) {
                if (mounted) setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              },
            ),
          if (_isLoading && !_hasError)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: SizeTokens.spaceMD),
                  Text(
                    l10n.pdfViewerLoading,
                    style: TextStyle(
                      fontSize: SizeTokens.fontSM,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.paddingLG),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: SizeTokens.iconXL,
                      color: AppTheme.error,
                    ),
                    SizedBox(height: SizeTokens.spaceMD),
                    Text(
                      l10n.pdfViewerError,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeTokens.fontSM,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
