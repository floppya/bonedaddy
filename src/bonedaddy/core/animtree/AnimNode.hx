package bonedaddy.core.animtree;

import bonedaddy.core.EntityState;

class AnimNode {
	public function new() {
	}

	public function update(dt:Float):Void { }

	public function getEntityState(entityState:EntityState):Void { }
	
	public function init(tree:AnimTree):Void {
		this.tree = tree;
	}

	public function clone():AnimNode {
		var node = new AnimNode();
		node.copy(this);
		return node;
	}

	public function copy(other:AnimNode) {
		name = other.name;
	}
	
	@:isVar public var name(get, set):String;
	function get_name() {
		return name;
	}
	function set_name(val:String) {
		if (tree != null) {
			if (name != val) {
				tree.renameNode(this, val);
			}
		}
		return name = val;
	}

	@:isVar public var tree(get, set):AnimTree;
	function get_tree() {
		return tree;
	}
	function set_tree(val:AnimTree) {
		if (tree != null)
			throw 'This node is already assigned a tree.';

		if (tree != val) {
			if (tree != null) {
				tree.removeNode(this);
			}
			tree = val;
			if (tree != null) {
				tree.addNode(this);
			}
		}
		return tree;
	}

}