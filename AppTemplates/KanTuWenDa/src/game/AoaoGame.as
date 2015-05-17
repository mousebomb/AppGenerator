package game {
	import com.aoaogame.sdk.AnalysisManager;
	import com.aoaogame.sdk.UMAnalyticsManager;
	import com.aoaogame.sdk.adManager.MyAdManager;
	import org.mousebomb.adservice.NotificationPush;

	import org.mousebomb.GameConf;
	import org.mousebomb.Localize;
	import org.mousebomb.ScreenshotHelper;
	import org.mousebomb.SoundMan;
	import org.mousebomb.adservice.AdFactory;

	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	import flash.ui.Keyboard;

	/**
	 * @author Mousebomb
	 */
	public class AoaoGame extends Sprite
	{

		public static var ad : AdFactory;

		public function AoaoGame()
		{
			if (stage == null)
			{
				addEventListener(Event.ADDED_TO_STAGE, onStage);
			}
			else
			{
				start();
				// setTimeout(start, 100);
			}
		}

		private function onStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			start();
			// setTimeout(start, 100);
		}

		protected function start() : void
		{
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			GameConf.onStage(stage, this);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyUp);

			if(!CONFIG::DEBUG)
			{
				if(CONFIG::ANDROID || CONFIG::IOS)
				{
			        // aoao analysis
			        AnalysisManager.instance.setAnalytics(GameConf.AOAO_APP_ID, GameConf.ANALYSIS_SO_NAME);
			        // UMAnalytics
			        CONFIG::IOS{
			            UMAnalyticsManager.instance.startWithAppkey(GameConf.UMENG_APPID_IOS);
			            UMAnalyticsManager.instance.startSession();
					}
			        CONFIG::ANDROID{
			            UMAnalyticsManager.instance.startSession();
			        }
			        // TODO fixme
		            ad = new AdFactory();
				}
			}
			CONFIG::DEBUG{
				// 桌面 debug ，，要截图功能
				ScreenshotHelper.init(stage);
			}

			
			// aoao Ad
			MyAdManager.init(GameConf.AOAO_APP_ID, stage);
			// notification
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActive);
			notificationTomorrow();
			//
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactive);
		}

		private function onDeactive(event : Event) : void
		{
			SoundMan.deactive();
		}

		private function onActive(event : Event) : void
		{
			SoundMan.active();
			notificationTomorrow();
		}

		// 安返回键＝退出
		private function onKeyUp(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.BACK)
			{
				event.preventDefault();
				NativeApplication.nativeApplication.exit();
			}
		}

		public function notificationTomorrow() : void
		{
            if(CONFIG::ANDROID)
            {
                NotificationPush.notifyTomorrow();
            }
		}
	}
}
