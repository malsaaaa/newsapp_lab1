// backend/server.js

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const axios = require('axios');
const jwt = require('jsonwebtoken');
const bcryptjs = require('bcryptjs');
const { Server } = require('socket.io');
const http = require('http');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// Middleware
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json());

// MongoDB Connection
const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/news_app';
mongoose.connect(mongoURI).catch(err => {
  console.error('❌ MongoDB connection error:', err.message);
});

const db = mongoose.connection;
db.on('error', (err) => console.error('MongoDB error:', err));
db.once('open', function() {
  console.log('✅ Connected to MongoDB');
});

// Define Article Schema
const articleSchema = new mongoose.Schema({
  source: {
    id: String,
    name: String
  },
  author: String,
  title: { type: String, required: true },
  description: String,
  url: { type: String, required: true, unique: true },
  urlToImage: String,
  publishedAt: { type: Date, default: Date.now },
  content: String,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, { timestamps: true });

const Article = mongoose.model('Article', articleSchema);

// Define User Schema
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, { timestamps: true });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return;
  try {
    const salt = await bcryptjs.genSalt(10);
    this.password = await bcryptjs.hash(this.password, salt);
  } catch (error) {
    throw error;
  }
});

// Method to compare passwords
userSchema.methods.comparePassword = async function(passwordToCheck) {
  return await bcryptjs.compare(passwordToCheck, this.password);
};

const User = mongoose.model('User', userSchema);

// Define Bookmark Schema
const bookmarkSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  articleUrl: { type: String, required: true },
  title: String,
  description: String,
  urlToImage: String,
  source: String,
  bookmarkedAt: { type: Date, default: Date.now }
});

const Bookmark = mongoose.model('Bookmark', bookmarkSchema);

// Auth Middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ status: 'error', message: 'No token provided' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ status: 'error', message: 'Invalid token' });
    }
    req.user = user;
    next();
  });
}

// Sample news data (for seeding database)
const sampleNews = [
  {
    source: { id: "techcrunch", name: "TechCrunch" },
    author: "Sarah Chen",
    title: "AI Breakthrough: New Model Achieves Human-Level Performance",
    description: "Researchers announce a groundbreaking AI model that matches human performance in multiple domains, marking a significant milestone in artificial intelligence.",
    url: "https://techcrunch.com/ai-breakthrough",
    urlToImage: "https://picsum.photos/600/400?random=1",
    publishedAt: "2026-05-05T10:30:00Z",
    content: "A major breakthrough in artificial intelligence research has been announced today. Scientists have developed a new model..."
  },
  {
    source: { id: "bbc-news", name: "BBC News" },
    author: "James Wilson",
    title: "Global Climate Summit Reaches Historic Agreement",
    description: "World leaders agree on bold new climate action plan during the International Climate Conference, pledging significant emissions reductions.",
    url: "https://bbc.com/news/climate",
    urlToImage: "https://picsum.photos/600/400?random=2",
    publishedAt: "2026-05-04T14:15:00Z",
    content: "In a historic moment for global climate action, world leaders have reached an agreement on unprecedented climate measures..."
  },
  {
    source: { id: "cnn", name: "CNN" },
    author: "Maria Garcia",
    title: "New Medical Treatment Shows Promise in Cancer Research",
    description: "Clinical trials reveal a new immunotherapy treatment that significantly improves survival rates in advanced cancer patients.",
    url: "https://cnn.com/health/cancer-treatment",
    urlToImage: "https://picsum.photos/600/400?random=3",
    publishedAt: "2026-05-04T08:45:00Z",
    content: "Researchers have published promising results from clinical trials of a new cancer treatment. The immunotherapy approach..."
  },
  {
    source: { id: "the-guardian", name: "The Guardian" },
    author: "Robert Johnson",
    title: "Tech Company Launches Revolutionary Mobile Device",
    description: "A leading technology company unveils its latest smartphone with groundbreaking features and innovative design.",
    url: "https://theguardian.com/tech/mobile",
    urlToImage: "https://picsum.photos/600/400?random=4",
    publishedAt: "2026-05-03T16:20:00Z",
    content: "The technology world has been buzzing with anticipation, and today the wait is over. A major tech company has unveiled..."
  },
  {
    source: { id: "espn", name: "ESPN" },
    author: "Mike Anderson",
    title: "Championship Match Delivers Thrilling Victory",
    description: "In an exciting match, the home team defeats rivals in a nail-biting championship game, securing their position in the finals.",
    url: "https://espn.com/sports/championship",
    urlToImage: "https://picsum.photos/600/400?random=5",
    publishedAt: "2026-05-03T22:30:00Z",
    content: "What a game! The championship match delivered everything fans could have hoped for. In a thrilling display of skill..."
  },
  {
    source: { id: "reuters", name: "Reuters" },
    author: "David Smith",
    title: "Markets Rally on Strong Economic Data",
    description: "Global stock markets surge following the release of positive economic indicators and corporate earnings reports.",
    url: "https://reuters.com/business/markets",
    urlToImage: "https://picsum.photos/600/400?random=6",
    publishedAt: "2026-05-02T13:00:00Z",
    content: "Financial markets around the world have responded positively to economic news. The strong economic indicators suggest..."
  },
  {
    source: { id: "nasa", name: "NASA" },
    author: "Dr. Elena Rodriguez",
    title: "Space Telescope Captures Stunning Images of Distant Galaxy",
    description: "The latest images from the James Webb Space Telescope reveal unprecedented details about a galaxy billions of light-years away.",
    url: "https://nasa.gov/jwst",
    urlToImage: "https://picsum.photos/600/400?random=7",
    publishedAt: "2026-05-01T09:15:00Z",
    content: "Scientists are marveling at spectacular new images captured by the James Webb Space Telescope. These images provide..."
  },
  {
    source: { id: "nature", name: "Nature" },
    author: "Prof. Lisa Wong",
    title: "Scientists Discover New Species in Amazon Rainforest",
    description: "Researchers uncover a previously unknown species of bird in the depths of the Amazon rainforest, expanding our understanding of biodiversity.",
    url: "https://nature.com/biodiversity",
    urlToImage: "https://picsum.photos/600/400?random=8",
    publishedAt: "2026-04-30T11:45:00Z",
    content: "In a remarkable discovery, scientists exploring the Amazon rainforest have identified a species previously unknown to science..."
  }
];

