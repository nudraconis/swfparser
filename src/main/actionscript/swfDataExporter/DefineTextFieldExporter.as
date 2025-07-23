package swfDataExporter 
{
	import fastByteArray.IByteArray;
	import flash.geom.Rectangle;
	import swfDataExporter.ExporerTypes;
	import swfDataExporter.SwfTagExporter;
	import swfdata.FrameData;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagDefineSprite;
	import swfdata.dataTags.SwfPackerTagDefineText;
	import util.PackerHelper;
	import utils.BitMask;

	public class DefineTextFieldExporter extends SwfPackerTagExporter
	{
		/*
		 * 
		 * 	public var fontId:uint;
			public var fontClass:String;
			public var fontHeight:uint;
			public var textColor:uint;
			public var maxLength:uint;
			public var align:uint;
			public var leftMargin:uint;
			public var rightMargin:uint;
			public var indent:uint;
			public var leading:int;
			public var initialText:String;
		*/
			
		/**
		 * 1nt16		- tagHeader
		 * int16		- char id
		 * 4x int32		- rectangle
		 * int16		- mask of text field flags
		 * int16		- fontId
		 * int16		- fontHeight
		 * int32		- textColor
		 * int16		- maxLenght
		 * int16		- align
		 * int16		- leftMargin
		 * int16		- rightMargin
		 * int16		- ident
		 * int16		- leading
		 * int8			- mask of utf values
		 * utfString	- fontClass
		 * utfString	- variable name
		 * uifString	- initialText
		 */
		
		public function DefineTextFieldExporter() 
		{
			super(ExporerTypes.DEFINE_TEXT_FIELD);
		}
		
		override public function exportTag(tag:SwfPackerTag, output:IByteArray):void 
		{
			super.exportTag(tag, output);
			
			var tagCasted:SwfPackerTagDefineText = tag as SwfPackerTagDefineText;
			
			if (tagCasted.characterId == 0) {
				trace("erorr");
			}
			
			output.writeInt16(tagCasted.characterId);
			
			/**
			 * 	public var hasText:Boolean;
				public var wordWrap:Boolean;
				public var multiline:Boolean;
				public var password:Boolean;
				public var readOnly:Boolean;
				public var hasTextColor:Boolean;
				public var hasMaxLength:Boolean;
				public var hasFont:Boolean;
				public var hasFontClass:Boolean;
				public var autoSize:Boolean;
				public var hasLayout:Boolean;
				public var noSelect:Boolean;
				public var border:Boolean;
				public var wasStatic:Boolean;
				public var html:Boolean;
				public var useOutlines:Boolean;
			 */
			var textFieldFlags:BitMask = new BitMask();
			textFieldFlags.setBit2(0, tagCasted.hasText);
			textFieldFlags.setBit2(1, tagCasted.wordWrap);
			textFieldFlags.setBit2(2, tagCasted.multiline);
			textFieldFlags.setBit2(3, tagCasted.password);
			textFieldFlags.setBit2(4, tagCasted.readOnly);
			textFieldFlags.setBit2(5, tagCasted.hasTextColor);
			textFieldFlags.setBit2(6, tagCasted.hasMaxLength);
			textFieldFlags.setBit2(7, tagCasted.hasFont);
			textFieldFlags.setBit2(8, tagCasted.hasFontClass);
			textFieldFlags.setBit2(9, tagCasted.autoSize);
			textFieldFlags.setBit2(10, tagCasted.hasLayout);
			textFieldFlags.setBit2(11, tagCasted.noSelect);
			textFieldFlags.setBit2(12, tagCasted.border);
			textFieldFlags.setBit2(13, tagCasted.wasStatic);
			textFieldFlags.setBit2(14, tagCasted.html);
			textFieldFlags.setBit2(15, tagCasted.useOutlines);
			
			PackerHelper.writeRectangle(tagCasted.bounds, output);
			
			output.writeInt16(textFieldFlags.mask);
			output.writeInt16(tagCasted.fontId);
			output.writeInt16(tagCasted.fontHeight);
			output.writeInt32(tagCasted.textColor);
			output.writeInt16(tagCasted.maxLength);
			output.writeInt16(tagCasted.align);
			output.writeInt16(tagCasted.leftMargin);
			output.writeInt16(tagCasted.rightMargin);
			output.writeInt16(tagCasted.indent);
			output.writeInt16(tagCasted.leading);
			
			var utfFieldsMask:BitMask = new BitMask();
			utfFieldsMask.setBit2(0, tagCasted.variableName != null);
			utfFieldsMask.setBit2(1, tagCasted.fontClass != null);
			utfFieldsMask.setBit2(2, tagCasted.initialText != null);
			
			output.writeInt8(utfFieldsMask.mask);
			
			if (utfFieldsMask.isBitSet(0))
				output.writeUTF(tagCasted.variableName);
			if (utfFieldsMask.isBitSet(1))
				output.writeUTF(tagCasted.fontClass);
			if (utfFieldsMask.isBitSet(2))
				output.writeUTF(tagCasted.initialText);
		}
		
		override public function importTag(tag:SwfPackerTag, input:IByteArray):void 
		{
			super.importTag(tag, input);
			
			var tagCasted:SwfPackerTagDefineText = tag as SwfPackerTagDefineText;
			
			tagCasted.characterId = input.readInt16();
			tagCasted.bounds = PackerHelper.readRectangle(input);			
			
			var textFieldFlags:BitMask = new BitMask(input.readInt16());
			tagCasted.hasText = textFieldFlags.isBitSet(0);
			tagCasted.wordWrap = textFieldFlags.isBitSet(1);
			tagCasted.multiline = textFieldFlags.isBitSet(2);
			tagCasted.password = textFieldFlags.isBitSet(3);
			tagCasted.readOnly = textFieldFlags.isBitSet(4);
			tagCasted.hasTextColor = textFieldFlags.isBitSet(5);
			tagCasted.hasMaxLength = textFieldFlags.isBitSet(6);
			tagCasted.hasFont = textFieldFlags.isBitSet(7);
			tagCasted.hasFontClass = textFieldFlags.isBitSet(8);
			tagCasted.autoSize = textFieldFlags.isBitSet(9);
			tagCasted.hasLayout = textFieldFlags.isBitSet(10);
			tagCasted.noSelect = textFieldFlags.isBitSet(11);
			tagCasted.border = textFieldFlags.isBitSet(12);
			tagCasted.wasStatic = textFieldFlags.isBitSet(13);
			tagCasted.html = textFieldFlags.isBitSet(14);
			tagCasted.useOutlines = textFieldFlags.isBitSet(15);
			
			tagCasted.fontId = input.readInt16();
			
			tagCasted.fontHeight = input.readInt16();
			tagCasted.textColor = input.readInt32();
			tagCasted.maxLength = input.readInt16();
			tagCasted.align = input.readInt16();
			tagCasted.leftMargin = input.readInt16();
			tagCasted.rightMargin = input.readInt16();
			tagCasted.indent = input.readInt16();
			tagCasted.leading = input.readInt16();

			var utfFieldsMask:BitMask = new BitMask(input.readInt8());
			if (utfFieldsMask.isBitSet(0))
				tagCasted.variableName = input.readUTF();
			if (utfFieldsMask.isBitSet(1))
				tagCasted.fontClass = input.readUTF();
			if (utfFieldsMask.isBitSet(2))
				tagCasted.initialText = input.readUTF();
		}
	}
}