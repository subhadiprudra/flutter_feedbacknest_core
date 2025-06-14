# Feedbacknest Core

<div align="center">
  <img src="screenshots/feedbacknest_feedback.jpg" alt="Feedbacknest Core" width="200" />
  <p><em>The complete feedback collection and analytics toolkit for Flutter applications</em></p>
</div>

Feedbacknest Core is a comprehensive feedback collection and user analytics platform for Flutter applications. It provides powerful tools to collect user feedback, analyze user behavior, and gain actionable insights to improve your app.

## 🚀 Key Features

### 📱 **Feedback Collection**
- **Multiple Communication Types**: Support for feedback, bug reports, feature requests, and contact messages
- **Rich Media Support**: Attach screenshots, images, and files to feedback submissions
- **Customizable UI**: Beautiful, themeable dialog widgets (light/dark mode support)  
- **Smart Forms**: Collect user ratings, reviews, and detailed feedback with validation
- **Offline Support**: Queue feedback when offline and sync when connection is restored

### 📊 **Comprehensive User Analytics**
- **👥 Total Users**: Track your complete user base with detailed metrics
- **📈 Sessions Today**: Monitor daily active sessions and engagement patterns
- **🆕 New Users**: Track daily user acquisition and growth trends
- **📊 Active Users**: Monitor 7-day, 30-day active user metrics
- **⭐ User Ratings**: Comprehensive app satisfaction monitoring with rating distributions
- **📈 Historical Trends**: Interactive charts showing user growth patterns over time
- **🗺️ Geographic Insights**: World map visualization of user distribution by country
- **📱 Version Analytics**: Track user adoption across different app versions
- **💤 Inactive Users**: Monitor user retention, churn, and re-engagement opportunities
- **📊 Session Patterns**: Detailed session analytics with duration, frequency, and behavior patterns

### 🤖 **AI-Enhanced Feedback Intelligence**
- **🎯 Auto-Generated Titles**: AI creates meaningful, descriptive titles like "UI appearance issue", "Random login logouts"
- **🏷️ Smart Categorization**: Automatic content-based tagging and classification
- **😊 Sentiment Analysis**: Real-time emotion detection and sentiment scoring
- **📊 Priority Assignment**: AI-powered urgency and importance scoring
- **🔍 Content Analysis**: Extract key insights and themes from user feedback
- **📈 Trend Detection**: Identify emerging issues and patterns across feedback

### 👥 **Advanced User Management**
- **🔍 User Context**: Complete user profiles with communication history
- **📋 Feedback Timeline**: Chronological view of all user interactions
- **🏷️ User Segmentation**: Categorize users by behavior, feedback type, and engagement
- **📞 Communication Tracking**: Full history of all user touchpoints
- **🎯 Targeted Insights**: User-specific analytics and behavior patterns

### 🔄 **Workflow Management**
- **📋 Status Tracking**: Monitor feedback progress from submission to resolution
- **🎯 Assignment System**: Route feedback to appropriate team members
- **⏰ Response Time Tracking**: Monitor and optimize response times
- **🔔 Smart Notifications**: Automated alerts for high-priority feedback
- **📊 Team Performance**: Analytics on resolution times and team efficiency

### 🛠️ **Developer Experience**
- **⚡ Easy Integration**: Simple 3-line setup with minimal configuration
- **🔒 Secure API**: End-to-end encryption for all data transmission
- **📱 Cross-Platform**: Full support for iOS, Android, Web, macOS, Windows, Linux
- **🎨 Customizable**: Extensive theming and UI customization options
- **📚 Rich Documentation**: Comprehensive guides, examples, and API reference

## 🏁 Getting Started

### Installation

1. Add `feedbacknest_core` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  feedbacknest_core: ^1.0.0  # Use latest version
```

2. Install the package:

```bash
flutter pub get
```

3. Import the package in your Dart code:

```dart
import 'package:feedbacknest_core/feedbacknest.dart';
```

### Quick Setup

Initialize Feedbacknest in your app's main function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Feedbacknest with your API key
  await Feedbacknest.init('YOUR_API_KEY');
  
  runApp(MyApp());
}
```

