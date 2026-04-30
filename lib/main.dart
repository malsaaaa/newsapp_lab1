// lib/main.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'article.dart';
import 'news_api_service.dart';
import 'article_detail_page.dart';
import 'theme.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatefulWidget {
  const NewsApp();

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  bool isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App Lab',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: NewsHomePage(onThemeToggle: _toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const NewsHomePage({
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  final NewsApiService newsApiService = NewsApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Article> articles = [];
  bool isLoading = false;
  bool isSearching = false;
  int currentPage = 1;
  String? currentSearchQuery;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHeadlines();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Loads initial headlines
  void _loadHeadlines() async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final newArticles = await newsApiService.fetchTopHeadlines(page: currentPage);
      setState(() {
        if (currentPage == 1) {
          articles = newArticles;
        } else {
          articles.addAll(newArticles);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Loads search results
  void _searchArticles(String query) async {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    if (isLoading) return;

    setState(() {
      isLoading = true;
      isSearching = true;
      currentSearchQuery = query;
      errorMessage = null;
      currentPage = 1;
    });

    try {
      final newArticles = await newsApiService.searchNews(
        query: query,
        page: currentPage,
      );
      setState(() {
        articles = newArticles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Clears search and returns to headlines
  void _clearSearch() {
    setState(() {
      isSearching = false;
      currentSearchQuery = null;
      currentPage = 1;
      articles.clear();
      errorMessage = null;
    });
    _searchController.clear();
    _loadHeadlines();
  }

  /// Detects when user scrolls near bottom to load more articles
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!isLoading) {
        currentPage++;
        if (isSearching && currentSearchQuery != null) {
          _loadMoreSearchResults();
        } else {
          _loadHeadlines();
        }
      }
    }
  }

  /// Loads more search results
  void _loadMoreSearchResults() async {
    if (isLoading || currentSearchQuery == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newArticles = await newsApiService.searchNews(
        query: currentSearchQuery!,
        page: currentPage,
      );
      setState(() {
        articles.addAll(newArticles);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        elevation: 0,
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.brightness_7 : Icons.brightness_4,
            ),
            tooltip: widget.isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: widget.onThemeToggle,
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                currentPage = 1;
                articles.clear();
                errorMessage = null;
              });
              _loadHeadlines();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search news...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _searchController.clear,
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSubmitted: (query) {
                      _searchArticles(query);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchController.text.isEmpty
                      ? null
                      : () => _searchArticles(_searchController.text),
                  child: const Text('Search'),
                ),
                if (isSearching)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                    tooltip: 'Clear search',
                  ),
              ],
            ),
          ),

          /// Error Message
          if (errorMessage != null)
            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          /// Articles List
          Expanded(
            child: articles.isEmpty && !isLoading
                ? Center(
                    child: Text(
                      isSearching
                          ? 'No articles found for "$currentSearchQuery"'
                          : 'No news available',
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: articles.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == articles.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return NewsArticleTile(article: articles[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class NewsArticleTile extends StatelessWidget {
  final Article article;

  const NewsArticleTile({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: _buildArticleImage(),
        title: Text(article.title),
        subtitle: Text(
          article.truncatedDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailPage(article: article),
            ),
          );
        },
      ),
    );
  }

  /// Build article thumbnail with improved error handling
  Widget _buildArticleImage() {
    return CachedNetworkImage(
      imageUrl: article.imageUrl,
      width: 100,
      height: 80,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      httpHeaders: const {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      placeholder: (context, url) => Container(
        width: 100,
        height: 80,
        alignment: Alignment.center,
        color: Colors.grey[200],
        child: const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}