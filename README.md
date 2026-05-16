# 📰 News App - Full-Stack Mobile Application

A modern, full-featured news application built with **Flutter** and **Node.js**, featuring real-time notifications, user authentication, and bookmarking capabilities. Built for ITT632 Mobile Cloud Computing course.

**Status**: ✅ Complete with 3 Phases

---

## 🎯 Project Overview

This project demonstrates a complete full-stack mobile application with:
- Cross-platform Flutter frontend (iOS, Android, Web, Desktop)
- Node.js + Express.js backend with MongoDB
- Real-time WebSocket communication via Socket.io
- JWT-based authentication with password hashing
- Responsive Material Design UI with dark/light themes

---

## 📋 Table of Contents

1. [Phase 1: Foundation](#phase-1-foundation)
2. [Phase 2: Authentication & Bookmarks](#phase-2-authentication--bookmarks)
3. [Phase 3: Real-Time Notifications](#phase-3-real-time-notifications)
4. [Tech Stack](#-tech-stack)
5. [Getting Started](#-getting-started)
6. [API Endpoints](#-api-endpoints)
7. [Project Structure](#-project-structure)

---

## 📱 Phase 1: Foundation

### Features
- ✅ **Top Headlines**: Display 50+ real articles from NewsAPI.org
- ✅ **Search Functionality**: Search articles by keyword
- ✅ **Pagination**: Load more articles with infinite scroll
- ✅ **Category Filtering**: Filter news by source/category
- ✅ **Article Details**: View full article content
- ✅ **Image Handling**: Display article images with fallbacks
- ✅ **Dark/Light Theme**: Toggle between themes
- ✅ **Responsive Design**: Works on all screen sizes
- ✅ **Error Handling**: Graceful error messages and retry logic

### Backend
- Express.js REST API
- MongoDB article storage
- NewsAPI.org integration
- CORS support for Flutter web

---

## 🔐 Phase 2: Authentication & Bookmarks

### User Management
- ✅ **User Registration**: Sign up with name, email, password
- ✅ **User Login**: Secure login with JWT tokens
- ✅ **Password Hashing**: bcryptjs for secure password storage
- ✅ **Token Storage**: Local token persistence with SharedPreferences
- ✅ **Session Management**: Auto-login for returning users

### Bookmarking System
- ✅ **Save Articles**: Bookmark articles with one tap
- ✅ **Bookmark Management**: View all saved articles
- ✅ **Remove Bookmarks**: Delete articles from bookmarks
- ✅ **User-Specific Bookmarks**: Each user has their own bookmarks
- ✅ **Bookmark Persistence**: Bookmarks stored in MongoDB

### Security
- JWT tokens with 7-day expiration
- Password hashing with 10-round salt
- Protected API endpoints requiring authentication
- Email uniqueness validation

---

## 🔔 Phase 3: Real-Time Notifications

### WebSocket Features
- ✅ **Real-Time Notifications**: Receive updates instantly via Socket.io
- ✅ **Article Update Alerts**: Notified when new articles are synced
- ✅ **Bookmark Notifications**: Get feedback when articles are bookmarked
- ✅ **User-Specific Rooms**: Each user has dedicated notification channel
- ✅ **Automatic Reconnection**: Handles disconnections gracefully

### Notification UI
- ✅ **Animated Notifications**: Slide and fade animations
- ✅ **Color-Coded**: Blue for articles, amber for bookmarks
- ✅ **Auto-Dismiss**: Disappear after 5 seconds
- ✅ **Manual Dismiss**: Close notifications with X button
- ✅ **Stacked Display**: Show multiple notifications

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|-----------|---------|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **socket_io_client** | WebSocket client |
| **http** | HTTP requests |
| **cached_network_image** | Image caching |
| **shared_preferences** | Local storage |
| **flutter_dotenv** | Environment variables |

### Backend
| Technology | Purpose |
|-----------|---------|
| **Node.js** | Runtime environment |
| **Express.js** | Web framework |
| **Socket.io** | Real-time communication |
| **MongoDB** | NoSQL database |
| **Mongoose** | MongoDB ORM |
| **JWT** | Authentication |
| **bcryptjs** | Password hashing |
| **axios** | HTTP requests |
| **CORS** | Cross-origin support |

### Database
- **MongoDB** (Local instance)
- Collections: Users, Articles, Bookmarks

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest)
- Node.js 18+
- MongoDB (local or Atlas)
- NewsAPI.org API key

### Frontend Setup

```bash
# Navigate to project root
cd news_app_lab

# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Or on device
flutter run
```

### Backend Setup

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Create .env file with:
# MONGODB_URI=mongodb://localhost:27017/news_app
# NEWSAPI_KEY=your_api_key_here
# JWT_SECRET=your_jwt_secret
# PORT=3000

# Start development server
npm run dev

# Or production
npm start
```

### MongoDB Setup

```bash
# Start MongoDB (if local)
mongod

# Or use MongoDB Atlas (cloud)
# Update MONGODB_URI in .env
```

---

## 📡 API Endpoints

### Authentication
```
POST   /api/auth/signup          - Register new user
POST   /api/auth/login           - Login user
```

### Bookmarks (requires token)
```
GET    /api/bookmarks            - Get user's bookmarks
POST   /api/bookmarks            - Add article to bookmarks
DELETE /api/bookmarks/:id        - Remove bookmark
```

### News
```
GET    /api/news/top-headlines   - Get latest articles
GET    /api/news/search?q=query  - Search articles
GET    /api/news/category/:cat   - Get articles by category
GET    /api/news/article/:id     - Get specific article
POST   /api/news/sync            - Manually sync from NewsAPI
GET    /api/health               - Health check
```

---

## 📁 Project Structure

```
news_app_lab/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config.dart                  # Configuration
│   ├── theme.dart                   # Theme definitions
│   ├── article.dart                 # Article model
│   ├── news_api_service.dart        # API client
│   ├── article_detail_page.dart     # Article details screen
│   ├── services/
│   │   ├── auth_service.dart        # Authentication service
│   │   └── notification_service.dart # WebSocket notifications
│   ├── screens/
│   │   ├── login_screen.dart        # Login UI
│   │   ├── signup_screen.dart       # Signup UI
│   │   └── bookmarks_screen.dart    # Bookmarks UI
│   └── widgets/
│       └── notification_overlay.dart # Notification widget
│
├── backend/
│   ├── server.js                    # Express server + Socket.io
│   ├── package.json                 # Dependencies
│   ├── .env                         # Environment config
│   └── .env.example                 # Example env file
│
├── pubspec.yaml                     # Flutter dependencies
└── README.md                        # This file
```

---

## 🔑 Key Features by Phase

### Phase 1 ✅
- Real news articles from NewsAPI
- Search and filtering
- Responsive UI
- Offline caching

### Phase 2 ✅
- User authentication (JWT)
- Bookmark articles
- Password security (bcrypt)
- Protected API endpoints

### Phase 3 ✅
- WebSocket real-time notifications
- Article sync alerts
- Bookmark notifications
- Animated notification UI

---

## 🧪 Testing

### Manual Testing
1. **Signup**: Create a new account
2. **Login**: Sign in with credentials
3. **Browse**: View articles with pagination
4. **Bookmark**: Save articles and view in bookmarks
5. **Sync**: Run sync endpoint to trigger notifications
6. **Notifications**: See real-time updates

### API Testing
```bash
# Signup
POST http://localhost:3000/api/auth/signup
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}

# Login
POST http://localhost:3000/api/auth/login
{
  "email": "john@example.com",
  "password": "password123"
}

# Sync articles
POST http://localhost:3000/api/news/sync

# Get bookmarks (requires token)
GET http://localhost:3000/api/bookmarks
Authorization: Bearer <token>
```

---

## 📊 Database Schema

### Users Collection
```javascript
{
  _id: ObjectId,
  name: String,
  email: String (unique),
  password: String (hashed),
  createdAt: Date,
  updatedAt: Date
}
```

### Articles Collection
```javascript
{
  _id: ObjectId,
  source: { id: String, name: String },
  author: String,
  title: String,
  description: String,
  url: String (unique),
  urlToImage: String,
  publishedAt: Date,
  content: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Bookmarks Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User),
  articleUrl: String,
  title: String,
  description: String,
  urlToImage: String,
  source: String,
  bookmarkedAt: Date
}
```

---

## 🔧 Configuration

### Environment Variables (.env)
```
# Server
PORT=3000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/news_app

# Authentication
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRY=7d

# NewsAPI
NEWSAPI_KEY=your_newsapi_key_here
NEWSAPI_BASE_URL=https://newsapi.org/v2
NEWSAPI_COUNTRY=us

# CORS
CORS_ORIGIN=*

# Features
ENABLE_DEBUG_LOGS=true
ENABLE_SAMPLE_DATA=true
```

---

## 🐛 Troubleshooting

### "No Overlay widget found"
✅ **Fixed** - Added Directionality wrapper to notification UI

### "Module not found: socket.io"
```bash
npm install socket.io
```

### "MongoDB connection refused"
```bash
# Start MongoDB
mongod

# Or check connection string in .env
```

### "CORS errors"
Ensure backend has CORS middleware:
```javascript
app.use(cors({ origin: '*' }));
```

---

## 📈 Performance

- **Article Caching**: 24-hour local cache
- **Image Caching**: Efficient image management with cached_network_image
- **WebSocket Efficiency**: Real-time updates without polling
- **Database Indexing**: Indexes on email, URL for fast lookups
- **Pagination**: Load 20 articles per page

---

## 🔒 Security

- ✅ Password hashing with bcryptjs (10-round salt)
- ✅ JWT tokens with expiration
- ✅ HTTPS ready (production)
- ✅ Input validation
- ✅ Email uniqueness enforcement
- ✅ Protected API endpoints
- ✅ CORS configuration

---

## 📝 License

Educational project for ITT632 Mobile Cloud Computing course

---

## 👨‍💻 Developer Notes

### Future Enhancements
- [ ] User profiles with avatars
- [ ] Reading history
- [ ] Advanced search filters
- [ ] Article collections/lists
- [ ] Social features (share, follow)
- [ ] Push notifications
- [ ] Offline mode (cached articles)
- [ ] Analytics dashboard

### Known Limitations
- Local MongoDB required (no Atlas integration yet)
- WebSocket only (polling fallback available)
- Single-user bookmarks (no sharing)

---

## 📞 Support

For issues or questions, refer to:
- Flutter Documentation: https://flutter.dev/docs
- Node.js Docs: https://nodejs.org/docs
- Socket.io Guide: https://socket.io/docs
- NewsAPI Docs: https://newsapi.org/docs

---

**Last Updated**: May 16, 2026  
**Version**: 3.0 (Complete)  
**Status**: ✅ Production Ready

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
