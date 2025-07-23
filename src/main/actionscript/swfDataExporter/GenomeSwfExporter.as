package swfDataExporter 
{
	import fastByteArray.IByteArray;
	import flash.utils.ByteArray;
	import swfdata.ShapeLibrary;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.dataTags.SwfPackerTag;
	
	public class GenomeSwfExporter 
	{
		private var atlasExporter:GenomeAtlasExporter = new GenomeAtlasExporter();
		private var dataExporter:SwfTagExporter = new SwfTagExporter();
		
		public function GenomeSwfExporter() 
		{
			
		}
		
		public function clear():void
		{
			
		}
		
		private var version:int = 1;
		
		public function exportSwf(atlasList:Array.<BitmapTextureAtlas>, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>, output:IByteArray):ByteArray
		{
			output.begin();
			
			output.writeInt16(0);
			output.writeInt16(9);
			output.writeInt16(0);
			output.writeInt16(1);
			output.writeInt16(1);
			output.writeInt16(9);
			output.writeInt16(8);
			output.writeInt16(8);
			output.writeInt16(version);
			
			for (var i:int = 0; i < atlasList.length; i++) {
				var atlas:BitmapTextureAtlas = atlasList[i];
				
				atlasExporter.exportAtlas(atlas, shapesList, output);
				atlas.dispose();
			}
			
			//output.position = output.byteArray.position;
			trace("EXPORT POS", output.position);
			var atlasPart:int = output.position;
			
			trace("export tags", tagsList.length);
			dataExporter.exportTags(tagsList, output);
			
			output.end(true);
			
			//output.length = output.position;
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeBytes(output.byteArray, 0, output.position);
			
			trace("swf data size", atlasPart, output.position);
			
			//byteArray.deflate();
			
			trace('compress', byteArray.length);
			
			return byteArray;
		}
		
		public function importSwf(name:String, input:IByteArray, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>, format:String):BaseTextureAtlas
		{
			//if (input.byteArray[0] == 93) {
			//	input.byteArray.uncompress("lzma");
			//} else {
				//input.byteArray.inflate();
			//}
			
			
			input.begin();
			
			var header0:int = input.readInt16();
			var header1:int = input.readInt16();
			var header2:int = input.readInt16();
			var header3:int = input.readInt16();
			var header4:int = input.readInt16();
			var header5:int = input.readInt16();
			var header6:int = input.readInt16();
			var header7:int = input.readInt16();
			var version:int = input.readInt16();
			
			if (header0 != 0 || header1 != 9 || header2 != 0 || header3 != 1 || header4 != 1 || header5 != 9 || header6 != 8 || header7 != 8) {
				throw new Error("Wrong file header " + header0 + header1 + header2 + header3 + header4 + header5 + header6 + header7);
			}
			
			trace('format version: ' + version);
			
			var atlas:BaseTextureAtlas = atlasExporter.importAtlas(name, input, shapesList, format);
			
			dataExporter.importTags(tagsList, input);
			
			input.end(true);
			
			return atlas;
		}
	}
}