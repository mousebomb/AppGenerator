package jianbihua
{
	import org.mousebomb.GameConf;

import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;
import flash.utils.Dictionary;
	import flash.display.MovieClip;
	import flash.net.SharedObject;
	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2014年8月24日
	 */
	public class LevelModel extends Object
	{
		private static var _instance : LevelModel;

		public static function getInstance() : LevelModel
		{
			if (_instance == null)
			{
				_instance = new LevelModel(new SingletonEnforcer());
			}
			return _instance;
		}

		public function LevelModel(s : SingletonEnforcer)
		{
		}

        //  当前分类
        public var category : int ;

/**
 * 当前关卡 PicXXXX
 */
		public var level : int;

		/**
		 * 所有关卡
         *  category => levels : Vector.<int>
		 */
        public var categorys:Dictionary = new Dictionary();
        public var categorysNum:int =0;

        private var isInited :Boolean = false;

		public function initAllLevels() : void
		{
            if(isInited) return ;
            isInited = true;

            // category

            var categorySample :CategoryBtn = new CategoryBtn();
            categorysNum = categorySample.categorys.totalFrames;
            for(var i : int = 1;i<=categorysNum;i++ )
            {
                // 每个category 若干pic category * 1000 + picid
var picList :Vector.<int> = new Vector.<int>();
                var j: int = i*1000;
                while(true)
                {
                    var hasClass :Boolean = ApplicationDomain.currentDomain.hasDefinition("Pic" + (++j));
                    if(!hasClass )  break;
                    else picList.push(j);
                }
                trace("category"+i+" Pic量=" , j);

                categorys[i] = picList;
            }


		}

	}
}

class SingletonEnforcer
{
}