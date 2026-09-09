import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Full-height sections with scrollable overflow and deliberate page changes.
class SectionPager extends StatefulWidget {
  const SectionPager({super.key, required this.children, required this.labels});
  final List<Widget> children;
  final List<String> labels;

  @override
  State<SectionPager> createState() => SectionPagerState();
}

class SectionPagerState extends State<SectionPager> {
  final _pages = PageController();
  late final _scrolls =
      List.generate(widget.children.length, (_) => ScrollController());
  int _index = 0;
  bool _moving = false;
  double _overscroll = 0;
  DateTime _lastWheel = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> goTo(int index) async {
    if (_moving ||
        index < 0 ||
        index >= widget.children.length ||
        index == _index) {
      return;
    }
    _moving = true;
    _overscroll = 0;
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      _pages.jumpToPage(index);
    } else {
      await _pages.animateToPage(index,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic);
    }
    if (mounted) _moving = false;
  }

  void _wheel(PointerSignalEvent event, int index) {
    if (event is! PointerScrollEvent || event.scrollDelta.dy == 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final now = DateTime.now();
      final continuing = now.difference(_lastWheel).inMilliseconds < 180;
      _lastWheel = now;
      if (_moving || index != _index) return;
      final position = _scrolls[index].position;
      final delta = event.scrollDelta.dy;
      final atEdge = delta > 0
          ? position.pixels >= position.maxScrollExtent - 1
          : position.pixels <= 1;
      if (atEdge) {
        if (!continuing) goTo(index + (delta > 0 ? 1 : -1));
      } else {
        _scrolls[index].jumpTo(
            (position.pixels + delta).clamp(0.0, position.maxScrollExtent));
      }
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    for (final scroll in _scrolls) {
      scroll.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
            child: PageView.builder(
          controller: _pages,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.children.length,
          onPageChanged: (index) => setState(() => _index = index),
          itemBuilder: (context, index) => _RetainedSection(
              child: AnimatedBuilder(
            animation: _pages,
            child: LayoutBuilder(
                builder: (context, constraints) =>
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.depth != 0) return false;
                        if (notification is ScrollStartNotification) {
                          _overscroll = 0;
                        }
                        if (notification is OverscrollNotification &&
                            notification.dragDetails != null) {
                          _overscroll += notification.overscroll;
                          if (_overscroll.abs() > 65) {
                            goTo(index + (_overscroll > 0 ? 1 : -1));
                          }
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _scrolls[index],
                        physics: const ClampingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerSignal: (event) => _wheel(event, index),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Center(child: widget.children[index]),
                          ),
                        ),
                      ),
                    )),
            builder: (context, child) {
              final distance =
                  _pages.hasClients && _pages.position.hasContentDimensions
                      ? ((_pages.page ?? 0) - index).abs().clamp(0.0, 1.0)
                      : 0.0;
              final reduced = MediaQuery.disableAnimationsOf(context);
              return Opacity(
                  opacity: reduced ? 1 : 1 - distance * .45,
                  child: Transform.scale(
                      scale: reduced ? 1 : 1 - distance * .05, child: child));
            },
          )),
        )),
        SafeArea(
            top: false,
            child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        tooltip: 'Phần trước',
                        onPressed: _index > 0 ? () => goTo(_index - 1) : null,
                        icon: const Icon(Icons.keyboard_arrow_up)),
                    Flexible(
                        child: Text(
                            '${_index + 1}/${widget.children.length} · ${widget.labels[_index]}',
                            overflow: TextOverflow.ellipsis)),
                    IconButton(
                        tooltip: 'Phần tiếp theo',
                        onPressed: _index < widget.children.length - 1
                            ? () => goTo(_index + 1)
                            : null,
                        icon: const Icon(Icons.keyboard_arrow_down)),
                  ],
                ))),
      ]);
}

class _RetainedSection extends StatefulWidget {
  const _RetainedSection({required this.child});
  final Widget child;

  @override
  State<_RetainedSection> createState() => _RetainedSectionState();
}

class _RetainedSectionState extends State<_RetainedSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

