/**
 * Created by rhett on 15/6/12.
 */
package YP
{

import YP.MusicModel;

import com.aoaogame.sdk.adManager.MyAdManager;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filesystem.File;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	import org.mousebomb.ui.Shelf;

	public class YPSelect extends Sprite implements IDispose
	{

		public var ui : SelectUI ;

		public var picShelf :Shelf;


		public function YPSelect(  )
		{
			ui = new SelectUI();
			ui.x = (GameConf.VISIBLE_SIZE_W - GameConf.DESIGN_SIZE_W)/2;
			addChild(ui);
//			picShelf = Shelf.transformFromTf(ui.picShelf);

			picShelf = new Shelf();
			//
			if(GameConf.HW_RATE>GameConf.HW_RATE_IPHONE4)
				picShelf.autoConfig(640, GameConf.VISIBLE_SIZE_H - (1136-743),640,145,1,5,YPMp3Li,liVoGlue);
			else if (GameConf.HW_RATE <= GameConf.HW_RATE_IPHONE4)
			{
				picShelf.autoConfig(640, GameConf.VISIBLE_SIZE_H - (1136-743),640,145,1,4,YPMp3Li,liVoGlue);
			}
			picShelf.x=9;picShelf.y=160;

			ui.addChild(picShelf);

			picShelf.setList(MusicModel.getInstance().list);

			ui.prevBtn.addEventListener(MouseEvent.CLICK, onLeftClick );
			ui.nextBtn.addEventListener(MouseEvent.CLICK, onRightClick );
			//
			ui.moreBtn.visible = MyAdManager.showMoreBtn;
			ui.moreBtn.addEventListener(MouseEvent.CLICK, onMoreClick);


		}

		private function liVoGlue( li : YPMp3Li,vo :MusicInfoVO):void
		{
			li.vo  = vo ;
			li.addEventListener(MouseEvent.CLICK, onLiClick);
            li.select = (vo.order == MusicModel.getInstance().curSelectedOrder);
		}
		private function onMoreClick(event : MouseEvent) : void
		{
			MyAdManager.showAd(MyAdManager.RIGHT_TOP);
			SoundMan.playSfx(SoundMan.BTN);

		}

		private function onLiClick( event:MouseEvent ):void
		{
            MusicModel.getInstance().curSelectedOrder = (event.currentTarget as YPMp3Li).vo.order;
			Player.getInstance().play((event.currentTarget as YPMp3Li).vo.mp3File.url);
			Game.instance.replaceScene(new YPListen((event.currentTarget as YPMp3Li).vo));
			SoundMan.playSfx(SoundMan.BTN);

		}

		private function onRightClick( event:MouseEvent ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			picShelf.nextPage();
		}

		private function onLeftClick( event:MouseEvent ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			picShelf.prevPage();
		}

		public function dispose():void
		{
		}
	}
}
