// lib/article_detail_page.dart

import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'article.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleDetailPage extends StatefulWidget {
  final Article article;

  const ArticleDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool isLoading = true;
  String? errorMessage;

  // Only used on mobile platforms
  late dynamic _webViewController;
  bool _isWebPlatform = false;

  @override
  void initState() {
    super.initState();
    _initializeView();
  }

  /// Initialize view based on platform
  void _initializeView() {
    // Check if running on web
    try {
      _isWebPlatform = !Platform.isAndroid && !Platform.isIOS;
    } catch (e) {
      _isWebPlatform = true;
    }

    // Skip WebView due to CORS/ORB issues - just show article preview on all platforms
    setState(() {
      isLoading = false;
    });
  }

  /// Initialize WebViewController (disabled due to CORS/ORB issues)
  void _initializeWebView() {
    // WebView disabled - use article preview and external browser instead
  }
  /// Opens URL in external browser
  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article URL is not available')),
      );
      return;
    }

    final Uri url = Uri.parse(urlString);
    try {
      // Try to launch with external app
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Try with platformDefault mode as fallback
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening URL: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        elevation: 0,
        actions: [
          // Open in browser button
          if (widget.article.url.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: 'Open in browser',
              onPressed: () => _launchURL(widget.article.url),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Always show article preview (WebView disabled due to CORS/ORB issues)
          _buildArticlePreviewPage(),

          // Loading indicator
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  /// Builds error widget when WebView fails
  Widget _buildErrorWidget() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Unable to load article',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              // Fallback article preview
              _buildArticlePreview(),
              const SizedBox(height: 24),
              // Retry or open in browser buttons
              if (widget.article.url.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isWebPlatform)
                      ElevatedButton.icon(
                        onPressed: () => _initializeWebView(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    if (!_isWebPlatform) const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _launchURL(widget.article.url),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open in Browser'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds full article preview page (for web or when WebView unavailable)
  Widget _buildArticlePreviewPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildArticlePreview(),
      ),
    );
  }

  /// Builds article preview card
  Widget _buildArticlePreview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.article.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.article.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                httpHeaders: const {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                },
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.article.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.article.url.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL(widget.article.url),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Read Full Article'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
