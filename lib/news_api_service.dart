// lib/news_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article.dart';
import 'cache_manager.dart';

class NewsApiService {
  final String apiKey = '06c35b644d90456d9c3ffb64dca6c39b'; // Get free key at https://newsapi.org
  final String baseUrl = 'https://newsapi.org/v2';
  final CacheManager cacheManager = CacheManager();

  /// Validates if the API key has been set
  bool get isApiKeyConfigured => apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE';

  /// Fetches top headlines with optional filters and pagination
  /// [country] - Country code (e.g., 'us' for USA - NewsAPI.org uses lowercase)
  /// [category] - News category (e.g., 'business', 'sports', 'health')
  /// [page] - Page number for pagination (starts at 1)
  /// [pageSize] - Number of articles per page (default 20, max 100)
  /// [useCache] - Whether to use cached data if available
  Future<List<Article>> fetchTopHeadlines({
    String country = 'us',
    String? category,
    int page = 1,
    int pageSize = 20,
    bool useCache = true,
  }) async {
    if (!isApiKeyConfigured) {
      throw Exception('API key not configured. Please set your NewsAPI.org API key. Get one free at https://newsapi.org');
    }

    if (country.isEmpty) {
      throw Exception('Country code cannot be empty');
    }

    if (page < 1) {
      throw Exception('Page number must be greater than 0');
    }

    if (pageSize < 1 || pageSize > 100) {
      throw Exception('Page size must be between 1 and 100');
    }

    // Try to use cache for first page
    if (page == 1 && useCache) {
      await cacheManager.init();
      final cachedArticles = await cacheManager.getHeadlines();
      if (cachedArticles != null) {
        return cachedArticles;
      }
    }

    String url = '$baseUrl/top-headlines?country=${country.toLowerCase()}&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout. Please check your internet connection.'),
      );

      if (response.statusCode == 200) {
        // Explicitly decode response as UTF-8
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = json.decode(decodedBody);
        
        if (jsonData['articles'] == null) {
          throw Exception('Invalid response format: ${jsonData.keys.join(", ")}');
        }

        final List<dynamic> articlesJson = jsonData['articles'] as List<dynamic>;

        if (articlesJson.isEmpty) {
          return [];
        }

        final articles = articlesJson
            .map((jsonItem) => Article.fromJson(jsonItem as Map<String, dynamic>))
            .toList();

        // Cache the first page
        if (page == 1) {
          await cacheManager.init();
          await cacheManager.saveHeadlines(articles);
        }

        return articles;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid API key. Get a free key at https://newsapi.org');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests: Rate limit exceeded');
      } else {
        throw Exception('Failed to load news (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Try to use cache as fallback
      if (page == 1) {
        await cacheManager.init();
        final cachedArticles = await cacheManager.getHeadlines();
        if (cachedArticles != null) {
          return cachedArticles;
        }
      }
      rethrow;
    }
  }

  /// Searches for news articles by query with pagination
  /// [query] - Search query string
  /// [sortBy] - Sort results by 'relevancy', 'popularity', or 'publishedAt'
  /// [page] - Page number for pagination (starts at 1)
  /// [pageSize] - Number of articles per page (default 20, max 100)
  /// [useCache] - Whether to use cached data if available
  Future<List<Article>> searchNews({
    required String query,
    String sortBy = 'publishedAt',
    int page = 1,
    int pageSize = 20,
    bool useCache = true,
  }) async {
    if (!isApiKeyConfigured) {
      throw Exception('API key not configured. Please set your NewsAPI.org API key. Get one free at https://newsapi.org');
    }

    if (query.isEmpty) {
      throw Exception('Search query cannot be empty');
    }

    if (page < 1) {
      throw Exception('Page number must be greater than 0');
    }

    if (pageSize < 1 || pageSize > 100) {
      throw Exception('Page size must be between 1 and 100');
    }

    // Try to use cache for first page
    if (page == 1 && useCache) {
      await cacheManager.init();
      final cachedArticles = await cacheManager.getSearchResults(query);
      if (cachedArticles != null) {
        return cachedArticles;
      }
    }

    final String url = '$baseUrl/everything?q=$query&sortBy=$sortBy&page=$page&pageSize=$pageSize&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout. Please check your internet connection.'),
      );

      if (response.statusCode == 200) {
        // Explicitly decode response as UTF-8
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = json.decode(decodedBody);
        
        if (jsonData['articles'] == null) {
          throw Exception('Invalid response format');
        }

        final List<dynamic> articlesJson = jsonData['articles'] as List<dynamic>;

        if (articlesJson.isEmpty) {
          return [];
        }

        final articles = articlesJson
            .map((jsonItem) => Article.fromJson(jsonItem as Map<String, dynamic>))
            .toList();

        // Cache the first page
        if (page == 1) {
          await cacheManager.init();
          await cacheManager.saveSearchResults(query, articles);
        }

        return articles;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid API key. Get a free key at https://newsapi.org');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests: Rate limit exceeded');
      } else {
        throw Exception('Failed to search news (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Try to use cache as fallback
      if (page == 1) {
        await cacheManager.init();
        final cachedArticles = await cacheManager.getSearchResults(query);
        if (cachedArticles != null) {
          return cachedArticles;
        }
      }
      rethrow;
    }
  }
}
