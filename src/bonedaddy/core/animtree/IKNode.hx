package bonedaddy.core.animtree;

import bonedaddy.core.Bone;
import bonedaddy.core.EntityState;
import nme.geom.Point;
import nme.Vector;

class IKNode extends AnimNode {
	public var baseAnimNode:AnimNode;
	public var targetPosition(get, set):Point;
	public var tipBoneName:String;
	public var depth:Int;
	public var positiveTipAngle:Bool = false;
	var entityState:EntityState;
	var flattenedEntityState:EntityState;
	var bones:Vector<Bone>;
	var _targetPosition:Point;
	var _targetIsDirty:Bool = false;

	public function new(?baseNode:AnimNode, ?tipBoneName:String, ?depth:Int=0, ?positiveTipAngle:Bool=false) {
		super();
		this.baseAnimNode = baseNode;
		this.tipBoneName = tipBoneName;
		this.depth = depth;
		this.positiveTipAngle = positiveTipAngle;
		bones = new Vector<Bone>();
		_targetPosition = new Point(0.0, 0.0);
		
	}

	override public function init(tree:AnimTree):Void {
		super.init(tree);
		baseAnimNode.init(tree);
		// create a list of the interesting bones
		entityState = tree.animationSet.entityStatePool.fetch();
		flattenedEntityState = tree.animationSet.entityStatePool.fetch();
		var bone = entityState.boneByName.get(tipBoneName);
		if (bone == null)
			throw 'no bone named ' + tipBoneName;
		bones.push(bone);
		for (i in 0...depth) {
			if (bone.parent == -1)
				break;
			bone = entityState.bones[bone.parent];
			bones.push(bone);
		}
	}

	override public function update(dt:Float):Void {
		baseAnimNode.update(dt);
	}

	override public function getEntityState(entityState:EntityState):Void {
		baseAnimNode.getEntityState(entityState);
		// solve IK
		if (_targetIsDirty) {
			applyBonesTo(entityState);
			entityState.bakeHierarchy(flattenedEntityState); // TODO: a "bakeBranch" function
			solveIk();
			_targetIsDirty = false;
		}
		applyBonesTo(entityState);
	}
	
	inline function applyBonesTo(entityState:EntityState) {
		for (bone in bones) {			
			entityState.bones[bone.id].copy(bone);
		}
	}
	
	function get_targetPosition() {
		return _targetPosition;
	}

	function set_targetPosition(val:Point) {
		_targetIsDirty = true;
		_targetPosition.copyFrom(val);
		return _targetPosition;
	}
	
	function solveIk() {
		if (bones.length == 2) {
			solveIk2Bone();
		} else {
			solveIkCcd();
		}
	}
	
	function solveIkCcd(maxIterations:Int=10) {
		var finished:Bool = false;
		var numIterations:Int = 0;
		while (!finished && numIterations != maxIterations) {
			finished = _ikCcdIteration();
			numIterations += 1;
		}
		//trace('f=' + finished + ', its=' + numIterations);
	}
	
	inline function _ikCcdIteration():Bool {
		// I adapted this from http://www.ryanjuckett.com/programming/animation/21-cyclic-coordinate-descent-in-2d?showall=1
		// which can be used according to the following license:
		/******************************************************************************
		  Copyright (c) 2008-2009 Ryan Juckett
		  http://www.ryanjuckett.com/
		 
		  This software is provided 'as-is', without any express or implied
		  warranty. In no event will the authors be held liable for any damages
		  arising from the use of this software.
		 
		  Permission is granted to anyone to use this software for any purpose,
		  including commercial applications, and to alter it and redistribute it
		  freely, subject to the following restrictions:
		 
		  1. The origin of this software must not be misrepresented; you must not
			 claim that you wrote the original software. If you use this software
			 in a product, an acknowledgment in the product documentation would be
			 appreciated but is not required.
		 
		  2. Altered source versions must be plainly marked as such, and must not be
			 misrepresented as being the original software.
		 
		  3. This notice may not be removed or altered from any source
			 distribution.
		******************************************************************************/
		var result:Bool = false;
		var tipBone = bones[0];
		var flatTipBone = flattenedEntityState.bones[tipBone.id];
		var targetX = targetPosition.x;
		var targetY = targetPosition.y;
		var endX = flatTipBone.transform.x;
		var endY = flatTipBone.transform.y + 10; // HACK: need to calculate bone length somewhere
		var arrivalDistSqr = 2.0;
		var epsilon = 0.0001;
		var trivialArcLength = 0.00001;
		var modifiedBones = false;
		trace(targetPosition);
		for (i in 0...bones.length) {
			var thisBone = bones[i];
			var thisFlatBone = flattenedEntityState.bones[thisBone.id];
			var thisFlatBoneX = thisFlatBone.transform.x;
			var thisFlatBoneY = thisFlatBone.transform.y;

			var curToEndX = endX - thisFlatBoneX;
			var curToEndY = endY - thisFlatBoneY;
			var curToEndMag = Math.sqrt(curToEndX * curToEndX + curToEndY * curToEndY);

			var curToTargetX = targetX - thisFlatBoneX;
			var curToTargetY = targetY - thisFlatBoneY;
			var curToTargetMag = Math.sqrt(curToTargetX * curToTargetX + curToTargetY * curToTargetY);

			var cosRotAng:Float;
			var sinRotAng:Float;
			var endTargetMag:Float = curToEndMag * curToTargetMag;
			if (endTargetMag <= epsilon) {
				cosRotAng = 1.0;
				sinRotAng = 0.0;
			} else {
				cosRotAng = (curToEndX * curToTargetX + curToEndY * curToTargetY) / endTargetMag;
				sinRotAng = (curToEndX * curToTargetY - curToEndY * curToTargetX) / endTargetMag;
			}
			var rotAng = Math.acos(Math.max(-1.0, Math.min(1.0, cosRotAng)));
			if (sinRotAng < 0.0)
				rotAng = -rotAng;
			
			endX = thisFlatBoneX + cosRotAng * curToEndX - sinRotAng * curToEndY;
			endY = thisFlatBoneY + sinRotAng * curToEndX + cosRotAng * curToEndY;
			var newAngle = rotAng % (2 * Math.PI);
			if (newAngle < -Math.PI)
				newAngle += 2 * Math.PI;
			else if (newAngle > Math.PI)
				newAngle -= 2 * Math.PI;
			thisBone.transform.angle = newAngle;

			var endToTargetX = targetX - endX;
			var endToTargetY = targetY - endY;
			var sqrError = endToTargetX * endToTargetX + endToTargetY * endToTargetY;
			if (sqrError <= arrivalDistSqr) {
				result = true;
				break;
			}
			if (!modifiedBones && Math.abs(rotAng) * curToEndMag > trivialArcLength) {
				modifiedBones = true;
			}
		}
		if (!result && !modifiedBones) {
			result = true;
		}
		return result;
	}
	
