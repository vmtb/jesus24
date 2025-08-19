import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jesus24/utils/app_const.dart';

import '../components/app_text.dart';
import '../utils/app_func.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  final GlobalKey webViewKey = GlobalKey();
  bool isLoadingHere = false;

  // Contrôleurs d'animation multiples
  late AnimationController _colorAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _waveAnimationController;
  late AnimationController _glowAnimationController; // Suppression du contrôleur particule inutile

  // Animations
  late Animation<Color?> _colorAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions sharedSettings = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: false,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptCanOpenWindowsAutomatically: true,
        applicationNameForUserAgent: 'Jesus24TV',
        userAgent:
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.105 Mobile Safari/537.36',
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    super.initState();
    
    // Animation de couleur principale (bleu vers violet) - ralentie pour moins de charge
    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 6), // Augmenté de 4 à 6 secondes
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: const Color(0xFF1976D2), // Bleu profond
      end: const Color(0xFF7B1FA2), // Violet profond
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Animation du logo (rotation et scale) - ralentie
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 8), // Augmenté de 6 à 8 secondes
      vsync: this,
    );
    
    _logoRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.linear,
    ));
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Animation des vagues - ralentie pour fluidité
    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 4), // Augmenté de 3 à 4 secondes
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.linear,
    ));
    
    // Animation de glow/brillance
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3), // Augmenté de 2 à 3 secondes
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Démarrer toutes les animations
    _colorAnimationController.repeat(reverse: true);
    _logoAnimationController.repeat();
    _waveAnimationController.repeat();
    _glowAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _logoAnimationController.dispose();
    _waveAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _colorAnimation,
        _logoRotationAnimation,
        _logoScaleAnimation,
        _waveAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _colorAnimation.value!,
                    _colorAnimation.value!.withOpacity(0.8),
                    Colors.purple.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _colorAnimation.value!.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: AppBar(
                title: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const AppText(
                    "Jesus24 TV", 
                    color: Colors.white, 
                    size: 22, 
                    weight: FontWeight.w700,
                  ),
                ), 
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Arrière-plan animé avec vagues
              Positioned.fill(
                child: CustomPaint(
                  painter: WavePainter(_waveAnimation.value, _colorAnimation.value!),
                ),
              ),
              
              // Particules flottantes
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticlePainter(_waveAnimation.value, _colorAnimation.value!),
                ),
              ),
              
              // Contenu principal
              RefreshIndicator(
                onRefresh: () {
                  return webViewController!.reload();
                },
                color: _colorAnimation.value,
                child: SizedBox(
                  height: getSize(context).height,
                  width: getSize(context).width,
                  child: ListView(
                    children: [
                      SizedBox(
                        width: getSize(context).width,
                        height: getSize(context).height - 50,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              bottom: 140,
                              left: 10,
                              right: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _colorAnimation.value!.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: FutureBuilder<bool>(
                                    future: isNetworkAvailable(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                _colorAnimation.value!.withOpacity(0.1),
                                                Colors.purple.withOpacity(0.1),
                                              ],
                                            ),
                                          ),
                                          child: const Center(
                                            child: CupertinoActivityIndicator(color: Colors.white),
                                          ),
                                        );
                                      }

                                      // Pas besoin de stocker networkAvailable, on utilise snapshot.data directement

                                      return InAppWebView(
                                        key: webViewKey,
                                        initialData: InAppWebViewInitialData(data: kHTMLPlayer),
                                        onProgressChanged: (controller, progress) {
                                          isLoadingHere = progress < 46;
                                          log("Progesss => $progress");
                                          setState(() {});
                                        },
                                        initialOptions: sharedSettings,
                                        onWebViewCreated: (controller) async {
                                          log("created");
                                          webViewController = controller;
                                        },
                                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                                          return NavigationActionPolicy.ALLOW;
                                        },
                                        onLoadStart: (controller, uri) async {
                                        },
                                        onConsoleMessage: (controller, msg) {
                                          log(msg);
                                        },
                                        onLoadStop: (controller, url) async {
                                          if (await isNetworkAvailable() && !(await isPWAInstalled())) {
                                            setPWAInstalled();
                                          }
                                          log("load stop");
                                        },
                                        onLoadError: (controller, err, error, stack) async {
                                          if (!(await isNetworkAvailable())) {
                                            if (!(await isPWAInstalled())) {}
                                            await controller.loadData(data: kHTMLErrorPageNotInstalled);
                                          }
                                        },
                                        onLoadHttpError: (controller, request, error, stack) async {
                                          if (!(await isNetworkAvailable())) {
                                            if (!(await isPWAInstalled())) {
                                              await controller.loadData(data: kHTMLErrorPageNotInstalled);
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            
                            // Logo animé en bas
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 100,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      _colorAnimation.value!.withOpacity(0.1),
                                      _colorAnimation.value!.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Transform.rotate(
                                    angle: _logoRotationAnimation.value * 0.1, // Rotation lente
                                    child: Transform.scale(
                                      scale: _logoScaleAnimation.value,
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 30),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _colorAnimation.value!.withOpacity(_glowAnimation.value * 0.6),
                                              blurRadius: 20 * _glowAnimation.value,
                                              spreadRadius: 5 * _glowAnimation.value,
                                            ),
                                            BoxShadow(
                                              color: Colors.purple.withOpacity(_glowAnimation.value * 0.4),
                                              blurRadius: 30 * _glowAnimation.value,
                                              spreadRadius: 2 * _glowAnimation.value,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: _colorAnimation.value!.withOpacity(0.5),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Image.asset(
                                              "assets/img/logo_splash.jpg",
                                              height: 70,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Indicateur de chargement premium
                            if (isLoadingHere)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        _colorAnimation.value!.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _colorAnimation.value!.withOpacity(0.9),
                                            Colors.purple.withOpacity(0.9),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _colorAnimation.value!.withOpacity(0.5),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: CircularProgressIndicator(
                                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                                  strokeWidth: 3,
                                                  backgroundColor: Colors.white.withOpacity(0.3),
                                                ),
                                              ),
                                              Transform.rotate(
                                                angle: _logoRotationAnimation.value,
                                                child: const Icon(
                                                  Icons.play_circle_fill,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          const Text(
                                            'Chargement de Jesus24 TV',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Préparation du lecteur...',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }

    return true;
  }
}

// Painter optimisé pour les vagues d'arrière-plan
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 30.0;
    final waveLength = size.width / 2;
    
    // Optimisation: réduire le nombre de points (step de 4 au lieu de 1)
    final step = 4.0;

    path.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x += step) {
      final y = size.height * 0.8 + 
          sin((x / waveLength * 2 * pi) + animationValue) * waveHeight +
          sin((x / waveLength * 4 * pi) + animationValue * 2) * waveHeight * 0.5;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Deuxième vague optimisée
    final paint2 = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.9);

    for (double x = 0; x <= size.width; x += step) {
      final y = size.height * 0.9 + 
          sin((x / waveLength * 3 * pi) + animationValue * 1.5) * waveHeight * 0.7;
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.color != color;
  }
}

// Painter optimisé pour les particules flottantes
class ParticlePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  
  // Cache des positions pour éviter les recalculs
  static final List<double> _basePositionsX = List.generate(10, (i) => i / 10); // Réduit de 15 à 10 particules
  static final List<double> _basePositionsY = List.generate(10, (i) => (i * 0.13) % 1);

  ParticlePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Créer des particules flottantes optimisées
    for (int i = 0; i < 10; i++) { // Réduit de 15 à 10
      final baseX = _basePositionsX[i] * size.width;
      final baseY = _basePositionsY[i] * size.height;
      
      final x = (baseX + sin(animationValue + i * 0.5) * 20) % size.width;
      final y = (baseY + sin(animationValue * 0.5 + i * 0.7) * 30) % size.height;
      final radius = 2 + sin(animationValue + i) * 1;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.color != color;
  }
}