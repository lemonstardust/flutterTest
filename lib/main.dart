import 'package:flutter/material.dart';
import 'package:flutter_mytest/widget/viewpager_demo_page.dart'
    deferred as viewpager_demo_page;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: routers,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    List<String> routeLists = routers.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Flutter ViewPager"),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(routeLists[index]);
            },
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(10),
                height: 50,
                alignment: Alignment.center,
                child: Text(routeLists[index]),
              ),
            ),
          );
        },
        itemCount: routeLists.length,
      ),
    );
  }
}

Map<String, WidgetBuilder> routers = {
  "viewPager": (BuildContext context) {
    return ContainerAsyncRouterPage(viewpager_demo_page.loadLibrary(), (c) {
      return viewpager_demo_page.ViewPagerDemoPage();
    });
  }
};

class ContainerAsyncRouterPage extends StatelessWidget {
  final Future libraryFuture;

  ///不能直接传widget，因为 release 打包时 dart2js 优化会导致时许不对
  ///稍后更新文章到掘金
  final WidgetBuilder child;

  const ContainerAsyncRouterPage(this.libraryFuture, this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: libraryFuture,
        builder: (c, s) {
          if (s.connectionState == ConnectionState.done) {
            if (s.hasError) {
              return Scaffold(
                appBar: AppBar(),
                body: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Error: ${s.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            return child.call(context);
          }
          return Scaffold(
            appBar: AppBar(),
            body: Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        });
  }
}
