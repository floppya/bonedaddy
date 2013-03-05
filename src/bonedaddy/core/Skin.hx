package bonedaddy.core;

import bonedaddy.utils.StateMacros;

class Skin {
	public var id:Int;
	public var name:String = '';
	public var filename:String = '';
	public var parent:Int = -1;
	public var folder:Int = -1;
	public var file:Int = -1;
	public var transform:Transform;
	public var pivotX:Float;
	public var pivotY:Float;
	public var opacity:Float;
	public var zIndex:Int;

	public function new() {
		transform = new Transform();
	}
	
	inline public function copy(other:Skin) {
		name = other.name;
		filename = other.filename;
		parent = other.parent;
		folder = other.folder;
		file = other.file;
		transform.copy(other.transform);
		pivotX = other.pivotX;
		pivotY = other.pivotY;
		opacity = other.opacity;
		zIndex = other.zIndex;
	}
	
	inline public function clone():Skin {
		var state = new Skin();
		state.copy(this);
		return state;
	}
	
	inline public function interpolate(state0:Skin, state1:Skin, t:Float, ?shortest:Bool=false) {
		parent = state0.parent;
		folder = state0.folder;
		file = state0.file;
		transform.interpolate(state0.transform, state1.transform, t, shortest);
		pivotX = StateMacros.interp(state0.pivotX, state1.pivotX, t);
		pivotY = StateMacros.interp(state0.pivotY, state1.pivotY, t);
		opacity = StateMacros.interp(state0.opacity, state1.opacity, t);
		zIndex = state0.zIndex;
	}
}