package mintDungeon;

import openfl.geom.Point;
import openfl.geom.Rectangle;

class Hallway extends DrawableObject
{
	public var startPoint:Point = new Point();
	public var endPoint:Point = new Point();
	public var direction:Int;

	public function new()
	{
		super();
	}
}