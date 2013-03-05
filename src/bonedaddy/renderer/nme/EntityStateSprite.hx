package bonedaddy.renderer.nme;

import bonedaddy.core.EntityState;
import nme.display.Sprite;
import nme.display.Tilesheet;

class EntityStateSprite extends Sprite {
	public var nmeFactory:NMEFactory;
	public var tilesheetAtlas:TilesheetAtlas;
	@:isVar public var entityState(get, set):EntityState;
	var flattenedEntityState:EntityState;
	var _tileData:Array<Float>;
	
	public function new() {
		super();
	}
	
	public function updateBitmap() {
		if (entityState == null || tilesheetAtlas == null)
			return;
		
		entityState.bakeHierarchy(flattenedEntityState);
		var lookupTileId = nmeFactory.getTileForSkin;
		var index:Int = 0;
		graphics.clear();
		for (skin in flattenedEntityState.skins) {
			var skinTransform = skin.transform;
			var tileId:Int = lookupTileId(skin);
			_tileData[index++] = skinTransform.x;
			_tileData[index++] = skinTransform.y;
			_tileData[index++] = tileId;
			_tileData[index++] = -skinTransform.angle;
		}
		tilesheetAtlas.tilesheet.drawTiles(graphics, _tileData, true, Tilesheet.TILE_ROTATION);
	}
	
	function get_entityState() {
		return entityState;
	}
	
	function set_entityState(val:EntityState) {
		entityState = val.clone();
		flattenedEntityState = entityState.clone();
		_tileData = new Array<Float>();
		var numItems = flattenedEntityState.skins.length * 4;
		while (numItems-- > 0) {
			_tileData.push(0.0);
		}
		return entityState;
	}
}