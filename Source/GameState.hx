package;

import haxe.Log;
import mintDungeon.Generator;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

class GameState extends Sprite
{
	private var _generator:Generator;
	private var _params:TextField;
	private var _testButton:TextField;

	private var _testStartTime:Int;
	private var _testRunsLeft:Int = 0;

	public function new()
	{
		super();

		addEventListener(Event.ADDED_TO_STAGE, init);
		addEventListener(Event.ENTER_FRAME, update);
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

		_testButton = new TextField();
		_testButton.text = "Test";
		_testButton.autoSize = TextFieldAutoSize.CENTER;
		_testButton.selectable = false;
		_testButton.x = stage.stageWidth - _testButton.textWidth - 5;
		_testButton.y = stage.stageHeight - _testButton.textHeight - 5;
		_testButton.background = true;
		_testButton.backgroundColor = 0xFFFFFF;
		_testButton.addEventListener(MouseEvent.CLICK, testMap);
		addChild(_testButton);
	}

	private function update(e:Event):Void
	{
		if (_testRunsLeft > 0) runTest(1);
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
		if (e.keyCode == 13)
		{
			makeMap();
			showMap();
		}
		if (e.keyCode == Keyboard.BACKQUOTE) showMap();
	}

	private function testMap(e:MouseEvent):Void
	{
		_testStartTime = Lib.getTimer();
		_testRunsLeft = 100;
	}

	private function runTest(n:Int):Void
	{
		for (i in 0...n)
		{
			makeMap();
			showMap();
		}

		_testRunsLeft -= n;

		trace(_testRunsLeft + " left");

		if (_testRunsLeft == 0)
		{
			var totalTime = Lib.getTimer() - _testStartTime;
			Log.clear();
			trace("Test complete, 100 maps took " + Math.round(totalTime / 1000) + " seconds. About " + Math.round(totalTime / 100) + " miliseconds per map.");

			if (totalTime / 100 < 10) trace("An impossibly efficient map.")
			else if (totalTime / 100 < 30) trace("A great map.")
			else if (totalTime / 100 < 50) trace("A good map.")
			else if (totalTime / 100 < 80) trace("A standard map.")
			else if (totalTime / 100 < 100) trace("A bulky map.")
			else if (totalTime / 100 < 500) trace("A heavy map.")
			else if (totalTime / 100 < 1000) trace("An extremely complex map.")
			else trace("Don't use this. . .");
		}
	}
}