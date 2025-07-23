package swfDataExporter 
{
	import com.codeazur.as3swf.utils.ColorUtils;
	import fastByteArray.ByteArrayUtils;
	import fastByteArray.Constants;
	import fastByteArray.FastByteArray;
	import fastByteArray.IByteArray;
	import fastByteArray.SlowByteArray;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import startup.StartUp;
	import swfdata.ShapeLibrary;
	import swfdata.atlas.BaseSubTexture;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.atlas.TextureTransform;
	import util.PackerHelper;
	import flash.display.PNGEncoderOptions;
	
	public class BaseSwfAtlasExporter implements ISwfAtlasExporter
	{
		protected var bitmapBytes:ByteArray = new ByteArray();
		
		public function BaseSwfAtlasExporter() 
		{
			
		}
		
		public function readTextureTransform(input:IByteArray):TextureTransform
		{	
			var scaleX:Number = 1;
			var scaleY:Number = 1;
			
		/*	if (input.readBits(1) == 1) 
			{
				var scaleBits:uint = input.readBits(5);
				scaleX = input.readFixedBits(scaleBits);
				scaleY = input.readFixedBits(scaleBits);
			}*/
			
			if (input.readInt8() == 1)
			{
				scaleX = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
				scaleY = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			}
			
			//input.bitsReader.clear();
			
			//var translateBits:uint = input.readBits(5);
			
			//var translateX:Number = input.readBits(translateBits);
			//var translateY:Number = input.readBits(translateBits);
			
			var translateX:Number = input.readInt32();
			var translateY:Number = input.readInt32();
			
			//trace('read transform', scaleX, scaleY, translateX / 2000, translateY / 2000);
			
			return new TextureTransform(scaleX, scaleY, translateX / 2000, translateY / 2000);
		}
		
		public function writeTextureTransform(transform:TextureTransform, output:IByteArray):void
		{
			var translateX:int = transform.tx * 2000;
			var translateY:int = transform.ty * 2000;
			
			var scaleX:Number = transform.scaleX;
			var scaleY:Number = transform.scaleY;
			
			var hasScale:Boolean = (scaleX != 1) || (scaleY != 1);
			
			//output.writeBits(hasScale ? 1 : 0, 1);
			output.writeInt8(hasScale? 1:0);
			if (hasScale) 
			{
				/*var scaleBits:uint;
				if (scaleX == 0 && scaleY == 0) 
				{
					scaleBits = 1;
				} 
				else 
				{
					scaleBits = ByteArrayUtils.calculateMaxBits(true, scaleX * Constants.FIXED_PRECISSION_VALUEE, scaleY * Constants.FIXED_PRECISSION_VALUEE);
				}
				
				if (scaleX < 0 || scaleY < 0)
					throw new Error("value range error: " + scaleX + ", " + scaleY);
				
				output.writeBits(scaleBits, 5);
				output.writeFixedBits(scaleX, scaleBits);
				output.writeFixedBits(scaleY, scaleBits);*/
				
				output.writeInt32(scaleX * Constants.FIXED_PRECISSION_VALUE);
				output.writeInt32(scaleY * Constants.FIXED_PRECISSION_VALUE);
			}
			
			//output.end(false);
			
			//var translateBits:uint = ByteArrayUtils.calculateMaxBits(true, translateX, translateY);
			
			//output.writeBits(translateBits, 5);
			//output.writeBits(translateX, translateBits);
			//output.writeBits(translateY, translateBits);
			
			output.writeInt32(translateX);
			output.writeInt32(translateY);
			
			//trace('wirte trnasform', scaleX, scaleY, transform.tx, transform.ty);
		}
		
		public function exportAtlas(atlas:BitmapTextureAtlas, shapesList:ShapeLibrary, output:IByteArray):void 
		{
			var bitmap:BitmapData = atlas.data;
			
			var bitmapBytes:ByteArray = bitmap.getPixels(bitmap.rect);
			bitmapBytes.position = 0;
			
			trace("export atlas", bitmap.width, bitmap.height);
			
			if (bitmap.width < 2 || bitmap.height < 2)
				internal_trace("Error: somethink wrong with atlas data");
			
			var pixelsCount:int = bitmap.width * bitmap.height;
			var colorDataBytes:ByteArray = new ByteArray();
			colorDataBytes.length = pixelsCount * 2;
			var bit:int = 15;
			var colorConversionMultiplier:Number = 0.05882352941;//1 / 255 * bit;
			//4 4 4 4
			
			for (var i = 0; i < pixelsCount; i++) {
				var color:uint = bitmapBytes.readUnsignedInt();
				var r:uint = color >> 16 & 255;
				var g:uint = color >> 8 & 255;
				var b:uint = color & 255;
				var a:uint = color >> 24 & 255;
				
				//r = Math.round(r * colorConversionMultiplier);
				//g = Math.round(g * colorConversionMultiplier);
				//b = Math.round(b * colorConversionMultiplier);
				//a = Math.round(a * colorConversionMultiplier);
				
				//color = b | g << 4 | r << 8 | a << 12;
				color = b >> 4 | g >> 4 << 4 | r >> 4 << 8 | a >> 4 << 12;
				colorDataBytes.writeShort(color);
			}
			
			output.writeInt8(atlas.padding);
			//output.writeInt32(colors.length);
			//output.writeInt32(alpha.length);
			output.writeInt32(colorDataBytes.length);
			output.writeInt16(bitmap.width);
			output.writeInt16(bitmap.height);
			
			trace("write atlas", bitmap.width, bitmap.height, colorDataBytes.length);
			//trace("write atlas", bitmap.width, bitmap.height, colors.length, alpha.length);
			//output.writeBytes(colors.byteArray, 0, colors.length);
			//output.writeBytes(alpha.byteArray, 0, alpha.length);
			colorDataBytes.position = 0;
			output.writeBytes(colorDataBytes, 0, colorDataBytes.length);
			//colors.clear();
			//alpha.clear();
			colorDataBytes.clear();
			
			output.writeInt16(atlas.texturesCount);
			trace('write texturesCount', atlas.texturesCount);
			
			//trace('pre write', output.position);
			
			for each(var texture:BaseSubTexture in atlas.subTextures)
			{
				//trace('write texture', texture.id);
				output.writeInt16(texture.id);
				
				writeTextureTransform(texture.transform, output);
				writeRectangle(texture.bounds, output);
				
				writeRectangle(shapesList.getShape(texture.id).shapeData.shapeBounds, output);
				
				//trace('write', output.position);
			}
			
			bitmapBytes.clear();
			//output.end(false);
		}
		
		public function importAtlas(name:String, input:IByteArray, shapesList:ShapeLibrary, format:String):BaseTextureAtlas 
		{
			return null;
		}
		
		
		/* INTERFACE swfDataExporter.ISwfAtlasExporter */
		
		[Inline]
		final public function readRectangle(input:IByteArray):Rectangle 
		{
			return PackerHelper.readRectangle(input);
		}
		
		[Inline]
		final public function writeRectangle(rectangle:Rectangle, output:IByteArray):void 
		{
			PackerHelper.writeRectangle(rectangle, output);
		}
	}
}