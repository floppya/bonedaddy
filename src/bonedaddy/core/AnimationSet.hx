package bonedaddy.core;

import bonedaddy.utils.ObjectPool;

class AnimationSet {
	public var id:Int;
	public var name:String;
	public var animations:Array<Animation>;
	public var animationByName:Map<String, Animation>;
	
	public function new() {
		animations = new Array<Animation>();
		animationByName = new Map<String, Animation>();	
	}
	
	public function addAnimation(animation:Animation) {
		animations.insert(animation.id, animation);
		animationByName.set(animation.name, animation);
	}
	
	inline public function getAnimationByName(name:String):Animation {
		return animationByName.get(name);
	}
	
	public var entityStatePool(get, null):ObjectPool<EntityState>;
	function get_entityStatePool() {
		if (animations.length > 0) {
			return animations[0].entityStatePool;
		}
		return null;
	}
}
