package swfDataExporter 
{
	import fastByteArray.IByteArray;
	import swfDataExporter.ExporerTypes;
	import swfDataExporter.SwfTagExporter;
	import swfdata.FrameData;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagDefineSprite;

	public class DefineSpriteExporter extends SwfPackerTagExporter
	{
		/**
		 * 1nt16 - tagHeader
		 * int16 - char id
		 * int8  - frames count
		 * int8  - tags count
		 * array of frame data
		 * [int8 - isHaveLabel, utfBytes - frameLabel]
		 * array of tags data
		 */
		
		private var swfTagExporter:SwfTagExporter;
		
		public function DefineSpriteExporter(swfTagExporter:SwfTagExporter) 
		{
			super(ExporerTypes.DEFINE_SPRITE);
			
			this.swfTagExporter = swfTagExporter;
		}
		
		override public function exportTag(tag:SwfPackerTag, output:IByteArray):void 
		{
			super.exportTag(tag, output);
			
			var tagAsSpriteDefine:SwfPackerTagDefineSprite = tag as SwfPackerTagDefineSprite;
			
			var tagsCount:int = tagAsSpriteDefine.tags.length;
			var frameCount:int = tagAsSpriteDefine.frameCount;
			
			output.writeInt16(tagAsSpriteDefine.characterId);
			output.writeInt16(frameCount);
			output.writeInt16(tagsCount);
			
			var i:int;
			
			for (i = 0; i < frameCount; i++)
			{
				var currentFrameData:FrameData = tagAsSpriteDefine.frames[i];
				
				output.writeInt16(currentFrameData.numChildren);
				
				if (currentFrameData.frameLabel)
				{
					output.writeInt8(1);
					output.writeUTF(currentFrameData.frameLabel);
				}
				else
				{
					output.writeInt8(0);
				}
			}
			
			//trace('export sub tags', tagAsSpriteDefine.tags.length);
			swfTagExporter.exportTags(tagAsSpriteDefine.tags, output);
		}
		
		override public function importTag(tag:SwfPackerTag, input:IByteArray):void 
		{
			super.importTag(tag, input);
			
			var tagAsSpriteDefine:SwfPackerTagDefineSprite = tag as SwfPackerTagDefineSprite;
			
			var characterId:uint = input.readInt16();
			var frameCount:int = input.readInt16();
			var tagsCount:int = input.readInt16();
			
			tagAsSpriteDefine.characterId = characterId;
			tagAsSpriteDefine.frameCount = frameCount;
			
			if (frameCount > 0)
				tagAsSpriteDefine.frames = new Vector.<FrameData>(frameCount, true);
			
			var i:int;
			
			for (i = 0; i < frameCount; i++)
			{
				var numChildren:int = input.readInt16();
				var currentFrameData:FrameData = new FrameData(i, null, numChildren);
				
				var isHaveLabel:Boolean = input.readInt8() == 1;
				
				if (isHaveLabel)
					currentFrameData.frameLabel = input.readUTF();
					
				tagAsSpriteDefine.frames[i] = currentFrameData;
			}
			
			if (tagsCount > 0)
			{
				tagAsSpriteDefine.tags = new Vector.<SwfPackerTag>(tagsCount, true);
				
				for (i = 0; i < tagsCount; i++)
				{
					//try
					//{
						tagAsSpriteDefine.tags[i] = swfTagExporter.importSingleTag(input);
					//}
					//catch (e:Error)
					//{
					//	e.message += " at: " + i;
						
					//	throw e;
					//}
				}
			}
		}
	}
}