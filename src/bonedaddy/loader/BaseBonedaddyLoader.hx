package bonedaddy.loader;

import bonedaddy.core.AnimationSet;
import nme.Vector;

class BaseBonedaddyLoader {
	var animationSets:Vector<AnimationSet>;
	var animationSetByName:Map<String, AnimationSet>;
	var filenames:Vector<Vector<String>>;
	
	public function new() {
		animationSets = new Vector<AnimationSet>();
		animationSetByName = new Map<String, AnimationSet>();
		filenames = new Vector<Vector<String>>();
	}
	
	public function getAnimationSets():Map<String, AnimationSet> {
		return animationSetByName;
	}
	
	public function getFilenameIndex():Vector<Vector<String>> {
		return filenames;
	}

	public function load(filename:String):Void {
		
	}
}
