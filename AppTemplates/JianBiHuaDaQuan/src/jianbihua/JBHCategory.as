package jianbihua {
	import com.aoaogame.sdk.adManager.MyAdManager;

import jianbihua.JBHLevel;

import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	/**
	 * @author rhett
	 */
	public class JBHCategory extends Sprite  implements IDispose,IFlyIn {
		private var ui : UILevel;
		private static var lastPage : int = 0;

		public function JBHCategory() {
			ui = new UILevel();
			addChild(ui);

			shelf = new Shelf();
			var rect : Rectangle = new Rectangle(15, 138, 610, 720);
			shelf.x = 100;
			shelf.y = 250;

			//
			var pageBtnH : Number = ui.nextBtn.height;
			var pageBtnOffsetY : Number = pageBtnH / 2;
			var shelfH : Number = GameConf.VISIBLE_SIZE_H_MINUS_AD - (shelf.y-102) - pageBtnH - 50;
			ui.prevBtn.y = ui.nextBtn.y = GameConf.VISIBLE_SIZE_H - 120 - pageBtnOffsetY;
			//
			var rows :int = int(shelfH / 206 );
			shelf.autoConfig(620, shelfH, 181, 206, 3, rows, CategoryBtn, onAddLi);

			ui.addChild(shelf);
            //
            var levelModel : LevelModel = LevelModel.getInstance();
            levelModel.initAllLevels();
            var list :Array = [];
            for(var i : int = 1;i<=levelModel.categorysNum;i++ )
            {
                list.push(i);
            }

            trace("category shelf setlist" , list);
			shelf.setList(list);
			if(lastPage>0) shelf.showPage(lastPage);

			if (levelModel.categorysNum > rows * 3) {
				//
				ui.prevBtn.addEventListener(MouseEvent.CLICK, onPrevBtn);
				ui.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtn);
			} else {
				ui.removeChild(ui.prevBtn);
				ui.removeChild(ui.nextBtn);
			}
			//
			ui.moreBtn.visible = MyAdManager.showMoreBtn;
			ui.moreBtn.addEventListener(MouseEvent.CLICK, onMoreClick);
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
		}

		private function onMoreClick(event : MouseEvent) : void {
			MyAdManager.showAd(MyAdManager.RIGHT_TOP);
		}

		private function onBackClick(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			JianBiHua.instance.replaceScene(new JBHWelcome());
		}

		private var shelf : Shelf;

		private function onNextBtn(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			shelf.nextPage();
			lastPage = shelf.curPage;
		}

		private function onPrevBtn(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			shelf.prevPage();
			lastPage = shelf.curPage;
		}

		private function onAddLi(li : CategoryBtn, level : int) : void {
			li.titles.gotoAndStop(level);
			li.mouseChildren = false;
			li.addEventListener(MouseEvent.MOUSE_UP, onLiUp);
			li.category = level;
			li.categorys.gotoAndStop(level);
            trace("onAddLi",li,level);
		}

		private function onLiUp(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
            var li : CategoryBtn = event.currentTarget as CategoryBtn;
            LevelModel.getInstance().category = li.category;
			JianBiHua.instance.replaceScene(new JBHLevel());
		}

		public function dispose() : void {
		}

		public function flyIn() : void {
		}
	}
}
