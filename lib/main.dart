import 'package:flutter/material.dart';
import 'package:flutter_app/grid_card.dart';
import 'package:flutter_app/home_controller.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Weather',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController get c => Get.find();

  final edge = 16.0;
  final itemCount = 40;

  final listViewKey = GlobalKey(debugLabel: 'listView');

  @override
  void initState() {
    super.initState();

    Get.put(HomeController());

    c.scrollController.addListener(() => onUpdateScroll(context));
  }

  void onUpdateScroll(BuildContext context) {
    c.listOffset.value = c.scrollController.offset;

    final renderBox =
        listViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    c.listViewTop.value = renderBox.localToGlobal(Offset.zero).dy;
    c.listViewBottom.value = renderBox.localToGlobal(Offset.zero).dy +
        renderBox.size.bottomCenter(Offset.zero).dy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: n.Stack([
        n.Image.network(
          // 'https://picsum.photos/id/961/1200/1920',
          'https://picsum.photos/id/914/1200/1920',
        )
          ..fit = BoxFit.cover
          ..w = double.infinity
          ..h = double.infinity,
        n.Column([
          'My Location'.n
            ..fontSize = 30
            ..fontWeight = FontWeight.w600
            ..color = Colors.white,
          'CATPLANET'.n
            ..fontSize = 12
            ..fontWeight = FontWeight.w600
            ..color = Colors.white,
          '26°C｜Sunny'.n
            ..fontSize = 15
            ..fontWeight = FontWeight.w600
            ..color = Colors.white,
          _buildList(context),
          // _buildList(context),
        ])
          ..wFull
          ..hFull
          ..safeTop
          ..safeX,
      ]),
    );
  }

  Widget _buildList(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onUpdateScroll(context);
    });

    return Expanded(
      child: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            onUpdateScroll(context);
          });
          return true;
        },
        child: SizeChangedLayoutNotifier(
          child: ListView.builder(
            key: listViewKey,
            controller: c.scrollController,
            itemCount: itemCount,
            padding: EdgeInsets.symmetric(horizontal: edge, vertical: 30),
            itemBuilder: ((context, index) {
              final items = _buildItems(context)
                  .expand((element) => [element, n.Box()..h = edge])
                  .toList();

              return items[index % items.length];
            }),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    return [
      GridCard(
        icon: Icons.cloud,
        title: 'HOURLY FORECAST',
        content: placeholderText.n..maxLines = 5,
      ),
      GridCard(
        icon: Icons.timeline,
        title: '10-DAY FORECAST',
        content: placeholderText.n..maxLines = 7,
      ),
      n.Row([
        GridCard(
          icon: Icons.sunny,
          title: 'UV INDEX',
          content: placeholderText.n..maxLines = 5,
        ).niku
          ..expanded,
        GridCard(
          icon: Icons.sunny_snowing,
          title: 'SUNSET',
          content: placeholderText.n..maxLines = 5,
        ).niku
          ..expanded,
      ])
        ..gap = edge,
      n.Row([
        GridCard(
          icon: Icons.thermostat,
          title: 'WEATHER',
          content: placeholderText.n..maxLines = 6,
        ).niku
          ..expanded,
        GridCard(
          icon: Icons.water_drop_sharp,
          title: 'WEATHER',
          content: placeholderText.n..maxLines = 6,
        ).niku
          ..expanded,
      ])
        ..gap = edge,
    ];
  }

  final placeholderText =
      'Mea etiam iudico officiis in, an nam augue liber nusquam, modus tractatos salutandi ut mel. Eam an tempor accumsan patrioque. Quis honestatis duo ei. Vel at solet iudicabit adversarium, pri ludus everti ad, at vix quas primis. At eirmod adolescens duo, mei ex tota dicta quaestio.';
}
