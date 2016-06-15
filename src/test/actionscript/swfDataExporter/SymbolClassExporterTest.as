package swfDataExporter 
{
	import fastByteArray.FastByteArray;
	import flexunit.framework.Assert;
	import swfdata.dataTags.RawClassSymbol;
	import swfdata.dataTags.SwfPackerTagSymbolClass;
	import swfdata.dataTags.SwfPackerTagSymbolClass;
	import swfDataExporter.SymbolClassExporter;
	
	public class SymbolClassExporterTest 
	{
		private var symbolClassExporter:SymbolClassExporter;
		private var tagSymbolClass:SwfPackerTagSymbolClass;
		private var utilityByteArray:FastByteArray;
		
		public function SymbolClassExporterTest() 
		{
			
		}
		
		[Before]
		public function startUp():void
		{
				var minvalue:int = -16383;
			var maxValue:int = 16383;
			
			symbolClassExporter = new SymbolClassExporter();
			tagSymbolClass = new SwfPackerTagSymbolClass(maxValue + Math.abs(minvalue));
			
		
			var c:int = 0;
			for (var i:int = minvalue; i < maxValue; i++,c++)
			{
				tagSymbolClass.linkageList[c] = "linkage#" + i;
				tagSymbolClass.characterIdList[c] = i;
			}
			
			utilityByteArray = new FastByteArray(null, 32768 * 4 + 65536 * 100);
			utilityByteArray.begin();
		}
		
		[After]
		public function end():void
		{
			symbolClassExporter = null;
			tagSymbolClass = null;
			utilityByteArray.end(true);
			utilityByteArray = null;
		}
		
		[Test]
		public function exportImportTest():void
		{
			symbolClassExporter.exportTag(tagSymbolClass, utilityByteArray);
			
			utilityByteArray.position = 1;//tag type read;
			
			var outputTag:SwfPackerTagSymbolClass = new SwfPackerTagSymbolClass();
			symbolClassExporter.importTag(outputTag, utilityByteArray);
			
			Assert.assertEquals("length of class-symbol in imported tag is not same with Etalon tag", tagSymbolClass.length, outputTag.length);
			Assert.assertEquals("length of charIdList in imported tag is not same with Etalon tag", tagSymbolClass.characterIdList.length, outputTag.characterIdList.length);
			Assert.assertEquals("length of linkageList in imported tag is not same with Etalon tag", tagSymbolClass.linkageList.length, outputTag.linkageList.length);
			
			for (var i:int = 0; i < outputTag.length; i++)
			{
				Assert.assertEquals("inspect class-symbol cahracterId at: " + i + " is not equals to Etalon", tagSymbolClass.characterIdList[i], outputTag.characterIdList[i]);
				Assert.assertEquals("inspect class-symbol linkage at: " + i + " is not equals to Etalon", tagSymbolClass.linkageList[i], outputTag.linkageList[i]);
			}
		}
	}

}