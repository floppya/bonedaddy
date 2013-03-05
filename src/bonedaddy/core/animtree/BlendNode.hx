package bonedaddy.core.animtree;

import bonedaddy.core.EntityState;

class BlendNode extends AnimNode {
	public var weight0:Float = 1.0; // weight for child0, child1 gets whatever remains
	public var child0:AnimNode;
	public var child1:AnimNode;
	var _tmpEntityState0:EntityState;
	var _tmpEntityState1:EntityState;

	public function new(?child0:AnimNode, ?child1:AnimNode) {
		this.child0 = child0;
		this.child1 = child1;
		super();
	}

	override public function init(tree:AnimTree) {
		super.init(tree);

		_tmpEntityState0 = tree.animationSet.entityStatePool.fetch();
		_tmpEntityState1 = tree.animationSet.entityStatePool.fetch();
		if (child0 != null) {
			child0.init(tree);
		}
		if (child1 != null) {
			child1.init(tree);
		}
	}
	
	override public function update(dt:Float) {
		if (child0 != null) {
			child0.update(dt);
		}
		if (child1 != null) {
			child1.update(dt);
		}
	}

	override public function getEntityState(entityState:EntityState):Void {
		if (child0 != null && child1 != null) {
			child0.getEntityState(_tmpEntityState0);
			child1.getEntityState(_tmpEntityState1);
			entityState.interpolate(_tmpEntityState1, _tmpEntityState0, weight0, true);
		} else {
			if (child0 != null)
				child0.getEntityState(entityState);
			if (child1 != null)
				child1.getEntityState(entityState);
		}
	}
	
	override public function clone():AnimNode {
		var node = new BlendNode();
		node.child0 = child0.clone();
		node.child1 = child1.clone();
		node.copy(this);
		return cast node;
	}
	
	override public function copy(other:AnimNode) {
		super.copy(other);
		var bnOther:BlendNode = cast other;
		weight0 = bnOther.weight0;
		child0.copy(bnOther.child0);
		child1.copy(bnOther.child1);
	}
	
}