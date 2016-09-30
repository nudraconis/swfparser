package swfDataExporter 
{
	import flash.geom.Rectangle;
	import fastByteArray.IByteArray;
	import swfdata.ShapeLibrary;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.atlas.TextureTransform;
	import swfdata.atlas.genome.GenomeTextureAtlas;
	
	public interface ISwfAtlasExporter 
	{
		function readRectangle(input:IByteArray):Rectangle;
		
		function writeRectangle(rectangle:Rectangle, output:IByteArray):void;
		
		function readTextureTransform(input:IByteArray):TextureTransform;
		
		function writeTextureTransform(transform:TextureTransform, output:IByteArray):void;
		
		function exportAtlas(atlas:BitmapTextureAtlas, shapesList:ShapeLibrary, output:IByteArray):void;
		
		function importAtlas(name:String, input:IByteArray, shapesList:ShapeLibrary, format:String):BaseTextureAtlas;
	}
}