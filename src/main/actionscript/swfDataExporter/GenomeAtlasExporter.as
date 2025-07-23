package swfDataExporter 
{
	import com.codeazur.as3swf.utils.ColorUtils;
	import fastByteArray.IByteArray;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import swfdata.ShapeData;
	import swfdata.ShapeLibrary;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.atlas.TextureTransform;
	import swfdata.atlas.genome.GenomeMultiAtlas;
	import swfdata.atlas.genome.GenomeSubTexture;
	import swfdata.atlas.genome.GenomeTextureAtlas;

	public class GenomeAtlasExporter extends BaseSwfAtlasExporter implements ISwfAtlasExporter
	{	
		public function GenomeAtlasExporter() 
		{
			
		}
		
		private function readAtlas(name:String, input:IByteArray, shapesList:ShapeLibrary, format:String, atlasIndex:int):BaseTextureAtlas 
		{
			var textureAtlas:GenomeTextureAtlas;
			
			var position:Number = input.position;
			
			var padding:int = input.readInt8();
			var bitmapSize:int = input.readInt32();
			var width:int = input.readInt16();
			var height:int = input.readInt16();
			
			if (width * height * 2 != bitmapSize) {
				//not atlas signature
				input.position = position;
				return null;
			}
			
			trace("read atlas", width, height, bitmapSize);
			
			bitmapBytes.length = 0;
			
			input.readBytes(bitmapBytes, 0, bitmapSize);
			
			//var newBa:ByteArray = new ByteArray();
			//var pixelsCount:int = width * height;
			//var newBa:ByteArray = new ByteArray();
			//for (var i = 0; i < pixelsCount; i++) {
			//	var color:uint = bitmapBytes.readShort();
			//	var r:int = ColorUtils.r(color) >> 3;
			//	var g:int = ColorUtils.g(color) >> 3;
			//	var b:int = ColorUtils.b(color) >> 3;
			//	var a:int = ColorUtils.alpha(color) >> 7;
				
			//	color = b | (g << 5) | (r << 10) | (a << 15);
			//	newBa.writeShort(color);
				
			//}
			
			if (width < 2 || height < 2)
				internal_trace("Error: somethink wrong with atlas data");
			
			var bitmapData:BitmapData = new BitmapData(width, height, true);
			//bitmapData.setPixels(bitmapData.rect, bitmapBytes);
			
			var bit:int = 15;
			var colorConversionMultiplier:Number = 1 / bit * 255;
			for (var j:int = 0; j < height; j++) {
				for (var i:int = 0; i < width; i++) {
					var color:uint = bitmapBytes.readUnsignedShort();
					var r:uint = color >> 8 & bit;
					var g:uint = color >> 4 & bit;
					var b:uint = color & bit;
					var a:uint = color >> 12 & bit;
					
					color = b / bit * 255 | (g / bit * 255 << 8) | (r / bit * 255 << 16) | (a / bit * 255 << 24);
					bitmapData.setPixel32(i, j, color);
				}
			}
			
			//WindowUtil.openWindowToReview(bitmapData);
			
			textureAtlas = new GenomeTextureAtlas(name + atlasIndex, bitmapData, format, padding);
			
			var texturesCount:int = input.readInt16();
			trace("read texturesCount", texturesCount);
			
			//trace('pre read', input.position);
			
			var rectangle:Rectangle = new Rectangle();
			for (var i:int = 0; i < texturesCount; i++)
			{
				var id:int = input.readInt16();
				
				var textureTransform:TextureTransform = readTextureTransform(input);
				var textureRegion:Rectangle = readRectangle(input);
				var shapeBounds:Rectangle = readRectangle(input);
				
				//trace("read", input.position);
				
				/*
				//if (textureTransform.scaleX != 1 || textureTransform.scaleY != 1)
				//{
					r.setTo(textureRegion.x + padding, textureRegion.y + padding, textureRegion.width - padding * 2, 1);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + padding, textureRegion.y + padding, 1, textureRegion.height - padding *2);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + textureRegion.width - padding, textureRegion.y + padding, 1, textureRegion.height - padding *2);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + padding, textureRegion.y + textureRegion.height - padding, textureRegion.width - padding * 2, 1);
					bitmapData.fillRect(r, 0xFF00FF00);
				//}	
				*/
				//trace('read texture', id);
				shapesList.addShape(null, new ShapeData(id, shapeBounds));
				var texture:GenomeSubTexture = new GenomeSubTexture(id, textureRegion, textureTransform, textureAtlas);
				
				textureAtlas.putTexture(texture);
			}
			
			//Create debug texture for text fields
			//var testTexture:GenomeSubTexture = new GenomeSubTexture(int.MAX_VALUE, new Rectangle(0, 0, 10, 10), new TextureTransform(1, 1, 0, 0), textureAtlas);
			//bitmapData.fillRect(new Rectangle(0, 0, 10, 10), 0xFFFF0000);
			//textureAtlas.putTexture(testTexture);
			
			//input.bitsReader.clear();
			
			textureAtlas.reupload();
			
			return textureAtlas;
		}
		
		override public function importAtlas(name:String, input:IByteArray, shapesList:ShapeLibrary, format:String):BaseTextureAtlas
		{
			var textureAtlasList:Vector.<GenomeTextureAtlas> = new Vector.<GenomeTextureAtlas>();
			var atlasIndex:int = 0;
			
			while (true) {
				var textureAtlas:GenomeTextureAtlas = readAtlas(name, input, shapesList, format, atlasIndex++);
				
				if (textureAtlas == null) break;
				else textureAtlasList.push(textureAtlas);
			}
			
			if (textureAtlasList.length == 1) 
			{
				return textureAtlasList[0];
			}
			else {
				var multiAtlas:GenomeMultiAtlas = new GenomeMultiAtlas(name);
				for (var i:int = 0; i < textureAtlasList.length; i++) {
					multiAtlas.addAtlas(textureAtlasList[i]);
				}
				
				return multiAtlas;
			}
		}
	}
}