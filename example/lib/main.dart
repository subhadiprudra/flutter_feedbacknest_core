import 'package:feedbacknest_core/feedbacknest.dart';
import 'package:flutter/material.dart';
import 'screens/feedback_dialog_demo.dart';

/// The main entry point for the Flutter application.
void main() {
  runApp(MyApp());
  // Feedbacknest.init("Q1UJxjPOWwj4K9hlxK69CFXT38phJt8a");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback Dialog Demo',
      navigatorObservers: [FeedbacknestScreenObserver()],
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FeedbackNest(
        apiKey: "8ZOAj1LzCoSfZXBp1Tts-pCa_9oBL3HE",
        child: FeedbackDialogDemo(),
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}
