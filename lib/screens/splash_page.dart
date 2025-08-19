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
    super.initState();
    _controller = TimerController.seconds(2);
    _controller.start();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimerControllerListener(
      listener: (BuildContext context, TimerValue value) async {
        //navigateToNextPage(context, const HomePage(), back: false);
      },
      listenWhen: (previousValue, currentValue) {
        log(previousValue);
        log(currentValue);
        return currentValue.remaining == 0;
      },
      controller: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xfffffd03), // Fond jaune
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dans un cercle blanc
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                     // color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: true ? Image.asset("assets/img/logo_splash.jpg") : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'JESUS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '24',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'TV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Section "Text" et message de bienvenue
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
              
                    
                    const SizedBox(height: 15),
                    
                    // Message de bienvenue
                    Text(
                      'Bienvenue sur\nJESUS 24 TV',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Bouton ENTREE
              Container(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    navigateToNextPage(context, const HomePage(), back: false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'ENTRER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}