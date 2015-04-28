/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
import so.cuo.platform.ads360.Ads360;
import so.cuo.platform.ads360.Ads360Event;
import so.cuo.platform.ads360.Ads360Position;

	import org.mousebomb.TieZhiConf;

	import flash.utils.setTimeout;

	public class AdFactory
	{
		public function AdFactory()
		{
			if (!CONFIG::DEBUG)
			{
                setTimeout(runBanner, 1000);
            }
			else
			{
				trace("桌面调试模式，不加载广告");
			}
		}

		public function runBanner() : void
		{
            Ads360.getInstance().showBanner(TieZhiConf.AD360_ANDROID, Ads360.BANNER, Ads360Position.BOTTOM, true);
            //在应用的顶部显示banner测试广告，最后一个boolean参数表示是否是测试模式
		}
        private var nextInterstitialI:uint = 0;

		public function runInterstitial() : void
		{
            if(++nextInterstitialI % ${interstitialAdLevel} == 0)
            {
                try{
                    Ads360.getInstance().showInterstitial(TieZhiConf.AD360_ANDROID, true);
                }catch(e:*){}
            }
		}
	}
}