// Fetch articles from NewsAPI
async function fetchFromNewsAPI() {
  if (!process.env.NEWSAPI_KEY) {
    console.warn('⚠️  NEWSAPI_KEY not configured. Skipping NewsAPI sync.');
    return [];
  }

  try {
    const url = `${process.env.NEWSAPI_BASE_URL}/top-headlines`;
    const response = await axios.get(url, {
      params: {
        country: process.env.NEWSAPI_COUNTRY || 'us',
        apiKey: process.env.NEWSAPI_KEY,
        pageSize: 50
      },
      timeout: 10000
    });

    if (response.data.articles && Array.isArray(response.data.articles)) {
      console.log(`📰 Fetched ${response.data.articles.length} articles from NewsAPI`);
      return response.data.articles;
    }
    return [];
  } catch (error) {
    console.error('❌ Error fetching from NewsAPI:', error.message);
    return [];
  }
}

// Sync articles from NewsAPI to MongoDB
async function syncNewsAPIArticles() {
  if (process.env.ENABLE_SAMPLE_DATA !== 'true') {
    console.log('📚 ENABLE_SAMPLE_DATA is false. Skipping initial sync.');
    return;
  }

  try {
    const count = await Article.countDocuments();
    if (count > 0) {
      console.log(`✅ Database already has ${count} articles. Skipping sync.`);
      return;
    }

    console.log('🔄 Syncing articles from NewsAPI...');
    const articles = await fetchFromNewsAPI();

    if (articles.length === 0) {
      console.log('⚠️  No articles fetched from NewsAPI. Using sample data instead.');
      await initializeSampleData();
      return;
    }

    // Transform NewsAPI format to our format
    const formattedArticles = articles.map(article => ({
      source: {
        id: article.source?.id || 'unknown',
        name: article.source?.name || 'Unknown Source'
      },
      author: article.author || 'Unknown',
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: article.urlToImage,
      publishedAt: article.publishedAt,
      content: article.content,
      createdAt: new Date(),
      updatedAt: new Date()
    }));

    await Article.insertMany(formattedArticles, { ordered: false }).catch(err => {
      if (err.code === 11000) {
        console.log('✅ Some articles already exist. Continuing...');
      } else {
        throw err;
      }
    });

    console.log(`✅ Synced ${formattedArticles.length} articles from NewsAPI`);
  } catch (error) {
    console.error('Error syncing NewsAPI articles:', error.message);
    console.log('Falling back to sample data...');
    await initializeSampleData();
  }
}

