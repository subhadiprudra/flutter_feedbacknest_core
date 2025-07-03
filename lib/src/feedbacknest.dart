import 'package:feedbacknest_core/src/feedbacknest_core.dart';
import 'package:flutter/material.dart';

class FeedbackNest extends StatefulWidget {
  String apiKey;
  Widget child;

  FeedbackNest({super.key, required this.apiKey, required this.child});

  @override
  State<FeedbackNest> createState() => _FeedbackNestState();
}

class _FeedbackNestState extends State<FeedbackNest>
    with WidgetsBindingObserver, RouteAware {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    FeedbackNestCore.init(widget.apiKey);
    WidgetsBinding.instance.addObserver(this);
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError caught in main');
      debugPrint('error : ' + details.toString());
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<void>? currentRoute = ModalRoute.of(context);
    if (currentRoute != null) {
      debugPrint(
          'FeedbackNest subscribed to route: ${currentRoute.settings.name}');
    }
  }

  @override
  void dispose() {
    print("app disposed");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FeedbackNestCore.onLifeCycleEventChange(state);
  }
}
