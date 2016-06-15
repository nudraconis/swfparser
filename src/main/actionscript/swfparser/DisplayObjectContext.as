package swfparser 
{
	import swfdata.DisplayObjectContainer;
	import swfdata.DisplayObjectData;
	import swfdata.DisplayObjectTypes;
	import swfdata.MovieClipData;
	import swfdata.SpriteData;
	import swfdata.swfdata_inner;
	
	use namespace swfdata_inner;
	
	public class DisplayObjectContext 
	{
		public var currentDisplayObjectAsMovieClip:MovieClipData;
		public var currentDisplayObject:SpriteData;
		public var currentContainer:DisplayObjectContainer;
		public var currentDisplayList:Vector.<DisplayObjectData>;
		
		public function DisplayObjectContext() 
		{
			
		}
		
		[Inline]
		public final function setCurrentDisplayObject(displayObject:SpriteData):void
		{
			currentDisplayObjectAsMovieClip = null;
			currentContainer = null;
			currentDisplayList = null;
			
			currentDisplayObject = displayObject;
			
			if (currentDisplayObject == null)
				return;
			
			if (currentDisplayObject.displayObjectType == DisplayObjectTypes.SPRITE_TYPE)
			{
				currentContainer = currentDisplayObject.displayContainer;
				currentDisplayList = currentContainer._displayObjects;
			}
			else
			{
				currentDisplayObjectAsMovieClip = currentDisplayObject as MovieClipData;
				updateFrame();
			}
		}
		
		[Inline]
		public final function updateFrame():void 
		{
			currentContainer = currentDisplayObjectAsMovieClip._currentFrameData;
			currentDisplayList = currentContainer._displayObjects;
		}
		
		[Inline]
		public final function nextFrame():void
		{
			if (currentDisplayObjectAsMovieClip == null)
				return;
				
			currentDisplayObjectAsMovieClip.nextFrame();
			updateFrame();
		}
		
		public function clear():void 
		{
			if(currentDisplayObject)
				currentDisplayObject.destroy();
			
			currentDisplayObjectAsMovieClip = null;
			currentDisplayObject = null;
			currentContainer = null;
			currentDisplayList = null;
		}
	}
}