/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{

import org.mousebomb.DebugHelper;
import org.mousebomb.GameConf;
    import org.mousebomb.DebugHelper;

	import flash.utils.setTimeout;

	public class AdFactory
	{
		public function AdFactory()
		{
			if (!CONFIG::DESKTOP)
			{
				AdManager.instance.init(GameConf.AOAO_APP_ID, GameConf.BAIDU_IOS, GameConf.BAIDU_ANDROID, GameConf.ADMOB_iOS_BANNER, GameConf.ADMOB_iOS_INTERSTITIAL, GameConf.ADMOB_ANDROID_BANNER, GameConf.ADMOB_ANDROID_INTERSTITIAL);
				AdManager.instance.addEventListener(AdManager.GET_DATA_SUCCESS, onAdConfigData);
				AdManager.instance.addEventListener(AdManager.GET_DATA_FAIL, onAdConfigData);
                DebugHelper.log("初始化AD,AppID:"+GameConf.AOAO_APP_ID);
                DebugHelper.log("预设:BAIDU_IOS:"+GameConf.BAIDU_IOS +",BAIDU_ANDROID:"+GameConf.BAIDU_ANDROID);
			}
			else
			{
				trace("桌面调试模式，不加载广告");
			}
		}

        private var isAdConfigLoading:Boolean =true;
		private function onAdConfigData(event : *) : void
		{
			// 数据获得了 请求banner和预加载插屏
            isAdConfigLoading = false;
            runBanner();
            AdManager.instance.cacheInterstitial();
        }

		public function runBanner() : void
		{
            if (CONFIG::DESKTOP) return ;
            if(isAdConfigLoading ) return ;

            AdManager.instance.showBanner
                (
                    AdManager.IAB_LEADERBOARD,
                    AdManager.CENTER,
                    GameConf.IS_BANNER_BOTTOM?AdManager.BOTTOM:AdManager.TOP,
                    0, 0
                );
		}

        private var nextInterstitialI:uint = 0;

        public function runInterstitial() : void
		{
            if (CONFIG::DESKTOP) return ;
            if(isAdConfigLoading ) return ;

            if(++nextInterstitialI % GameConf.INTERSTITIAL_AD_LEVEL == 0)
            {
                try{
                    AdManager.instance.showInterstitial();
                }catch(e:*){}
            }
		}
	}
}
