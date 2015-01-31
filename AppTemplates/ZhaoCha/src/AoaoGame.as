package
{
	import com.aoaogame.sdk.AnalysisManager;
	import com.aoaogame.sdk.UMAnalyticsManager;
	import com.aoaogame.sdk.adManager.MyAdManager;
	import com.juankpro.ane.localnotif.Notification;
	import com.juankpro.ane.localnotif.NotificationManager;

	import org.mousebomb.Localize;
	import org.mousebomb.ScreenshotHelper;
	import org.mousebomb.SoundMan;
	import org.mousebomb.ZhaoChaConf;
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
    private static const NOTIFICATION_CODE:String = "NOTIFICATION_CODE_001";
    private var notificationManager:NotificationManager;
    public static var adsMogo:AdFactory;


    protected var rootView:Sprite;

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

    private function onStage(event:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onStage);
        start();
        // setTimeout(start, 100);
    }

    protected function start():void
    {
        SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
        rootView = new Sprite();
        this.addChild(rootView);
        ZhaoChaConf.onStage(stage, rootView);
        SoundMan.init();
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyUp);
		if(!CONFIG::DESKTOP)
		{
		        // aoao analysis
		        AnalysisManager.instance.setAnalytics(ZhaoChaConf.AOAO_APP_ID, ZhaoChaConf.ANALYSIS_SO_NAME);
		        // UMAnalytics
		        CONFIG::IOS{
		            UMAnalyticsManager.instance.startWithAppkey(ZhaoChaConf.UMENG_APPID_IOS);
		            UMAnalyticsManager.instance.startSession();
				}
		        CONFIG::ANDROID{
		            UMAnalyticsManager.instance.startSession();
		        }
		        // TODO fixme
	            adsMogo = new AdFactory();
	            adsMogo.runBanner();
		}
		CONFIG::DESKTOP{
			// 桌面 DESKTOP ，，要截图功能
			ScreenshotHelper.init(stage);
		}

        // aoao Ad
        MyAdManager.init(ZhaoChaConf.AOAO_APP_ID, stage);
        // notification
        NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActive);
        notificationTomorrow();
        //
        NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactive);
	}
    private function onDeactive(event:Event):void
    {
        SoundMan.deactive();
    }

    private function onActive(event:Event):void
    {
        SoundMan.active();
        notificationTomorrow();
    }

    // 安返回键＝退出
    private function onKeyUp(event:KeyboardEvent):void
    {
        if (event.keyCode == Keyboard.BACK)
        {
            event.preventDefault();
            NativeApplication.nativeApplication.exit();
        }
    }

    public function notificationTomorrow():void
    {
        if(!CONFIG::DESKTOP)
        {
            //
            if (NotificationManager.isSupported)
            {
                notificationManager = new NotificationManager();
                var notification:Notification = new Notification();
                // 滑动来xx
                notification.actionLabel = Localize.notificationAction;
                // 通知内容
                notification.body = Localize.notificationIntro;
                notification.title = Localize.notificationTitle;
                notification.fireDate = new Date((new Date()).time + (1000 * 60 * 60 * 24));
                notification.numberAnnotation = 1;
                notificationManager.cancel(NOTIFICATION_CODE);
                notificationManager.notifyUser(NOTIFICATION_CODE, notification);
            }
        }
    }
}
}
