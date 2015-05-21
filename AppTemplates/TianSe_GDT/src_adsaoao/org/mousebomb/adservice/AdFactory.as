/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
import org.mousebomb.DebugHelper;
import org.mousebomb.GameConf;
    import org.mousebomb.DebugHelper;
import flash.system.Capabilities;

import so.cuo.platform.gdt.GDTAds;
import so.cuo.platform.gdt.GDTEvent;
import so.cuo.platform.gdt.GDTSize;

import com.aoaogame.sdk.GlobalConfig;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.system.Capabilities;

	import flash.utils.setTimeout;

	public class AdFactory
	{

        private var gdtad:GDTAds;


        private var _request : URLRequest;
        private var _urlLoader : URLLoader = new URLLoader();

        public function AdFactory()
		{
			if (!CONFIG::DESKTOP)
			{
                gdtad=GDTAds.getInstance();
                if (gdtad.supportDevice)
                {
                    gdtad.setKeys(GameConf.GDT_ANDROID_APPID,GameConf.GDT_ANDROID_BANNER, GameConf.GDT_ANDROID_INTERSTITIAL);
                    gdtad.addEventListener(GDTEvent.onInterstitialReceive, onAdEvent);
                    gdtad.addEventListener(GDTEvent.onBannerReceive, onAdEvent);
                    gdtad.enableTrace=false;
                }

                DebugHelper.log("预设:GDT:"+GameConf.GDT_ANDROID_APPID+","+GameConf.GDT_ANDROID_BANNER+","+ GameConf.GDT_ANDROID_INTERSTITIAL);


                // 加载数据
                var descriptor : XML = NativeApplication.nativeApplication.applicationDescriptor;
                var ns : Namespace = descriptor.namespaceDeclarations()[0];
                var version : String = descriptor.ns::versionNumber.toString();
                _request = new URLRequest(GlobalConfig.GET_AD_DATA_PHP_URL + "?i=" + GameConf.AOAO_APP_ID + "&o=" + Capabilities.os + "&l=" + Capabilities.language + "&v=" + version);
                _request.method = URLRequestMethod.GET;
                _urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
                _urlLoader.load(_request);
                _urlLoader.addEventListener(Event.COMPLETE, urlLoaded);
                _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onAdConfigData);

                DebugHelper.log("加载,AppID:"+GameConf.AOAO_APP_ID);

			}
			else
			{
				trace("桌面调试模式，不加载广告");
			}
		}
        private function onAdEvent(event:GDTEvent):void
        {
            DebugHelper.log("GDT事件:"+event.type);
        }

        // 显示广告
        private var allowShowAd :Boolean = true;

        private function urlLoaded(event : Event) : void {
            // trace('_urlLoader.data: ' + (_urlLoader.data));
            var res : Object = JSON.parse(_urlLoader.data);

            DebugHelper.log(_urlLoader.data);
            var _errorCode = res.errorCode;
            if (_errorCode == 0) {
                var _adObjArr = res.result;
                var resultLen : int = res.result.length;
                // 根据获得的后端数据，重置各个广告的percent
                allowShowAd=false;
                for(var i : int = 0 ; i < resultLen; i++)
                {
                    var eachadobj=res.result[i];
                    if(eachadobj.bannerPercent>0) allowShowAd = true;
                    if(eachadobj.interstitialPercent>0) allowShowAd = true;
                }
                //有配置 按配置 全0则关
                onAdConfigData(new Event("GET_DATA_SUCCESS"));
            } else {
                //后台无配置
                onAdConfigData(new Event("GET_DATA_FAIL"));
            }
        }


        private var isAdConfigLoading:Boolean =true;
		private function onAdConfigData(event : *) : void
		{
            DebugHelper.log("数据事件:"+event.type);
			// 数据获得了 请求banner和预加载插屏
            isAdConfigLoading = false;
            runBanner();
            gdtad.cacheInterstitial();
        }

		public function runBanner() : void
		{
            if (CONFIG::DESKTOP) return ;
            if(isAdConfigLoading ) return ;
            if( !allowShowAd ) return ;

            DebugHelper.log("RUNBANNER");

            gdtad.showBannerAbsolute(GDTAds.BANNER, 0, 0);

		}

        private var nextInterstitialI:uint = 0;

        public function runInterstitial() : void
		{
            if (CONFIG::DESKTOP) return ;
            if(isAdConfigLoading ) return ;
            if( !allowShowAd ) return ;

            DebugHelper.log("runInterstitial");
            ++nextInterstitialI;
            if (gdtad.isInterstitialReady())
            {
                if(nextInterstitialI % GameConf.INTERSTITIAL_AD_LEVEL == 0)
                {
                    try{
                            gdtad.showInterstitial();
                            // 若是顶部banner，防止挡住插屏关闭按钮，要hide
                            if(!GameConf.IS_BANNER_BOTTOM) gdtad.hideBanner();
                    }catch(e:*){}
                }
            }
            else
            {
                gdtad.cacheInterstitial();
            }
		}
	}
}
