package bonedaddy.core;

import bonedaddy.utils.ObjectPool;

class Animation {
	public var id:Int;
	public var name:String;
	public var length:Int;
	public var looping:Bool;
	public var keys:Array<Key>;
	public var entityStatePool:ObjectPool<EntityState>;
	
	public function new() {
		keys = new Array<Key>();
	}
	
	inline public function addKey(key:Key) {
		key.id = keys.length;
		keys.push(key);
		if (keys.length == 1) {
			// we now have an example EntityState to clone.
			entityStatePool = new ObjectPool<EntityState>(function():EntityState {
				return keys[0].state.clone();
			});
		}
	}
	
	inline public function getKey(id:Int) {
		return keys[id];
	}
	
	inline public function getKeyAt(t:Int):Key {
		var resultKey:Key = null;
		for (key in keys) {			
			if (key.time > t) {
				break;
			}		
			resultKey = key;
		}
		return resultKey;
	}
	
	inline public function getNextKey(key:Key):Key {
		var nextId = key.id + 1;
		if (nextId >= keys.length) {
			if (looping) {
				nextId = 0;
			} else {
				nextId = key.id;
			}
		}
		return keys[nextId];
	}
	
	inline public function updateState(state:EntityState, t:Int) {
		var key0 = getKeyAt(t);
		var key1 = getNextKey(key0);
		if (key0 == key1) {
			state.copy(key0.state);
		} else {
			var relativeT:Float = (t - key0.time) * key0.inverseLength;
			state.interpolate(key0.state, key1.state, relativeT);
		}
	}
}