package terrylib.util;

import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
#if !(flash || html5)
import sys.io.File;
import sys.FileSystem.*;
import sys.io.FileInput;
import sys.io.FileOutput;
import gamecontrol.*;
#end
import haxegon.*;

class Fileaccess {
	public static function init():Void {
		for (i in 0...2000) {
			directorylisting.push("");
			subdirectorylisting.push("");
		}
		directorysize = 0;
		subdirectorysize = 0;
	}
	
	#if !(flash || html5)
	
	
	public static function read_levelstring(filename:String):Bool {
		filename = folderoffset + filename;
		try {
			World.levelstring = File.getContent(filename);  
		}
		catch (unknown : Dynamic) {
			trace(unknown);
			return false;
		}
		return true;
	}
	
	public static function write_levelstring(filename:String):Bool {
		filename = folderoffset + filename;
		try {
			var file = File.write(filename, false);
			file.writeString(World.levelstring);
			file.close();
		}
		catch (unknown : Dynamic) {
			trace(unknown);
			return false;
		}
		return true;
	}
	
	public static function createdirectory(stagename:String, newdir:String):Void {
		//Ok, create directory "newdir" in stage stagename.
		if (stagename != World.stage) World.stage = stagename;
		if (World.stage == "") {
			filestring = "levels/" + newdir;
		}else {
			filestring = "levels/" + World.stage + "/" + newdir;
		}
		filestring = folderoffset + filestring;
		
		if (!exists(filestring)) {
			createDirectory(filestring);
		}
	}
	
	public static function getdirectorylisting(stagename:String):Void {
		//Load in a given map
		if (stagename != World.stage) World.stage = stagename;
		if (World.stage == "") {
			filestring = "levels/";
		}else {
			filestring = "levels/" + World.stage + "/";
		}
		
		filestring = folderoffset + filestring;
		rawdirectorylist = readDirectory(filestring);
		directorysize = rawdirectorylist.length;
		for (i in 0...directorysize) {
			directorylisting[i] = rawdirectorylist[i];
			//help.getroot(help.getlastbranch(rawdirectorylist[i].url, "/"), ".");
		}
	}
	
	public static function loadscriptfile(filename:String):Bool {
		filename = folderoffset + "scripts/" + filename + ".txt";
		
		try {
			var filein = File.read(filename, false);
			while (true) { 
				try { 
					currentline = filein.readLine();
					if (currentline != "") Script.add(currentline);
				} 
				catch (e:haxe.io.Eof) { break; }
			} 
			return true;
		}
		catch (unknown : Dynamic) {
			trace(unknown);
			return false;
		}
		return false;
	}
	
	
	public static function createscriptcache():Bool {
		//Create a level cache file by spidering through all the external scripts. 
		var cachestring:String = "";
		
		//Boilerplate begin:
		cachestring += "//Generated by code: Never edit this file by hand!\n";
		cachestring += "package config;\n";
		cachestring += "\n";
		cachestring += "import haxegon.Game;\n";
		cachestring += "\n";
		cachestring += "class Scriptcache {\n";
		cachestring += "	public static function localloadscript(scriptname:String):Bool {\n";
		
		//Get stages
		filestring = folderoffset + "scripts/";
		rawdirectorylist = readDirectory(filestring);
		directorysize = rawdirectorylist.length;
		for (i in 0...directorysize) {
			directorylisting[i] = Help.getroot(rawdirectorylist[i], ".");
			cachestring += "    if (scriptname == \"" + directorylisting[i] + "\") {\n";
			
			filestring = folderoffset + "scripts/" + directorylisting[i] + ".txt";
			
			try {
				var filein = File.read(filestring, false);
				while (true) { 
					try { 
						currentline = filein.readLine();
						if (currentline != "") {
							cachestring += "      s(\""+currentline+"\");\n";
						}else {
							cachestring += "      \n";
						}
					} 
					catch (e:haxe.io.Eof) { break; }
				} 
			}
			catch (unknown : Dynamic) {	trace(unknown);	}
			
		  cachestring += "		  return true;\n";
			cachestring += "    }\n";
		}
		
		//Boilerplate end:
		cachestring += "		return false;\n";
		cachestring += "  }\n";
		cachestring += "  \n";
		cachestring += "  public static function s(t:String):Void {Game.add(t);}\n";
		cachestring += "}\n";
		
		var filename:String = folderoffset + "src/config/Scriptcache.hx";
		try {
			var file = File.write(filename, false);
			file.writeString(cachestring);
			file.close();
		}
		catch (unknown : Dynamic) {
			trace(unknown);
			return false;
		}
		return true;
	}
	
