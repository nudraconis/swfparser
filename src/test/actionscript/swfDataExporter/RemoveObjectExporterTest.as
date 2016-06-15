package swfDataExporter 
{
	import fastByteArray.FastByteArray;
	import flexunit.framework.Assert;
	import swfdata.dataTags.SwfPackerTagRemoveObject;
	import swfDataExporter.RemoveObjectExporter;
	
	public class RemoveObjectExporterTest 
	{
		private var removeObjectTagExporter:RemoveObjectExporter;
		private var tagRemoveObject:SwfPackerTagRemoveObject;
		private var utilityByteArray:FastByteArray;
		
		public function RemoveObjectExporterTest() 
		{
			
		}
		
		[Before]
		public function startUp():void
		{
			
			removeObjectTagExporter = new RemoveObjectExporter();
			tagRemoveObject = new SwfPackerTagRemoveObject(12, 24);
			utilityByteArray = new FastByteArray(null, 65536 * 8);
			
			utilityByteArray.begin();
		}
		
		[After]
		public function end():void
		{
			
			removeObjectTagExporter = null;
			tagRemoveObject = null;
			utilityByteArray.end(true);
			utilityByteArray = null;
		}
		
		[Test]
		public function exportImportCharacterIDTest():void
		{
			var maxNegativeValue:int = 0;
			var maxPositiveValue:int = 32767;
			var i:int = 0;
			
			for (i = maxNegativeValue; i < maxPositiveValue; i++)
			{				
				tagRemoveObject.characterId = i;
				removeObjectTagExporter.exportTag(tagRemoveObject, utilityByteArray);
			}
			
			utilityByteArray.position = 0;
			for (i = maxNegativeValue; i < maxPositiveValue; i++)
			{
				tagRemoveObject.characterId = i;
				
				utilityByteArray.position += 1;//tag type read
				
				var outputTag:SwfPackerTagRemoveObject = new SwfPackerTagRemoveObject();
				
				removeObjectTagExporter.importTag(outputTag, utilityByteArray);
				
				if(!outputTag.isEquals(tagRemoveObject))
					Assert.fail("output tag is not same to Etalon tag at: " + i + " should be " + tagRemoveObject.toString() + ", but was " + outputTag.toString());
			}
		}
		
		[Test]
		public function exportImportDepthTest():void
		{
			var minValue:int = 0;
			var maxValue:int = 255;
			var i:int = 0;
			
			for (i = minValue; i < maxValue; i++)
			{				
				tagRemoveObject.depth = i;
				removeObjectTagExporter.exportTag(tagRemoveObject, utilityByteArray);
			}
			
			utilityByteArray.position = 0;
			for (i = minValue; i < maxValue; i++)
			{
				tagRemoveObject.depth = i;
				
				utilityByteArray.position += 1;//tag type read
				
				var outputTag:SwfPackerTagRemoveObject = new SwfPackerTagRemoveObject();
				
				removeObjectTagExporter.importTag(outputTag, utilityByteArray);
				
				if(!outputTag.isEquals(tagRemoveObject))
					Assert.fail("output tag is not same to Etalon tag at: " + i + " should be " + tagRemoveObject.toString() + ", but was " + outputTag.toString());
			}
		}
	}
}