package bonedaddy.utils;

import haxe.xml.Fast;
import nme.Assets;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;

class ImageAtlas {
	public var bitmapData:BitmapData;
	public var regionBitmapData:Map<String, BitmapData>;
	public var regions:Map<String, Rectangle>;
	
	public function new(bitmapData:BitmapData) {
		this.bitmapData = bitmapData;
		regions = new Map<String, Rectangle>();
		regionBitmapData = new Map<String, BitmapData>();
	}

	public function addRect(name:String, rect:Rectangle) {
		var data = new BitmapData(Std.int(rect.width), Std.int(rect.height));
		data.copyPixels(bitmapData, rect, new Point(0.0, 0.0));
		regions.set(name, rect);
		regionBitmapData.set(name, data);
	}
	
	inline public function getBitmapData(name:String) {
		return regionBitmapData.get(name);
	}
	
	inline public function getRect(name:String):Rectangle {
		return regions.get(name);
	}
	
	static public function fromStarling(filename:String):ImageAtlas {
		var xmlText = Assets.getText(filename);
		var xml = Xml.parse(xmlText);
		var root = new Fast(xml.firstElement());
		var imageFilename = root.att.imagePath;
		var bmpData = Assets.getBitmapData(imageFilename);
		var atlas = new ImageAtlas(bmpData);
		for (node in root.nodes.SubTexture) {
			atlas.addRect(
				node.att.name,
				new Rectangle(
					Std.parseInt(node.att.x),
					Std.parseInt(node.att.y),
					Std.parseInt(node.att.width),
					Std.parseInt(node.att.height)
				)
			);
		}
		return atlas;
	}
}
