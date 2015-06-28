package
{

	import YP.MusicModel;
	import YP.YPListen;
	import YP.YPSelect;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;

	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	/**
	 * @author rhett
	 */
	public class Game extends AoaoGame
	{
		public static var instance:Game;

		public function Game()
		{
			instance = this;
		}

		override protected function start():void
		{
			super.start();
			//
			var bgMusic:File = File.applicationDirectory.resolvePath( "res/bgm.mp3" );
			if( bgMusic.exists )
			{
				SoundMan.playBgm( bgMusic.url );
			}
			var list:Array = MusicModel.getInstance().grabMusicList();
			if( list.length > 1 )
			{
				_scene = new YPSelect();
			} else
			{
				// 只有一级则直接进内页
				_scene = new YPListen( list[0] , false );

			}
			rootView.addChild( _scene );
		}

		private var _scene:DisplayObject;


		public function replaceScene( scene:Sprite ):void
		{
			(_scene as IDispose).dispose();
			rootView.removeChild( _scene );
			_scene = scene;
			if( scene is IFlyIn )(scene as IFlyIn).flyIn();
			rootView.addChild( scene );
		}

	}
}
