package;

import mintDungeon.Generator;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

class GameState extends Sprite
{
	private var _generator:Generator;
	private var _params:TextField;

	public function new()
	{
		super();

		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(e:Event):Void
	{
		_params = new TextField();
		_params.type = TextFieldType.INPUT;
		_params.width = stage.stageWidth;
		_params.height = 20;
		_params.y = stage.stageHeight - _params.height;
		_params.text = "mapSize|50|50|roomSize|3|6|roomAmount|5|10|hallLength|5|10|doorPercentage|20|50";
		addChild(_params);

		_params.addEventListener(KeyboardEvent.KEY_UP, kUp);
	}

	private function makeMap():Void
	{
		var paramStrings:Array<String> = _params.text.split("|");
		var params:Array<Float> = [];
		for (i in 0...paramStrings.length) if (i % 3 != 0) params.push(Std.parseFloat(paramStrings[i]));

		_generator = new Generator(10);
		_generator.mapSizeInTiles.setTo(params[0], params[1]);
		_generator.roomSize.setTo(params[2], params[3]);
		_generator.roomAmount.setTo(params[4], params[5]);
		_generator.hallLength.setTo(params[6], params[7]);
		_generator.doorPercentage.setTo(params[8], params[9]);
		_generator.generate();

		showMap();
	}

	private function showMap():Void
	{
		var b:Bitmap = _generator.getMapAsBitmap();
		addChild(b);

		b.scaleX = b.scaleY = 100;
		while(b.width > stage.stageWidth - 100 || b.height > stage.stageHeight - 100)
		{
			b.scaleX -= 1;
			b.scaleY -= 1;
		}

		b.x = stage.stageWidth / 2 - b.width / 2;
		b.y = stage.stageHeight / 2 - b.height / 2;
	}

	private function kUp(e:KeyboardEvent):Void
	{
		if (e.keyCode == 13) makeMap();
		if (e.keyCode == Keyboard.BACKQUOTE) showMap();
	}
}