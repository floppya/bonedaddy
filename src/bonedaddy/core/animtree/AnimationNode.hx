package bonedaddy.core.animtree;

import bonedaddy.core.Animation;
import bonedaddy.core.AnimationPlayer;
import bonedaddy.core.EntityState;

class AnimationNode extends AnimNode {
	public function new(animationName:String) {
		super();
		animationPlayer = new AnimationPlayer();
		this.animationName = animationName;
	}
	
	override public function update(dt:Float):Void {
		if (animation != null) {
			animationPlayer.isPlaying = true;
			animationPlayer.advanceTime(dt);
		}
	}
	
	override public function getEntityState(entityState:EntityState):Void {
		if (animation != null) {
			animationPlayer.updateEntityState(entityState);
		}
	}
	
	override public function clone():AnimNode {
		var node = new AnimationNode(animationName);
		node.copy(this);
		return cast node;
	}
	
	override public function copy(other:AnimNode) {
		super.copy(other);
		var bnOther:AnimationNode = cast other;
		animationName = bnOther.animationName;
		// TODO: copy AnimationPlayer state?
	}
	
	override public function init(tree:AnimTree) {
		super.init(tree);
		if (animationName != '') {
			animation = tree.animationSet.getAnimationByName(animationName);
			animationPlayer.animation = animation;
		}
	}
	
	@:isVar public var animationName(get, set):String;
	function get_animationName() {
		return animationName;
	}
	function set_animationName(val:String) {
		if (animationName != val) {
			animationName = val;
			if (tree != null && val != '') {
				animation = tree.animationSet.getAnimationByName(val);
				animationPlayer.animation = animation;
			}
		}
		return animationName;
	}

	var animation:Animation;
	var animationPlayer:AnimationPlayer;
}