	public static function createlevelcache():Bool {
		//Create a level cache file by spidering through all the external levels. 
		var cachestring:String = "";
		
		//Boilerplate begin:
		cachestring += "//Generated by code: Never edit this file by hand!\n";
		cachestring += "package config;\n";
		cachestring += "\n";
		cachestring += "import terrylib.World;\n";
		cachestring += "\n";
		cachestring += "class Levelcache {\n";
		cachestring += "	public static function localloadmap(s:String, r:String):Bool {\n";
		
		//Get stages
		filestring = folderoffset + "levels/";
		rawdirectorylist = readDirectory(filestring);
		directorysize = rawdirectorylist.length;
		for (i in 0...directorysize) {
			directorylisting[i] = rawdirectorylist[i];
			cachestring += "    if (s == \"" + directorylisting[i] + "\") {\n";
			
			filestring = folderoffset + "levels/" + directorylisting[i] + "/";
			rawsubdirectorylist = readDirectory(filestring);
			subdirectorysize = rawsubdirectorylist.length;
			for (j in 0...subdirectorysize) {
				subdirectorylisting[j] = rawsubdirectorylist[j];
				if (Help.Instr(subdirectorylisting[j], ".txt") != 0) {
					cachestring += "      if (r == \"" + Help.getroot(subdirectorylisting[j], ".") + "\") {\n";
					cachestring += "        World.loadmapfromstring(s, r, \"" + getfilestring(folderoffset + "levels/" + directorylisting[i] + "/" + subdirectorylisting[j]) + "\"); return true;\n";
					cachestring += "      }\n";
				}
			}
			cachestring += "    }\n";
		}
		
		//Boilerplate end:
		cachestring += "		return false;\n";
		cachestring += "  }\n";
		cachestring += "}\n";
		
		var filename:String = folderoffset + "src/config/Levelcache.hx";
		try {
			var file = File.write(filename, false);
			file.writeString(cachestring);
			file.close();
		}
		catch (unknown : Dynamic) {
			trace(unknown);
			return false;
		}
		return true;
	}
	
	public static function getfilestring(filename:String):String {
		//A way that works, but that is very slow:
		//return Help.removenewlines(File.getContent(filename));
		//A better way: read line by line, and put it altogther.
		var localfilestring:String = "";
		
		var filein = File.read(filename, false);
		while(true){ try{ localfilestring += filein.readLine(); } catch(e:haxe.io.Eof){ break; }} 
    return localfilestring;
	}
	
	#else
	
	public static function write_levelstring(filename:String):Bool {
		trace("Error (in write_levelstring): Cannot access files in flash");
		return false;
	}
	
	public static function createdirectory(stagename:String, newdir:String):Void {
		trace("Error (in createdirectory): Cannot access files in flash");
	}
	
	public static function getdirectorylisting(stagename:String):Void {
		trace("Error (in getdirectorylisting): Cannot access files in flash");
	}
	
	public static function loadscriptfile(filename:String):Bool {
		trace("Error (in loadscriptfile): Cannot access files in flash");
	  return false;	
	}
	
	public static function createscriptcache():Bool {
		trace("Error (in createscriptcache): Cannot access files in flash");
	  return false;	
	}
	
	public static function createlevelcache():Bool {
		trace("Error (in createlevelcache): Cannot access files in flash");
	  return false;	
	}
	
	#end
	
	public static var currentline:String;
	public static var filestring:String;
	public static var rawdirectorylist:Array<String> = new Array<String>();
	public static var directorylisting:Array<String> = new Array<String>();
	public static var directorysize:Int;
	public static var rawsubdirectorylist:Array<String> = new Array<String>();
	public static var subdirectorylisting:Array<String> = new Array<String>();
	public static var subdirectorysize:Int;
	
	public static var folderoffset:String = "../../../../";
}
