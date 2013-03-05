package bonedaddy.renderer.nme;

import bonedaddy.core.AnimationSet;
import bonedaddy.core.animtree.AnimTree;
import bonedaddy.core.Skin;
import bonedaddy.loader.BaseBonedaddyLoader;
import bonedaddy.utils.ImageAtlas;
import nme.Vector;

class NMEFactory {
	var animationSetByName:Map<String, AnimationSet>;
	var filenameToTile:Map<String, Int>;
	var filenameToTilesheetAtlas:Map<String, TilesheetAtlas>;
	var folderFileTile:Vector<Vector<Int>>;

	public function new() {
		filenameToTile = new Map<String, Int>();
		filenameToTilesheetAtlas = new Map<String, TilesheetAtlas>();
		animationSetByName = new Map<String, AnimationSet>();
		folderFileTile = new Vector<Vector<Int>>();
	}
	
	public function assimilateLoader(loader:BaseBonedaddyLoader) {
		animationSetByName = loader.getAnimationSets();
		var filenameIndex = loader.getFilenameIndex();
		var numFolders = filenameIndex.length;
		for (i in 0...numFolders) {
			var fileIndex = filenameIndex[i];
			var numFiles = fileIndex.length;
			var fileTiles = new Vector<Int>();
			folderFileTile.push(fileTiles);
			for (j in 0...numFiles) {
				var filename:String = fileIndex[j];
				var tile:Int = filenameToTile.get(filename);
				fileTiles.push(tile);
			}
		}
	}
	
	public function addImageAtlas(imageAtlas:ImageAtlas):TilesheetAtlas {
		var tilesheetAtlas = TilesheetAtlas.fromImageAtlas(imageAtlas);
		for (tileName in tilesheetAtlas.nameToTile.keys()) {
			var tile = tilesheetAtlas.getTile(tileName);
			filenameToTile.set(tileName, tile);
			filenameToTilesheetAtlas.set(tileName, tilesheetAtlas);
		}
		return tilesheetAtlas;
	}

	public function getAnimTreeSprite(name:String, animTree:AnimTree, tilesheetAtlas:TilesheetAtlas) {
		var animationSet = animationSetByName.get(name);
		var sprite:AnimTreeSprite = null;
		if (animationSet != null) {
			animTree.animationSet = animationSet;
			animTree.init();
			sprite = new AnimTreeSprite();
			sprite.animTree = animTree;
			sprite.tilesheetAtlas = tilesheetAtlas;
			sprite.nmeFactory = this;
		} else {
			throw 'No animation set named ' + name;
		}
		return sprite;
	}

	public function getEntityStateSprite(name:String, tilesheetAtlas:TilesheetAtlas) {
		var animationSet = animationSetByName.get(name);
		var sprite:EntityStateSprite = null;
		if (animationSet != null) {
			sprite = new EntityStateSprite();
			var state = animationSet.animations[0].entityStatePool.fetch();
			sprite.entityState = state;
			sprite.tilesheetAtlas = tilesheetAtlas;
			sprite.nmeFactory = this;
		} else {
			throw 'No animation named ' + name;
		}
		return sprite;
	}
	inline public function getTileForFile(filename:String):Int {
		return filenameToTile.get(filename);
	}
	
	inline public function getTileForSkin(skin:Skin):Int {
		return folderFileTile[skin.folder][skin.file];
	}

}