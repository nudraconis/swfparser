package swfparser.tags 
{
	import flash.geom.Matrix;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagDefineText;
	import swfparser.ISWFDataParser;
	import swfparser.SwfParserContext;

	public class TagProcessorDeifneText extends TagProcessorBase 
	{
		private var swfDataParser:ISWFDataParser;
		
		public static var spritesDefined:int = 0;
		
		private static const defaultMatrix:Matrix = new Matrix();
		
		public function TagProcessorDeifneText(context:SwfParserContext, swfDataParser:ISWFDataParser) 
		{
			super(context);
			this.swfDataParser = swfDataParser;
		}
		
		override public function processTag(tag:SwfPackerTag):void 
		{
			super.processTag(tag);
			
			var tagAsTextTag:SwfPackerTagDefineText = tag as SwfPackerTagDefineText;
			
			trace('try to define text');
		}
	}
}