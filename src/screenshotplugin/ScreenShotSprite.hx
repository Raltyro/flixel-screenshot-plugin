package screenshotplugin;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

class ScreenShotSprite extends Sprite {
	public var displayPersist:Bool = false;

	var outlineBitmap:Bitmap;
	var displayBitmap:Bitmap;

	public function new() {
		super();

		addChild(outlineBitmap = new Bitmap());
		addChild(displayBitmap = new Bitmap());
	}

	public function dispose(displayPersist:Bool = false) {
		ScreenShotPlugin.disposeBitmap(outlineBitmap.bitmapData);
		if (!displayPersist) ScreenShotPlugin.disposeBitmap(displayBitmap.bitmapData);
	}

	public function setDisplay(display:BitmapData, scale:Float = .2, outline:Int = 5):ScreenShotSprite {
		dispose(displayPersist);

		displayBitmap.bitmapData = display;
		displayBitmap.scaleX = displayBitmap.scaleY = scale;
		displayBitmap.x = displayBitmap.y = outline;
		outlineBitmap.bitmapData = new BitmapData(
			Math.floor(display.width * scale + (outline * 2)), Math.floor(display.height * scale + (outline * 2)),
			false, 0xFF000000
		);

		return this;
	}
}