// Initialize sample data if enabled
async function initializeSampleData() {
  if (process.env.ENABLE_SAMPLE_DATA !== 'true') {
    return;
  }

  try {
    const count = await Article.countDocuments();
    if (count === 0) {
      console.log('📝 Seeding database with sample news data...');
      await Article.insertMany(sampleNews);
      console.log(`✅ Inserted ${sampleNews.length} sample articles`);
    }
  } catch (error) {
    console.error('Error seeding database:', error.message);
  }
}

// ===== API ENDPOINTS =====

// ===== AUTHENTICATION ENDPOINTS =====

// POST /api/auth/signup
// Register a new user
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { name, email, password, confirmPassword } = req.body;

    // Validation
    if (!name || !email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Name, email, and password are required'
      });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({
        status: 'error',
        message: 'Passwords do not match'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        status: 'error',
        message: 'Password must be at least 6 characters'
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'User with this email already exists'
      });
    }

    // Create new user
    const user = new User({ name, email, password });
    await user.save();

    // Generate token
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      status: 'ok',
      message: 'User registered successfully',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// POST /api/auth/login
// Login existing user
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Email and password are required'
      });
    }

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password'
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password'
      });
    }

    // Generate token
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(200).json({
      status: 'ok',
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// POST /api/bookmarks
// Add article to bookmarks (requires authentication)
app.post('/api/bookmarks', authenticateToken, async (req, res) => {
  try {
    const { articleUrl, title, description, urlToImage, source } = req.body;

    if (!articleUrl) {
      return res.status(400).json({
        status: 'error',
        message: 'Article URL is required'
      });
    }

    // Check if already bookmarked
    const existing = await Bookmark.findOne({
      userId: req.user.userId,
      articleUrl
    });

    if (existing) {
      return res.status(400).json({
        status: 'error',
        message: 'Article already bookmarked'
      });
    }

    const bookmark = new Bookmark({
      userId: req.user.userId,
      articleUrl,
      title,
      description,
      urlToImage,
      source
    });

    await bookmark.save();

    res.status(201).json({
      status: 'ok',
      message: 'Article bookmarked',
      bookmark
    });

    // Broadcast bookmark notification
    broadcastBookmarkNotification(req.user.userId, 'added', title);
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// GET /api/bookmarks
// Get user's bookmarks (requires authentication)
app.get('/api/bookmarks', authenticateToken, async (req, res) => {
  try {
    const bookmarks = await Bookmark.find({ userId: req.user.userId }).sort({ bookmarkedAt: -1 });

    res.status(200).json({
      status: 'ok',
      bookmarks,
      total: bookmarks.length
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// DELETE /api/bookmarks/:bookmarkId
// Remove bookmark (requires authentication)
app.delete('/api/bookmarks/:bookmarkId', authenticateToken, async (req, res) => {
  try {
    const bookmark = await Bookmark.findByIdAndDelete(req.params.bookmarkId);

    if (!bookmark) {
      return res.status(404).json({
        status: 'error',
        message: 'Bookmark not found'
      });
    }

    res.status(200).json({
      status: 'ok',
      message: 'Bookmark removed'
    });

    // Broadcast bookmark removal notification
    broadcastBookmarkNotification(req.user.userId, 'removed', bookmark.title);
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Backend server is running' });
});

// POST /api/news/sync
// Manually sync articles from NewsAPI
app.post('/api/news/sync', async (req, res) => {
  try {
    const articles = await fetchFromNewsAPI();

    if (articles.length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Failed to fetch articles from NewsAPI. Check API key.'
      });
    }

    // Transform and save articles
    const formattedArticles = articles.map(article => ({
      source: {
        id: article.source?.id || 'unknown',
        name: article.source?.name || 'Unknown Source'
      },
      author: article.author || 'Unknown',
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: article.urlToImage,
      publishedAt: article.publishedAt,
      content: article.content
    }));

    // Insert with error handling for duplicates
    const result = await Article.insertMany(formattedArticles, { ordered: false }).catch(err => {
      if (err.code === 11000) {
        return { insertedCount: err.insertedCount || 0 };
      }
      throw err;
    });

    res.status(200).json({
      status: 'ok',
      message: `Synced articles from NewsAPI`,
      inserted: result.insertedCount || articles.length,
      total: articles.length
    });

    // Broadcast notification to all connected clients
    if (result.insertedCount > 0) {
      broadcastArticleUpdate(result.insertedCount);
    }
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// GET /api/news/top-headlines
// Fetch top headlines with pagination from MongoDB
app.get('/api/news/top-headlines', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const pageSize = Math.min(parseInt(req.query.pageSize) || 20, 100);

    if (page < 1) {
      return res.status(400).json({ status: 'error', message: 'Page number must be greater than 0' });
    }

    const skip = (page - 1) * pageSize;

    // Get total count
    const totalResults = await Article.countDocuments();

    // Fetch articles
    const articles = await Article.find()
      .sort({ publishedAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .lean();

    res.status(200).json({
      status: 'ok',
      totalResults: totalResults,
      articles: articles,
      pageSize: pageSize,
      currentPage: page,
      totalPages: Math.ceil(totalResults / pageSize)
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// GET /api/news/search
// Search for articles by query in MongoDB
app.get('/api/news/search', async (req, res) => {
  try {
    const query = req.query.q;
    const page = parseInt(req.query.page) || 1;
    const pageSize = Math.min(parseInt(req.query.pageSize) || 20, 100);

    if (!query) {
      return res.status(400).json({ status: 'error', message: 'Search query is required' });
    }

    const skip = (page - 1) * pageSize;

    // Search using regex for case-insensitive search
    const searchFilter = {
      $or: [
        { title: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } },
        { content: { $regex: query, $options: 'i' } }
      ]
    };

    const totalResults = await Article.countDocuments(searchFilter);
    const articles = await Article.find(searchFilter)
      .sort({ publishedAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .lean();

    res.status(200).json({
      status: 'ok',
      totalResults: totalResults,
      articles: articles,
      pageSize: pageSize,
      currentPage: page,
      totalPages: Math.ceil(totalResults / pageSize)
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// GET /api/news/category/:category
// Fetch news by category from MongoDB
app.get('/api/news/category/:category', async (req, res) => {
  try {
    const category = req.params.category.toLowerCase();
    const page = parseInt(req.query.page) || 1;
    const pageSize = Math.min(parseInt(req.query.pageSize) || 20, 100);

    const skip = (page - 1) * pageSize;

    // Filter by source id (category)
    const totalResults = await Article.countDocuments({ 'source.id': category });
    const articles = await Article.find({ 'source.id': category })
      .sort({ publishedAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .lean();

    res.status(200).json({
      status: 'ok',
      totalResults: totalResults,
      articles: articles,
      pageSize: pageSize,
      currentPage: page,
      totalPages: Math.ceil(totalResults / pageSize)
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// GET /api/news/article/:id
// Fetch a specific article by MongoDB ID
app.get('/api/news/article/:id', async (req, res) => {
  try {
    const article = await Article.findById(req.params.id).lean();
    if (!article) {
      return res.status(404).json({ status: 'error', message: 'Article not found' });
    }
    res.status(200).json({ status: 'ok', article: article });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// GET /api/news/all
// Fetch all articles without pagination
app.get('/api/news/all', async (req, res) => {
  try {
    const articles = await Article.find().sort({ publishedAt: -1 }).lean();
    res.status(200).json({
      status: 'ok',
      totalResults: articles.length,
      articles: articles
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// POST /api/news/add
// Add a new article to MongoDB
app.post('/api/news/add', async (req, res) => {
  try {
    const article = new Article(req.body);
    const savedArticle = await article.save();
    res.status(201).json({ status: 'ok', article: savedArticle });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({
        status: 'error',
        message: 'Article URL already exists'
      });
    }
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// PUT /api/news/:id
// Update an article in MongoDB
app.put('/api/news/:id', async (req, res) => {
  try {
    const article = await Article.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: new Date() },
      { new: true }
    );
    if (!article) {
      return res.status(404).json({ status: 'error', message: 'Article not found' });
    }
    res.status(200).json({ status: 'ok', article: article });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// DELETE /api/news/:id
// Delete an article from MongoDB
app.delete('/api/news/:id', async (req, res) => {
  try {
    const article = await Article.findByIdAndDelete(req.params.id);
    if (!article) {
      return res.status(404).json({ status: 'error', message: 'Article not found' });
    }
    res.status(200).json({ status: 'ok', message: 'Article deleted' });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'News App Backend API',
    version: '2.0.0',
    database: 'MongoDB',
    dataSource: 'NewsAPI.org',
    authentication: 'JWT',
    endpoints: {
      health: 'GET /api/health',
      // Auth endpoints
      signup: 'POST /api/auth/signup {name, email, password, confirmPassword}',
      login: 'POST /api/auth/login {email, password}',
      // Bookmarks (requires token)
      bookmarks: 'GET /api/bookmarks (requires auth token)',
      addBookmark: 'POST /api/bookmarks (requires auth token)',
      removeBookmark: 'DELETE /api/bookmarks/:bookmarkId (requires auth token)',
      // News endpoints
      sync: 'POST /api/news/sync (manually sync from NewsAPI)',
      topHeadlines: 'GET /api/news/top-headlines?page=1&pageSize=20',
      search: 'GET /api/news/search?q=query&page=1&pageSize=20',
      category: 'GET /api/news/category/:category?page=1&pageSize=20',
      article: 'GET /api/news/article/:id',
      all: 'GET /api/news/all',
      add: 'POST /api/news/add',
      update: 'PUT /api/news/:id',
      delete: 'DELETE /api/news/:id'
    }
  });
});

// Socket.io connection handling
io.on('connection', (socket) => {
  console.log(`🔌 New client connected: ${socket.id}`);

  // Join user's notification room
  socket.on('join-notifications', (userId) => {
    socket.join(`user-${userId}`);
    console.log(`✅ User ${userId} joined notifications`);
  });

  // Listen for disconnect
  socket.on('disconnect', () => {
    console.log(`🔌 Client disconnected: ${socket.id}`);
  });
});

// Function to emit notifications
function broadcastArticleUpdate(articleCount) {
  io.emit('article-update', {
    type: 'new_articles',
    message: `${articleCount} new articles added`,
    timestamp: new Date(),
    count: articleCount
  });
}

function broadcastBookmarkNotification(userId, action, articleTitle) {
  io.to(`user-${userId}`).emit('bookmark-update', {
    type: action, // 'added' or 'removed'
    message: `Article ${action === 'added' ? 'bookmarked' : 'removed'}: ${articleTitle}`,
    timestamp: new Date(),
    articleTitle
  });
}

// Export io for use in other modules
module.exports = { io, broadcastArticleUpdate, broadcastBookmarkNotification };

// Start server
server.listen(PORT, '0.0.0.0', async () => {
  console.log(`🚀 News App Backend Server is running on http://localhost:${PORT}`);
  console.log(`📊 MongoDB URI: ${mongoURI}`);
  console.log(`📰 NewsAPI: ${process.env.NEWSAPI_KEY ? 'Enabled' : 'Disabled (no API key)'}`);
  
  // Sync articles from NewsAPI (or use sample data as fallback)
  await syncNewsAPIArticles();
  
  console.log(`\n🔐 Authentication endpoints:`);
  console.log(`  - Signup: POST http://localhost:${PORT}/api/auth/signup`);
  console.log(`  - Login: POST http://localhost:${PORT}/api/auth/login`);
  console.log(`  - Bookmarks: GET http://localhost:${PORT}/api/bookmarks (requires token)`);
  
  console.log(`\n📰 News endpoints:`);
  console.log(`  - Health Check: http://localhost:${PORT}/api/health`);
  console.log(`  - Top Headlines: http://localhost:${PORT}/api/news/top-headlines`);
  console.log(`  - Search: http://localhost:${PORT}/api/news/search?q=technology`);
  console.log(`  - Sync: POST http://localhost:${PORT}/api/news/sync`);
  
  console.log(`\nPress Ctrl+C to stop the server`);
});
