package mintDungeon;

import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import mintDungeon.FlxTilemapNoGraphics;

class FlxTilemapNoGraphics extends FlxTilemap
{


	public function new()
	{
		super();
	}

	override private function loadMapHelper(TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0, TileHeight:Int = 0, ?AutoTile:FlxTilemapAutoTiling,
		StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1)
	{
		return;
	}
}