/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
	import com.aoaogame.sdk.adManager.AdManager;
	import org.mousebomb.TieZhiConf;

	import flash.utils.setTimeout;

	public class AdFactory
	{
		public function AdFactory()
		{
			if (!CONFIG::DEBUG)
			{
				AdManager.instance.init(TieZhiConf.AOAO_APP_ID, TieZhiConf.BAIDU_IOS, TieZhiConf.BAIDU_ANDROID, TieZhiConf.ADMOB_iOS_BANNER, TieZhiConf.ADMOB_iOS_INTERSTITIAL, TieZhiConf.ADMOB_ANDROID_BANNER, TieZhiConf.ADMOB_ANDROID_INTERSTITIAL);
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
        private var nextInterstitialI:uint = 0;

		public function runInterstitial() : void
		{
            if(++nextInterstitialI % ${interstitialAdLevel} == 0)
            {
                try{
			    AdManager.instance.showInterstitial();
                }catch(e:*){}
            }
		}
	}
}