> 💡 **Get your API key**: Visit [Feedbacknest Dashboard](https://feedbacknest.app) to create an account and get your API key.

## 📖 Usage Guide

### 1. Basic Feedback Collection

#### Show Feedback Dialog

Display a beautiful feedback dialog to collect user input:

```dart
// Simple feedback dialog
showDialog(
  context: context,
  builder: (context) => FeedbackDialog(
    type: CommunicationType.feedback,
    theme: CommunicationTheme.light,
  ),
);

// Bug report dialog
showDialog(
  context: context,
  builder: (context) => FeedbackDialog(
    type: CommunicationType.bug,
    theme: CommunicationTheme.dark,
    title: "Report a Bug",
    subtitle: "Help us improve by reporting any issues you encounter",
  ),
);
```

#### Communication Types

```dart
enum CommunicationType {
  feedback,        // General feedback
  bug,            // Bug reports  
  featureRequest, // Feature requests
  contact,        // Contact/support
}
```

### 2. Rating and Reviews

Collect user ratings and reviews:

```dart
// Submit rating with review
await Feedbacknest.submitRatingAndReview(
  rating: 5,
  review: 'Amazing app! Love the new features.',
);

// Rating only
await Feedbacknest.submitRatingAndReview(rating: 4);
```

### 3. Advanced Feedback Submission

Submit detailed feedback programmatically:

```dart
await Feedbacknest.submitCommunication(
  message: 'The app crashes when I try to export data',
  type: 'bug',
  email: 'user@example.com',
  files: [
    File('/path/to/screenshot.png'),
    File('/path/to/log.txt'),
  ],
);
```

### 4. Custom User Identification

```dart
// Initialize with custom user identifier
await Feedbacknest.init(
  'YOUR_API_KEY',
  userIdentifier: 'user_12345',
);

// Or set it later
Feedbacknest.setUserIdentifier('custom_user_id');
```

## 🎨 Customization

### Theme Customization

```dart
FeedbackDialog(
  type: CommunicationType.feedback,
  theme: CommunicationTheme.custom(
    primaryColor: Colors.blue,
    backgroundColor: Colors.white,
    textColor: Colors.black87,
    borderRadius: 12.0,
  ),
  // Custom styling options
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
)
```

### Widget Customization

```dart
FeedbackDialog(
  type: CommunicationType.bug,
  title: "Found a Bug?",
  subtitle: "We're here to help! Please describe the issue.",
  placeholder: "Describe the bug you encountered...",
  submitButtonText: "Send Bug Report",
  cancelButtonText: "Not Now",
  allowFileAttachment: true,
  maxFileSize: 5 * 1024 * 1024, // 5MB
  allowedFileTypes: ['.jpg', '.png', '.pdf', '.txt'],
)
```

## 📊 Analytics Dashboard

Access comprehensive analytics through the [Feedbacknest Dashboard](https://feedbacknest.app/dashboard):

### User Analytics
- **Real-time Metrics**: Live user counts, session data, and activity monitoring
- **Growth Analytics**: User acquisition trends, retention rates, and churn analysis  
- **Geographic Distribution**: World map showing user locations and regional insights
- **Version Analytics**: Track user distribution across app versions
- **Session Analytics**: Deep dive into user behavior patterns and engagement

### Feedback Intelligence
- **AI-Powered Insights**: Automated categorization, sentiment analysis, and priority scoring
- **Trend Analysis**: Identify emerging issues and improvement opportunities
- **Response Management**: Track feedback resolution and team performance
- **Sentiment Monitoring**: Real-time emotional analysis of user feedback

### Reporting Features
- **Custom Reports**: Generate detailed reports for stakeholders
- **Export Options**: CSV, PDF, and JSON export capabilities
- **Scheduled Reports**: Automated weekly/monthly analytics summaries
- **API Access**: Programmatic access to all analytics data

## 🛠️ Advanced Configuration

### Environment Setup

```dart
// Development environment
await Feedbacknest.init(
  'dev_api_key',
  environment: FeedbacknestEnvironment.development,
  debugMode: true,
);

// Production environment  
await Feedbacknest.init(
  'prod_api_key',
  environment: FeedbacknestEnvironment.production,
  debugMode: false,
);
```

### Network Configuration

```dart
await Feedbacknest.init(
  'YOUR_API_KEY',
  networkConfig: NetworkConfig(
    timeout: Duration(seconds: 30),
    retryAttempts: 3,
    enableCaching: true,
  ),
);
```

### Privacy Controls

```dart
await Feedbacknest.init(
  'YOUR_API_KEY',
  privacyConfig: PrivacyConfig(
    collectDeviceInfo: true,
    collectLocationData: false,
    anonymizeUserData: true,
    dataRetentionDays: 365,
  ),
);
```

## 🔧 API Reference

### Core Methods

#### `Feedbacknest.init()`
Initialize the Feedbacknest SDK with your API key.

```dart
static Future<void> init(
  String apiKey, {
  String userIdentifier = "",
  FeedbacknestEnvironment environment = FeedbacknestEnvironment.production,
  NetworkConfig? networkConfig,
  PrivacyConfig? privacyConfig,
  bool debugMode = false,
}) async
```

#### `Feedbacknest.submitRatingAndReview()`
Submit user ratings and reviews.

```dart
static Future<void> submitRatingAndReview({
  required int rating,        // 1-5 star rating
  String? review,            // Optional review text
}) async
```

#### `Feedbacknest.submitCommunication()`
Submit detailed feedback with attachments.

```dart
static Future<void> submitCommunication({
  required String message,   // Feedback message
  required String type,      // feedback, bug, feature_request, contact
  String? email,            // User's email
  List<File>? files,        // File attachments
}) async
```

### Widget Components

#### `FeedbackDialog`
Customizable dialog widget for collecting feedback.

```dart
FeedbackDialog({
  required CommunicationType type,
  CommunicationTheme theme = CommunicationTheme.light,
  String? title,
  String? subtitle,
  String? placeholder,
  String submitButtonText = "Submit",
  String cancelButtonText = "Cancel",
  bool allowFileAttachment = true,
  int maxFileSize = 10 * 1024 * 1024, // 10MB
  List<String> allowedFileTypes = const ['.jpg', '.png', '.pdf'],
  ButtonStyle? buttonStyle,
  TextStyle? titleStyle,
  TextStyle? subtitleStyle,
})
```

## 🎯 Examples

### Complete Implementation Example

```dart
import 'package:flutter/material.dart';
import 'package:feedbacknest_core/feedbacknest.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedbacknest Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initializeFeedbacknest();
  }

  Future<void> _initializeFeedbacknest() async {
    await Feedbacknest.init('YOUR_API_KEY');
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        type: CommunicationType.feedback,
        theme: CommunicationTheme.light,
        title: "Share Your Feedback",
        subtitle: "Help us improve your experience",
      ),
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        type: CommunicationType.bug,
        theme: CommunicationTheme.dark,
        title: "Report a Bug",
        subtitle: "Encountered an issue? Let us know!",
      ),
    );
  }

  void _submitRating() async {
    await Feedbacknest.submitRatingAndReview(
      rating: 5,
      review: "Great app! Easy to use and very helpful.",
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you for your rating!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedbacknest Example')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _showFeedbackDialog,
              child: Text('Give Feedback'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showBugReportDialog,
              child: Text('Report Bug'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitRating,
              child: Text('Rate App'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Custom Feedback Form

```dart
class CustomFeedbackForm extends StatefulWidget {
  @override
  _CustomFeedbackFormState createState() => _CustomFeedbackFormState();
}

class _CustomFeedbackFormState extends State<CustomFeedbackForm> {
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  List<File> _attachedFiles = [];

  void _submitFeedback() async {
    try {
      await Feedbacknest.submitCommunication(
        message: _messageController.text,
        type: 'feedback',
        email: _emailController.text,
        files: _attachedFiles,
      );
      
      Navigator.of(context).pop();
      _showSuccessMessage();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Feedback')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔒 Security & Privacy

### Data Collection
Feedbacknest Core automatically collects the following information to provide better support:

- **Device Information**: Platform, OS version, device model
- **App Information**: App version, build number
- **User Identifier**: Anonymous or custom user ID
- **Session Data**: App usage patterns and session duration

### Privacy Controls
- **Anonymization**: Option to anonymize all user data
- **Data Retention**: Configurable data retention periods
- **Opt-out Options**: Users can opt out of data collection
- **GDPR Compliance**: Full compliance with GDPR and privacy regulations

### Security Measures
- **End-to-End Encryption**: All data is encrypted in transit and at rest
- **Secure API**: Industry-standard security protocols
- **Regular Audits**: Regular security audits and penetration testing
- **Compliance**: SOC 2 Type II and ISO 27001 certified

## 🚀 Performance

### Optimizations
- **Lazy Loading**: Components are loaded only when needed
- **Efficient Caching**: Smart caching reduces network requests
- **Background Processing**: Non-blocking operations for smooth UX
- **Minimal Footprint**: Lightweight package with minimal dependencies

### Benchmarks
- **Package Size**: < 500kb
- **Memory Usage**: < 5MB additional RAM
- **Cold Start Impact**: < 50ms
- **Network Efficiency**: Compressed payloads, smart retries

## 🧪 Testing

### Unit Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:feedbacknest_core/feedbacknest.dart';

void main() {
  group('Feedbacknest Tests', () {
    test('should initialize successfully', () async {
      await Feedbacknest.init('test_api_key');
      expect(Feedbacknest.isInitialized, true);
    });

    test('should submit rating', () async {
      await Feedbacknest.init('test_api_key');
      
      expect(
        () async => await Feedbacknest.submitRatingAndReview(rating: 5),
        returnsNormally,
      );
    });
  });
}
```

### Widget Testing

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedbacknest_core/feedbacknest.dart';

void main() {
  testWidgets('FeedbackDialog should display correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedbackDialog(
            type: CommunicationType.feedback,
            theme: CommunicationTheme.light,
          ),
        ),
      ),
    );

    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
```

## 🌟 Migration Guide

### From Version 0.x to 1.x

#### Breaking Changes
1. **Initialization**: Now requires explicit initialization
2. **Communication Types**: Enum-based type system
3. **Theme System**: New theming approach

#### Migration Steps

```dart
// Old (0.x)
FeedbackWidget(
  apiKey: 'YOUR_API_KEY',
  type: 'feedback',
);

// New (1.x)
await Feedbacknest.init('YOUR_API_KEY');
showDialog(
  context: context,
  builder: (context) => FeedbackDialog(
    type: CommunicationType.feedback,
  ),
);
```

## 📱 Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| iOS | ✅ Full | iOS 12.0+ |
| Android | ✅ Full | API 21+ |
| Web | ✅ Full | All modern browsers |
| macOS | ✅ Full | macOS 10.14+ |
| Windows | ✅ Full | Windows 10+ |
| Linux | ✅ Full | All distributions |

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/feedbacknest/feedbacknest-core.git

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- 🌐 **Website**: [feedbacknest.app](https://feedbacknest.app)
- 📊 **Dashboard**: [feedbacknest.app/dashboard](https://feedbacknest.app/dashboard)
- 📚 **Documentation**: [docs.feedbacknest.app](https://docs.feedbacknest.app)
- 🐛 **Issues**: [GitHub Issues](https://github.com/feedbacknest/feedbacknest-core/issues)
- 💬 **Discord**: [Join our community](https://discord.gg/feedbacknest)
- 🐦 **Twitter**: [@FeedbacknestApp](https://twitter.com/FeedbacknestApp)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Open source contributors
- Beta testers and early adopters
- The developer community for feedback and suggestions

---

<div align="center">
  <p>Made with ❤️ by the Feedbacknest team</p>
  <p>
    <a href="https://feedbacknest.app">Website</a> •
    <a href="https://docs.feedbacknest.app">Documentation</a> •
    <a href="https://github.com/feedbacknest/feedbacknest-core/issues">Support</a>
  </p>
</div>
