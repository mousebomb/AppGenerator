/**
 * Created by rhett on 15/6/12.
 */
package YP
{

	import com.aoaogame.sdk.adManager.MyAdManager;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;

	import flash.display.Loader;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.filesystem.File;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;

	import org.mousebomb.interfaces.IDispose;

	public class YPListen extends Sprite implements IDispose
	{
		private var ui:ListenUI;
		/** 当前页 0开始 */
		private var curPage:int = 0;
		private var _vo:MusicInfoVO;

		public function YPListen( vo:MusicInfoVO ,showBackBtn:Boolean=true )
		{
			super();
			_vo = vo;
			ui = new ListenUI();
			ui.x = (GameConf.VISIBLE_SIZE_W - GameConf.DESIGN_SIZE_W) / 2;
			addChild( ui );
			ui.backBtn.visible = showBackBtn;
			ui.backBtn.addEventListener( MouseEvent.CLICK, onBackClick );
			ui.restartBtn.addEventListener( MouseEvent.CLICK, onRestartClick );
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			//
			loadPage( 0 );

			if( !CONFIG::DESKTOP )
			{
				AoaoGame.ad.runBanner();
			}
		}


		private function onRestartClick( event:MouseEvent ):void
		{
			Player.getInstance().reset();
			SoundMan.playSfx( SoundMan.BTN );
		}

		private function onBackClick( event:MouseEvent ):void
		{
			if( !CONFIG::DESKTOP )
			{
				AoaoGame.ad.runInterstitial();
			}
			Game.instance.replaceScene( new YPSelect() );
			SoundMan.playSfx( SoundMan.BTN );
		}


		/* ------------------- # PAGE # ---------------- */

		private var imgLoader:Loader;

		public function loadPage( page:int ):void
		{

			if(_vo.pages.length> page  && page >-1)
			{
				Player.getInstance().stop();
				ui.restartBtn.visible =false;
				if( imgLoader != null )
				{
					// 先移除
					disposeCurLoader(page>curPage);
				}
				imgLoader = new Loader();
				var ctx :LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain)
//				ctx.allowCodeImport = true;
				imgLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImgLoaded );
				var pageInf:PageInfoVO = _vo.pages[page];
				imgLoader.load( new URLRequest( pageInf.imgFile.url ) ,ctx );
				curPage = page;

			}
		}

		private function disposeCurLoader(isLeft :Boolean = false):void
		{
			TweenMax.to( imgLoader,.4,{x:isLeft?-768:768 ,onComplete:loaderRemComp,onCompleteParams:[imgLoader]});
		}
		private function loaderRemComp(l :Loader):void
		{
			l.unloadAndStop(true);
			if(l.parent) l.parent.removeChild(l);
		}

		private function onImgLoaded( event:Event ):void
		{
			imgLoader.mouseChildren = false;
			imgLoader.mouseEnabled = false;
			imgLoader.width = GameConf.VISIBLE_SIZE_W;
			imgLoader.height = GameConf.VISIBLE_SIZE_H_MINUS_AD - 134;
			imgLoader.y = 134;
			addChild( imgLoader );
			var pageInf:PageInfoVO = _vo.pages[curPage];
			if(pageInf.mp3File!=null)
			{
				ui.restartBtn.visible =true;
				Player.getInstance().play(pageInf.mp3File.url);
			}

		}


		public function dispose():void
		{
			Player.getInstance().stop();
		}


		//* ------------------- # touch 翻页 # ---------------- */

		private function onMouseDown( event:MouseEvent ):void
		{
			touchBeginX = event.stageX;
		}

		private var touchBeginX:Number;

		private function onMouseUp( event:MouseEvent ):void
		{
			if(event.stageY<134) return;
			if( event.stageX < touchBeginX -HOLDSHELD )
			{
				// 左划  nextPage
				loadPage(curPage+1);
			} else if(event.stageX > touchBeginX+HOLDSHELD)
			{
				// 右划 prevPage
				loadPage(curPage-1);
			}else{
				// 点击
				if(event.stageX  > GameConf.VISIBLE_SIZE_W/2)
				{
					loadPage(curPage+1);
				}else
				{
					loadPage(curPage-1);
				}
			}
		}

		public static const HOLDSHELD:uint = Capabilities.screenDPI;
	}
}
