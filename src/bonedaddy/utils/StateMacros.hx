package bonedaddy.utils;

import haxe.macro.Expr;

class StateMacros {
	macro static public function interp(x0:Expr, x1:Expr, t:Expr) {
		return macro $t * ($x1 - $x0) + $x0;
	}
	
	macro static public function interpAngle(x0:Expr, x1:Expr, t:Expr) {
		return macro {
			$t * ($x1 - $x0) + $x0;
		}
	}
}
