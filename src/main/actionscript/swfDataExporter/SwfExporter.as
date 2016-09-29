package swfDataExporter 
{
	import fastByteArray.FastByteArray;
	import fastByteArray.IByteArray;
	import swfdata.atlas.GenomeTextureAtlas;
	import swfdata.dataTags.SwfPackerTag;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.ShapeLibrary;
	import swfDataExporter.SwfAtlasExporter;
	import swfDataExporter.SwfTagExporter;
	
	public class SwfExporter 
	{
		private var atlasExporter:SwfAtlasExporter = new SwfAtlasExporter();
		private var dataExporter:SwfTagExporter = new SwfTagExporter();
		
		public function SwfExporter() 
		{
			
		}
		
		public function clear():void
		{
			
		}
		
		public function exportSwf(atlas:BitmapTextureAtlas, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>, output:IByteArray):IByteArray
		{
			output.begin();
			
			atlasExporter.exportAtlas(atlas, shapesList, output);
			//output.position = output.byteArray.position;
			trace("EXPORT POS", output.position);
			var atlasPart:int = output.position;
			
			
			dataExporter.exportTags(tagsList, output);
			
			
			output.end(true);
			
			output.length = output.position;
			
			trace("swf data size", atlasPart, output.length);
			
			output.byteArray.deflate();
			
			trace('compress', output.byteArray.length);
			
			return output;
		}
		
		public function importSwfGenome(name:String, input:IByteArray, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>, format:String):GenomeTextureAtlas
		{
			input.byteArray.inflate();
			
			input.begin();
			
			var atlas:GenomeTextureAtlas = atlasExporter.importAtlasGenome(name, input, shapesList, format);
			
			dataExporter.importTags(tagsList, input);
			
			input.end(true);
			
			return atlas;
		}
		
		public function importSwf(input:IByteArray, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>):BitmapTextureAtlas
		{
			//input.byteArray.inflate();
			
			//var atlas:BitmapTextureAtlas = atlasExporter.importAtlas(input.byteArray, shapesList);
			//input.position = input.byteArray.position;
			//dataExporter.importTags(tagsList, input);
			
			return null;
		}
	}
}