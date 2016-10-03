package swfDataExporter 
{
	import fastByteArray.IByteArray;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import swfdata.ShapeData;
	import swfdata.ShapeLibrary;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.atlas.TextureTransform;
	import swfdata.atlas.genome.GenomeSubTexture;
	import swfdata.atlas.genome.GenomeTextureAtlas;

	public class GenomeAtlasExporter extends BaseSwfAtlasExporter implements ISwfAtlasExporter
	{	
		public function GenomeAtlasExporter() 
		{
			
		}
		
		override public function importAtlas(name:String, input:IByteArray, shapesList:ShapeLibrary, format:String):BaseTextureAtlas
		{
			var textureAtlas:GenomeTextureAtlas;
			
			var padding:int = input.readInt8();
			var bitmapSize:int = input.readInt32();
			var width:int = input.readInt16();
			var height:int = input.readInt16();
			
			bitmapBytes.length = 0;
			
			input.readBytes(bitmapBytes, 0, bitmapSize);
			
			if (width < 2 || height < 2)
				internal_trace("Error: somethink wrong with atlas data");
			
			var bitmapData:BitmapData = new BitmapData(width, height, true);
			bitmapData.setPixels(bitmapData.rect, bitmapBytes);
			
			//WindowUtil.openWindowToReview(bitmapData);
			
			textureAtlas = new GenomeTextureAtlas(name, bitmapData, format, padding);
			
			var texturesCount:int = input.readInt16();
			
			//trace('pre read', input.position);
			
			var r:Rectangle = new Rectangle();
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
				shapesList.addShape(null, new ShapeData(id, shapeBounds));
				var texture:GenomeSubTexture = new GenomeSubTexture(id, textureRegion, textureTransform, textureAtlas);
				
				textureAtlas.putTexture(texture);
			}
			
			//input.bitsReader.clear();
			
			textureAtlas.reupload();
			
			return textureAtlas;
		}
	}
}