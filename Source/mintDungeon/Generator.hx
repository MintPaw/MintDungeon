package mintDungeon;

import mintDungeon.Random;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;

class Generator
{
	public static var WALL:Int = 1;
	public static var GROUND:Int = 0;

	public var mapSizeInTiles:Point = new Point();
	public var roomSize:Point = new Point();

	public var rooms:Array<Room> = [];

	private var _mapArray:Array<Array<Int>> = [];

	private var _tryAgain:Bool;
	private var _tries:Int;

	public function new(seed:Int)
	{
		Random.giveSeed(seed);
	}

	public function generate():Void
	{
		_tryAgain = false;
		_tries = 0;

		generateEmptyMap();
		generateStartingRoom();
	}

	private function generateEmptyMap():Void
	{
		for (i in 0...Std.int(mapSizeInTiles.y))
		{
			var row:Array<Int> = [];

			for (i in 0...Std.int(mapSizeInTiles.x)) row.push(WALL);

			_mapArray.push(row);
		}
	}

	private function generateStartingRoom():Void
	{
		var size:Point = new Point(Random.minMaxInt(roomSize.x, roomSize.y), Random.minMaxInt(roomSize.x, roomSize.y));
		var location:Point = new Point(mapSizeInTiles.x / 2 - size.x / 2, mapSizeInTiles.y / 2 - size.y / 2);

		trace(size);

		var room:Room = generateRoom(Math.round(location.x), Math.round(location.y), Math.round(size.x), Math.round(size.y));
	}

	private function generateRoom(x:Int = -1, y:Int = -1, width:Int = -1, height:Int = -1):Room
	{
		var room:Room = new Room();

		room.location.setTo(x, y, width, height);

		for (i in 0...Std.int(height))
		{
			for (j in 0...Std.int(width))
			{
				_mapArray[y + i][x + j] = GROUND;
			}
		}

		return room;
	}

	public function getMapAsString():String
	{
		var s:String = "";

		for (i in _mapArray)
		{
			for (j in i) s += j + " ";
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