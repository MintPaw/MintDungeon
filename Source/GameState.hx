package ;

import mintDungeon.Generator;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

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
		makeMap();

		stage.addEventListener(KeyboardEvent.KEY_UP, kUp);
	}

	private function makeMap():Void
	{
		_generator = new Generator(10);
		_generator.mapSizeInTiles.setTo(50, 50);
		_generator.roomSize.setTo(2, 6);
		_generator.roomAmount.setTo(5, 10);
		_generator.hallLength.setTo(3, 5);
		_generator.generate();

		var b:Bitmap = _generator.getMapAsBitmap();
		b.scaleX = b.scaleY = 14;
		b.x = stage.stageWidth / 2 - b.width / 2;
		b.y = stage.stageHeight / 2 - b.height / 2;
		addChild(b);
	}

	private function kUp(e:KeyboardEvent):Void
	{
		if (e.keyCode == 32) makeMap();
	}
}