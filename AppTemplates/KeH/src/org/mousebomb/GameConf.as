package org.mousebomb
{
	import org.mousebomb.interactive.MouseDrager;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;
    import flash.desktop.NativeApplication;

	/**
	 * @author Mousebomb
	 */
	public class GameConf
	{

        // 友盟统计－iOS ： 修改引号里的内容!!!!
        public static const UMENG_APPID_IOS : String = "${iosUMeng}";

        // 嗷嗷游戏的id，game54 唯一id，且自动关联嗷嗷后台设置的广告
        public static const AOAO_APP_ID : uint = ${appID};


        // admob广告id iOS		修改引号里的内容!!!!  banner
        public static const ADMOB_iOS_BANNER:String = "${iosAdmobBanner}";
        // admob广告id iOS		修改引号里的内容!!!!  插屏
        public static const ADMOB_iOS_INTERSTITIAL:String = "${iosAdmobInterstitial}";
        // admob android -banner
        public static const ADMOB_ANDROID_BANNER:String = "${androidAdmobBanner}";
        // admob android -插屏
        public static const ADMOB_ANDROID_INTERSTITIAL:String = "${androidAdmobInterstitial}";

        // baidu ios
        public static const BAIDU_IOS:String = "${iosBaiduAd}";
        // baidu android
        public static const BAIDU_ANDROID:String = "${androidBaiduAd}";

        //每N次调用才真正显示插屏
        public static const INTERSTITIAL_AD_LEVEL : uint = ${interstitialAdLevel};

        //  游戏实际尺寸
        public static const GAME_SWF_W:Number = ${gameW};
        public static const GAME_SWF_H:Number = ${gameH};

        // ----------- 要修改的内容结束
        // banner位置 true 下方
        public static const BANNER_POS_V: String = "${bannerPosV}";
        public static const BANNER_POS_H: String = "${bannerPosH}";



        public static const LOCAL_SO_NAME : String = "com.aoaogame.game"+AOAO_APP_ID;
		public static const ANALYSIS_SO_NAME : String = "com.aoaogame.game"+AOAO_APP_ID+".analysis";

		/**
		 * 设计尺寸
		 */
		public static const DESIGN_SIZE_W : Number = 640;
		public static const DESIGN_SIZE_H : Number = 1136;
        /**
         * 参考尺寸
         * iPad
         */
		public static const SIZE_W_IPAD : Number = 768;
		public static const SIZE_H_IPAD : Number = 1024;
		/** 实际尺寸 */
		public static var VISIBLE_SIZE_W : Number = 640.0;
		public static var VISIBLE_SIZE_H : Number = 960.0;
		
		public static var ROOT_SCALE :Number;
		// 宽高比
		public static var HW_RATE:Number;
		public static var HW_RATE_IPHONE4:Number = 3/2;
		
		static public const CN : String = "Cn";
		static public const EN : String = "En";
		// 记录当前是中文环境，还是外文环境
		public static var LANG :String= CN;
		
		

		public static function onStage(s : Stage,root:Sprite) : void
		{
            var realBundleID=NativeApplication.nativeApplication.applicationID;
            if(   "${buneleID}" != realBundleID
                &&
                "air.${buneleID}" != realBundleID
                )
            {
                throw new Error("Fatal Error");
                NativeApplication.nativeApplication.exit(3);
            }
//			trace('AD_H: ' + (AD_H));
			s.align = StageAlign.TOP_LEFT;
			s.scaleMode = StageScaleMode.NO_SCALE;
			
			HW_RATE = s.fullScreenHeight / s.fullScreenWidth;
			var sw : Number = s.fullScreenWidth / DESIGN_SIZE_W ;
			var sh : Number = s.fullScreenHeight / DESIGN_SIZE_H ;
			var scale : Number = sw > sh ? sw : sh;
            if(HW_RATE < HW_RATE_IPHONE4)
            {
                //pad等 尺寸
                sw = s.fullScreenWidth / SIZE_W_IPAD;
                sh = s.fullScreenHeight / SIZE_H_IPAD;
                scale = sw > sh ? sw:sh;
            }else{
                //  左偏
                root.x = (DESIGN_SIZE_W - SIZE_W_IPAD)*scale/2;
			}
            ROOT_SCALE=scale;
			trace(sw,sh,'ROOT_SCALE: ' + (ROOT_SCALE));
			
			VISIBLE_SIZE_W = s.fullScreenWidth/scale;
//			trace('VISIBLE_SIZE_W: ' + (VISIBLE_SIZE_W));
			VISIBLE_SIZE_H = s.fullScreenHeight/scale;
//			trace('VISIBLE_SIZE_H: ' + (VISIBLE_SIZE_H));
			// 策略： 根据比例确保显示 等比例缩放
			root.scaleX = root.scaleY = scale;
			//
			trace('Capabilities.OS: ' + (Capabilities.os));
			trace('Capabilities.language: ' + (Capabilities.language));
			if (Capabilities.language == "zh-CN"
			|| Capabilities.language == "zh-TW"
			) {
				LANG = CN;
			} else {
				LANG = EN;
			}
			//
			MouseDrager.thresholdMoveDistance =   4*Capabilities.screenDPI / 72 * MouseDrager.thresholdMoveDistance;
            //
            new DebugHelper(s);
            DebugHelper.log("APPID:"+AOAO_APP_ID + " INTERSTITIAL_AD_LEVEL="+INTERSTITIAL_AD_LEVEL);
		}
	}
}