import 'package:flutter/material.dart';

class SliverAppScaffold extends StatelessWidget {
  final String title;
  final Widget flexibleContent;
  final Widget body;
  final Widget? floatingActionButton; // 🆕
  final Widget? endDrawer; // 🆕
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final double flexibleContentHeight;

  const SliverAppScaffold({
    super.key,
    required this.title,
    required this.flexibleContent,
    required this.body,
    this.floatingActionButton, // 🆕
    this.endDrawer, // 🆕
    this.scaffoldKey,
    this.flexibleContentHeight = 135,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        endDrawer: endDrawer, // 🆕
        floatingActionButton: floatingActionButton, // 🆕
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(title),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(flexibleContentHeight),
                child: SizedBox(
                  height: flexibleContentHeight,
                  child: flexibleContent,
                ),
              ),
            ),
          ],
          body: body,
        ),
      ),
    );
  }
}
