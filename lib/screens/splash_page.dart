 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timer_controller/timer_controller.dart';
import 'package:jesus24/components/app_text.dart';
import 'package:jesus24/utils/app_const.dart';

import '../utils/app_func.dart';
import 'home_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late TimerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TimerController.seconds(2);
    _controller.start();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimerControllerListener(
      listener: (BuildContext context, TimerValue value) async {
        navigateToNextPage(context, const HomePage(), back: false);
      },
      listenWhen: (previousValue, currentValue){
        log(previousValue);
        log(currentValue);
        return currentValue.remaining == 0;
      },
      controller: _controller,
      child: Scaffold(
//        backgroundColor: AppColor.secondary,
        backgroundColor: Color(0xfffffd03),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 50,
              right: 50,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:   [
                    Image.asset("assets/img/logo_splash.jpg"),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 40,
                right: 0,
                left: 0,
                child: Column(
                  children: const [
                    CircularProgressIndicator(),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
