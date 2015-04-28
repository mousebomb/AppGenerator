package org.mousebomb.adservice {
	import so.cuo.platform.baidu.BaiDu;
	import so.cuo.platform.baidu.BaiDuAdEvent;
	import so.cuo.platform.baidu.RelationPosition;

	import com.aoaogame.sdk.GlobalConfig;
	import com.milkmangames.nativeextensions.AdMob;
	import com.milkmangames.nativeextensions.AdMobAdType;
	import com.milkmangames.nativeextensions.AdMobAlignment;
	import com.milkmangames.nativeextensions.events.AdMobErrorEvent;
	import com.milkmangames.nativeextensions.events.AdMobEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.Capabilities;

import org.mousebomb.DebugHelper;
	/**
	 * 广告接口管理类，会根据后台数据，来请求具体的广告
	 * @author hanson
	 */
	public class AdManager extends EventDispatcher {
		// ===========banner广告的位置===========
		public static const LEFT : String = AdMobAlignment.LEFT;
		public static const RIGHT : String = AdMobAlignment.RIGHT;
		public static const CENTER : String = AdMobAlignment.CENTER;
		public static const TOP : String = AdMobAlignment.TOP;
		public static const BOTTOM : String = AdMobAlignment.BOTTOM;
		// ===========广告类型===========
		// 适用于手机的小型条状banner
		public static const BANNER : String = AdMobAdType.BANNER;
		// 适用于PAD的中型条状banner
		public static const IAB_BANNER : String = AdMobAdType.IAB_BANNER;
		// 适用于PAD的大型条状banner
		public static const IAB_LEADERBOARD : String = AdMobAdType.IAB_LEADERBOARD;
		// 方形banner
		public static const IAB_MRECT : String = AdMobAdType.IAB_MRECT;
		// 永远布满全屏宽度的banner：为了让百度和谷歌广告更好的兼容，取消这个admob的这个模式，同时百度的 IAB_MRECT_BIG（大方块儿）模式也取消
		// public static const SMART_BANNER : String = AdMobAdType.SMART_BANNER;
		// ===========自定义事件===========
		// 从官网获取广告数据成功
		public static const GET_DATA_SUCCESS : String = "AD_MANAGER_GET_DATA_SUCCESS";
		// 从官网获取广告数据失败
		public static const GET_DATA_FAIL : String = "AD_MANAGER_GET_DATA_FAIL";
		// 从广告平台获取广告失败
		public static const GET_AD_FAIL : String = "AD_MANAGER_GET_AD_FAIL";
		// 单例
		private static var _instance : AdManager;
		// 应用ID
		private var _appID : int = -1;
		// 默认广告ID
		private var _admob_ios_banner_id : String = "";
		private var _admob_android_banner_id : String = "";
		private var _admob_ios_interstitial_id : String = "";
		private var _admob_android_interstitial_id : String = "";
		private var _baidu_ios_id : String = "";
		private var _baidu_android_id : String = "";
		// 系统环境
		private var os : int;
		private const IPHONE : int = 0;
		private const IPAD : int = 1;
		private const ANDROID : int = 2;
		private const WINDOWS : int = 3;
		// 语言环境
		private var language : int;
		private const CN : int = 0;
		private const EN : int = 1;
		private var _request : URLRequest;
		private var _urlLoader : URLLoader = new URLLoader();
		// errorCode为0，表示没有错误，可以正常解析广告
		private var _errorCode : int = -1;
		private var _adObjArr : Array = [];
		private var _adAdmobObj : Object;
		private var _adBaiduObj : Object;
		// 判断全屏广告是否缓存过，在展示全屏广告的时候，将会根据这个判断，只展示已经缓存成功的全屏广告。默认admob是缓存的，也就是说如果游戏代码有问题，忘记缓存，就会只展示admob广告了！！
		private var _admobIsCache : Boolean = true;
		private var _baiduIsCache : Boolean = false;
		// 是否自动缓存全屏
		static public var autoCache : Boolean = true;

		public function AdManager() {
			if (Capabilities.os.indexOf("iPad") != -1) {
				os = IPAD;
			} else if (Capabilities.os.indexOf("iPhone") != -1) {
				os = IPHONE;
			} else if (Capabilities.os.indexOf("Windows") != -1) {
				os = WINDOWS;
			} else {
				os = ANDROID;
			}

			if (Capabilities.language == "zh-CN") {
				language = CN;
			} else {
				language = EN;
			}
		}

		/**
		 * 构造一个单例
		 */
		public static function get instance() : AdManager {
			if (_instance != null) {
				return _instance;
			} else {
				_instance = new AdManager();
				return _instance;
			}
		}

		/**
		 * 初始化广告
		 * @param app_id 应用ID。
		 */
		public function init(app_id : int, baidu_ios_id : String, baidu_android_id : String, admob_ios_banner_id : String, admob_ios_interstitial_id : String, admob_android_banner_id : String, admob_android_interstitial_id : String) : void {
			_appID = app_id;
			_baidu_ios_id = baidu_ios_id;
			_baidu_android_id = baidu_android_id;
			_admob_ios_banner_id = admob_ios_banner_id;
			_admob_ios_interstitial_id = admob_ios_interstitial_id;
			_admob_android_banner_id = admob_android_banner_id;
			_admob_android_interstitial_id = admob_android_interstitial_id;

			// 初始化广告
			if (os == IPAD || os == IPHONE) {
				// 如果是苹果系统，默认就显示谷歌广告
				if (AdMob.isSupported) {
					AdMob.init(_admob_ios_banner_id);
					AdMob.addEventListener(AdMobErrorEvent.FAILED_TO_RECEIVE_AD, onGoogleAdErrorEvent);
					AdMob.addEventListener(AdMobEvent.RECEIVED_AD, onGoogleAdEvent);
					AdMob.addEventListener(AdMobEvent.SCREEN_PRESENTED, onGoogleAdEvent);
					AdMob.addEventListener(AdMobEvent.SCREEN_DISMISSED, onInterstitialDismissEvent);
					AdMob.addEventListener(AdMobEvent.LEAVE_APPLICATION, onGoogleAdEvent);
				}
			} else if (os == ANDROID) {
				if (language == EN) {
					if (AdMob.isSupported) {
						AdMob.init(_admob_android_banner_id);
						AdMob.addEventListener(AdMobErrorEvent.FAILED_TO_RECEIVE_AD, onGoogleAdErrorEvent);
						AdMob.addEventListener(AdMobEvent.RECEIVED_AD, onGoogleAdEvent);
						AdMob.addEventListener(AdMobEvent.SCREEN_PRESENTED, onGoogleAdEvent);
						AdMob.addEventListener(AdMobEvent.SCREEN_DISMISSED, onInterstitialDismissEvent);
						AdMob.addEventListener(AdMobEvent.LEAVE_APPLICATION, onGoogleAdEvent);
					}
				} else if (language == CN) {
					// BaiDu.getInstance().setKeys("debug", "debug");
					trace('_baidu_android_id: ' + (_baidu_android_id));
                    DebugHelper.log("BaiduSetKeys:"+_baidu_android_id);
					BaiDu.getInstance().setKeys(_baidu_android_id, _baidu_android_id);
					BaiDu.getInstance().addEventListener(BaiDuAdEvent.onBannerLeaveApplication, onBaiduAdEvent);
					BaiDu.getInstance().addEventListener(BaiDuAdEvent.onInterstitialReceive, onBaiduAdEvent);
					BaiDu.getInstance().addEventListener(BaiDuAdEvent.onInterstitialFailedReceive, onBaiduInterstitialAdErrorEvent);
					BaiDu.getInstance().addEventListener(BaiDuAdEvent.onBannerFailedReceive, onBaiduBannerAdErrorEvent);
					BaiDu.getInstance().addEventListener(BaiDuAdEvent.onInterstitialDismiss, onInterstitialDismissEvent);
				}
			}

			// 加载数据
			_request = new URLRequest(GlobalConfig.GET_AD_DATA_PHP_URL + "?i=" + _appID + "&o=" + Capabilities.os + "&l=" + Capabilities.language);
			_request.method = URLRequestMethod.GET;
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.load(_request);
			_urlLoader.addEventListener(Event.COMPLETE, urlLoaded);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoadError);
		}

		private function onInterstitialDismissEvent(event : Event) : void {
			// 每当一个全屏关闭的时候，就自动缓存下一个全屏
			trace("onInterstitialDismissEvent");
			if (autoCache) cacheInterstitial();
		}

		private function onBaiduAdEvent(event : BaiDuAdEvent) : void {
			trace(event);
		}

		private function onBaiduBannerAdErrorEvent(event : BaiDuAdEvent) : void {
			DebugHelper.log("获得baidu banner广告失败：" + event);
			dispatchEvent(new Event(GET_AD_FAIL));
		}

		private function onBaiduInterstitialAdErrorEvent(event : BaiDuAdEvent) : void {
			DebugHelper.log("获得baidu全屏广告失败：" + event);
			dispatchEvent(new Event(GET_AD_FAIL));
		}

		private function onGoogleAdEvent(event : Event) : void {
			trace(event);
		}

		private function onGoogleAdErrorEvent(event : AdMobErrorEvent) : void {
            DebugHelper.log("获得google广告失败：" + event.text);
			dispatchEvent(new Event(GET_AD_FAIL));
		}

		private function urlLoadError(event : IOErrorEvent) : void {
			DebugHelper.log("获得ADCONFIG失败：" + event.text);
			dispatchEvent(new Event(GET_DATA_FAIL));
		}

		private function urlLoaded(event : Event) : void {
            DebugHelper.log('ADCONFIG.data: ' + (_urlLoader.data));
			var res : Object = JSON.parse(_urlLoader.data);
			_errorCode = res.errorCode;
			if (_errorCode == 0) {
				_adObjArr = res.result;
				// 根据获得的后端数据，重置各个广告的KEY
				if (String(_adObjArr[0].adtype).toUpperCase() == "ADMOB") {
					_adAdmobObj = _adObjArr[0];
					_adBaiduObj = _adObjArr[1];
				} else {
					_adAdmobObj = _adObjArr[1];
					_adBaiduObj = _adObjArr[0];
				}

				if ((os == ANDROID && language == CN) || os == WINDOWS) {
					AdMob.init(_adAdmobObj.bannerKey);
				} else {
					AdMob.setBannerAdUnitID(_adAdmobObj.bannerKey);
				}

				DebugHelper.log('ADMOB.bannerKey: ' + (_adAdmobObj.bannerKey));
				DebugHelper.log('BaiduSetKeys: ' + (_adBaiduObj.bannerKey) +"," + _adBaiduObj.interstitialKey);
                BaiDu.getInstance().setKeys(_adBaiduObj.bannerKey, _adBaiduObj.interstitialKey);
				BaiDu.getInstance().addEventListener(BaiDuAdEvent.onBannerLeaveApplication, onBaiduAdEvent);
				BaiDu.getInstance().addEventListener(BaiDuAdEvent.onInterstitialReceive, onBaiduAdEvent);
				BaiDu.getInstance().addEventListener(BaiDuAdEvent.onInterstitialFailedReceive, onBaiduInterstitialAdErrorEvent);
				BaiDu.getInstance().addEventListener(BaiDuAdEvent.onBannerFailedReceive, onBaiduBannerAdErrorEvent);
				BaiDu.getInstance().addEventListener(BaiDuAdEvent.onInterstitialDismiss, onInterstitialDismissEvent);

				dispatchEvent(new Event(GET_DATA_SUCCESS));
			} else {
				dispatchEvent(new Event(GET_DATA_FAIL));
			}
			DebugHelper.log('_errorCode: ' + (_errorCode));
			if (_adObjArr[0] != null) DebugHelper.log(_adObjArr[0].adtype+" , "+ _adObjArr[0].bannerPercent);
			if (_adObjArr[1] != null) DebugHelper.log(_adObjArr[1].adtype+" , "+ _adObjArr[1].bannerPercent);
		}

		/**
		 * 显示banner广告
		 * @param bannerType 设置要在pad上显示的banner的尺寸类型
		 * @param horizontal 水平位置
		 * @param vertical 垂直位置
		 */
		public function showBanner(bannerType : String = IAB_LEADERBOARD, horizontal : String = CENTER, vertical : String = TOP, offsetX : int = 0, offsetY : int = 0) : void {
			if (_errorCode == 0) {
				// =========正常获得广告数据，目前因为只有百度和谷歌，所以直接进行ifelse判断，暂时不做循环智能判断=========
//				DebugHelper.log('ADMOB.bannerPercent == 0: ' + (_adAdmobObj.bannerPercent == 0));
//				DebugHelper.log('ADMOB.bannerPercent: ' + (_adAdmobObj.bannerPercent));
				if (_adAdmobObj.bannerPercent == 0) {
					// 如果谷歌广告的百分比为0，就显示百度广告
					AdMob.destroyAd();
					showBaiduBanner(bannerType, horizontal, vertical);
				} else if (_adBaiduObj.bannerPercent == 0) {
					// 如果百度广告的百分比为0，就显示谷歌广告
					BaiDu.getInstance().hideBanner();
					showAdmobBanner(bannerType, horizontal, vertical, offsetX, offsetY);
				} else {
					// 如果双方都不为0，就按比例随机展示广告
					if (_adAdmobObj.bannerPercent >= _adBaiduObj.bannerPercent) {
//						trace("_adAdmobObj.bannerPercent:" + _adAdmobObj.bannerPercent);
						if (Math.random() * 100 < _adAdmobObj.bannerPercent) {
							if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().hideBanner();
							showAdmobBanner(bannerType, horizontal, vertical, offsetX, offsetY);
						} else {
							AdMob.destroyAd();
							showBaiduBanner(bannerType, horizontal, vertical);
						}
					} else {
						trace("BAIDU.bannerPercent:" + _adBaiduObj.bannerPercent);
						var random : Number = Math.random() * 100;
						trace('random: ' + (random));
						if (random < _adBaiduObj.bannerPercent) {
							trace("showBaiduBanner");
							AdMob.destroyAd();
							showBaiduBanner(bannerType, horizontal, vertical);
						} else {
							trace("showAdmobBanner");
							if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().hideBanner();
							showAdmobBanner(bannerType, horizontal, vertical, offsetX, offsetY);
						}
					}
				}
			} else {
				// =========如果没有获得广告数据，就用默认广告ID显示=========
				if (language == CN && os == ANDROID) {
					// 中文安卓系统默认显示百度广告
					try {
						if (AdMob.isSupported) AdMob.destroyAd();
					} catch(error : Error) {
					}
					showBaiduBanner(bannerType, horizontal, vertical);
				} else {
					// 其他系统默认显示谷歌广告
					if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().hideBanner();
					showAdmobBanner(bannerType, horizontal, vertical, offsetX, offsetY);
				}
			}
		}

		// 显示百度banner广告
		private function showBaiduBanner(bannerType : String = IAB_LEADERBOARD, horizontal : String = CENTER, vertical : String = TOP) : void {
			if (BaiDu.getInstance().supportDevice) {
				if (os != IPAD) bannerType = BANNER;
				if (vertical == TOP) {
					BaiDu.getInstance().showBanner(BaiDu[bannerType], RelationPosition["TOP_" + horizontal]);
				} else if (vertical == CENTER) {
					BaiDu.getInstance().showBanner(BaiDu[bannerType], RelationPosition["MIDDLE_" + horizontal]);
				} else if (vertical == BOTTOM) {
					BaiDu.getInstance().showBanner(BaiDu[bannerType], RelationPosition["BOTTOM_" + horizontal]);
				}
			}
		}

		// 显示谷歌banner广告
		private function showAdmobBanner(bannerType : String = IAB_LEADERBOARD, horizontal : String = CENTER, vertical : String = TOP, offsetX : int = 0, offsetY : int = 0) : void {
			if (AdMob.isSupported) {
				// IAB_LEADERBOARD 模式在除了 IPAD 上的其他设备上都不能正常运行，所以要转换成IAB_BANNER。
				if (os != IPAD && (bannerType == IAB_LEADERBOARD || bannerType == IAB_BANNER)) {
					trace('bannerType: ' + (bannerType));
					AdMob.showAd(BANNER, horizontal, vertical, offsetX, offsetY);
				} else {
					trace('bannerType2: ' + (bannerType));
					AdMob.showAd(bannerType, horizontal, vertical, offsetX, offsetY);
				}
			}
		}

		/**
		 * 隐藏banner广告
		 */
		public function hideBanner() : void {
			try {
				if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().hideBanner();
				if (AdMob.isSupported) AdMob.destroyAd();
			} catch(error : Error) {
			}
		}

		/**
		 * 缓存interstitial广告
		 */
		public function cacheInterstitial() : void {
			if (_errorCode == 0) {
				if (_adAdmobObj.interstitialPercent == 0) {
					// 如果谷歌广告的百分比为0，就显示百度广告
					_baiduIsCache = true;
					_admobIsCache = false;
					if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().cacheInterstitial();
				} else if (_adBaiduObj.interstitialPercent == 0) {
					// 如果百度广告的百分比为0，就显示谷歌广告
					_baiduIsCache = false;
					_admobIsCache = true;
					if (AdMob.isSupported) AdMob.loadInterstitial(_adAdmobObj.interstitialKey, false);
				} else {
					// 如果双方都不为0，就按比例随机展示广告
					if (_adAdmobObj.interstitialPercent >= _adBaiduObj.interstitialPercent) {
						if (Math.random() * 100 < _adAdmobObj.interstitialPercent) {
							_baiduIsCache = false;
							_admobIsCache = true;
							if (AdMob.isSupported) AdMob.loadInterstitial(_adAdmobObj.interstitialKey, false);
						} else {
							_baiduIsCache = true;
							_admobIsCache = false;
							if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().cacheInterstitial();
						}
					} else {
						if (Math.random() * 100 < _adBaiduObj.bannerPercent) {
							_baiduIsCache = true;
							_admobIsCache = false;
							trace("cacheBaiduFull");
							if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().cacheInterstitial();
						} else {
							trace("cacheAdMobFull");
							_baiduIsCache = false;
							_admobIsCache = true;
							if (AdMob.isSupported) AdMob.loadInterstitial(_adAdmobObj.interstitialKey, false);
						}
					}
				}
			} else {
				// =========如果没有获得广告数据，就用默认广告ID显示=========
				if (language == CN && os == ANDROID) {
					// 中文安卓系统默认显示百度广告
					_baiduIsCache = true;
					_admobIsCache = false;
					if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().cacheInterstitial();
				} else {
					// 其他系统默认显示谷歌广告
					_baiduIsCache = false;
					_admobIsCache = true;
					if (os == ANDROID) {
						if (AdMob.isSupported) AdMob.loadInterstitial(_admob_android_interstitial_id, false);
					} else {
						if (AdMob.isSupported) AdMob.loadInterstitial(_admob_ios_interstitial_id, false);
					}
				}
			}
		}

		/**
		 * 显示interstitial广告
		 */
		public function showInterstitial() : void {
			if (os != WINDOWS) {
				if (_admobIsCache) {
					if (AdMob.isInterstitialReady()) AdMob.showPendingInterstitial();
				} else {
					if (BaiDu.getInstance().supportDevice) BaiDu.getInstance().showInterstitial();
				}
			}
		}
	}
}
