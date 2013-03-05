package bonedaddy.core;

class AnimationState {
	var animationSet:AnimationSet;
	var currentAnimation:Animation;
	var queuedAnimation:Animation;
	var time:Int = 0;
	var absTime:Int = 0;
	var frameTime:Int = 0;
	public var timeScale:Float = 1.0; // greater than 0
	public var reverse:Bool = false;

	public function new(animationSet:AnimationSet)  {
		this.animationSet = animationSet;
		fixCurrentAnimation();
	}
	
	@:isVar public var isPlaying(get, set):Bool;
	function get_isPlaying() {
		return isPlaying;
	}
	function set_isPlaying(val:Bool) {
		if (val) {
			play();
		} else {
			stop();
		}
		return isPlaying = val;
	}
	
	function fixCurrentAnimation() {
		if (currentAnimation == null) {
			currentAnimation = animationSet.animations[0];
		}
	}

	public function play() {
	}
	
	public function stop() {
		
	}
	
	public function currentAnimationName():String {
		return currentAnimation.name;
	}
	
	public function playAnimation(name:String, ?startImmediately = true) {
		queuedAnimation = animationSet.getAnimationByName(name);
		if (queuedAnimation == null)
			throw 'No animation named ' + name;
		if (startImmediately) {
			time = currentAnimation.length;
			if (reverse)
				time = -time;
		}
	}
	
	public function advanceTime(dt:Float) {
		var msDt:Float = dt * 1000;
		if (!isPlaying)
			return;
		var absDt = msDt * timeScale;
		var dir = reverse ? -1 : 1;
		time += Std.int(absDt * dir);
		absTime = Std.int(Math.abs(time));
		frameTime = time;
		if (frameTime < 0) {
			frameTime += currentAnimation.length;
		}

		var nextAnimation:Animation = null;
		if (absTime >= currentAnimation.length) {
			if (queuedAnimation != null) {
				nextAnimation = queuedAnimation;
				queuedAnimation = null;
			} else { 
				// no animation queued up
				if (currentAnimation.looping) {
					nextAnimation = currentAnimation;
				}
			}
			if (reverse) {
				time += currentAnimation.length;
			} else {
				time -= currentAnimation.length;
			}
			currentAnimation = nextAnimation;
			absTime = Std.int(Math.abs(time));
			frameTime = time;
			if (frameTime < 0) {
				frameTime += currentAnimation.length;
			}
		}
	}
	
	public function updateEntityState(state:EntityState) {
		var actualTime = frameTime > currentAnimation.length ? currentAnimation.length : frameTime;
		currentAnimation.updateState(state, actualTime);
	}
}