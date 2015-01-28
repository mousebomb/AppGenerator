package
{

	import com.greensock.TweenLite;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	import flash.geom.Rectangle;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;

	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.AssetManager;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import td.util.CsvManager;

	import td.StarlingRoot;
	import td.util.StaticDataModel;
	import td.battlefield.model.BattleFieldModel;

	[SWF(width="640", height="1136", frameRate="60")]
	public class TDGame extends AoaoGame
	{

		public static var instance : TDGame;


			//资源管理器
		public static var assetsMan :AssetManager = new AssetManager();


		protected var starling : Starling;
		public function TDGame()
		{
			super();
			instance = this;
		}
		[Embed(source="../assets/Default-568h@2x.png")]
		public static const Logo:Class;
		private var logoScreen:Sprite = new Sprite();


		override protected function start():void
		{

			super.start();

			SoundMan.playBgm("lobby.mp3");
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

			logoScreen.addChild( new Logo() ) ;
			logoScreen.width = stage.fullScreenWidth;
			logoScreen.height = stage.fullScreenHeight;
			addChild(logoScreen);


			// 初始化 starling
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;

			var viewPort : Rectangle = new Rectangle(0,0,stage.fullScreenWidth,stage.fullScreenHeight);
			starling = new Starling(StarlingRoot, stage, viewPort);
			starling.addEventListener(Event.ROOT_CREATED, starlingRootCreated);
			starling.stage.color = 0;
//			CONFIG::DEBUG
//			{
//				starling.showStatsAt(HAlign.LEFT,VAlign.BOTTOM);
//			}
			starling.start();
		}

		private function loaded():void
		{
			StaticDataModel.getInstance().parseCsvConfigs();
			TweenLite.to(logoScreen,0.5,{alpha:0, onComplete:
					function():void
					{
						removeChild(logoScreen);
						// ENTRY  :
						(starling.root as StarlingRoot).presentLobby();
//						(starling.root as StarlingRoot).prepareBattle(1);
					}
			});
		}
		public static var assetsFolder : File = File.applicationDirectory.resolvePath("res/");

		private function starlingRootCreated(event : Event) : void
		{
			GameConf.onStage(stage, starling);
			stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);

			assetsMan.verbose = CONFIG::DEBUG;
			// 加载基础必须资源
			assetsMan.enqueue(assetsFolder.resolvePath("sfx/"));
			assetsMan.enqueue(assetsFolder.resolvePath("spritesheet/"));
			assetsMan.enqueue(assetsFolder.resolvePath("font/"));
			assetsMan.enqueue(assetsFolder.resolvePath("bg/"));
			assetsMan.loadQueue( function (ratio :Number):void{if(ratio ==1.0)
			{
				var staticDataModel :StaticDataModel = StaticDataModel.getInstance();
				staticDataModel.loadCSVs(loaded);
			}});

		}

		private function stage_resizeHandler(event : Event) : void
		{
			trace(stage.fullScreenSourceRect);
		}

		//


	}
}