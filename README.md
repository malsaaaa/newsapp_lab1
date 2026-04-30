# News App Lab

A modern Flutter-based news application that fetches and displays top headlines and allows users to search for news articles. Built for ITT632 Mobile Cloud Computing course.

## 📱 Features

### Core Features
- **Top Headlines**: Displays latest news articles from USA
- **Search Functionality**: Search for specific news topics
- **Pagination**: Load more articles with infinite scroll
- **Local Caching**: 24-hour cache with SharedPreferences
- **Dark/Light Theme**: Toggle between dark and light modes
- **Article Details**: View full article content with external link
- **Image Support**: Display article images with graceful fallbacks

### Advanced Features
- **UTF-8 Decoding**: Proper character encoding handling
- **HTML Entity Decoding**: Clean up corrupted text in descriptions
- **Smart Image Fallback**: Picsum.photos fallback for missing images
- **Error Handling**: Comprehensive error messages and retry mechanisms
- **Responsive Design**: Works on all Android/iOS screen sizes
- **Offline Support**: Cached articles available without internet

## 🛠️ Requirements

- **Flutter**: ^3.11.5
- **Dart**: Latest version
- **Android**: SDK 21+ (API Level 21 and above)
- **iOS**: 11.0+
- **NewsAPI.org Account**: Free tier API key (required)

## 🚀 Getting Started

### 1. Clone/Setup the Project
```bash
cd news_app_lab
flutter pub get
```

### 2. Get Your NewsAPI.org API Key
1. Visit [newsapi.org](https://newsapi.org)
2. Sign up for a free account
3. Copy your API key from the dashboard

### 3. Configure the API Key
Open `lib/news_api_service.dart` and replace the API key:
```dart
final String apiKey = 'YOUR_API_KEY_HERE'; // Replace with your key
```

### 4. Run the App

**On Android Device:**
```bash
flutter clean
flutter build apk --debug
flutter install -d A015
flutter run -d A015
```

**On Android Emulator:**
```bash
flutter run
```

**On iOS:**
```bash
cd ios
pod install
cd ..
flutter run
```

## 📂 Project Structure

```
lib/
├── main.dart                 # Main app and UI (NewsApp, NewsHomePage, NewsArticleTile)
├── article.dart              # Article data model with HTML decoding
├── article_detail_page.dart  # Article detail view with external link
├── news_api_service.dart     # API integration layer (NewsAPI.org)
├── cache_manager.dart        # Local storage with SharedPreferences
└── theme.dart                # Light/Dark theme definitions
```

## 🔧 Technologies & Dependencies

### Core Framework
- **flutter**: ^3.11.5 - UI framework
- **dart**: Latest - Programming language

### Networking & API
- **http**: ^0.13.5 - HTTP client for API requests
- **url_launcher**: ^6.1.0 - Open URLs in external browser

### Storage & Caching
- **shared_preferences**: ^2.1.0 - Local persistent storage
- **cached_network_image**: ^3.2.3 - Image caching and display

### Architecture
- **Stateful Widgets**: State management (no Provider/GetX)
- **JSON Serialization**: Built-in `dart:convert`
- **Async/Await**: Async operations for API calls

## 🎨 UI Components

### Main Views
1. **NewsApp**: Root widget with theme toggle state
2. **NewsHomePage**: Main feed with search and pagination
3. **NewsArticleTile**: List item showing article preview
4. **ArticleDetailPage**: Full article view with external link

### Theme
- **Light Mode**: Blue accent, white background
- **Dark Mode**: Dark grey (#1F1F1F) background, elevated cards

## 🔌 API Configuration

### NewsAPI.org Endpoints Used
```
GET /top-headlines?country=us&apikey=YOUR_KEY
GET /everything?q={query}&sortBy=publishedAt&apikey=YOUR_KEY
```

### Response Format
```json
{
  "articles": [
    {
      "title": "Article Title",
      "description": "Article description",
      "urlToImage": "https://image.url",
      "url": "https://article.url"
    }
  ]
}
```

## 💾 Cache Configuration

- **Cache Duration**: 24 hours
- **Storage**: SharedPreferences
- **Cached Items**:
  - Top headlines (first page)
  - Search results (per query)
  - Timestamps for expiration

## 🎯 Key Features Explained

### Pagination
- Scroll detection triggers automatic loading of next page
- Scroll threshold: 500 pixels from bottom
- Infinite scroll loading with spinner indicator

### Search
- Searches across all articles globally
- Separate cache for each search query
- Shows "No news available" if no results

### Image Handling
**Priority Order:**
1. API-provided image (`urlToImage`)
2. Picsum.photos fallback with hash-based seed
3. Grey placeholder if all fail

### Character Decoding
Handles:
- UTF-8 byte-level decoding
- HTML entities (&amp;, &#8217;, etc.)
- HTML tag removal
- Whitespace normalization

## ⚙️ Configuration Options

### Hard-Coded Values (Configurable)

| Element | Value | Location | Purpose |
|---------|-------|----------|---------|
| API Timeout | 10 seconds | `news_api_service.dart:58` | HTTP request timeout |
| Cache Duration | 24 hours | `cache_manager.dart:9` | Cache validity period |
| Scroll Threshold | 500 pixels | `main.dart:158` | Pagination trigger distance |
| Image Fallback | Picsum.photos | `article.dart:39` | Placeholder image service |

## 🐛 Known Limitations

### Free Tier Restrictions
- **NewsAPI.org Free**: Limited to USA only (premium required for other countries)
- **Rate Limiting**: 100 requests per day on free tier
- **Article Age**: May include older articles based on source updates

### Platform Support
- **iOS**: WebView disabled due to CORS/ORB restrictions
- **Web**: CORS issues with external article links
- **Android**: Fully supported with all features

## 🔄 State Management

### State Variables (Per Page)
```dart
List<Article> articles = [];           // Current articles
int currentPage = 1;                   // Pagination counter
bool isSearching = false;              // Search mode flag
String currentSearchQuery;             // Active search term
bool isLoading = false;                // Loading indicator
String? errorMessage;                  // Error display
```

### Theme State (App Level)
```dart
bool isDarkMode = false;               // Theme toggle
```

## 📝 Usage Examples

### Load Headlines
```dart
final articles = await newsApiService.fetchTopHeadlines(
  country: 'us',
  page: 1,
  pageSize: 20,
);
```

### Search Articles
```dart
final results = await newsApiService.searchNews(
  query: 'technology',
  sortBy: 'publishedAt',
  page: 1,
);
```

## 🔐 Security Notes

- API keys are hard-coded (not recommended for production)
- For production, use environment variables or secure storage
- Never commit real API keys to version control

## 📖 API Documentation

- [NewsAPI.org Docs](https://newsapi.org/docs)
- [Flutter Official Docs](https://flutter.dev/docs)

## 🚧 Future Enhancements

- [ ] Multiple country selection
- [ ] Category filtering (business, sports, health, etc.)
- [ ] Bookmark/Save articles
- [ ] Share articles
- [ ] Push notifications for breaking news
- [ ] Offline-first architecture
- [ ] Provider/GetX state management
- [ ] Unit and widget tests

## 📄 License

This project is part of ITT632 - Mobile Cloud Computing course assignment.

## 👤 Author

Created for Academic Purposes - ITT632 Mobile Cloud Computing Lab

---

**Last Updated**: April 2026
**Version**: 1.0.0
