package swfDataExporter 
{
	import fastByteArray.FastByteArray;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flexunit.framework.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.matrix.isMatrixEquals;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagPlaceObject;
	import swfDataExporter.PlaceObjectExporter;
	
	public class PlaceObjectExporterTest 
	{
		private var placeObjectExporter:PlaceObjectExporter;
		private var swfPackerTag:SwfPackerTagPlaceObject;
		private var utilityByteArray:FastByteArray;
		
		public function PlaceObjectExporterTest() 
		{
			
		}
		
		[Before]
		public function setup():void
		{
			placeObjectExporter = new PlaceObjectExporter();
			
			prepareTagToPacking();
			
			utilityByteArray = new FastByteArray();
			utilityByteArray.begin();
		}
		
		private function prepareTagToPacking():void
		{
			swfPackerTag = new SwfPackerTagPlaceObject();
			
			//matrix section lets use floats
			swfPackerTag.setMatrix(1.1245, 2.432, 3.123, 4.42, 5.412, 6.213);
			swfPackerTag.hasMatrix = true;
			
			swfPackerTag.hasCharacter = true;
			swfPackerTag.characterId = 1;
			
			swfPackerTag.placeMode = SwfPackerTagPlaceObject.PLACE_MODE_REPLACE;
			
			swfPackerTag.depth = 15;
			
			swfPackerTag.hasClipDepth = true;
			swfPackerTag.clipDepth = 22;
			
			swfPackerTag.hasName = true;
			swfPackerTag.instanceName = "testInstanceName";
		}
		
		[After]
		public function end():void
		{
			placeObjectExporter = null;
			swfPackerTag = null;
			utilityByteArray.end(true);
			utilityByteArray = null;
		}
		
		[Test]
		public function testExportImportMaxValuesTest():void
		{
			
		}
		
		[Test]
		public function testExportImport():void
		{
			placeObjectExporter.exportTag(swfPackerTag, utilityByteArray);
			
			var outputTag:SwfPackerTagPlaceObject = new SwfPackerTagPlaceObject();
			
			utilityByteArray.position = 1;//read swf packer tag type
			placeObjectExporter.importTag(outputTag, utilityByteArray);
			
			assertThat("TagPlaceObject shouls equals to Etalon tag, passed tag is: "+outputTag+", but should be " + swfPackerTag, outputTag.isEquals(swfPackerTag));
			assertThat("Test matrix equals", swfPackerTag, isMatrixEquals(outputTag));
		}
		
		[Test]
		public function testExportImportNegativeMatrixValues():void
		{
			var minValue:int = -32768;
			var maxValue:int = 32767;
			var i:int = 0;
			
			for (i = minValue; i < maxValue; i++)
			{
				utilityByteArray.position = 0;

				swfPackerTag.tx = i/100;
				swfPackerTag.ty = i/100;
				swfPackerTag.a = i / 1000;
				swfPackerTag.b = i / 1000;
				swfPackerTag.c = i / 1000;
				swfPackerTag.d = i / 1000;
				
				swfPackerTag.characterId = i;
				
				placeObjectExporter.exportTag(swfPackerTag, utilityByteArray);
				
				var outputTag:SwfPackerTagPlaceObject = new SwfPackerTagPlaceObject();
				
				utilityByteArray.position = 1;//read swf packer tag type
				placeObjectExporter.importTag(outputTag, utilityByteArray);
				
				assertThat("TagPlaceObject shouls equals to Etalon tag at: " + i + ", passed tag is: "+outputTag+", but should be " + swfPackerTag, outputTag.isEquals(swfPackerTag));
				assertThat("Test matrix equals at " + i, swfPackerTag, isMatrixEquals(outputTag));
			}
		}
	}
}