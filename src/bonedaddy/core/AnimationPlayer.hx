package bonedaddy.core;

class AnimationPlayer {
	var time:Int = 0;
	var absTime:Int = 0; // how long it has been running
	var frameTime:Int = 0; // which frame are we on
	var animationLength:Int = 0; // cache dat
	public var timeScale:Float = 1.0; // greater than 0
	public var reverse:Bool = false;

	@:isVar public var animation(get, set):Animation;
	function get_animation() { return animation; }
	function set_animation(val:Animation) {
		time = 0;
		if (val == null) {
			animationLength = 0;
		} else {
			animationLength = val.length;
		}
		return animation = val;
	}

	public function new(animation:Animation=null)  {
		this.animation = animation;
	}
	
	@:isVar public var isPlaying(get, set):Bool;
	function get_isPlaying() {
		return isPlaying;
	}
	function set_isPlaying(val:Bool) {
		if (val != isPlaying) {
			if (val) {
				onPlay();
			} else {
				onStop();
			}
		}
		return isPlaying = val;
	}
	
	function onPlay() { }
	function onStop() { }
	
	public function advanceTime(dt:Float) {
		var msDt:Float = dt * 1000;
		if (!isPlaying)
			return;
		var absDt = msDt * timeScale;
		var dir = reverse ? -1 : 1;
		time += Std.int(absDt * dir);
		absTime = Std.int(Math.abs(time));
	
		if (absTime >= animationLength) {
			if (animation.looping) {
				if (reverse) {
					time += animationLength;
				} else {
					time -= animationLength;
				}
			} else {
				time = animationLength;
			}
			absTime = Std.int(Math.abs(time));
		}
		frameTime = time;
		if (frameTime < 0) {
			frameTime += animationLength;
		}
	}
	
	public function updateEntityState(state:EntityState) {
		if (animation != null) {
			animation.updateState(state, frameTime);
		}
	}
	
	public function scaleToDuration(duration:Int) {
		if (animationLength != 0) {
			timeScale = Std.int(duration / animationLength * 1000); 
		}
	}
}