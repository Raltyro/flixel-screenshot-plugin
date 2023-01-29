# flixel-screenshot-plugin
A Haxeflixel plugin for screenshot management
Some original code from [flixel-addons](http://lib.haxe.org/p/flixel-addons).

Press F2 to screenshot, All screenshots will be saved to the `./screenshots/` folder.
You can change the path/keybind for the screenshots in the plugin class.

## Configuring:
Make sure you have `flixel` and `openfl` installed.

To install this haxelib, use the "haxelib install" command:
```
haxelib install flixel-screenshot-plugin
```
or you can use the development haxelib, using the "haxelib git" command:
```
haxelib git flixel-screenshot-plugin https://github.com/sayofthelor/flixel-screenshot-plugin/
```

In your `Project.xml` make sure this is there:
```xml
<haxelib name="flixel-screenshot-plugin" />
```

In your project's `Main.hx` file, after the `FlxGame` is initialized, add this line:
```haxe
flixel.FlxG.plugins.add(new screenshotplugin.ScreenShotPlugin());
```
And you're done!
