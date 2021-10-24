package;

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
		return Assets.getText(getPath(key, TEXT));
		 //NAO IMPORTA SE TA FEIO O QUE IMPORTA E FUNCIONAR
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
		#if MODS_ALLOWED
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var txtExists:Bool = false;

		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
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
		return 'preload/' + key;
	} //Ninguem gosta de você, agora já pra cama!

	inline static public function modsJson(key:String, ?library:String) {
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function modsSounds(key:String, ?library:String) {
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function modsImages(key:String, ?library:String):Dynamic {
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function modsXml(key:String, ?library:String) {
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}
 //This is the power of GAMBIAARAAAAAAAAAAAAAAAAAAAA
	inline static public function modsTxt(key:String, ?library:String) {
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
	#end
}