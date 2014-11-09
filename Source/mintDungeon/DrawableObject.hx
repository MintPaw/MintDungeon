package mintDungeon;

import openfl.geom.Point;

class DrawableObject
{
	public var tiles:Array<Point> = [];
	public var outline:Array<Point> = [];

	public function new()
	{

	}

	public function generateOutline():Void
	{
		var tempOutline:Array<Point> = [];
		for (i in tiles)
		{
			tempOutline.push(new Point(i.x, i.y));

			tempOutline.push(new Point(i.x + 1, i.y));
			tempOutline.push(new Point(i.x, i.y + 1));
			tempOutline.push(new Point(i.x + 1, i.y + 1));

			tempOutline.push(new Point(i.x - 1, i.y));
			tempOutline.push(new Point(i.x, i.y - 1));
			tempOutline.push(new Point(i.x - 1, i.y - 1));

			tempOutline.push(new Point(i.x + 1, i.y - 1));
			tempOutline.push(new Point(i.x - 1, i.y + 1));
		}
		
		for (i in tempOutline)
		{
			var add:Bool = true;
			for (j in outline) if (i.equals(j)) add = false;

			if (add) outline.push(i);
		}
	}
}