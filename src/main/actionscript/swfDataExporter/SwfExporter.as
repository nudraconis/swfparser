package swfDataExporter 
{
	import fastByteArray.FastByteArray;
	import fastByteArray.IByteArray;
	import swfdata.atlas.ITextureAtlas;
	import swfdata.atlas.genome.GenomeTextureAtlas;
	import swfdata.atlas.gl.GLTextureAtlas;
	import swfdata.dataTags.SwfPackerTag;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.ShapeLibrary;
	import swfDataExporter.GenomeAtlasExporter;
	import swfDataExporter.SwfTagExporter;
	
	public class SwfExporter 
	{
		private var atlasExporter:GenomeAtlasExporter = new GenomeAtlasExporter();
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
		
		public function importSwf(name:String, input:IByteArray, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>, format:String):ITextureAtlas
		{
			input.byteArray.inflate();
			
			input.begin();
			
			var atlas:ITextureAtlas = atlasExporter.importAtlas(name, input, shapesList, format);
			
			dataExporter.importTags(tagsList, input);
			
			input.end(true);
			
			return atlas;
		}
	}
}