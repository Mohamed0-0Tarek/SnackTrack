import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  /// Set this to true to show the overlay, false to hide it.
  final bool isLoading;
  /// The widget underneath the loading overlay (e.g., your main screen content).
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 1. Initialize the controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Speed of one pulse direction
    );

    // 2. Define the scale range (e.g., 85% to 115% size)
    _animation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth easing
      ),
    );

    // 3. Start animating if initially loading
    if (widget.isLoading) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start or stop the animation when the isLoading state changes
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main content of your app/screen goes here
        widget.child,

        // The Loading Overlay (only visible when isLoading is true)
        if (widget.isLoading)
          Container(
            color: Colors.black.withAlpha(100), 
            child: Center(
              child: ScaleTransition(
                scale: _animation,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                      child: Image.asset("assets/images/logo.png"),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
