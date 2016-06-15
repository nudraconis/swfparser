package swfDataExporter 
{
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SwfDataExporterTestSuite 
	{
		
		public function SwfDataExporterTestSuite() 
		{
			
		}
		
		public var placeObjectExporterTest:PlaceObjectExporterTest;
		public var removeObjectExporterTest:RemoveObjectExporterTest;
		public var symbolClassExporterTest:SymbolClassExporterTest;
		public var swfPackerTagExporterTest:SwfPackerTagExporterTest;
		public var defineSpriteExporterTest:DefineSpriteExporterTest;
	}

}