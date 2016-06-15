package swfDataExporter 
{
	import fastByteArray.FastByteArray;
	import flexunit.framework.Assert;
	import swfdata.dataTags.SwfPackerTag;
	import swfDataExporter.SwfPackerTagExporter;
	/**
	 * ...
	 * @author ...
	 */
	public class SwfPackerTagExporterTest 
	{
		private var swfPackerTagExporter:SwfPackerTagExporter;
		private var swfPackerTag:SwfPackerTag;
		private var utilityByteArray:FastByteArray;
		
		public function SwfPackerTagExporterTest() 
		{
			
		}
		
		[Before]
		public function startUp():void
		{
			swfPackerTagExporter = new SwfPackerTagExporter();
			swfPackerTag = new SwfPackerTag();
			
			utilityByteArray = new FastByteArray();
		}
		
		[After]
		public function end():void
		{
			swfPackerTagExporter = null;
			swfPackerTag = null;
			utilityByteArray.end(true);
			utilityByteArray = null;
		}
		
		[Test]
		public function exportImportTest():void
		{
			var type:int = 22;
			swfPackerTagExporter.type = type;
			
			swfPackerTagExporter.exportTag(swfPackerTag, utilityByteArray);
			utilityByteArray.end(false);
			
			utilityByteArray.position = 0;
			
			Assert.assertEquals("import tag is not same as Etalong tag", type, utilityByteArray.readInt8());			
		}
	}

}