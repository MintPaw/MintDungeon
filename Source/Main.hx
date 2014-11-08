package;


import flixel.FlxGame;
import openfl.display.Sprite;


class Main extends Sprite
{
		
	public function new()
	{
		var flixel:FlxGame = new FlxGame(640, 360, GameState, 1, 60, 60, true);
		addChild(flixel);

		super();
	}

}