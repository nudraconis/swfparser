package swfDataExporter 
{
	import fastByteArray.FastByteArray;
	import flash.geom.Matrix;
	import flexunit.framework.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.matrix.isMatrixEquals;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagDefineSprite;
	import swfdata.dataTags.SwfPackerTagEnd;
	import swfdata.dataTags.SwfPackerTagPlaceObject;
	import swfdata.dataTags.SwfPackerTagRemoveObject;
	import swfdata.dataTags.SwfPackerTagShowFrame;
	import swfdata.dataTags.SwfPackerTagSymbolClass;
	import swfdata.FrameData;
	import swfdata.swfdata_inner;
	import swfDataExporter.DefineSpriteExporter;
	import swfDataExporter.SwfTagExporter;
	
	use namespace swfdata_inner;
	
	public class DefineSpriteExporterTest 
	{
		private var symbolClassExporter:DefineSpriteExporter;
		private var utilityByteArray:FastByteArray;
		private var defineSpriteTag:SwfPackerTagDefineSprite;
		
		public function DefineSpriteExporterTest() 
		{
			
		}
		
		[Before]
		public function startUp():void
		{
			var swfPackerTagExporter:SwfTagExporter = new SwfTagExporter();
			
			defineSpriteTag = new SwfPackerTagDefineSprite();
			
			defineSpriteTag.tags = new Vector.<SwfPackerTag>();
			defineSpriteTag.frames = new Vector.<FrameData>();
							
			var c:int = 0;
			for (var i:int = -1600; i < 1600; i++, c++)
			{
				defineSpriteTag.tags.push(new SwfPackerTagEnd());
				
				
				var swfPackerTagPlaceObject:SwfPackerTagPlaceObject = new SwfPackerTagPlaceObject();
				
				swfPackerTagPlaceObject.setMatrix(1.1245, -2.432, 3.123, 4.42, -5.412, -6.213);
				swfPackerTagPlaceObject.hasMatrix = true;
				
				swfPackerTagPlaceObject.hasCharacter = true;
				swfPackerTagPlaceObject.characterId = i;
				
				swfPackerTagPlaceObject.placeMode = SwfPackerTagPlaceObject.PLACE_MODE_REPLACE;
				
				swfPackerTagPlaceObject.depth = 15;
				
				swfPackerTagPlaceObject.hasClipDepth = true;
				swfPackerTagPlaceObject.clipDepth = 22;
				
				swfPackerTagPlaceObject.hasName = true;
				swfPackerTagPlaceObject.instanceName = "testInstanceName" + i;
				
				defineSpriteTag.tags.push(swfPackerTagPlaceObject);
				
				defineSpriteTag.frames.push(new FrameData(c, "test frame " + i, c));
				
				
				defineSpriteTag.tags.push(new SwfPackerTagRemoveObject(i, 1));
				defineSpriteTag.tags.push(new SwfPackerTagShowFrame());
				defineSpriteTag.tags.push(new SwfPackerTagSymbolClass());
				
			}
			
			defineSpriteTag.frameCount = defineSpriteTag.frames.length;
			
			
			symbolClassExporter = new DefineSpriteExporter(swfPackerTagExporter);

			utilityByteArray = new FastByteArray(null, 800000);
			utilityByteArray.begin();
		}
		
		[After]
		public function end():void
		{
			symbolClassExporter = null;
			
			utilityByteArray.end(true);
			utilityByteArray = null;
		}
		
		[Test]
		public function exportImportTest():void
		{
			var i:int;
			symbolClassExporter.exportTag(defineSpriteTag, utilityByteArray);
			
			utilityByteArray.position = 1;//tag type read;
			
			var outputTag:SwfPackerTagDefineSprite = new SwfPackerTagDefineSprite();
			symbolClassExporter.importTag(outputTag, utilityByteArray);
			
			
			Assert.assertEquals("output tag frames count is not equals to Etalon tag", defineSpriteTag.frameCount, outputTag.frameCount);
			
			for (i = 0; i < outputTag.frameCount; i++)
			{
				Assert.assertEquals("frame data(frameIndex) is not equals to Etalon data at index:" + i, defineSpriteTag.frames[i].frameIndex, outputTag.frames[i].frameIndex);
				Assert.assertEquals("frame data(frameLabel) is not equals to Etalon data at index:" + i, defineSpriteTag.frames[i].frameLabel, outputTag.frames[i].frameLabel);
				Assert.assertEquals("frame data(displayObjectsCount) is not equals to Etalon data at index:" + i, defineSpriteTag.frames[i].displayObjectsCount, outputTag.frames[i].displayObjectsCount);
			}
			
			Assert.assertEquals("output tag tags count is not equals to Etalon tag", defineSpriteTag.tags.length, outputTag.tags.length);
			
			for (i = 0; i < outputTag.tags.length; i++)
			{
				var currentTag:SwfPackerTag = outputTag.tags[i];
				var etalonTag:SwfPackerTag = defineSpriteTag.tags[i];
				
				if (currentTag['constructor'] != etalonTag['constructor'])
					Assert.fail("tag type is not match to Etalon tag at:" + i);
				
				if (currentTag is SwfPackerTagPlaceObject)
				{
					var swfPackerTagPlaceObject:SwfPackerTagPlaceObject = currentTag as SwfPackerTagPlaceObject;
					var swfPackerTagPlaceObjectEtalon:SwfPackerTagPlaceObject = etalonTag as SwfPackerTagPlaceObject;
					
					assertThat("TagPlaceObject shouls equals to Etalon tag, passed tag is: "+swfPackerTagPlaceObject+", but should be " + swfPackerTagPlaceObjectEtalon, swfPackerTagPlaceObject.isEquals(swfPackerTagPlaceObjectEtalon));
					assertThat("Test matrix equals", swfPackerTagPlaceObjectEtalon, isMatrixEquals(swfPackerTagPlaceObject));
				}
				else if (currentTag is SwfPackerTagRemoveObject)
				{
					var swfPackerTagRemoveObject:SwfPackerTagRemoveObject = currentTag as SwfPackerTagRemoveObject;
					var swfPackerTagRemoveObjectEtalon:SwfPackerTagRemoveObject = etalonTag as SwfPackerTagRemoveObject;
					
					if(!swfPackerTagRemoveObject.isEquals(swfPackerTagRemoveObjectEtalon))
						Assert.fail("output tag is not same to Etalon tag should be " + swfPackerTagRemoveObjectEtalon.toString() + ", but was " + swfPackerTagRemoveObject.toString());
				}
				else if (currentTag is SwfPackerTagSymbolClass)
				{
					var swfPackerTagSymbolClassObject:SwfPackerTagSymbolClass = currentTag as SwfPackerTagSymbolClass;
					var swfPackerTagSymbolClassObjectEtalon:SwfPackerTagSymbolClass = etalonTag as SwfPackerTagSymbolClass;
					
					Assert.assertEquals("length of class-symbol in imported tag is not same with Etalon tag", swfPackerTagSymbolClassObjectEtalon.length, swfPackerTagSymbolClassObject.length);
			
					for (var j:int = 0; j < swfPackerTagSymbolClassObject.length; i++)
					{
						Assert.assertEquals("inspect class-symbol cahracterId at: " + j + " is not equals to Etalon", swfPackerTagSymbolClassObjectEtalon.characterIdList[j], swfPackerTagSymbolClassObject.characterIdList[j]);
						Assert.assertEquals("inspect class-symbol linkage at: " + j + " is not equals to Etalon", swfPackerTagSymbolClassObjectEtalon.linkageList[j], swfPackerTagSymbolClassObject.linkageList[j]);
					}
				}
			}
		}
	}
}