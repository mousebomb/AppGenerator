/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
	import com.aoaogame.sdk.adManager.AdManager;

	import org.mousebomb.ZhaoChaConf;

	import flash.utils.setTimeout;

	public class AdFactory
	{
		public function AdFactory()
		{
			if (!CONFIG::DESKTOP)
			{
				AdManager.instance.init(ZhaoChaConf.AOAO_APP_ID, ZhaoChaConf.BAIDU_IOS, ZhaoChaConf.BAIDU_ANDROID, ZhaoChaConf.ADMOB_iOS_BANNER, ZhaoChaConf.ADMOB_iOS_INTERSTITIAL, ZhaoChaConf.ADMOB_ANDROID_BANNER, ZhaoChaConf.ADMOB_ANDROID_INTERSTITIAL);
				AdManager.instance.addEventListener(AdManager.GET_DATA_SUCCESS, onAdConfigData);
			}
			else
			{
				trace("桌面调试模式，不加载广告");
			}
		}

		private function onAdConfigData(event : *) : void
		{
			// 数据获得了 ， 如果已经请求了banner，则重新启动后台配置的广告
			if (_isBannerRunning)
			{
				AdManager.instance.hideBanner();
				_isBannerRunning = false;
				setTimeout(runBanner, 1000);
			}
		}


		private var _isBannerRunning : Boolean = false;

		public function runBanner() : void {
			if(_isBannerRunning) {
				refreshBanner(); return ;
			}
			AdManager.instance.showBanner(AdManager.IAB_LEADERBOARD, AdManager.CENTER, AdManager.BOTTOM, 0, 0);
			_isBannerRunning = true;
			AdManager.instance.cacheInterstitial();
		}

		private function refreshBanner() : void {
//			AdManager.instance.hideBanner();
			AdManager.instance.showBanner(AdManager.IAB_LEADERBOARD, AdManager.CENTER, AdManager.BOTTOM, 0, 0);
		}
        private var nextInterstitialI:uint = 0;

		public function runInterstitial() : void {
            if(++nextInterstitialI % ${interstitialAdLevel} == 0)
            {
                try{AdManager.instance.showInterstitial();}catch(e:*){}
            }
		}
	}
}
