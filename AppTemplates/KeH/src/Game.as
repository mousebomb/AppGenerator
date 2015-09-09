/**
 * Created by rhett on 14-7-19.
 */
package
{

	import com.aoaogame.sdk.adManager.MyAdManager;
import org.mousebomb.GameConf;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;

import org.mousebomb.SoundMan;

public class Game extends AoaoGame
	{
		public function Game()
		{
			super();
		}

		private static const RATE_16_9:Number = 16 / 9;
		private static const RATE_3_2:Number = 3 / 2;
		private static const RATE_4_3:Number = 4 / 3;
		private var picLoader:Loader = new Loader();
		private var whrate:Number;
		private var isLandscape:Boolean;

		private var mainLoader:Loader;

		override protected function start():void
		{
			super.start();

			// 加载主要内容

			// 是否横屏设备
			isLandscape = stage.fullScreenWidth > stage.fullScreenHeight;
			trace( 'stage.fullScreenHeight: ' + (stage.fullScreenHeight) );
			trace( 'stage.fullScreenWidth: ' + (stage.fullScreenWidth) );
			var shortLen:Number;
			var longLen:Number;
			// 宽高比总用长边除以短边,外部图片总是竖屏
			if( isLandscape )
			{
				whrate = stage.fullScreenWidth / stage.fullScreenHeight;
				longLen = stage.fullScreenWidth;
				shortLen = stage.fullScreenHeight;
			} else
			{
				whrate = stage.fullScreenHeight / stage.fullScreenWidth;
				longLen = stage.fullScreenHeight;
				shortLen = stage.fullScreenWidth;
			}

			var request:URLRequest = new URLRequest();
			var scale:Number = 1.0;
			var longLenOffset:Number;
			if( whrate >= RATE_16_9 )
			{
				request.url = (CONFIG::DESKTOP?"assets/":"")+"Default-568h@2x.png";
				scale = shortLen / 640;
				longLenOffset = (longLen - 1136 * scale) / 2;
			} else if( whrate >= RATE_3_2 )
			{
				request.url = (CONFIG::DESKTOP?"assets/":"")+"Default@2x.png";
				scale = shortLen / 640;
				longLenOffset = (longLen - 960 * scale) / 2;
			} else if( whrate >= RATE_4_3 )
			{
				request.url = (CONFIG::DESKTOP?"assets/":"")+"Default~ipad.png";
				scale = shortLen / 768;
				longLenOffset = (longLen - 1024 * scale) / 2;
			}
			trace( request.url );
			// 显示比例保证短边顶满，长边可以显示不全，保证撑满屏幕
			picLoader.load( request );
			picLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onPicLoaded );
			picLoader.scaleX = picLoader.scaleY = scale;
			if( isLandscape )
			{
				picLoader.rotation = -90;
				picLoader.y += shortLen;
				trace( 'picLoader.y: ' + (picLoader.y) );
				picLoader.x += longLenOffset;
				trace( 'longLenOffset: ' + (longLenOffset) );
				trace( 'picLoader.x: ' + (picLoader.x) );
			}
			trace( 'scale: ' + (scale) );
			addChild( picLoader );
		}


		private function onPicLoaded( event:Event ):void
		{
			mainLoader = new Loader();
			var request:URLRequest = new URLRequest();
			request.url = "main.swf";
            var ctx :LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain)
            ctx.allowCodeImport = true;
            mainLoader.load( request ,ctx);
			mainLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onMainLoaded );
		}

		private function onMainLoaded( event:Event ):void
		{
			addChild( mainLoader );
			removeChild( picLoader );
			//
			mainLoader.content.addEventListener( "GENG_DUO", onGengDuo );
			mainLoader.content.addEventListener( "BANNER", onBanner );
			mainLoader.content.addEventListener( "INTERSTITIAL", onInterstitial );
            // 缩放 强拉
            trace(stage.fullScreenWidth+"x"+stage.fullScreenHeight,GameConf.GAME_SWF_W+"x"+GameConf.GAME_SWF_H );
            scaleX = stage.fullScreenWidth/GameConf.GAME_SWF_W ;
            scaleY = stage.fullScreenHeight/GameConf.GAME_SWF_H;
            trace(stage.fullScreenWidth+"x"+stage.fullScreenHeight,GameConf.GAME_SWF_W+"x"+GameConf.GAME_SWF_H );
            trace(scaleX,scaleY,mainLoader.scaleX,mainLoader.scaleY);
		}

		private function onInterstitial( event:Event ):void
		{
            if(!CONFIG::DESKTOP)
			    adsMogo.runInterstitial();
		}

		private function onBanner( event:Event ):void
		{
            if(!CONFIG::DESKTOP)
			    adsMogo.runBanner();
		}

		private function onGengDuo( event:Event ):void
		{
			MyAdManager.showAd( MyAdManager.LEFT_DOWN );
		}


	}
}
