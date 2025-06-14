<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Feedbacknest Core

Feedbacknest Core is a feedback collection toolkit for Flutter applications. It enables you to easily integrate user feedback, bug reports, feature requests, and contact forms with customizable UI components.

## Features

- Collect user feedback, bug reports, feature requests, and contact messages
- Customizable feedback dialog widget with support for light and dark themes
- Attach screenshots or files to feedback submissions
- Collect user ratings and reviews
- Automatic device and app info collection (platform, version, device model, OS version)
- API integration for sending feedback to your backend (via Feedbacknest API)
- Persistent user identification using shared preferences
- Easy integration with minimal setup

## Getting started

1. Add `feedbacknest_core` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  feedbacknest_core: <latest_version>
```

2. Import the package in your Dart code:

```dart
import 'package:feedbacknest_core/feedbacknest.dart';
```

3. Initialize Feedbacknest in your app (e.g., in `main()` or before showing the dialog):

```dart
await Feedbacknest.init('YOUR_API_KEY');
```

## Usage

### Show Feedback Dialog

You can use the provided `FeedbackDialog` widget to collect feedback from users. Example:

```dart
showDialog(
  context: context,
  builder: (context) => FeedbackDialog(
    type: CommunicationType.feedback, // or bug, featureRequest, contact
    theme: CommunicationTheme.light, // or dark
  ),
);
```

### Submit Rating and Review

```dart
await Feedbacknest.submitRatingAndReview(rating: 5, review: 'Great app!');
```

### Submit Custom Communication

```dart
await Feedbacknest.submitCommunication(
  message: 'I found a bug in the app',
  type: CommunicationType.bug,
  email: 'user@example.com',
  files: [/* File objects for screenshots */],
);
```

## Example

See the `/example` folder for a complete Flutter app demonstrating all features and customization options.

## Additional information

- [Feedbacknest Website](https://feedbacknest.app)
- For issues, feature requests, or contributions, please open an issue or pull request on the repository.
- Device and app info is collected automatically to help you better understand user feedback.
- All feedback is sent securely to the Feedbacknest API.
