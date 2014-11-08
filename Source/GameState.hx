package ;

import flixel.FlxG;
import flixel.FlxState;
import mintDungeon.MintDungeon;
import openfl.display.Bitmap;

class GameState extends FlxState
{
	private var _generator:Generator;

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xFFFFFF;

		_generator = new Generator();
		_generator.mapSizeInTiles.setTo(50, 50);
		_generator.generate();

		var b:Bitmap = _generator.getMapAsBitmap();
		FlxG.stage.addChild(b);

		super.create();
	}
}