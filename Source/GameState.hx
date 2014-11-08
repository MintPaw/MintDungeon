package ;

import mintDungeon.Generator;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;

class GameState extends Sprite
{
	private var _generator:Generator;

	public function new()
	{
		super();

		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(e:Event):Void
	{
		_generator = new Generator(10);
		_generator.mapSizeInTiles.setTo(50, 50);
		_generator.roomSize.setTo(2, 6);
		_generator.generate();

		var b:Bitmap = _generator.getMapAsBitmap();
		b.scaleX = b.scaleY = 10;
		b.x = stage.stageWidth / 2 - b.width / 2;
		b.y = stage.stageHeight / 2 - b.height / 2;
		addChild(b);
	}
}