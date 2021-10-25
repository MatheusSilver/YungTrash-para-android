package;

import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxG;

import extension.webview.WebView;

using StringTools;

class VideoState extends MusicBeatState
{
	public static var androidPath:String = 'file:///android_asset/';

	public var nextState:FlxState;

	var text:FlxText;

	public function new(source:String, toTrans:FlxState)
	{
		super();

		if(ClientPrefs.easteregg){
		text = new FlxText(0, 0, 0, "Easter egg parça \nagora toque para continuar", 48); //Eu aprendi a mexer  nas opçoes só pra isso, por favor me mata
		text.screenCenter();
		text.alpha = 0;
		add(text);
		} else {
			text = new FlxText(0, 0, 0, "toque para continuar", 48);
			text.screenCenter();
			text.alpha = 0;
			add(text);
		}


		nextState = toTrans;

		//FlxG.autoPause = false;

		WebView.onClose=onClose;
		WebView.onURLChanging=onURLChanging;

		WebView.open(androidPath + source + '.html', false, null, ['http://exitme(.*)']);
	}

	public override function update(dt:Float) {
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				ClientPrefs.easteregg = false; //I FORGOR :skull:
				onClose();

		super.update(dt);	
	}

	function onClose(){// not working
		text.alpha = 0;
		//FlxG.autoPause = true;
		trace('close!');
		trace(nextState);
		FlxG.switchState(nextState);
	}

	function onURLChanging(url:String) {
		text.alpha = 1;
		if (url == 'http://exitme(.*)') onClose(); // drity hack lol
		trace("WebView is about to open: "+url);
	}
}