	function solveIk2Bone():Bool {
		// I adapted this from http://www.ryanjuckett.com/programming/animation/22-constraint-relaxation-ik-in-2d
		// which can be used according to the following license:
		/******************************************************************************
		  Copyright (c) 2008-2009 Ryan Juckett
		  http://www.ryanjuckett.com/
		 
		  This software is provided 'as-is', without any express or implied
		  warranty. In no event will the authors be held liable for any damages
		  arising from the use of this software.
		 
		  Permission is granted to anyone to use this software for any purpose,
		  including commercial applications, and to alter it and redistribute it
		  freely, subject to the following restrictions:
		 
		  1. The origin of this software must not be misrepresented; you must not
			 claim that you wrote the original software. If you use this software
			 in a product, an acknowledgment in the product documentation would be
			 appreciated but is not required.
		 
		  2. Altered source versions must be plainly marked as such, and must not be
			 misrepresented as being the original software.
		 
		  3. This notice may not be removed or altered from any source
			 distribution.
		******************************************************************************/
		var result:Bool = true;
		var epsilon = 0.0001;
		var angleTip:Float;
		var angleRoot:Float;
		var tipBone = bones[0];
		var rootBone = bones[1];
		var flatTipBone = flattenedEntityState.bones[tipBone.id];
		var flatRootBone = flattenedEntityState.bones[rootBone.id];
		var originX = flatRootBone.transform.x;
		var originY = flatRootBone.transform.y;
		var targetX = targetPosition.x - originX;
		var targetY = targetPosition.y - originY;
		var targetDistSqr = targetX * targetX + targetY * targetY;
		var tipBoneX = flatTipBone.transform.x - originX;
		var tipBoneY = flatTipBone.transform.y - originY;
		// TODO: precalculate actual length for tip bone
		var lengthTip = 30; 
		var lengthRoot = Math.sqrt(tipBoneX * tipBoneX + tipBoneY * tipBoneY);
		
		var sinAngleTip:Float;
		var cosAngleTip:Float;
		var cosAngleTipDenom = 2 * lengthTip * lengthRoot;
		if (cosAngleTipDenom > epsilon) {
			cosAngleTip = (targetDistSqr - lengthRoot * lengthRoot - lengthTip * lengthTip ) / cosAngleTipDenom;
			// if our result is not in the legal cosine range, we can not find a
			// legal solution for the target
			if (cosAngleTip < -1.0 || cosAngleTip > 1.0) {
				result = false;
			}
			// clamp our value into range so we can calculate the best
			// solution when there are no valid ones
			cosAngleTip = Math.max(-1.0, Math.min(1.0, cosAngleTip));
			angleTip = Math.acos(cosAngleTip);
			if (!positiveTipAngle)
				angleTip = -angleTip;
			sinAngleTip = Math.sin(angleTip);
		} else {
			// At leaset one of the bones had a zero length. This means our
			// solvable domain is a circle around the origin with a radius
			// equal to the sum of our bone lengths.
			var totalLenSqr = (lengthRoot + lengthTip) * (lengthRoot + lengthTip);
			if (targetDistSqr < totalLenSqr - epsilon ||
					targetDistSqr > totalLenSqr + epsilon) {
				result = false;
			}
			angleTip = 0.0;
			cosAngleTip = 1.0;
			sinAngleTip = 0.0;
		}	
		// Compute the value of angle1 based on the sine and cosine of angle2
		var triAdjacent = lengthRoot + lengthTip * cosAngleTip;
		var triOpposite = lengthTip * sinAngleTip;
	 
		var tanY = targetY * triAdjacent - targetX * triOpposite;
		var tanX = targetX * triAdjacent + targetY * triOpposite;
	 
		// Note that it is safe to call Atan2(0,0) which will happen if targetX and
		// targetY are zero
		angleRoot = Math.atan2(tanY, tanX);

		tipBone.transform.angle = angleTip;
		// HACK: something is not quite right
		rootBone.transform.angle = angleRoot + Math.PI * 0.5;

		return result;
	}
	
	public function setEntityState(other:EntityState) {
		for (bone in bones) {
			bone.copy(other.bones[bone.id]);
		}
	}

	override public function clone():AnimNode {
		var node = new IKNode();
		node.copy(cast this);
		return cast node;
	}

	override public function copy(other:AnimNode) {
		super.copy(other);
		var ikOther:IKNode = cast other;
		tipBoneName = ikOther.tipBoneName;
		depth = ikOther.depth;
		baseAnimNode = ikOther.baseAnimNode.clone();
	}
}