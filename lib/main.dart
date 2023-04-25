import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SamplePage(),
    );
  }
}

class SamplePage extends StatefulWidget {
  const SamplePage({Key? key}) : super(key: key);

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final _tabs = [
    'ひだり',
    'みぎ',
  ];

  double offset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController?.animation?.addListener(() => setState(() {
          offset = _tabController?.animation?.value ?? 0;
        }));
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: _tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              const SliverAppBar(title: Text('Sample')),
              SliverPersistentHeader(
                delegate: _StickyTabBarDelegate(
                  offset: offset,
                  tabBar: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelColor: Colors.pink,
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: _tabs.map((e) => Tab(text: e)).toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((e) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    height: 100,
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Text('$e $index'),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

//SliverPersistentHeaderDelegateを継承したTabBarを作る
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate({
    required this.tabBar,
    required this.offset,
  });

  final TabBar tabBar;
  final double offset;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  TabController? get controller => tabBar.controller;

  /// PageViewのスクロール量を[0~1]で取得する
  double get animationValue => controller?.animation?.value ?? 0;

  /// [0~1]で生成されるデータを[-1~1]に変換する
  double get indicatorPosition => animationValue * 2 - 1;

  /// 現在表示されているWidget
  Widget get currentWidget => tabBar.tabs[controller?.index ?? 0];

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Stack(
      children: [
        AnimatedAlign(
          alignment: Alignment(indicatorPosition, 0),
          duration: const Duration(milliseconds: 1),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: MediaQuery.of(context).size.width / 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.pink,
              ),
              child: Opacity(opacity: 0, child: currentWidget),
            ),
          ),
        ),
        Container(color: Colors.transparent, child: tabBar),
      ],
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
