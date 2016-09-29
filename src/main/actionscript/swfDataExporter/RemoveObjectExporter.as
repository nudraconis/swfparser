package swfDataExporter 
{
	import fastByteArray.IByteArray;
	import swfDataExporter.ExporerTypes;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagRemoveObject;

	public class RemoveObjectExporter extends SwfPackerTagExporter
	{
		
		public function RemoveObjectExporter() 
		{
			super(ExporerTypes.REMOVE_OBJECT);
		}
		
		override public function exportTag(tag:SwfPackerTag, output:IByteArray):void 
		{
			super.exportTag(tag, output);
			
			var tagAsRemoveObject:SwfPackerTagRemoveObject = tag as SwfPackerTagRemoveObject;
			
			if (tagAsRemoveObject.depth > 32767 || tagAsRemoveObject.depth < 0)
				throw new Error("out of range");
			
			output.writeInt16(tagAsRemoveObject.depth);
			output.writeInt16(tagAsRemoveObject.characterId);
		}
		
		override public function importTag(tag:SwfPackerTag, input:IByteArray):void 
		{
			super.importTag(tag, input);
			
			var tagAsRemoveObject:SwfPackerTagRemoveObject = tag as SwfPackerTagRemoveObject;
			
			tagAsRemoveObject.depth = input.readInt16();
			tagAsRemoveObject.characterId = input.readInt16();
		}
	}

}