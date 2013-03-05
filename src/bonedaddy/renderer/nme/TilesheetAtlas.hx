package bonedaddy.renderer.nme;

import bonedaddy.utils.ImageAtlas;
import nme.display.Tilesheet;
import nme.display.BitmapData;
import nme.geom.Rectangle;

class TilesheetAtlas {
	public var nameToTile:Map<String, Int>;
	public var tilesheet:Tilesheet;
	
	public function new(bitmap:BitmapData) {
		nameToTile = new Map<String, Int>();
		tilesheet = new Tilesheet(bitmap);
	}
	
	public function setSubTile(name:String, rect:Rectangle):Int {
		var tile = tilesheet.addTileRect(rect);
		nameToTile.set(name, tile);
		return tile;
	}
	
	inline public function getTile(name:String):Int {
		return nameToTile.get(name);
	}
	
	static public function fromImageAtlas(imageAtlas:ImageAtlas):TilesheetAtlas {
		var tileAtlas = new TilesheetAtlas(imageAtlas.bitmapData);
		for (regionName in imageAtlas.regions.keys()) {
			tileAtlas.setSubTile(regionName, imageAtlas.getRect(regionName));
		}
		return tileAtlas;
	}
}