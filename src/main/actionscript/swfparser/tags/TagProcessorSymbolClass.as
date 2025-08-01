package swfparser.tags 
{
	import flash.geom.Matrix;
	import swfdata.DisplayObjectData;
	import swfdata.DisplayObjectTypes;
	import swfdata.FrameData;
	import swfdata.MovieClipData;
	import swfdata.ShapeData;
	import swfdata.SpriteData;
	import swfdata.TextFieldData;
	import swfdata.Timeline;
	import swfdata.swfdata_inner;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagSymbolClass;
	import swfparser.SwfParserContext;
	
	use namespace swfdata_inner;
	/**
	 * Тут получаем список ликейджев из библиотеки. Они идут парами characterId, linkageId
	 */
	public class TagProcessorSymbolClass extends TagProcessorBase 
	{
		private static const IDENT_MATRIX:Matrix = new Matrix();
		private static const SHAPE_HELPER_MATRIX:Matrix = new Matrix();
		
		public function TagProcessorSymbolClass(context:SwfParserContext) 
		{	
			super(context);
		}
	
		override public function processTag(tag:SwfPackerTag):void 
		{
			super.processTag(tag);
			
			var tagSymbolClass:SwfPackerTagSymbolClass = tag as SwfPackerTagSymbolClass;
			
			var symbolsLength:int = tagSymbolClass.length;
			
			var characterIds:Vector.<int> = tagSymbolClass.characterIdList;
			var linkages:Vector.<String> = tagSymbolClass.linkageList;
			
			for (var i:int = 0; i < symbolsLength; i++)
			{
				var currentCharacterId:int = characterIds[i];
				var currentLinkage:String = linkages[i];
				
				var displayObject:DisplayObjectData = context.library.getDisplayObject(currentCharacterId);
				
				if (!displayObject)
				{
					internal_error("Error: 1no symbol for linkage(symbol=" + currentCharacterId + ", linkage=" + currentLinkage + ")");
					continue;
				}
				
				displayObject.libraryLinkage = currentLinkage;
				//trace("link#", currentSymbol.name);
				context.library.addDisplayObjectByLinkage(displayObject);
				
				IDENT_MATRIX.identity();
				calculateSceneTransforms(displayObject, IDENT_MATRIX);
			}
		}
		
		[Inline]
		public final function calculateSceneTransforms(processedDisplayObject:DisplayObjectData, parentTransform:Matrix):void
		{
			if (!processedDisplayObject) return;
			if(processedDisplayObject.displayObjectType == DisplayObjectTypes.SPRITE_TYPE)
			{
				calculateSpriteTransform(processedDisplayObject as SpriteData, parentTransform);
				
			}
			else if (processedDisplayObject.displayObjectType == DisplayObjectTypes.SHAPE_TYPE)
			{
				calculeteShapeTransform(processedDisplayObject as ShapeData, parentTransform);
			}
			else if (processedDisplayObject.displayObjectType == DisplayObjectTypes.TEXT_FIELD_TYPE)
			{
				//calculateTextFieldTransform(processedDisplayObject as TextFieldData, parentTransform);
			}
			else 
			{
				calculateMovieClipTransform(processedDisplayObject as MovieClipData, parentTransform);
			}
		}
		
		[Inline]
		public final function calculateSpriteTransform(spriteData:SpriteData, parentTransform:Matrix):void 
		{
			var sceneTransform:PooledMatrix = PooledMatrix.get(1, 0, 0, 1, 0, 0);
			GeomMath.concatMatrices(spriteData.transform, parentTransform, sceneTransform);
			
			var displayObjects:Vector.<DisplayObjectData> = spriteData.displayObjects;
			var displayObjectsCount:int = displayObjects.length;
				
			for (var j:int = 0; j < displayObjectsCount; j++)
			{
				calculateSceneTransforms(displayObjects[j], sceneTransform);
			}
			
			sceneTransform.dispose();
		}
		
		[Inline]
		public final function calculateMovieClipTransform(movieClipData:MovieClipData, parentTransform:Matrix):void 
		{
			var sceneTransform:PooledMatrix = PooledMatrix.get(1, 0, 0, 1, 0, 0);
			
			GeomMath.concatMatrices(movieClipData.transform, parentTransform, sceneTransform);
			//MathUtils.concatMatrices(sceneTransform, parentTransform, sceneTransform);
			//MathUtils.concatMatrices(sceneTransform, movieClipData.transform, sceneTransform);
			//MathUtils.concatMatrices(sceneTransform, parentTransform, sceneTransform);
			
			var timeline:Timeline = movieClipData.timeline;
			var framesCount:int = movieClipData.framesCount;
			
			//framesTransformMap = { };
			
			for (var i:int = 0; i < framesCount; i++)
			{
				var frame:FrameData = timeline.frames[i];
				
				var displayObjects:Vector.<DisplayObjectData> = frame._displayObjects;
				var displayObjectsCount:int = displayObjects.length;
				
				for (var j:int = 0; j < displayObjectsCount; j++)
				{
					var currentDisplayObject:DisplayObjectData = displayObjects[j];
					
					//if (currentDisplayObject.isCalculatedInPrevFrame)
					//	continue;
					
					//currentDisplayObject.isCalculatedInPrevFrame = true;
						
					calculateSceneTransforms(currentDisplayObject, sceneTransform);
				}
			}
			
			sceneTransform.dispose();
		}
		
		private function calculeteShapeTransform(shapeData:ShapeData, parentTransform:Matrix):void 
		{
			GeomMath.concatMatrices(shapeData.transform, parentTransform, SHAPE_HELPER_MATRIX);
			context.shapeLibrary.getShape(shapeData.characterId).checkTransform2(SHAPE_HELPER_MATRIX, shapeData.tx, shapeData.ty);
		}
		
		private function calculateTextFieldTransform(textFieldData:TextFieldData, parentTransform:Matrix):void 
		{
			var sceneTransform:PooledMatrix = PooledMatrix.get(1, 0, 0, 1, 0, 0);
			
			GeomMath.concatMatrices(textFieldData.transform, parentTransform, sceneTransform);
		}
	}
}