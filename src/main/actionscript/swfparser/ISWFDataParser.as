package swfparser 
{
	import swfdata.dataTags.SwfPackerTag;
	
	public interface ISWFDataParser 
	{
		
		function processDisplayObject(tags:Vector.<SwfPackerTag>):void;
		
		function set context(value:SwfParserContext):void;
		
		function get context():SwfParserContext;
	}
	
}