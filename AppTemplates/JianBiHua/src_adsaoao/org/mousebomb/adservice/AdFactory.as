/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
	import flash.utils.setTimeout;

	import com.aoaogame.sdk.adManager.AdManager;

	import org.mousebomb.GameConf;

	public class AdFactory
	{
		public function AdFactory()
		{
			if (!CONFIG::DESKTOP)
			{
				AdManager.instance.init(GameConf.AOAO_APP_ID, GameConf.BAIDU_IOS, GameConf.BAIDU_ANDROID, GameConf.ADMOB_iOS_BANNER, GameConf.ADMOB_iOS_INTERSTITIAL, GameConf.ADMOB_ANDROID_BANNER, GameConf.ADMOB_ANDROID_INTERSTITIAL);
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

		public function runBanner() : void
		{
			AdManager.instance.showBanner(AdManager.IAB_LEADERBOARD, AdManager.CENTER, AdManager.BOTTOM, 0, 0);
			if(_isBannerRunning) return;
			_isBannerRunning = true;
			AdManager.instance.cacheInterstitial();
		}

		public function runInterstitial() : void
		{
			try{AdManager.instance.showInterstitial();}catch(e:*){}
		}
	}
}
