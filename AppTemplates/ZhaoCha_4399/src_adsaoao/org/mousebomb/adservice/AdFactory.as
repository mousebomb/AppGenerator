/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
    import com.unionsy.sdk.ane.SsjjAdsParams;
    import com.unionsy.sdk.ane.SsjjAdsManager;

	import flash.utils.setTimeout;

	public class AdFactory {
		public function AdFactory() {
			if (!CONFIG::DEBUG) {
                SsjjAdsManager.getInstance().init();
                setTimeout(onAdConfigData, 1000);
			} else {
				trace("桌面调试模式，不加载广告");
			}
		}

		private function onAdConfigData(event : *) : void {
            if (!CONFIG::DEBUG) {
                // 数据获得了 ， 如果已经请求了banner，则重新启动后台配置的广告
                if (_isBannerRunning) {
                    SsjjAdsManager.getInstance().hideBanner();
                    _isBannerRunning = false;
                    setTimeout(runBanner, 1000);
                }
            }
		}

		private var _isBannerRunning : Boolean = false;

		public function runBanner() : void {
            if (!CONFIG::DEBUG) {

                var param : SsjjAdsParams = SsjjAdsParams.SIZE_320x50_DP;
                param.gravity=1;
                SsjjAdsManager.getInstance().showBanner(param);
                if(_isBannerRunning) return;
                _isBannerRunning = true;
                SsjjAdsManager.getInstance().preloadScreen(true);
            }
		}

		public function runInterstitial() : void {
            if (!CONFIG::DEBUG) {
                try{            SsjjAdsManager.getInstance().showPauseScreen(); }catch(e:*){}
            }
		}
	}
}