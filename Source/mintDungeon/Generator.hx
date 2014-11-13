package mintDungeon;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import mintDungeon.DrawableObject;
import mintDungeon.Hallway;
import mintDungeon.Random;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;

class Generator
{
	public static var LEFT:Int = 0;
	public static var RIGHT:Int = 1;
	public static var UP:Int = 2;
	public static var DOWN:Int = 3;

	public static var GROUND:Int = 1;
	public static var WALL:Int = 2;
	public static var OFF_MAP:Int = 98;
	public static var DEBUG:Int = 99;

	public static var colours:Array<Int> = [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF];

	public var mapSizeInTiles:Point = new Point();
	public var roomSize:Point = new Point();
	public var roomAmount:Point = new Point();
	public var hallLength:Point = new Point();
	public var doorPercentage:Point = new Point();

	public var spawnPoint:Point = new Point();
	public var keys:Array<Key>;
	public var doors:Array<Door>;

	private var _mapArray:Array<Array<Int>>;

	private var _hallways:Array<Hallway>;
	private var _rooms:Array<Room>;

	private var _tryAgain:Bool;
	private var _tries:Int;
	private var _colourOn:Int;

	public function new(seed:Int)
	{
		Random.giveSeed(seed);
	}

	public function generate():Void
	{
		_tryAgain = true;

		while (_tryAgain)
		{
			_tryAgain = false;
			_tries = 0;
			_colourOn = 0;
			_mapArray = [];
			_rooms = [];
			_hallways = [];
			keys = [];
			doors = [];

			generateEmptyMap();
			generateRooms();
			generateDoors();
		}
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

		var roomsToGenerate:Int = Random.minMaxInt(roomAmount.x, roomAmount.y) - 1;

		var room:Room;
		var hall:Hallway;

		for (i in 0...roomsToGenerate)
		{
			while (true)
			{
				tried();

				hall = generateHallway();

				var size:Point = new Point(Random.minMaxInt(roomSize.x, roomSize.y), Random.minMaxInt(roomSize.x, roomSize.y));
				var location:Point = new Point();

				if (hall.direction == LEFT) location = new Point(hall.endPoint.x - size.x, hall.endPoint.y - Random.minMaxInt(0, size.y - 1));
				if (hall.direction == RIGHT) location = new Point(hall.endPoint.x + 1, hall.endPoint.y - Random.minMaxInt(0, size.y - 1));
				if (hall.direction == UP) location = new Point(hall.endPoint.x - Random.minMaxInt(0, size.x - 1), hall.endPoint.y - size.y);
				if (hall.direction == DOWN) location = new Point(hall.endPoint.x - Random.minMaxInt(0, size.x - 1), hall.endPoint.y + 1);

				room = generateRoom(Math.round(location.x), Math.round(location.y), Math.round(size.x), Math.round(size.y));

				if (_tryAgain) return;
				if (canBuild(hall) && canBuild(room)) break;
			}

			drawObject(room);
			drawObject(hall);

			_rooms.push(room);
			_hallways.push(hall);
		}
	}

	private function generateDoors():Void
	{
		doors = [];
		keys = [];

		var absDoorPerc:Int = Random.minMaxInt(doorPercentage.x, doorPercentage.y);
		var doorsToCreate:Int = Math.round(_hallways.length * absDoorPerc / 100);

		for (i in 0...doorsToCreate)
		{
			var currentCSV:String = getMapAsCSV();
			while (true)
			{
				var doorLoc:Point;
				while (true)
				{
					var badDoorPos:Bool = false;
					doorLoc = _hallways[Random.minMaxInt(0, _hallways.length - 1)].endPoint.clone();
					
					for (i in doors) if (i.x == doorLoc.x && i.y == doorLoc.y) badDoorPos = true;

					if (!badDoorPos) break;
				}

				var keyLoc:Point = new Point();

				while(true)
				{
					keyLoc.setTo(Random.minMaxInt(1, mapSizeInTiles.x - 1), Random.minMaxInt(1, mapSizeInTiles.y - 1));
					if (getTile(keyLoc.x, keyLoc.y) == GROUND && !keyLoc.equals(spawnPoint)) break;
				}

				if (isReachable(spawnPoint, keyLoc, currentCSV, doorLoc))
				{
					keys.push( {x: Std.int(keyLoc.x), y: Std.int(keyLoc.y), colour: colours[_colourOn]} );
					doors.push( {x: Std.int(doorLoc.x), y: Std.int(doorLoc.y), colour: colours[_colourOn]} );
					
					_colourOn++;

					break;
				}
			}
		}
	}

