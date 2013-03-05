package bonedaddy.core.animtree;

import bonedaddy.core.AnimationSet;
import bonedaddy.core.EntityState;
import bonedaddy.utils.ObjectPool;

class AnimTree {
	public var rootAnimNode:AnimNode;
	public var nodeByName:Map<String, AnimNode>;
	public var entityStatePool:ObjectPool<EntityState>;

	public function new(?rootNode:AnimNode) {
		rootAnimNode = rootNode;
		nodeByName = new Map<String, AnimNode>();
	}
	
	public function addNode(node:AnimNode) {
		if (node.name != '') {
			nodeByName.set(node.name, node);
		}
	}
	
	public function removeNode(node:AnimNode) {
		if (node.name != '') {
			nodeByName.remove(node.name);
		}
	}
	
	public function renameNode(node:AnimNode, newName:String) {
		nodeByName.remove(node.name);
		if (newName != '') {
			nodeByName.set(newName, node);
		}
	}
	
	public function init() {
		if (rootAnimNode != null) {
			rootAnimNode.init(this);
		}
	}

	public function update(dt:Float):Void {
		if (rootAnimNode != null) {
			rootAnimNode.update(dt);
		}
	}

	public function getEntityState(entityState:EntityState):Void {
		if (rootAnimNode != null) {
			rootAnimNode.getEntityState(entityState);
		}
	}

	public function clone():AnimNode {
		var node = new AnimTree();
		node.copy(cast this);
		return cast node;
	}

	public function copy(other:AnimNode) {
		var otherTree:AnimTree = cast other;
		animationSet = otherTree.animationSet;
		var otherRootAnimNode = otherTree.rootAnimNode;
		if (otherRootAnimNode != null) {
			rootAnimNode = otherRootAnimNode.clone();
		} else {
			rootAnimNode = null;
		}
	}
	
	@:isVar public var animationSet(get, set):AnimationSet;
	public function get_animationSet() {
		return animationSet;
	}
	public function set_animationSet(val:AnimationSet) {
		if (animationSet != null)
			throw 'AnimationSet was already assigned.';
		if (val != null) {
			entityStatePool = val.entityStatePool;
		}
		return animationSet = val;
	}

}