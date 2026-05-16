// lib/main.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'article.dart';
import 'news_api_service.dart';
import 'article_detail_page.dart';
import 'theme.dart';
import 'config.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'widgets/notification_overlay.dart';

void main() async {
  // Initialize environment configuration
  await AppConfig.initialize();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Log configuration for debugging
  if (AppConfig.enableDetailedLogs) {
    AppConfig.printConfiguration();
  }
  
  runApp(const NewsApp());
}

class NewsApp extends StatefulWidget {
  const NewsApp();

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  bool isDarkMode = false;
  late Future<bool> _isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = AuthService.isLoggedIn();
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void _refreshAuth() {
    setState(() {
      _isLoggedInFuture = AuthService.isLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationOverlay(
      child: MaterialApp(
        title: 'News App Lab',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: FutureBuilder<bool>(
          future: _isLoggedInFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isLoggedIn = snapshot.data ?? false;

            if (!isLoggedIn) {
              return AuthNavigation(
                onLoginSuccess: _refreshAuth,
              );
            }

            return NewsHomePage(
              onThemeToggle: _toggleTheme,
              isDarkMode: isDarkMode,
              onLogout: _refreshAuth,
            );
          },
        ),
      ),
    );
  }
}

// Auth Navigation
class AuthNavigation extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthNavigation({
    Key? key,
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  State<AuthNavigation> createState() => _AuthNavigationState();
}

class _AuthNavigationState extends State<AuthNavigation> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? LoginScreen(
            onLoginSuccess: widget.onLoginSuccess,
            onNavigateToSignup: () {
              setState(() => _showLogin = false);
            },
          )
        : SignupScreen(
            onSignupSuccess: widget.onLoginSuccess,
            onNavigateToLogin: () {
              setState(() => _showLogin = true);
            },
          );
  }
}


class NewsHomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final VoidCallback? onLogout;

  const NewsHomePage({
    required this.onThemeToggle,
    required this.isDarkMode,
    this.onLogout,
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
          // Bookmarks button
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'My Bookmarks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarksScreen(
                    onLogout: widget.onLogout ?? () {},
                  ),
                ),
              );
            },
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
          // Logout button
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            AuthService.logout();
                            if (widget.onLogout != null) {
                              widget.onLogout!();
                            }
                          },
                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
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

class NewsArticleTile extends StatefulWidget {
  final Article article;

  const NewsArticleTile({Key? key, required this.article}) : super(key: key);

  @override
  State<NewsArticleTile> createState() => _NewsArticleTileState();
}

class _NewsArticleTileState extends State<NewsArticleTile> {
  bool _isBookmarking = false;

  void _handleBookmark() async {
    setState(() => _isBookmarking = true);

    final result = await AuthService.addBookmark(
      articleUrl: widget.article.url,
      title: widget.article.title,
      description: widget.article.description,
      urlToImage: widget.article.imageUrl,
      source: 'News Source',
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article bookmarked! 📚')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result['message']}')),
      );
    }

    setState(() => _isBookmarking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: _buildArticleImage(),
        title: Text(widget.article.title),
        subtitle: Text(
          widget.article.truncatedDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: _isBookmarking
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.bookmark_border),
          onPressed: _isBookmarking ? null : _handleBookmark,
          tooltip: 'Bookmark article',
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailPage(article: widget.article),
            ),
          );
        },
      ),
    );
  }

  /// Build article thumbnail with improved error handling
  Widget _buildArticleImage() {
    return CachedNetworkImage(
      imageUrl: widget.article.imageUrl,
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