	private function isReachable(start:Point, end:Point, csv:String, toAdd:Point = null):Bool
	{
		var map:FlxTilemap = new FlxTilemap();
		map.loadMapFromCSV(csv, "assets/empty.png", 1, 1);
		map.setTileProperties(GROUND, FlxObject.NONE);

		for (i in doors) map.setTile(Std.int(i.x), Std.int(i.y), WALL);
		if (toAdd != null) map.setTile(Std.int(toAdd.x), Std.int(toAdd.y), WALL);

		var path:Array<FlxPoint> = map.findPath(new FlxPoint(Std.int(start.x), Std.int(start.y)), new FlxPoint(Std.int(end.x), Std.int(end.y)));

		return path != null;
	}

	private function generateHallway():Hallway
	{
		var hall:Hallway;

		hall = new Hallway();
		var startingWall:Point = new Point();

		while (true)
		{
			startingWall.setTo(Random.minMaxInt(1, mapSizeInTiles.x - 1), Random.minMaxInt(0, mapSizeInTiles.y - 1));
			if (getTile(startingWall.x, startingWall.y) == GROUND)
			{
				if (
					getTile(startingWall.x + 1, startingWall.y) == WALL ||
					getTile(startingWall.x - 1, startingWall.y) == WALL ||
					getTile(startingWall.x, startingWall.y + 1) == WALL ||
					getTile(startingWall.x, startingWall.y - 1) == WALL || _tryAgain) break;
			}
		}

		var direction:Int = Random.minMaxInt(0, 3);
		var length:Int = Random.minMaxInt(hallLength.x, hallLength.y) + 1;
		hall.direction = direction;

		for (i in 1...length)
		{
			if (direction == LEFT)  hall.tiles.push(new Point(startingWall.x - i, startingWall.y));
			if (direction == RIGHT)  hall.tiles.push(new Point(startingWall.x + i, startingWall.y));
			if (direction == UP)  hall.tiles.push(new Point(startingWall.x, startingWall.y - i));
			if (direction == DOWN)  hall.tiles.push(new Point(startingWall.x, startingWall.y + i));
		}

		hall.startPoint = hall.tiles.shift();
		hall.endPoint = hall.tiles[hall.tiles.length - 1];

		return hall;
	}

	private function generateStartingRoom():Room
	{
		var size:Point = new Point(Random.minMaxInt(roomSize.x, roomSize.y), Random.minMaxInt(roomSize.x, roomSize.y));
		var location:Point = new Point(mapSizeInTiles.x / 2 - size.x / 2, mapSizeInTiles.y / 2 - size.y / 2);

		spawnPoint.x = Math.round(location.x + size.x / 2);
		spawnPoint.y = Math.round(location.y + size.y / 2);

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

	public function getMapAsCSV():String
	{
		var s:String = "";

		for (i in _mapArray)
		{
			for (j in i) s += j + ",";
			s = s.substr(0, s.length - 1);
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

			for (i in doors) b.setPixel(Std.int(i.x), Std.int(i.y), 0x440000);
			for (i in keys) b.setPixel(Std.int(i.x), Std.int(i.y), 0x55FF55);
		}

		b.setPixel(Std.int(spawnPoint.x), Std.int(spawnPoint.y), 0x0000FF);

		return new Bitmap(b);
	}

	private function setTile(xpos:Float, ypos:Float, type:Int):Void
	{
		if (_tryAgain) return;
		_mapArray[Std.int(ypos)][Std.int(xpos)] = type;
	}

	private function getTile(xpos:Float, ypos:Float):Int
	{
		if (xpos < 0 || xpos > mapSizeInTiles.x - 1 || ypos < 0 || ypos > mapSizeInTiles.y - 1) return OFF_MAP;
		return _mapArray[Std.int(ypos)][Std.int(xpos)];
	}

	private function drawObject(o:DrawableObject):Void
	{
		for (i in o.tiles) setTile(i.x, i.y, GROUND);
		if (Std.is(o, Hallway)) setTile(cast(o, Hallway).startPoint.x, cast(o, Hallway).startPoint.y, GROUND);
	}

	private function canBuild(o:DrawableObject):Bool
	{
		o.generateOutline();

		for (i in o.outline)
		{
			if (getTile(i.x, i.y) != WALL || i.x < 0 || i.y < 0 || i.x > mapSizeInTiles.x - 1 || i.y > mapSizeInTiles.y - 1)
			{
				return false;
			}
		}

		return true;
	}

	private function tried():Void
	{
		if (_tries++ > 1000) _tryAgain = true;
	}

	public function shuffleArray(input:Array<Dynamic>):Void
	{
		var i:Int = input.length - 1;

		while (i >= 0)
		{
			var randomIndex:Int = Math.floor(Math.random()*(i+1));
			var itemAtIndex:Dynamic = input[randomIndex];
			input[randomIndex] = input[i];
			input[i] = itemAtIndex;
			i--;
		}
	}
}

typedef Door =
{
	x:Int,
	y:Int,
	colour:Int
}

typedef Key =
{
	x:Int,
	y:Int,
	colour:Int
}