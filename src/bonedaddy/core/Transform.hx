package bonedaddy.core;

import bonedaddy.utils.StateMacros;

class Transform {
	public var x:Float;
	public var y:Float;
	public var angle:Float;
	public var scaleX:Float;
	public var scaleY:Float;
	public var spin:Int;
	
	public function new() {
		
	}
	
	inline public function copy(other:Transform) {
		x = other.x;
		y = other.y;
		angle = other.angle;
		scaleX = other.scaleX;
		scaleY = other.scaleY;
		spin = other.spin;
	}
	
	inline public function clone():Transform {
		var state = new Transform();
		state.copy(this);
		return state;
	}

	inline public function interpolate(state0:Transform, state1:Transform, t:Float, ?ignoreSpin:Bool=false) {
		x = StateMacros.interp(state0.x, state1.x, t);
		y = StateMacros.interp(state0.y, state1.y, t);
		if (ignoreSpin)
			spin = 0;
		else
			spin = state0.spin;
		angle = interpAngle(state0.angle, state1.angle, t, spin);
		scaleX = StateMacros.interp(state0.scaleX, state1.scaleX, t);
		scaleY = StateMacros.interp(state0.scaleY, state1.scaleY, t);
	}
	
	inline function interpAngle(angle0:Float, angle1:Float, t:Float, spin:Int):Float {
		var angle = 0.0;
		if (spin != 0) {
			if (spin > 0 && angle0 > angle1) {
				angle = StateMacros.interp(angle0, (angle1 + Math.PI * 2), t);
			} else if (spin < 0 && angle0 < angle1) {
				angle = StateMacros.interp(angle0, (angle1 - Math.PI * 2), t);
			} else {
				angle = StateMacros.interp(angle0, angle1, t);
			}
		} else {
			// TODO: maybe change the transform representation to avoid
			// conditional stuff like this. Some sort of complex number
			// representation would probably work.
			if (Math.abs(angle0 - angle1) > Math.PI)
				angle1 += Math.PI * 2;
			angle = StateMacros.interp(angle0, angle1, t);
		}
		return angle;
	}
	
	public function applyTransform(other:Transform):Transform {
		x *= other.scaleX;
		y *= other.scaleY;
		
		var pc = Math.cos(other.angle);
		var ps = Math.sin(other.angle);
		
		var newX = other.x + x * pc - y * ps;
		var newY = other.y + x * ps + y * pc;
		
		x = newX;
		y = newY;
		
		angle += other.angle;
		
		scaleX *= other.scaleX;
		scaleY *= other.scaleY;
		
		return this;
	}
	
	public function toString():String {
		return 'Transform(' + [x, y, angle, scaleX, scaleY].join(', ') + ')';
	}
}