package;

import sys.io.File;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
#if MODS_ALLOWED
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#end


using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	#if MODS_ALLOWED
		#if (haxe >= "4.0.0")
		public static var customImagesLoaded:Map<String, FlxGraphic> = new Map();
		#else
		public static var customImagesLoaded:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
		#end
	#end

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
		{
			return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
		}
	
		inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
		{
			return sound(key + FlxG.random.int(min, max), library);
		}

	inline static public function music(key:String, ?library:String)
		{
			return getPath('music/$key.$SOUND_EXT', MUSIC, library);
		}

	inline static public function voices(song:String)
		{
			return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		}

	inline static public function inst(song:String)
		{
			return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		}

	#if windows
	inline static private function returnSongFile(file:String):Sound
	{
		if(FileSystem.exists(file)) {
			if(!customSoundsLoaded.exists(file)) {
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		return null;
	}
	#end

	inline static public function image(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		var imageToReturn:FlxGraphic = addCustomGraphic(key);
		if(imageToReturn != null) return imageToReturn;
		#end
		return getPath('images/$key.png', IMAGE, library);
	}
		
	
	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		if (!ignoreMods && FileSystem.exists(mods(key)))
			return File.getContent(mods(key));

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		if(OpenFlAssets.exists(Paths.getPath(key, type))) {
			return true;
		}

		#if MODS_ALLOWED
		if(FileSystem.exists(mods(key))) {
			return true;
		}
		#end
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
		{
			return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var txtExists:Bool = false;

		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#end
	}

	public static function destroyLoadedImages(ignoreCheck:Bool = false) {
		#if MODS_ALLOWED
		if(!ignoreCheck && ClientPrefs.imagesPersist) return; //If there's 20+ images loaded, do a cleanup just for preventing a crash

		for (key in customImagesLoaded.keys()) {
			var graphic:FlxGraphic = FlxG.bitmap.get(key);
			if(graphic != null) {
				graphic.bitmap.dispose();
				graphic.destroy();
				FlxG.bitmap.removeByKey(key);
			}
		}
		Paths.customImagesLoaded.clear();
		#end
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}
	
	#if MODS_ALLOWED
	static private function addCustomGraphic(key:String):FlxGraphic {
		if(FileSystem.exists(modsImages(key))) {
			if(!customImagesLoaded.exists(key)) {
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(modsImages(key)));
				newGraphic.persist = true;
				customImagesLoaded.set(key, newGraphic);
			}
			return customImagesLoaded.get(key);
		}
		return null;
	}

	inline static public function mods(key:String) {
		return 'mods/' + key;
	}
	inline static public function modsImages(key:String) {
		return mods('images/' + key + '.png');
	}
	
	inline static public function modsXml(key:String) {
		return mods('images/' + key + '.xml');
	}
	inline static public function modsTxt(key:String) {
		return mods('images/' + key + '.xml');
	}

	inline static public function modsJson(key:String, ?library:String) {
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function modsSounds(key:String, ?library:String) {
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

 //This is the power of GAMBIAARAAAAAAAAAAAAAAAAAAAA
	#end
}