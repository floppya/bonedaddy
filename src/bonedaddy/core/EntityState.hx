package bonedaddy.core;

import nme.Vector;

class EntityState {
	public var bones:Vector<Bone>;
	public var skins:Vector<Skin>;
	public var boneByName:Map<String, Bone>;
	public var skinByName:Map<String, Skin>;

	public function new() {
		bones = new Vector<Bone>();
		skins = new Vector<Skin>();
		boneByName = new Map<String, Bone>();
		skinByName = new Map<String, Skin>();
	}
	
	public function addBone(bone:Bone, ?id:Int = -1) {
		if (id == -1) {
			id = bone.id = bones.length;
		} else {
			bone.id = id;
		}
		while (bones.length < id) {
			bones.push(null);
		}
		bones[bone.id] = bone;
		if (bone.name != '')
			boneByName.set(bone.name, bone);
	}
	
	public function addSkin(skin:Skin) {
		skin.id = skins.length;
		skins.push(skin);
		if (skin.name != '')
			skinByName.set(skin.name, skin);
	}
	
	inline public function rootBone():Bone {
		return bones.length > 0 ? bones[0] : null;
	}
	
	inline public function copy(other:EntityState) {
		var numBones = bones.length;
		var numSkins = skins.length;
		for (i in 0...numBones) {
			var otherBone = other.bones[i];
			var thisBone = bones[i];
			thisBone.copy(otherBone);
		}
		for (i in 0...numSkins) {
			var otherSkin = other.skins[i];
			var thisSkin = skins[i];
			thisSkin.copy(otherSkin);
		}
	}
	
	inline public function clone():EntityState {
		var entity = new EntityState();
		for (bone in bones) {
			var newBone = bone.clone();
			entity.addBone(newBone);
		}
		for (skin in skins) {
			var newSkin = skin.clone();
			entity.addSkin(newSkin);
		}
		return entity;
	}
	
	inline public function interpolate(entity0:EntityState, entity1:EntityState, t:Float, ?shortest:Bool=false) {
		interpolateBones(entity0, entity1, t, shortest);
		interpolateSkins(entity0, entity1, t, shortest);
	}
	
	inline public function interpolateBones(entity0:EntityState, entity1:EntityState, t:Float, ?shortest:Bool=false) {
		var numBones = bones.length;
		var entity0Bones = entity0.bones;
		var entity1Bones = entity1.bones;
		for (i in 0...numBones) {
			var bone = bones[i];
			bone.interpolate(entity0Bones[i], entity1Bones[i], t, shortest);
		}
	}
		
	inline public function interpolateSkins(entity0:EntityState, entity1:EntityState, t:Float, ?shortest:Bool=false) {
		var numSkins = skins.length;
		var entity0Skins = entity0.skins;
		var entity1Skins = entity1.skins;
		for (i in 0...numSkins) {
			var skin = skins[i];
			skin.interpolate(entity0Skins[i], entity1Skins[i], t, shortest);
		}
	}
	
	// transform the hierarchy to entity-space from bone-local space.
	inline public function bakeHierarchy(target:EntityState) {
		bakeBones(target.bones);
		bakeSkins(target.skins, target.bones);
	}
	
	inline public function bakeBones(targetBones:Vector<Bone>) {
		var numBones = bones.length;
		for (i in 0...numBones) {
			var srcBone = bones[i];
			var targetBone = targetBones[i];
			targetBone.copy(srcBone);
			if (targetBone.parent != -1) {
				var parent = targetBones[targetBone.parent];
				targetBone.transform.applyTransform(parent.transform);
			}
		}
	}
	
	inline public function bakeSkins(targetSkins:Vector<Skin>, targetBones:Vector<Bone>) {
		var numSkins = skins.length;
		for (i in 0...numSkins) {
			var srcSkin = skins[i];
			var targetSkin = targetSkins[i];
			targetSkin.copy(srcSkin);
			if (targetSkin.parent != -1) {
				var parent = targetBones[targetSkin.parent];
				targetSkin.transform.applyTransform(parent.transform);
			}
		}
	}
}