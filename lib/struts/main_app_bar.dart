import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar(
      {Key? key, required this.title, this.actions, this.forceElevated})
      : super(key: key);

  final Widget title;
  final List<Widget>? actions;
  final bool? forceElevated;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
            appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(color: Colors.white))),
        child: SliverAppBar(
            backgroundColor: const Color.fromRGBO(78, 42, 132, 1),
            pinned: true,
            stretch: true,
            onStretchTrigger: () {
              // Function callback for stretch
              return Future<void>.value();
            },
            expandedHeight: 192.0,
            actions: actions,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              title: title,
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset("assets/media/background.png",
                      alignment: Alignment.bottomRight, fit: BoxFit.fitHeight),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 0.5),
                        end: Alignment.center,
                        colors: <Color>[
                          Color(0x40000000),
                          Color(0x20000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            forceElevated: forceElevated ?? false));
  }
}
