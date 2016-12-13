package swfparser.tags 
{

	import flash.utils.Dictionary;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagShowFrame;
	import swfdata.DisplayObjectContainer;
	import swfdata.DisplayObjectData;
	import swfdata.IDisplayObjectContainer;
	import swfdata.MovieClipData;
	import swfdata.SpriteData;
	import swfdata.swfdata_inner;
	import swfparser.DisplayObjectContext;
	import swfparser.SwfParserContext;
	
	use namespace swfdata_inner;
	
	/**
	 * Определяет показ кадра т.е последующие теги будут уже относится к следующему кадру
	 * тут нужно обработать переход между кадрами т.е если объекты не двигались в этом кадре и 
	 * не были получены их новые плейсы нжуно выставить им последнее значение в трансформ которое было 
	 * зарегестрировано в предидущих кадрах
	 */
	public class TagProcessorShowFrame extends TagProcessorBase 
	{
		
		public function TagProcessorShowFrame(context:SwfParserContext) 
		{
			super(context);
		}
		
		override public function processTag(tag:SwfPackerTag):void 
		{
			var currentDisplayObject:SpriteData = displayObjectContext.currentDisplayObject;
			
			if (currentDisplayObject == null)
				return;
				
			var tagShowFrame:SwfPackerTagShowFrame = tag as SwfPackerTagShowFrame;
			
			var container:DisplayObjectContainer = displayObjectContext.currentContainer;
			//trace('show frame', context.displayObjectContext.currentDisplayObjectAsMovieClip? context.displayObjectContext.currentDisplayObjectAsMovieClip.currentFrame:"");	
			//if (container.displayObjectsCount > 0)
			//{
				var currentDisplayList:Vector.<DisplayObjectData> = displayObjectContext.currentDisplayList;
				var index:int = container.displayObjectsPlacedCount;
				
				var placeObjectsMap:Dictionary = context.placeObjectsMap;
				
				for each(var objectToPlace:DisplayObjectData in placeObjectsMap)
				{
					currentDisplayList[index++] = objectToPlace;
				}
				
				container.displayObjectsPlacedCount = index;
				
				if(index > 1)// && container.displayObjectsPlacedCount == container.displayObjectsCount)
					currentDisplayList.sort(sortOnDepth);
				
				currentDisplayObject.updateMasks();
			//}
			
			displayObjectContext.nextFrame();
		}
		
		[Inline]
		public static function sortOnDepth(a:DisplayObjectData, b:DisplayObjectData):Number 
		{
			if (a && b && a.depth > b.depth)
				return 1;
			//else if (a.depth < b.depth)
			//	return -1;
			else
				return -1;
		}
		
	}
}