package screenshotplugin;

import sys.io.File;
import sys.FileSystem;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.utils.ByteArray;

import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
#if FLX_SOUND_SYSTEM
import flixel.system.FlxAssets;
#end
import flixel.FlxBasic;
import flixel.FlxG;

using StringTools;

class ScreenShotPlugin extends FlxBasic {
	public static var screenshotSprites:Array<ScreenShotSprite> = [];
	public static var poolScreenshotSprites:Array<ScreenShotSprite> = [];
	public static var screenshotKeys:Array<FlxKey> = [FlxKey.F2];
	public static var screenshotDirectory:String = "./screenshots/";
	public static var screenshotSound:String = "embed/screenshot.wav";
	public static var screenshotScale:Float = .2;
	public static var screenshotDelay:Float = .5;

	private static var lastScreenshotTime:Float = 0;
	private static var initialized:Bool = false;

	private var container:Sprite;
	private var flashSprite:Sprite;
	private var flashBitmap:Bitmap;
	private var screenshotSprite:Sprite;
	private var outlineBitmap:Bitmap;
	private var shotDisplayBitmap:Bitmap;
	private var flashTween:FlxTween;

	public function new() {
		super();

		if (initialized) {
			FlxG.plugins.remove(this);
			destroy();
			return;
		}
		initialized = true;

		container = new Sprite();

		flashSprite = new Sprite();
		flashSprite.alpha = 0;

		flashSprite.addChild(flashBitmap = new Bitmap(new BitmapData(1, 1, false, 0xFFFFFFFF)));
		container.addChild(flashSprite);

		FlxG.stage.addChild(container);
		FlxG.stage.addEventListener(Event.RESIZE, onResize);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		onResize();
	}

	public function capture():Void {
		if (!FileSystem.exists(screenshotDirectory)) FileSystem.createDirectory(screenshotDirectory);

		#if FLX_SOUND_SYSTEM
		var sound = FlxAssets.getSound(screenshotSound);
		if (sound != null)
			FlxG.sound.load(sound).play();
		#end

		var width:Int = FlxG.stage.stageWidth;
		var height:Int = FlxG.stage.stageHeight;

		var bounds:Rectangle = new Rectangle(0, 0, width, height);
		var shot:BitmapData = new BitmapData(width, height, true, 0);
        shot.draw(FlxG.stage, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));

		var png:ByteArray = shot.encode(bounds, new openfl.display.PNGEncoderOptions());
		File.saveContent('$screenshotDirectory/Screenshot${Date.now().toString().split(":").join("-")}.png', png.toString());
		png.clear();

		var sprite:ScreenShotSprite = poolScreenshotSprites.pop();
		if (sprite == null) sprite = new ScreenShotSprite();
		container.addChild(sprite.setDisplay(shot, screenshotScale));
		screenshotSprites.push(sprite);

		flashSprite.alpha = .8;

		sprite.x = sprite.y = 3;
		sprite.alpha = 1;

		if (flashTween != null) flashTween.cancel();
		flashTween = FlxTween.tween(flashSprite, {alpha: 0}, 0.2);
		FlxTween.tween(sprite, {alpha: 0.5}, 3, {onComplete: (_) -> {
			FlxTween.tween(sprite, {y: -sprite.height}, 0.1, {onComplete: (_) -> {
				container.removeChild(sprite);
				poolScreenshotSprites.push(sprite);
				sprite.dispose();
			}});
		}});
	}

	function handleInput(evt:KeyboardEvent) {
		@:privateAccess if (screenshotKeys.contains(FlxKey.toStringMap.get(evt.keyCode))) {
			var now:Float = Sys.time();
			if (now > lastScreenshotTime + screenshotDelay) {
				lastScreenshotTime = now;
				capture();
			}
		}
	}

	function onResize(?_) {
		var width:Int = FlxG.stage.stageWidth;
		var height:Int = FlxG.stage.stageHeight;

		flashBitmap.scaleX = width;
		flashBitmap.scaleY = height;
	}

	@:allow(screenshotplugin.ScreenShotSprite)
	private static function disposeBitmap(bitmap:BitmapData) {
		if (bitmap == null) return;

		bitmap.lock();
		@:privateAccess if (bitmap.__texture != null) bitmap.__texture.dispose();
		if (bitmap.image != null) bitmap.image.data = null;
		bitmap.disposeImage();
	}
}