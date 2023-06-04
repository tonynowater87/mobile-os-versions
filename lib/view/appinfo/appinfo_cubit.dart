import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meta/meta.dart';
import 'package:device_info_tool/constants.dart';
import 'package:device_info_tool/data/AppVersionProvider.dart';
import 'package:device_info_tool/oss_licenses.dart';
import 'package:url_launcher/url_launcher.dart';

part 'appinfo_state.dart';

class AppInfoCubit extends Cubit<AppInfoState> {
  final AppVersionProvider _appVersionProvider;
  final _githubUrl = 'https://github.com/tonynowater87/mobile-os-versions';
  String? _adUnitId;

  AppInfoCubit(this._appVersionProvider) : super(AppInfoInitial());

  Future<void> load() async {
    if (Platform.isAndroid) {
      _adUnitId = INTERSTITIAL_ANDROID_ID;
    }

    final appInfo = await _appVersionProvider.getAppInfo();

    emit(AppInfoLoaded(
        appName: appInfo.appName,
        appVersion: appInfo.version,
        githubLink: _githubUrl));
  }

  Future<void> loadAdAndShow() async {
    if (_adUnitId != null) {
      await InterstitialAd.load(
          adUnitId: _adUnitId!,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
            ad.show();
          }, onAdFailedToLoad: (error) {
            print('[DEBUG] load ad error: $error');
          }));
    }
  }

  Future<void> openGithubUrl() async {
    if (!await launchUrl(Uri.parse(_githubUrl))) {
      throw Exception('Could not launch $_githubUrl');
    }
  }

  Future<List<Package>> filterLicense() async {
    return Future.value(ossLicenses
        .where((element) => !element.isSdk && element.isDirectDependency)
        .toList());
  }
}
