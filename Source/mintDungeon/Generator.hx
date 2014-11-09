package mintDungeon;

import mintDungeon.DrawableObject;
import mintDungeon.Hallway;
import mintDungeon.Random;
import motion.Actuate;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;

class Generator
{
	public static var LEFT:Int = 0;
	public static var RIGHT:Int = 1;
	public static var UP:Int = 2;
	public static var DOWN:Int = 3;

	public static var WALL:Int = 1;
	public static var GROUND:Int = 0;
	public static var OFF_MAP:Int = 98;
	public static var DEBUG:Int = 99;

	public var mapSizeInTiles:Point = new Point();
	public var roomSize:Point = new Point();
	public var roomAmount:Point = new Point();
	public var hallLength:Point = new Point();

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
		generateRooms();
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

	private function generateRooms():Void
	{
		var startRoom:Room = generateStartingRoom();
		drawObject(startRoom);

		//var roomsToGenerate:Int = Random.minMaxInt(roomAmount.x, roomAmount.x) - 1;
		var roomsToGenerate:Int = 20;

		for (i in 0...roomsToGenerate)
		{
			generateHallway();
		}
	}

	private function generateHallway():Void
	{
		var hall:Hallway;

		while (true)
		{
			hall = new Hallway();
			var startingWall:Point = new Point();

			while (true)
			{
				startingWall.setTo(Random.minMaxInt(0, mapSizeInTiles.x - 1), Random.minMaxInt(0, mapSizeInTiles.y - 1));
				if (getTile(startingWall.x, startingWall.y) == GROUND) break;
			}

			var direction:Int = Random.minMaxInt(0, 3);
			var length:Int = Random.minMaxInt(hallLength.x, hallLength.y);

			for (i in 1...length)
			{
				if (direction == LEFT)  hall.tiles.push(new Point(startingWall.x - i, startingWall.y));
				if (direction == RIGHT)  hall.tiles.push(new Point(startingWall.x + i, startingWall.y));
				if (direction == UP)  hall.tiles.push(new Point(startingWall.x, startingWall.y - i));
				if (direction == DOWN)  hall.tiles.push(new Point(startingWall.x, startingWall.y + i));
			}

			hall.startPoint = hall.tiles.shift();

			if (canBuild(hall)) break;
		}

		drawObject(hall);
	}

	private function generateStartingRoom():Room
	{
		var size:Point = new Point(Random.minMaxInt(roomSize.x, roomSize.y), Random.minMaxInt(roomSize.x, roomSize.y));
		var location:Point = new Point(mapSizeInTiles.x / 2 - size.x / 2, mapSizeInTiles.y / 2 - size.y / 2);

		return generateRoom(Math.round(location.x), Math.round(location.y), Math.round(size.x), Math.round(size.y));
	}

	private function generateRoom(x:Int, y:Int, width:Int, height:Int):Room
	{
		var room:Room = new Room();

		room.location.setTo(x, y, width, height);

		for (i in 0...Std.int(height))
		{
			for (j in 0...Std.int(width))
			{
				room.tiles.push(new Point(x + j, y + i));
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
				if (_mapArray[i][j] == DEBUG) b.setPixel(j, i, 0xFF0000);
			}
		}

		return new Bitmap(b);
	}

	private function setTile(xpos:Float, ypos:Float, type:Int):Void
	{
		_mapArray[Std.int(ypos)][Std.int(xpos)] = type;
	}

	private function getTile(xpos:Float, ypos:Float):Int
	{
		if (xpos < 0 || xpos > mapSizeInTiles.x || ypos < 0 || ypos > mapSizeInTiles.y) return OFF_MAP;
		return _mapArray[Std.int(ypos)][Std.int(xpos)];
	}

	private function drawObject(o:DrawableObject):Void
	{
		for (i in o.tiles) setTile(i.x, i.y, GROUND);
		if (Std.is(o, Hallway)) setTile(cast(o, Hallway).startPoint.x, cast(o, Hallway).startPoint.y, GROUND);
		//for (i in o.outline) setTile(i.x, i.y, DEBUG);
	}

	private function canBuild(o:DrawableObject):Bool
	{
		o.generateOutline();

		for (i in o.outline)
		{
			if (getTile(i.x, i.y) != WALL)
			{
				return false;
			}
		}

		return true;
	}
}