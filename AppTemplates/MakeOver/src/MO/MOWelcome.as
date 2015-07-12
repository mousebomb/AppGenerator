/**
 * Created by rhett on 15/7/11.
 */
package MO
{

	import com.aoaogame.sdk.adManager.MyAdManager;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.mousebomb.SoundMan;

	import org.mousebomb.interfaces.IDispose;

	public class MOWelcome extends  Sprite implements IDispose
	{
		public var ui :Welcome = new Welcome();
		public function MOWelcome()
		{
			addChild(ui ) ;
			ui.playBtn.addEventListener(MouseEvent.CLICK, onPlayClick);
			ui.moreBtn.addEventListener(MouseEvent.CLICK, onMoreClick);
			ui.moreBtn.visible=MyAdManager.showMoreBtn;
		}

		private function onMoreClick( event:MouseEvent ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			MyAdManager.showAd(MyAdManager.RIGHT_DOWN);
		}

		private function onPlayClick( event:MouseEvent ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			Game.instance.replaceScene(new MOMovie());
		}

		public function dispose():void
		{
		}
	}
}
