import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:valineups/google_ads.dart';

class GoogleAdsPage extends StatefulWidget {
  const GoogleAdsPage({super.key});

  @override
  State<GoogleAdsPage> createState() => _GoogleAdsPageState();
}

class _GoogleAdsPageState extends State<GoogleAdsPage> {
  BannerAd? _bannerAd;
  final GoogleAds _googleAds = GoogleAds();

  @override
  void initState() {
    super.initState();
    _googleAds.loadBannerAd(onAdLoaded: (ad) {
      setState(() {
        _bannerAd = ad;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _bannerAd == null
              ? Container()
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
