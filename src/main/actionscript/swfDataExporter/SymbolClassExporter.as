package swfDataExporter 
{
	import fastByteArray.IByteArray;
	
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagSymbolClass;
	
	public class SymbolClassExporter extends SwfPackerTagExporter
	{
		
		public function SymbolClassExporter() 
		{
			super(ExporerTypes.SYMBOL_CLASS);
		}
	
		override public function exportTag(tag:SwfPackerTag, output:IByteArray):void 
		{
			super.exportTag(tag, output);
			
			var tagAsSymbolClass:SwfPackerTagSymbolClass = tag as SwfPackerTagSymbolClass;
			var symbolsCount:int = tagAsSymbolClass.length;
			
			output.writeInt16(symbolsCount);
			
			for (var i:int = 0; i < symbolsCount; i++)
			{
				
				var currentLinkage:String = tagAsSymbolClass.linkageList[i];
				var currentCharacterId:int = tagAsSymbolClass.characterIdList[i];
				
				//if (currentSumbol.linkage == null)
				//	continue;
				
				output.writeInt16(currentCharacterId);
				output.writeUTF(currentLinkage);
			}
		}
		
		override public function importTag(tag:SwfPackerTag, input:IByteArray):void 
		{
			super.importTag(tag, input);
			
			var tagAsSymbolClass:SwfPackerTagSymbolClass = tag as SwfPackerTagSymbolClass;
			
			var symbolsCount:int = input.readInt16();
			
			tagAsSymbolClass.length = symbolsCount;
			tagAsSymbolClass.initializeContent();
			
			var linkagesList:Vector.<String> = tagAsSymbolClass.linkageList;
			var characterList:Vector.<int> = tagAsSymbolClass.characterIdList;
			
			for (var i:int = 0; i < symbolsCount; i++)
			{
				characterList[i] = input.readInt16();
				linkagesList[i] = input.readUTF();
			}
		}
	}
}