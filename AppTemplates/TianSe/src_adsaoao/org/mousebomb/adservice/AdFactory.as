/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice {
	import flash.utils.setTimeout;

	import com.aoaogame.sdk.adManager.AdManager;

	import org.mousebomb.TianSeConf;

	public class AdFactory {
		public function AdFactory() {
			if (!CONFIG::DEBUG) {
				AdManager.instance.init(TianSeConf.AOAO_APP_ID, TianSeConf.BAIDU_IOS, TianSeConf.BAIDU_ANDROID, TianSeConf.ADMOB_iOS_BANNER, TianSeConf.ADMOB_iOS_INTERSTITIAL, TianSeConf.ADMOB_ANDROID_BANNER, TianSeConf.ADMOB_ANDROID_INTERSTITIAL);
				AdManager.instance.addEventListener(AdManager.GET_DATA_SUCCESS, onAdConfigData);
			} else {
				trace("桌面调试模式，不加载广告");
			}
		}

		private function onAdConfigData(event : *) : void {
            if (!CONFIG::DEBUG) {
                // 数据获得了 ， 如果已经请求了banner，则重新启动后台配置的广告
                if (_isBannerRunning) {
                    AdManager.instance.hideBanner();
                    _isBannerRunning = false;
                    setTimeout(runBanner, 1000);
                }
            }
		}

		private var _isBannerRunning : Boolean = false;

		public function runBanner() : void {
            if (!CONFIG::DEBUG) {
                if(_isBannerRunning) {
                    refreshBanner(); return ;
                }
                AdManager.instance.showBanner(AdManager.IAB_LEADERBOARD, AdManager.CENTER, AdManager.TOP, 0, 0);
                _isBannerRunning = true;
                AdManager.instance.cacheInterstitial();
            }
		}

		private function refreshBanner() : void {
//			AdManager.instance.hideBanner();
            if (!CONFIG::DEBUG) {
			    AdManager.instance.showBanner(AdManager.IAB_LEADERBOARD, AdManager.CENTER, AdManager.TOP, 0, 0);
            }
		}

		public function runInterstitial() : void {
            if (!CONFIG::DEBUG) {
                AdManager.instance.hideBanner();
                try{AdManager.instance.showInterstitial();}catch(e:*){}
            }
		}
	}
}
