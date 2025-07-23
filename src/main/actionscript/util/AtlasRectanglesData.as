package util 
{
	public class AtlasRectanglesData 
	{
		public var atlasIndex:int;
		public var rectangles:Vector.<PackerRectangle> = new Vector.<PackerRectangle>;
		
		public var width:Number = 1;
		public var height:Number = 1;
		
		public function AtlasRectanglesData(atlasIndex:int) 
		{
			this.atlasIndex = atlasIndex;
			
		}
		
		public function clear():void 
		{
			
			width = 1;
			height = 1;
			//atlasIndex = 0;
			
			clearRects();
		}
		
		public function clearRects():void 
		{
			//for (var i:int = 0; i < rectangles.length; i++)
			//{
			//	rectangles[i].dispose();
			//}
			
			rectangles = null;// length = 0;
		}
		
	}
}