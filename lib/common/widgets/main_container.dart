import 'package:flutter/material.dart';
import 'package:gsloution_mobile/common/config/app_fonts.dart';

class MainContainer extends StatelessWidget {
  String? appBarTitle;
  final Widget? appBarTitleWidget;
  Widget child;
  List<Widget>? actions = [];
  bool isAppBar = true;
  bool isAppBarWidget = false;
  Widget? leading;
  Color? backgroundColor;
  Widget? floatingActionButton;
  double? padding, elevation;
  Widget? bottomNavigationBar;
  String name = "";
  String post = "";
  final Widget? drawer;
  final PreferredSizeWidget? appBarBottom;

  MainContainer({
    required this.child,
    this.backgroundColor,
    this.appBarTitle,
    this.appBarTitleWidget,
    this.isAppBar = true,
    this.isAppBarWidget = false,
    this.actions,
    this.floatingActionButton,
    this.padding,
    this.elevation,
    this.leading,
    this.bottomNavigationBar,
    this.drawer,
    this.name = "",
    this.post = "",
    this.appBarBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton ?? null,
      appBar: isAppBar == true
          ? isAppBarWidget == false
              ? AppBar(
                  iconTheme: const IconThemeData(color: Colors.white),
                  leading: leading ?? null,
                  elevation: elevation ?? 0.0,
                  centerTitle: true,
                  bottom: appBarBottom ?? null,
                  actions: actions,
                  title: appBarTitleWidget ??
                      Text(appBarTitle ?? '',
                          style: AppFont.Title_H6_Medium(color: Colors.blue)),
                )
              : PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: Container(
                    color: Colors.teal,
                    padding: const EdgeInsets.only(
                        top: 20, left: 16, right: 16, bottom: 8),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.home, color: Colors.teal),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name!,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              post!,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.notifications, color: Colors.white),
                        const SizedBox(width: 16),
                        const Icon(Icons.settings, color: Colors.white),
                      ],
                    ),
                  ),
                )
          : null,
      drawer: drawer != null ? drawer : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding ?? 0.0),
          child: child,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar ?? null,
    );
  }
}
