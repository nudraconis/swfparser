package swfDataExporter 
{
	import flash.utils.ByteArray;
	import swfdata.dataTags.SwfPackerTag;
	
	/**
	 * ...
	 * @author ...
	 */
	public interface ISwfPackerTagExporter 
	{
		
		function exportTag(tag:SwfPackerTag, output:ByteArray):void;
		
		function importTag(tag:SwfPackerTag, input:ByteArray):void;
	}
	
}