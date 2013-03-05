package ;

import bonedaddy.core.animtree.AnimationNode;
import bonedaddy.core.animtree.AnimTree;
import bonedaddy.core.animtree.BlendNode;
import bonedaddy.core.animtree.IKNode;
import bonedaddy.loader.SCMLLoader;
import bonedaddy.renderer.nme.AnimTreeSprite;
import bonedaddy.renderer.nme.EntityStateSprite;
import bonedaddy.renderer.nme.NMEFactory;
import bonedaddy.renderer.nme.TilesheetAtlas;
import bonedaddy.utils.ImageAtlas;
import nme.Assets;
import nme.display.FPS;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.events.TimerEvent;
import nme.geom.Point;
import nme.Lib;
import nme.utils.Timer;

class Main extends Sprite 
{
	var inited:Bool;
	var esSprite:EntityStateSprite;
	var animTreeSprite:AnimTreeSprite;
	var blendNode:BlendNode;
	var ikNode:IKNode;
	var timer:Timer;
	var _goLeft:Bool;
	var _goRight:Bool;
	var lastTime:Int = 0;
	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		var imageAtlas = ImageAtlas.fromStarling('spriter/zippy_atlas.xml');
		var scml = new SCMLLoader();
		scml.load('spriter/zippy.scml');
		var nmeFactory = new NMEFactory();
		// first add your atlas
		var tilesheetAtlas = nmeFactory.addImageAtlas(imageAtlas);
		// then the loaders
		nmeFactory.assimilateLoader(scml);

		var animTree = new AnimTree();
		blendNode = new BlendNode(new AnimationNode('idle'), new AnimationNode('walk'));
		blendNode.weight0 = 0.5;
		//ikNode = new IKNode(blendNode, 'right_lower_leg', 1, true);
		ikNode = new IKNode(blendNode, 'right_hand', 1);
		animTree.rootAnimNode = ikNode;
		animTreeSprite = nmeFactory.getAnimTreeSprite('zippy', animTree, tilesheetAtlas);
		animTreeSprite.x = 200;
		//animTreeSprite.y = 600;
		animTreeSprite.y = 400;
		animTreeSprite.scaleX = animTreeSprite.scaleY = 0.6;
		animTreeSprite.updateBitmap();
		addChild(animTreeSprite);
		
		//esSprite = nmeFactory.getEntityStateSprite('zippy', tilesheetAtlas);
		//esSprite.x = 200;
		//esSprite.y = 400;
		//esSprite.scaleX = esSprite.scaleY = 0.6;
		//esSprite.updateBitmap();
		//addChild(esSprite);

		var fps = new FPS(10, 10, 0xFFFFFF);
		addChild(fps);
		
		Lib.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		Lib.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		
		timer = new Timer(20);
		timer.addEventListener(TimerEvent.TIMER, onTick);
		timer.start();
	}
	
	function onTick(event:TimerEvent) {
		var dir:Int = 0;
		if (_goLeft)
			dir -= 1;
		if (_goRight)
			dir += 1;
		if (dir != 0) {
			var w = blendNode.weight0;
			w -= dir / 100.0;
			blendNode.weight0 = Math.min(1.0, Math.max(0.0, w));
		}

		var time = Lib.getTimer();
		var dt = (time - lastTime) / 1000.0;
		animTreeSprite.advanceTime(dt);
		lastTime = time;
	}
	
	function onKeyDown(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case 37:
				_goLeft = true;
			case 39:
				_goRight = true;
		}
	}
	
	function onKeyUp(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case 37:
				_goLeft = false;
			case 39:
				_goRight = false;
		}
	}
	
	function onMouseMove(event:MouseEvent):Void {
		var pos = new Point(event.stageX, event.stageY);
		pos = animTreeSprite.globalToLocal(pos);
		ikNode.targetPosition = pos;
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = nme.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
