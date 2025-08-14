import 'dart:io';
import 'dart:math' as Math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ViewPagerDemoPage extends StatelessWidget {
  ViewPagerDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageView();
  }
}

class PageView extends StatefulWidget {
  const PageView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PageViewState();
  }
}

class _PageViewState extends State<PageView> {
  List<Color> colorList = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent
  ];

  // 创建 TransformerPageController 实例
  TransformerPageController controller = TransformerPageController(
    itemCount: 3, // 页面数量
    loop: false, // 是否循环
    reverse: false, // 是否反转
  );

  int _curIndex = 0;

  int _clickCount = 0;

  @override
  void initState() {
    super.initState();
    _readCounter().then((ccc) {
      _clickCount = ccc;
    });
  }

  Future<File> _getLocalFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File("$dir/counter.txt");
  }

  Future<int> _readCounter() async {
    try {
      final file = await _getLocalFile();
      String contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<Null> _incrementCounter() async {
    setState(() {
      _clickCount++;
    });
    await (await _getLocalFile()).writeAsString('$_clickCount');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Container(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20, top: 30),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3.0,
                    ),
                  ),
                  child: InkWell(
                      onTap: () {
                        _incrementCounter();
                        print("click head icon $_clickCount times");
                      },
                      splashFactory: NoSplash.splashFactory,
                      child: ClipOval(
                        child: Image.network(
                            "https://uploads-oss.xstudyedu.com/client/padmanageservice/test/56b3ad5ab369-44e1-8cb9-faa546491a361714390088909.png",
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80, errorBuilder: (context, url, error) {
                          return Image.asset("assets/pic_tx_default.png",
                              width: 80, height: 80, fit: BoxFit.cover);
                        }),
                      )),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30, left: 20),
                  child: Text(
                    "name",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  // Text(
                  //   "name",
                  //   style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ],
            ),
            // 圆形头像 - 加载网络图片

            const SizedBox(height: 20),
            Expanded(
              child: TransformerPageView(
                  loop: false,
                  controller: IndexController(),
                  onPageChanged: (index) {
                    if (index != null) {
                      _curIndex = index;
                    }
                    if (kDebugMode) {
                      print("current $index");
                    }
                  },
                  pageController: controller,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                          color: colorList[index % colorList.length],
                          border: Border.all(color: Colors.white)),
                      child: Center(
                        child: Text(
                          "$index",
                          style: const TextStyle(
                              fontSize: 80.0, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  itemCount: 3),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: colorList.asMap().entries.map((entry) {
                return GestureDetector(
                    onTap: () {
                      _curIndex = entry.key;
                      controller.jumpToPage(_curIndex);
                      print("onClick ${entry.key}");
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: entry.key == IndexController().index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    ));
              }).toList(),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}

class AccordionTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position < 0.0) {
      return Transform.scale(
        scale: 1 + position,
        alignment: Alignment.topRight,
        child: child,
      );
    } else {
      return Transform.scale(
        scale: 1 - position,
        alignment: Alignment.bottomLeft,
        child: child,
      );
    }
  }
}

class ThreeDTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double height = info.height!;
    double? width = info.width;
    double? pivotX = 0.0;
    if (position < 0 && position >= -1) {
      // left scrolling
      pivotX = width;
    }
    return Transform(
      transform: Matrix4.identity()
        ..rotate(vector.Vector3(0.0, 2.0, 0.0), position * 1.5),
      origin: Offset(pivotX!, height / 2),
      child: child,
    );
  }
}

class ZoomInPageTransformer extends PageTransformer {
  static const double ZOOM_MAX = 0.5;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double? width = info.width;
    if (position > 0 && position <= 1) {
      return Transform.translate(
        offset: Offset(-width! * position, 0.0),
        child: Transform.scale(
          scale: 1 - position,
          child: child,
        ),
      );
    }
    return child;
  }
}

class ZoomOutPageTransformer extends PageTransformer {
  static const double MIN_SCALE = 0.85;
  static const double MIN_ALPHA = 0.5;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double? pageWidth = info.width;
    double? pageHeight = info.height;

    if (position < -1) {
      // [-Infinity,-1)
      // This page is way off-screen to the left.
      //view.setAlpha(0);
    } else if (position <= 1) {
      // [-1,1]
      // Modify the default slide transition to
      // shrink the page as well
      double scaleFactor = Math.max(MIN_SCALE, 1 - position.abs());
      double vertMargin = pageHeight! * (1 - scaleFactor) / 2;
      double horzMargin = pageWidth! * (1 - scaleFactor) / 2;
      double dx;
      if (position < 0) {
        dx = (horzMargin - vertMargin / 2);
      } else {
        dx = (-horzMargin + vertMargin / 2);
      }
      // Scale the page down (between MIN_SCALE and 1)
      double opacity = MIN_ALPHA +
          (scaleFactor - MIN_SCALE) / (1 - MIN_SCALE) * (1 - MIN_ALPHA);

      return Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(dx, 0.0),
          child: Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    } else {
      // (1,+Infinity]
      // This page is way off-screen to the right.
      // view.setAlpha(0);
    }

    return child;
  }
}

class DeepthPageTransformer extends PageTransformer {
  DeepthPageTransformer() : super(reverse: true);

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position <= 0) {
      return Opacity(
        opacity: 1.0,
        child: Transform.translate(
          offset: const Offset(0.0, 0.0),
          child: Transform.scale(
            scale: 1.0,
            child: child,
          ),
        ),
      );
    } else if (position <= 1) {
      const double minScale = 0.75;
      // Scale the page down (between MIN_SCALE and 1)
      double scaleFactor = minScale + (1 - minScale) * (1 - position);

      return Opacity(
        opacity: 1.0 - position,
        child: Transform.translate(
          offset: Offset(info.width! * -position, 0.0),
          child: Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    }

    return child;
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double _scale;
  final double _fade;

  ScaleAndFadeTransformer({double fade = 0.3, double scale = 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double scaleFactor = (1 - position.abs()) * (1 - _scale);
    double fadeFactor = (1 - position.abs()) * (1 - _fade);
    double opacity = _fade + fadeFactor;
    double scale = _scale + scaleFactor;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}
