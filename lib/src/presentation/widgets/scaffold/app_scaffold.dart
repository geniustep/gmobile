import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? endDrawer;
  final Color backgroundColor;
  final bool centerTitle;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? flexibleContent;
  final bool pinned;
  final bool floating;
  final bool snap;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.endDrawer,
    this.backgroundColor = Colors.white,
    this.centerTitle = false,
    this.scaffoldKey,
    this.flexibleContent,
    this.pinned = true,
    this.floating = true,
    this.snap = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        endDrawer: endDrawer,
        floatingActionButton: floatingActionButton,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: pinned,
                floating: floating,
                snap: snap,
                backgroundColor: backgroundColor,
                expandedHeight: flexibleContent != null ? 150 : 60,
                centerTitle: centerTitle,
                title: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                actions: actions,
                flexibleSpace: flexibleContent != null
                    ? FlexibleSpaceBar(
                        background: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: flexibleContent,
                        ),
                      )
                    : null,
              ),
            ];
          },
          body: body,
        ),
      ),
    );
  }
}
