import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jesus24/utils/app_const.dart';

import '../components/app_text.dart';
import '../utils/app_func.dart';
import '../utils/helper_preferences.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey webViewKey = GlobalKey();
  bool isLoadingHere = false;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions sharedSettings = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: false,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptCanOpenWindowsAutomatically: true,
        applicationNameForUserAgent: 'Jesus24TV',
        userAgent:
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.105 Mobile Safari/537.36',
        // enable iOS service worker feature limited to defined App Bound Domains
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  // <iframe frameborder="0" allowfullscreen width="1280" height="720" src="https://player.infomaniak.com?channel=72457&player=11974"></iframe>

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText("Jesus24 TV", color: Colors.white, size: 22, weight: FontWeight.w700,), centerTitle: true,),
      backgroundColor: Colors.white,
      body: RefreshIndicator( onRefresh: () {
        return webViewController!.reload();
      },
        child: SizedBox(
          height: getSize(context).height,
          width: getSize(context).width,
          child: Stack(
            children: [
              Positioned(
                top: 40,
                bottom: 40,
                left: 0,
                right: 0,
                child: SizedBox(
                  // height: getSize(context).height-400,
                  width: getSize(context).width,
                  child: Column(
                    //physics: const BouncingScrollPhysics(),
                    children: [
                      Expanded(
                        child: FutureBuilder<bool>(
                          future: isNetworkAvailable(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CupertinoActivityIndicator(),
                              );
                            }

                            final bool networkAvailable = snapshot.data ?? false;

                            // Android-only
                            final cacheMode =
                            networkAvailable ? AndroidCacheMode.LOAD_DEFAULT : AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK;

                            // iOS-only
                            final cachePolicy = networkAvailable
                                ? IOSURLRequestCachePolicy.USE_PROTOCOL_CACHE_POLICY
                                : IOSURLRequestCachePolicy.RETURN_CACHE_DATA_ELSE_LOAD;


                            return InAppWebView(
                              key: webViewKey,
                              //initialUrlRequest: URLRequest(url: initialUri, iosCachePolicy: cachePolicy),
                              // initialUserScripts: UnmodifiableListView<UserScript>([
                              //   UserScript(source: scrpt, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END),
                              // ]),
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
                      Image.asset("assets/img/logo_splash.jpg"),
                    ],
                  ),
                ),
              ),
              if (isLoadingHere)
                const Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator( )))),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> isNetworkAvailable() async {
    // check if there is a valid network connection
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi) {
      return false;
    }

    // check if the network is really connected to Internet
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

