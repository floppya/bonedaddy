package bonedaddy.core;

import bonedaddy.utils.StateMacros;

class Bone {
	public var id:Int;
	public var parent:Int = -1;
	public var name:String = '';
	public var transform:Transform;
	
	public function new() {
		transform = new Transform();
	}

	inline public function copy(other:Bone) {
		parent = other.parent;
		name = other.name;
		transform.copy(other.transform);
	}
	
	inline public function clone():Bone {
		var newBone = new Bone();
		newBone.copy(this);
		return newBone;
	}

	inline public function interpolate(state0:Bone, state1:Bone, t:Float, ?shortest:Bool=false) {
		parent = state0.parent;
		name = state0.name;
		transform.interpolate(state0.transform, state1.transform, t, shortest);
	}
	
	public function toString():String {
		return 'Bone(' + transform + ')';
	}
}