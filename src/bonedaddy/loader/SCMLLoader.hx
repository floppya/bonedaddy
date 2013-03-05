package bonedaddy.loader;

import bonedaddy.core.Animation;
import bonedaddy.core.AnimationSet;
import bonedaddy.core.Bone;
import bonedaddy.core.EntityState;
import bonedaddy.core.Key;
import bonedaddy.core.Skin;
import haxe.xml.Fast;
import nme.Assets;
import nme.Vector;

class SCMLLoader extends BaseBonedaddyLoader {
	public function new() {
		super();
	}
	
	override public function load(filename:String) {
		var xmlText = Assets.getText(filename);
		var root = new Fast(Xml.parse(xmlText).firstElement());
		for (folderNode in root.nodes.folder) {
			var folderFilenames = new Vector<String>();
			filenames.push(folderFilenames);
			for (fileNode in folderNode.nodes.file) {
				folderFilenames.push(fileNode.att.name);
			}
		}
		for (entityNode in root.nodes.entity) {
			var animationSet = animationSetFromXml(entityNode);
			animationSets.push(animationSet);
			animationSetByName.set(animationSet.name, animationSet);
		}
	}
	
	function animationSetFromXml(node:Fast):AnimationSet {
		var animationSet = new AnimationSet();
		animationSet.name = node.has.name ? node.att.name : '';
		for (animationNode in node.nodes.animation) {
			var animation = animationFromXml(animationNode);
			animationSet.addAnimation(animation);
		}
		return animationSet;
	}
	
	function animationFromXml(node:Fast):Animation {
		var animation = new Animation();
		animation.id = Std.parseInt(node.att.id);
		animation.name = node.att.name;
		animation.length = Std.parseInt(node.att.length);
		animation.looping = node.has.looping ? node.att.looping == 'true' : true;
		
		var timelineSkinMap = new Map<Int, Int>();
		var lastKey:Key = null;
		for (keyNode in node.node.mainline.nodes.key) {
			var timelineBoneMap = new Map<Int, Int>();
			var time = keyNode.has.time ? Std.parseInt(keyNode.att.time) : 0;
			var entityState = new EntityState();
			
			var key = new Key(Std.parseInt(keyNode.att.id), time, entityState);
			if (lastKey != null) {
				lastKey.length = time - lastKey.time;
			}
			for (refNode in keyNode.nodes.bone_ref) {
				var bone = new Bone();
				var boneId = Std.parseInt(refNode.att.id);
				var timelineId = Std.parseInt(refNode.att.timeline);
				timelineBoneMap.set(boneId, timelineId);
				bone.parent = refNode.has.parent ? Std.parseInt(refNode.att.parent) : -1;
				if (bone.parent != -1) {
					bone.parent = timelineBoneMap.get(bone.parent);
				}
				key.state.addBone(bone, timelineId);
				var timelineId = Std.parseInt(refNode.att.timeline);
				timelineBoneMap.set(boneId, timelineId);
			}
			for (refNode in keyNode.nodes.object_ref) {
				var skin = new Skin();
				var skinId = Std.parseInt(refNode.att.id);
				skin.parent = refNode.has.parent ? Std.parseInt(refNode.att.parent) : -1;
				if (skin.parent != -1) {
					skin.parent = timelineBoneMap.get(skin.parent);
				}
				skin.zIndex = refNode.has.z_index ? Std.parseInt(refNode.att.z_index) : 0;
				key.state.addSkin(skin);
				var timelineId = Std.parseInt(refNode.att.timeline);
				timelineSkinMap.set(timelineId, skinId);
			}
			animation.addKey(key);
			lastKey = key;
		}
		lastKey.length = animation.length - lastKey.time; // set length for the final key
		
		for (timelineNode in node.nodes.timeline) {
			var timelineId = Std.parseInt(timelineNode.att.id);
			var timelineName = timelineNode.has.name ? timelineNode.att.name : '';
			var lastAngle:Float = 0.0;
			var lastKey:Key = null;
			for (keyNode in timelineNode.nodes.key) {
				var keyId = Std.parseInt(keyNode.att.id);
				var spin = keyNode.has.spin ? -Std.parseInt(keyNode.att.spin) : -1;
				var key = animation.getKey(keyId);
				if (timelineSkinMap.exists(timelineId)) {
					// this timeline refers to a skin
					var skin = key.state.skins[timelineSkinMap.get(timelineId)];
					var skinNode = keyNode.node.object;
					var transform = skin.transform;
					skin.name = timelineName;
					skin.folder = Std.parseInt(skinNode.att.folder);
					skin.file = Std.parseInt(skinNode.att.file);
					transform.x = Std.parseFloat(skinNode.att.x);
					transform.y = -Std.parseFloat(skinNode.att.y);
					transform.angle = skinNode.has.angle ? -Std.parseFloat(skinNode.att.angle) * Math.PI / 180.0 : 0.0;
					transform.scaleX = skinNode.has.scale_x ? Std.parseFloat(skinNode.att.scale_x) : 1.0;
					transform.scaleY = skinNode.has.scale_y ? Std.parseFloat(skinNode.att.scale_y) : 1.0;
					transform.spin = spin;
					skin.pivotX = skinNode.has.pivot_x ? Std.parseFloat(skinNode.att.pivot_x) : 0.0;
					skin.pivotY = skinNode.has.pivot_y ? (1.0 - Std.parseFloat(skinNode.att.pivot_y)) : 0.0;
					skin.opacity = skinNode.has.opacity ? Std.parseFloat(skinNode.att.opacity) : 1.0;
				} else { 
					// timeline refers to a bone
					var bone = key.state.bones[timelineId];
					var boneNode = keyNode.node.bone;
					var transform = bone.transform;
					bone.name = timelineName;
					transform.x = Std.parseFloat(boneNode.att.x);
					transform.y = -Std.parseFloat(boneNode.att.y);
					transform.angle = boneNode.has.angle ? -Std.parseFloat(boneNode.att.angle) * Math.PI / 180.0 : 0.0;
					transform.scaleX = boneNode.has.scale_x ? Std.parseFloat(boneNode.att.scale_x) : 1.0;
					transform.scaleY = boneNode.has.scale_y ? Std.parseFloat(boneNode.att.scale_y) : 1.0;
					transform.spin = spin;
				}
				lastKey = key;
			}
		}
		return animation;
	}
}