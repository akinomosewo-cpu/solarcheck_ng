import 'package:flutter/material.dart';

/// Short, non-blocking fade+slide transition used between the major routes
/// (splash → auth → home, login ↔ sign up) so navigation feels polished
/// without adding perceptible delay.
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  FadeSlidePageRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
                child: child,
              ),
            );
          },
        );
}

extension FadeSlideNavigation on BuildContext {
  Future<T?> pushFadeSlide<T>(Widget page) {
    return Navigator.of(this).push<T>(FadeSlidePageRoute(builder: (_) => page));
  }

  Future<T?> pushReplacementFadeSlide<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(FadeSlidePageRoute(builder: (_) => page));
  }
}
