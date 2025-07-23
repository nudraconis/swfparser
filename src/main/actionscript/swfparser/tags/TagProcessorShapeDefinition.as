package swfparser.tags 
{
	import com.codeazur.as3swf.data.SWFFillStyle;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsPath;
	import flash.display.IDrawCommand;
	import flash.display.IGraphicsData;
	import flash.geom.Matrix;
	import swfDataExporter.AS3GraphicsDataShapeExporter;
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
		private var shapesHashMap:Object = {};
		
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
			
			var hash:String = tagDefineShape.shapes.getHash();
			
			var shapeView:Shape = new Shape();
			var shapeView2:Shape = new Shape();
			
			var shapeBound:Rectangle = tagDefineShape.shapeBounds.rect;
			var shapeId:int = tagDefineShape.characterId;
			
			//trace('define shape', shapeId);
			if (shapeId == 0)
				trace('Error: wrong? shape dfinition');
				
			
			
			var tx:Number = shapeBound.x //- shapeBound.width / 2;
			var ty:Number = shapeBound.y //- shapeBound.height / 2;
			
			shapeBound.x = tx;
			shapeBound.y = ty;
			
			//TODO: possibly optimisation by refering to existed bitmap for that need to save textureId instead of use characterId
			//var fillStyles:Vector.<SWFFillStyle> = tagDefineShape.shapes != null ? tagDefineShape.shapes.initialFillStyles:null;
			//var optimisation:Boolean = false;
			//if (fillStyles != null && fillStyles.length > 0 && fillStyles[0].bitmapId == 4) 
			//{
			//	var fillStyle:SWFFillStyle = fillStyles[0];
			//	trace("fillStyle " + fillStyles.length);
			//}
			
			tagDefineShape.export(shapeExporter);
			
			var graphicsData:Vector.<IGraphicsData> = shapeExporter.graphicsData;
			
			//if (shapeId == 63) {
			//	trace(graphicsData);
			//}
			
			var graphicsDataLength:int = graphicsData.length;
			for (var i:int = 0; i < graphicsDataLength; i++) {
				var command:IGraphicsData = graphicsData[i];
				var bitmapFillCommand:GraphicsBitmapFill = command as GraphicsBitmapFill;
				
				if (bitmapFillCommand) {
					//if (shapeId == 63)
						//WindowUtil.openWindowToReview(bitmapFillCommand.bitmapData, "bitmap number 63");
						
					var x:Number = Number.MAX_VALUE;
					var y:Number = Number.MAX_VALUE;
				
					var path:GraphicsPath = graphicsData[i + 1];
					var pathData:Vector.<Number> = path.data;
					
					var pathLength:int = pathData.length / 2;
					for (var j:int = 0; j < pathLength; j+=2) {
						x = FastMath.min(pathData[j], x);
						y = FastMath.min(pathData[j+1], y);
					}
					
					var matrix:Matrix = bitmapFillCommand.matrix;
					
					if (x < matrix.tx) 
						//matrix.scale( -1, 1);
						matrix.a *= -1;
				}
			}
			
			shapeView.graphics.drawGraphicsData(shapeExporter.graphicsData);
			//shapeView2.graphics.drawGraphicsData(shapeExporter.graphicsData);
			
			shapeView2.x = -tx;
			shapeView2.y = -ty;
			//WindowUtil.openWindowForShape(shapeView2, "Shape: " + shapeId);
			
			shapeExporter.clear();
			
			//add shape data to library
			var shape:ShapeData = new ShapeData(shapeId, shapeBound);
			shape.tx = tx;
			shape.ty = ty;
			
			if (shapesHashMap[hash] == null) {
				shapesHashMap[hash] = shape;
			} else {
				var data:ShapeData = shapesHashMap[hash];
				//shape.textureId = data.textureId;
				//shape.transform.scale(data.shapeBounds.width / shape.shapeBounds.height, data.shapeBounds.height / data.shapeBounds.height);
			}
			
			context.library.addDisplayObject(shape);
			context.shapeLibrary.addShape(shapeView, shape);
		}
		
		public function clear():void 
		{
			context = null;
//			fillStyle = null;
			shapeExporter.destroy();
			shapeExporter = null;
		}
	}
}