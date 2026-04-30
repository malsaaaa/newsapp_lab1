// lib/cache_manager.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'article.dart';

class CacheManager {
  static const String _headlinesCacheKey = 'cached_headlines';
  static const String _searchCacheKeyPrefix = 'cached_search_';
  static const String _cacheTimestampKeyPrefix = 'cache_timestamp_';
  static const int _cacheExpirationHours = 24;

  late SharedPreferences _preferences;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Saves headlines to cache with timestamp
  Future<void> saveHeadlines(List<Article> articles) async {
    try {
      final jsonList = articles
          .map((article) => _articleToJson(article))
          .toList();
      
      await _preferences.setString(
        _headlinesCacheKey,
        jsonEncode(jsonList),
      );
      
      await _preferences.setInt(
        '$_cacheTimestampKeyPrefix$_headlinesCacheKey',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error saving headlines to cache: $e');
    }
  }

  /// Retrieves cached headlines
  Future<List<Article>?> getHeadlines() async {
    try {
      if (!_isCacheValid(_headlinesCacheKey)) {
        return null;
      }

      final jsonString = _preferences.getString(_headlinesCacheKey);
      if (jsonString == null) {
        return null;
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving headlines from cache: $e');
      return null;
    }
  }

  /// Saves search results to cache
  Future<void> saveSearchResults(String query, List<Article> articles) async {
    try {
      final cacheKey = '$_searchCacheKeyPrefix${query.hashCode}';
      
      final jsonList = articles
          .map((article) => _articleToJson(article))
          .toList();
      
      await _preferences.setString(
        cacheKey,
        jsonEncode(jsonList),
      );
      
      await _preferences.setInt(
        '$_cacheTimestampKeyPrefix$cacheKey',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error saving search results to cache: $e');
    }
  }

  /// Retrieves cached search results
  Future<List<Article>?> getSearchResults(String query) async {
    try {
      final cacheKey = '$_searchCacheKeyPrefix${query.hashCode}';
      
      if (!_isCacheValid(cacheKey)) {
        return null;
      }

      final jsonString = _preferences.getString(cacheKey);
      if (jsonString == null) {
        return null;
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving search results from cache: $e');
      return null;
    }
  }

  /// Checks if cache is still valid (not expired)
  bool _isCacheValid(String cacheKey) {
    try {
      final timestampKey = '$_cacheTimestampKeyPrefix$cacheKey';
      final timestamp = _preferences.getInt(timestampKey);
      
      if (timestamp == null) {
        return false;
      }

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cachedTime).inHours;

      return difference < _cacheExpirationHours;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }

  /// Gets cache timestamp for a specific key
  DateTime? getCacheTimestamp(String cacheKey) {
    try {
      final timestampKey = '$_cacheTimestampKeyPrefix$cacheKey';
      final timestamp = _preferences.getInt(timestampKey);
      
      if (timestamp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      print('Error getting cache timestamp: $e');
      return null;
    }
  }

  /// Checks if data is cached
  bool isCached(String cacheKey) {
    return _preferences.containsKey(cacheKey) && _isCacheValid(cacheKey);
  }

  /// Clears specific cache
  Future<void> clearCache(String cacheKey) async {
    try {
      await _preferences.remove(cacheKey);
      await _preferences.remove('$_cacheTimestampKeyPrefix$cacheKey');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Clears all cached data
  Future<void> clearAllCache() async {
    try {
      final keys = _preferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(_headlinesCacheKey) ||
            key.startsWith(_searchCacheKeyPrefix) ||
            key.startsWith(_cacheTimestampKeyPrefix)) {
          await _preferences.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  /// Converts Article to JSON for storage
  Map<String, dynamic> _articleToJson(Article article) {
    return {
      'title': article.title,
      'description': article.description,
      'urlToImage': article.urlToImage,
      'url': article.url,
    };
  }
}
