import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAds {
  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  void loadBannerAd({required Function(BannerAd) onAdLoaded}) {
    BannerAd bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('$ad loaded.');
          onAdLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, err) {
          print('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }
}
