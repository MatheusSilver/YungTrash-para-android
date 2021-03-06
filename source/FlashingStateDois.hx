package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingStateDois extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Aviso HIPER ULTRA MEGA IMPORTANTE!\n\n
			Este mod tem opçoes anti epilepsia! \n
			Port NÃO oficial feito pela Team Silver no prototípo da BS Engine!\n
			Isto não é, e nem nunca será aprovado pelo BeastlyChip ou Lone\n\n
			Agora sim, vambora!!! Aperte A para começar\n 
			Ou algum outro botao secreto para ver algo idiota antes.",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		#if mobileC
		addVirtualPad(NONE, A);
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = FlxG.android.justReleased.BACK;
			if (controls.ACCEPT) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				}
			}
			if (FlxG.android.justReleased.BACK) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(back) {
					ClientPrefs.easteregg = true;
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('secretSound')); //Porque é legal! Apenas!
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							LoadingState.loadAndSwitchState(new VideoState('assets/videos/bigshot', new TitleState()));
						});
					});
				}
			}
		}
		super.update(elapsed);
	}
}