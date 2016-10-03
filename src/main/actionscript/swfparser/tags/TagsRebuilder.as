package swfparser.tags 
{
	import com.codeazur.as3swf.data.filters.IFilter;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import com.codeazur.as3swf.tags.TagPlaceObject2;
	import com.codeazur.as3swf.tags.TagPlaceObject3;
	import com.codeazur.as3swf.tags.TagPlaceObject4;
	import com.codeazur.as3swf.tags.TagRemoveObject;
	import com.codeazur.as3swf.tags.TagRemoveObject2;
	import com.codeazur.as3swf.tags.TagShowFrame;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	import com.codeazur.as3swf.timeline.Frame;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import swfdata.ColorMatrix;
	import swfdata.dataTags.RawClassSymbol;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagDefineSprite;
	import swfdata.dataTags.SwfPackerTagEnd;
	import swfdata.dataTags.SwfPackerTagPlaceObject;
	import swfdata.dataTags.SwfPackerTagRemoveObject;
	import swfdata.dataTags.SwfPackerTagShowFrame;
	import swfdata.dataTags.SwfPackerTagSymbolClass;
	import swfdata.FrameData;

	public class TagsRebuilder 
	{
		
		private var tagsProcessors:Object = {};
		
		public function TagsRebuilder() 
		{
			tagsProcessors[TagDefineSprite.TYPE] = createDefineSpriteTag;
			//tagsProcessors[TagEnd.TYPE] = createEndTag
			
			tagsProcessors[TagRemoveObject.TYPE] = createRemoveObjectTag;
			tagsProcessors[TagRemoveObject2.TYPE] = createRemoveObjectTag;
			
			tagsProcessors[TagPlaceObject.TYPE] = createPlaceObjectTag;
			tagsProcessors[TagPlaceObject2.TYPE] = createPlaceObjectTag;
			tagsProcessors[TagPlaceObject3.TYPE] = createPlaceObjectTag;
			tagsProcessors[TagPlaceObject4.TYPE] = createPlaceObjectTag;
			
			tagsProcessors[TagShowFrame.TYPE] = createShowFrameTag;
			
			tagsProcessors[TagSymbolClass.TYPE] = createSymbolClassTag;
		}
		
		private function createEndTag(tag:TagEnd):SwfPackerTag 
		{
			var tagOut:SwfPackerTagEnd = new SwfPackerTagEnd();
			//tagOut.type = tag.type;
			
			return tagOut;
		}
		
		private function createSymbolClassTag(tag:TagSymbolClass):SwfPackerTag 
		{
			var tagOut:SwfPackerTagSymbolClass = new SwfPackerTagSymbolClass();
			tagOut.initializeContent(false);
			//tagOut.type = tag.type;
			
			var symbolsCount:int = tag.symbols.length;
			var c:int = 0;
			for (var i:int = 0; i < symbolsCount; i++)
			{
				var currentSymbol:SWFSymbol = tag.symbols[i];
				
				if (currentSymbol.name.indexOf("_fla.") != -1)
					continue;
				
				tagOut.length++;
				tagOut.characterIdList[c] = currentSymbol.tagId;
				tagOut.linkageList[c] = currentSymbol.name;
				c++;
			}
			
			return tagOut;
		}
		
		private function createShowFrameTag(tag:TagShowFrame):SwfPackerTag 
		{
			var tagOut:SwfPackerTagShowFrame = new SwfPackerTagShowFrame();
			//tagOut.type = tag.type;
			
			return tagOut;
		}
		
		private function createPlaceObjectTag(tag:TagPlaceObject):SwfPackerTag 
		{
			var tagOut:SwfPackerTagPlaceObject = new SwfPackerTagPlaceObject();
			//tagOut.type = tag.type;
			
			//tagOut.hasClipActions = tag.hasClipActions;
			tagOut.hasClipDepth = tag.hasClipDepth;
			tagOut.hasName = tag.hasName;
			//tagOut.hasRatio = tag.hasRatio;
			tagOut.hasColorTransform = tag.hasColorTransform;
			tagOut.hasMatrix = tag.hasMatrix;
			tagOut.hasCharacter = tag.hasCharacter;
			tagOut.hasMove = tag.hasMove;
			//tagOut.hasVisible = tag.hasVisible;
			//tagOut.hasImage = tag.hasImage;
			//tagOut.hasBlendMode = tag.hasBlendMode;
			//tagOut.hasFilterList = tag.hasFilterList;
			
			tagOut.characterId = tag.characterId;
				
			tagOut.depth = tag.depth;
			
			var colorTransform:ColorMatrix;
			
			if (tag.hasColorTransform)
			{

				var colorData:Vector.<Number> = new <Number>[ 1,0,0,0,0,
															  0,1,0,0,0,
															  0,0,1,0,0,
															  0, 0, 0, 1, 0];
				
				colorData[0] = tag.colorTransform.colorTransform.redMultiplier;
				colorData[4] = tag.colorTransform.colorTransform.redOffset;
				
				colorData[6] = tag.colorTransform.colorTransform.greenMultiplier;
				colorData[9] = tag.colorTransform.colorTransform.greenOffset;
				
				colorData[12] = tag.colorTransform.colorTransform.blueMultiplier;
				colorData[14] = tag.colorTransform.colorTransform.blueOffset;
				
				colorData[18] = tag.colorTransform.colorTransform.alphaMultiplier;
				colorData[19] = tag.colorTransform.colorTransform.alphaOffset;
				//trace("COLOR TRANSFORM ###", colorData);
				
				if (colorTransform == null)
					colorTransform = new ColorMatrix();
					
				colorTransform.concat(colorData);
			}
			
			/**
			 * TODO:
			 * Порядок наложения цветовых матриц такой
			 * 
			 * Колор трансформ потомка <- Сурфейс фильтр колор трансформ родителя <- Колор трансформ родителя
			 * В итоге не возможно отсюда компановать трансформы и нужно хранить отдельно Surface List (возможно компонованый)
			 * и отдельно ColorTransform cледовательно если у нас есть трансформ и флиьтр то для объекта будет 2 умножения матриц а не одно
			 */
			
			/*if (tag.hasFilterList)
			{
				var filtersLength:int = tag.surfaceFilterList.length;
				
				for (var i:int = 0; i < filtersLength; i++)
				{
					var surfaceFilter:IFilter = tag.surfaceFilterList[i];
					
					if (surfaceFilter.filter is ColorMatrixFilter)
					{
						//trace("SURFACE FILTER", (surfaceFilter.filter as ColorMatrixFilter).matrix);
						
						if (colorTransform == null)
							colorTransform = new ColorMatrix(); 
							
						colorTransform.concatArray((surfaceFilter.filter as ColorMatrixFilter).matrix);
					}
				}
			}*/
			
			if (colorTransform != null)
			{
				tagOut.hasColorTransform = true;
				
				tagOut.redColor0 = colorTransform.matrix[0];
				tagOut.redColor1 = colorTransform.matrix[1];
				tagOut.redColor2 = colorTransform.matrix[2];
				tagOut.redColor3 = colorTransform.matrix[3];
				tagOut.redColorOffset = colorTransform.matrix[4];
				
				tagOut.greenColor0 = colorTransform.matrix[5];
				tagOut.greenColor1 = colorTransform.matrix[6];
				tagOut.greenColor2 = colorTransform.matrix[7];
				tagOut.greenColor3 = colorTransform.matrix[8];
				tagOut.greenColorOffset = colorTransform.matrix[9];
				
				tagOut.blueColor0 = colorTransform.matrix[10];
				tagOut.blueColor1 = colorTransform.matrix[11];
				tagOut.blueColor2 = colorTransform.matrix[12];
				tagOut.blueColor3 = colorTransform.matrix[13];
				tagOut.blueColorOffset = colorTransform.matrix[14];
				
				tagOut.alpha0 = colorTransform.matrix[15];
				tagOut.alpha1 = colorTransform.matrix[16];
				tagOut.alpha2 = colorTransform.matrix[17];
				tagOut.alpha3 = colorTransform.matrix[18];
				tagOut.alphaOffset = colorTransform.matrix[19];
				
				//trace("GET MATRIX", colorTransform.matrix);
			}
			
			/*if (tag.hasFilterList)
			{
				for (var i:int = 0; i < tag.surfaceFilterList.length; i++)
				{
					var currentFilter:BitmapFilter = tag.surfaceFilterList[i].filter;
					
					if (currentFilter is ColorMatrixFilter)
					{
						tagOut.addColorMatrixArray((currentFilter as ColorMatrixFilter).matrix);
						tag.surfaceFilterList.splice(i, 1);
						i--;
					}
				}
				
				//tagOut.surfaceFilterList = tag.surfaceFilterList;
			}*/
			
			if (tag.hasMatrix)
			{
				var normalMatrix:Matrix = tag.matrix.getNormalMatrix();
				
				tagOut.setMatrix(normalMatrix.a, normalMatrix.b, normalMatrix.c, normalMatrix.d, normalMatrix.tx, normalMatrix.ty);
			}
				
			
			tagOut.placeMode = tag.placeMode;
			
			//tagOut.ratio = tag.ratio;
			tagOut.instanceName = tag.instanceName;
			tagOut.clipDepth = tag.clipDepth;
			
			//tagOut.blendMode = tag.blendMode;
			//tagOut.bitmapCache = tag.bitmapCache;
			//tagOut.bitmapBackgroundColor = tag.bitmapBackgroundColor;
			tagOut.visible = tag.visible;
			
			return tagOut;
		}
		
		private function createRemoveObjectTag(tag:TagRemoveObject):SwfPackerTag 
		{
			var tagOut:SwfPackerTagRemoveObject = new SwfPackerTagRemoveObject(tag.characterId, tag.depth);
			//tagOut.type = tag.type;
			
			return tagOut;
		}
		
		private function createDefineSpriteTag(tag:TagDefineSprite):SwfPackerTag 
		{
			var tagOut:SwfPackerTagDefineSprite = new SwfPackerTagDefineSprite();
			//tagOut.type = tag.type;
			
			if (tag.characterId == 0)
				internal_error("wrong?");
				
			tagOut.characterId = tag.characterId;
			
			var framesCount:int = tag.frameCount;
			
			tagOut.frameCount = framesCount;
			
			if (framesCount > 0)
			{
				tagOut.frames = new Vector.<FrameData>;
				
				for (var i:int = 0; i < framesCount; i++)
				{
					var currentFrame:Frame = tag.frames[i];
					
					tagOut.frames.push(new FrameData(currentFrame.frameNumber, currentFrame.label, currentFrame.numObjects));
				}
			}
				
			var tagsCount:int = tag.tags.length;
			
			if (tagsCount > 0)
			{
				tagOut.tags = new Vector.<SwfPackerTag>;
				
				rebuildTags(tag.tags, tagOut.tags);
			}
			
			return tagOut;
		}
		
		public function rebuildTags(tags:Vector.<ITag>, output:Vector.<SwfPackerTag>):void
		{
			for (var i:int = 0; i < tags.length; i++)
			{
				var builder:Function = tagsProcessors[tags[i].type];
				
				if (builder != null)
				{
					output.push(builder(tags[i]));
				}
			}
		}
	}
}