package bonedaddy.renderer.nme;

import bonedaddy.core.animtree.AnimTree;
import nme.display.Sprite;

class AnimTreeSprite extends EntityStateSprite {
	@:isVar public var animTree(get, set):AnimTree;

	public function new() {
		super();
	}

	inline public function advanceTime(dt:Float) {
		if (animTree != null) {
			animTree.update(dt);
			animTree.getEntityState(entityState);
			updateBitmap();
		}
	}

	function get_animTree() {
		return animTree;
	}

	function set_animTree(val:AnimTree) {
		if (animTree != null) {
			animTree.entityStatePool.returnToPool(entityState);
		}
		entityState = val.entityStatePool.fetch();
		return animTree = val;
	}
}