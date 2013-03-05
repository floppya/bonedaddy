package bonedaddy.core;

class Key {
	public var id:Int;
	public var time:Int;
	public var spin:Int;
	public var length(get_length, set_length):Int;
	public var inverseLength:Float = 0.0;
	public var state:EntityState;
	
	public function new(id:Int, time:Int, state:EntityState) {
		this.id = id;
		this.time = time;
		this.state = state;
	}
	
	var _length:Int;
	function set_length(newLength:Int):Int {
		_length = newLength;
		inverseLength = _length != 0 ? 1.0 / _length : 0.0;
		return _length;
	}
	
	function get_length():Int {
		return _length;
	}
}