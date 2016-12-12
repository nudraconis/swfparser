package swfparser 
{
	import flash.utils.Dictionary;
	import swfdata.BitmapLibrary;
	import swfdata.atlas.AtlasDrawer;
	import swfdata.DisplayObjectData;
	import swfdata.IDisplayObjectContainer;
	import swfdata.ShapeLibrary;
	import swfdata.SymbolsLibrary;
	import swfdata.SpriteData;
	
	public class SwfParserContext 
	{
		public var atlasDrawer:AtlasDrawer;
		public var library:SymbolsLibrary;
		public var shapeLibrary:ShapeLibrary;
		public var bitmapLibrary:BitmapLibrary;
		
		public var placeObjectsMap:Dictionary = new Dictionary();
		public var placedObjectsById:Dictionary = new Dictionary();
		
		//public var placeObjectsList:Vector.<DisplayObjectData> = new Vector.<DisplayObjectData>();
		
		public var displayObjectContext:DisplayObjectContext = new DisplayObjectContext();
		
		public var onlyTagReport:Boolean = false;
		
		public function SwfParserContext() 
		{
			
		}
		
		public function clear():void 
		{
			if(displayObjectContext)
				displayObjectContext.clear();
		
			for each(var dObject:DisplayObjectData in placeObjectsMap)
				dObject.destroy();
				
			placeObjectsMap = new Dictionary();
			placedObjectsById = new Dictionary();
			//placeObjectsList.length = 0;
		}
		
		public function dispose():void 
		{
			atlasDrawer.dispose();
		}
	}
}