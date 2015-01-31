/**
 * Created by rhett on 14-7-19.
 */
package {
	import org.mousebomb.SoundMan;
	import org.mousebomb.zhaocha.GameContext;

	public class Game extends AoaoGame {
		private var _context : GameContext;

		public function Game() {
			super();
			_context = new GameContext(rootView);
		}

		override protected function start() : void {
			super.start();
			SoundMan.playBgm("bgm.mp3");
		}
	}
}
