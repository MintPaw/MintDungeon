package mintDungeon;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;

class Generator
{
	public static var WALL:Int = 1;
	public static var GROUND:Int = 0;

	public var mapSizeInTiles:Point = new Point();

	private var _mapArray:Array<Array<Int>> = [];

	public function new()
	{

	}

	public function generate():Void
	{
		for (i in 0...Std.int(mapSizeInTiles.y))
		{
			var row:Array<Int> = [];

			for (i in 0...Std.int(mapSizeInTiles.x)) row.push(WALL);

			_mapArray.push(row);
		}
	}

	public function getMapAsString():String
	{
		var s:String = "";

		for (i in _mapArray)
		{
			for (j in i)
			{
				s += j + " ";
			}

			s += "\n";
		}

		return s;
	}

	public function getMapAsBitmap():Bitmap
	{
		var b:BitmapData = new BitmapData(Std.int(mapSizeInTiles.x), Std.int(mapSizeInTiles.y));

		for (i in 0..._mapArray.length)
		{
			for (j in 0..._mapArray[i].length)
			{
				if (_mapArray[i][j] == WALL) b.setPixel(j, i, 0x000000);
				if (_mapArray[i][j] == GROUND) b.setPixel(j, i, 0xFFFFFF);
			}

		}

		return new Bitmap(b);
	}
}