/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
import adm.JuHeGg;
import org.mousebomb.DebugHelper;
import org.mousebomb.GameConf;
    import org.mousebomb.DebugHelper;
import flash.system.Capabilities;

	import flash.utils.setTimeout;

	public class AdFactory
	{
		public function AdFactory()
		{
			if (!CONFIG::DESKTOP)
			{
                CONFIG::IOS
                {
                    JuHeGg.instance.init( GameConf.AOAO_APP_ID, GameConf.BAIDU_IOS_APPID, GameConf.BAIDU_IOS_BANNER, GameConf.BAIDU_IOS_INTERSTITIAL, GameConf.ADMOB_iOS_BANNER, GameConf.ADMOB_iOS_INTERSTITIAL );
                    JuHeGg.instance.addEventListener(JuHeGg.GET_DATA_SUCCESS, onAdConfigData);
                    JuHeGg.instance.addEventListener(JuHeGg.GET_DATA_FAIL, onAdConfigData);
                }
                CONFIG::ANDROID
                {
                    JuHeGg.instance.init( GameConf.AOAO_APP_ID, GameConf.BAIDU_ANDROID_APPID,GameConf.BAIDU_ANDROID_BANNER,GameConf.BAIDU_ANDROID_INTERSTITIAL, GameConf.ADMOB_ANDROID_BANNER, GameConf.ADMOB_ANDROID_INTERSTITIAL );
                    JuHeGg.instance.addEventListener(JuHeGg.GET_DATA_SUCCESS, onAdConfigData);
                    JuHeGg.instance.addEventListener(JuHeGg.GET_DATA_FAIL, onAdConfigData);
                }
			}
			else
			{
				trace("桌面调试模式，不加载广告");
			}
		}

        private var isAdConfigLoading:Boolean =true;
		private function onAdConfigData(event : *) : void
		{
            DebugHelper.log("数据事件:"+event.type);
			// 数据获得了 请求banner和预加载插屏
            isAdConfigLoading = false;
            runBanner();
            JuHeGg.instance.cacheInterstitial();
        }

		public function runBanner() : void
		{
            if (CONFIG::DESKTOP) return ;
            if(isAdConfigLoading ) return ;

            JuHeGg.instance.showBanner
                (
                    JuHeGg.CENTER,
                    GameConf.IS_BANNER_BOTTOM?JuHeGg.BOTTOM:JuHeGg.TOP
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
                    JuHeGg.instance.showInterstitial();
                    // 若是顶部banner，防止挡住插屏关闭按钮，要hide
                    if(!GameConf.IS_BANNER_BOTTOM) JuHeGg.instance.hideBanner();
                }catch(e:*){}
            }
		}
	}
}
