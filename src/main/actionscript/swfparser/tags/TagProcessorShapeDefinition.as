package swfparser.tags 
{
	import com.codeazur.as3swf.exporters.AS3GraphicsDataShapeExporter;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import swfdata.ShapeData;
	import swfparser.SwfParserContext;
	
	/**
	 * Обрабатывает объявление шейпа
	 * Тут можно получить реальный актуальный баунд шейпа
	 * 
	 * P.S Одинаковые шейпы объявляются один раз в своей изначальной позиции т.е
	 * если шейп был изначльно квдарат 50х50 и положен в позиции -10 -10 то его изачнаальый транфомр будет
	 * -10, -10, 50, 50 а все последующие плейсы скоректируют позицию именно относительно этого а не 0, 0, 50, 50
	 */
	public class TagProcessorShapeDefinition 
	{
		private var shapeExporter:AS3GraphicsDataShapeExporter;
		
		private var context:SwfParserContext;
		
		public static var shapesDefined:int = 0;
		
		public function TagProcessorShapeDefinition(context:SwfParserContext, shapeExporter:AS3GraphicsDataShapeExporter) 
		{
			this.context = context;
			
			this.shapeExporter = shapeExporter;
		}
		
		public function processTag(tag:ITag):void 
		{	
			shapesDefined++;
			
			var tagDefineShape:TagDefineShape = tag as TagDefineShape;
			
			var shapeView:Shape = new Shape();
			
			
			var shapeBound:Rectangle = tagDefineShape.shapeBounds.rect;
			var shapeId:int = tagDefineShape.characterId;
			
			//trace('define shape', shapeId);
			if (shapeId == 0)
				trace('Error: wrong? shape dfinition');
			
			var tx:Number = shapeBound.x //- shapeBound.width / 2;
			var ty:Number = shapeBound.y //- shapeBound.height / 2;
			
			shapeBound.x = tx;
			shapeBound.y = ty;
			
			tagDefineShape.export(shapeExporter);
			
			var shapeBuffer:Shape = new Shape();
			
			shapeView.graphics.drawGraphicsData(shapeExporter.graphicsData);
			
			shapeExporter.clear();
			
			//add shape data to library
			var shape:ShapeData = new ShapeData(shapeId, shapeBound);
			shape.tx = tx;
			shape.ty = ty;
			
			context.library.addDisplayObject(shape);
			context.shapeLibrary.addShape(shapeView, shape);
		}
		
		public function clear():void 
		{
			context = null;
			shapeExporter.destroy();
			shapeExporter = null;
		}
	}
}