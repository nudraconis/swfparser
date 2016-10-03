package swfDataExporter 
{
	import fastByteArray.IByteArray;
	
	import swfdata.dataTags.SwfPackerTag;
	
	public class SwfPackerTagExporter
	{
		public var type:int;
		
		public function SwfPackerTagExporter(type:int = ExporerTypes.BASE_TYPE) 
		{
			this.type = type;
		}
		
		public function exportTag(tag:SwfPackerTag, output:IByteArray):void
		{
			
			output.writeInt8(type);
		}
		
		public function importTag(tag:SwfPackerTag, input:IByteArray):void
		{
			
		}
	}
}