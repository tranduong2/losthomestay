import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

const adminBg = Color(0xFF090F21);
const adminPanel = Color(0xFF111D34);
const adminLine = Color(0xFF243754);
const adminBlue = Color(0xFF72D5FF);

class AdminPage extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const AdminPage(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: adminBg,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
            ])),
        Expanded(child: child),
      ]));
}

class AdminPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const AdminPanel(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(22)});
  @override
  Widget build(BuildContext context) => Container(
      padding: padding,
      decoration: BoxDecoration(
          color: adminPanel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: adminLine)),
      child: child);
}

class AdminGrid extends StatelessWidget {
  final int count;
  final Widget Function(BuildContext, int) builder;
  const AdminGrid({super.key, required this.count, required this.builder});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final columns = c.maxWidth >= 1120
            ? 3
            : c.maxWidth >= 700
                ? 2
                : 1;
        final width = (c.maxWidth - 48 - (columns - 1) * 16) / columns;
        return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(
                    count,
                    (i) =>
                        SizedBox(width: width, child: builder(context, i)))));
      });
}
