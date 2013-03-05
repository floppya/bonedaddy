package bonedaddy.utils;

class ObjectPool<T> {
	var pool:Array<T>;
	var fnCreate:Void->T;
	var growSize:Int;
	
	public function new(fnCreate:Void->T, growSize:Int=10) {
		this.fnCreate = fnCreate;
		pool = new Array<T>();
		this.growSize = growSize;
		//addNInstances(initialPoolSize);
	}
	
	inline public function addNInstances(n:Int) {
		for (i in 0...n) {
			pool.push(fnCreate());
		}	
	}
	
	inline public function fetch():T {
		var obj = pool.pop();
		if (obj == null) {
			obj = fnCreate();
			addNInstances(growSize);
		}
		return obj;
	}
	
	inline public function returnToPool(obj:T) {
		pool.push(obj);
	}
}
