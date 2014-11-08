package mintDungeon;

/**
 * Adapted from Nicolas Cannasse code.
 *
 * @author Franco Ponticelli
 * @author Nicolas Cannasse
 */

class Random
{
	public static var seed:Int;
	
	public static function giveSeed(s:Int)
	{
		seed = s;
	}

	public static function random():Float
	{
		return Math.random();
	}

	public static function minMaxInt(min:Float, max:Float):Int
	{
		return Math.round(min + Std.int((Math.random() * (max - min + 1))));
	}
}