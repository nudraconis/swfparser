package swfparser.tags 
{
	import flash.geom.Rectangle;
	import swfdata.TextFieldData;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagDefineText;
	import swfparser.SwfParserContext;
	
	public class TagProcessorTextFieldDefinition extends TagProcessorBase  
	{	
		public static var textFieldsDefined:int = 0;
		
		public function TagProcessorTextFieldDefinition(context:SwfParserContext) 
		{
			super(context);
		}
		
		override public function processTag(tag:SwfPackerTag):void 
		{
			super.processTag(tag);
			
			textFieldsDefined++;
			
			var tagDefineTextField:SwfPackerTagDefineText = tag as SwfPackerTagDefineText;
			
			var bounds:Rectangle = tagDefineTextField.bounds;
			var characterId:int = tagDefineTextField.characterId;
			
			if (characterId == 0)
				trace('Error: wrong? text field dfinition');
			
			var tx:Number = bounds.x //- shapeBound.width / 2;
			var ty:Number = bounds.y //- shapeBound.height / 2;
			
			bounds.x = tx;
			bounds.y = ty;
			
			//add shape data to library
			var textField:TextFieldData = new TextFieldData(characterId);
			textField.tx = tx;
			textField.ty = ty;
			
			textField.variableName = tagDefineTextField.variableName;
			textField.bounds = tagDefineTextField.bounds;
			
			textField.hasText = tagDefineTextField.hasText;
			textField.wordWrap = tagDefineTextField.wordWrap;
			textField.multiline = tagDefineTextField.multiline;
			textField.password = tagDefineTextField.password;
			textField.readOnly = tagDefineTextField.readOnly;
			textField.hasTextColor = tagDefineTextField.hasTextColor;
			textField.hasMaxLength = tagDefineTextField.hasMaxLength;
			textField.hasFont = tagDefineTextField.hasFont;
			textField.hasFontClass = tagDefineTextField.hasFontClass;
			textField.autoSize = tagDefineTextField.autoSize;
			textField.hasLayout = tagDefineTextField.hasLayout;
			textField.noSelect = tagDefineTextField.noSelect;
			textField.border = tagDefineTextField.border;
			textField.wasStatic = tagDefineTextField.wasStatic;
			textField.html = tagDefineTextField.html;
			textField.useOutlines = tagDefineTextField.useOutlines;
			
			textField.fontId = tagDefineTextField.fontId;
			textField.fontClass = tagDefineTextField.fontClass;
			textField.fontHeight = tagDefineTextField.fontHeight;
			textField.textColor = tagDefineTextField.textColor;
			textField.maxLength = tagDefineTextField.maxLength;
			textField.align = tagDefineTextField.align;
			textField.leftMargin = tagDefineTextField.leftMargin;
			textField.rightMargin = tagDefineTextField.rightMargin;
			textField.indent = tagDefineTextField.indent;
			textField.leading = tagDefineTextField.leading;
			textField.initialText = tagDefineTextField.initialText;
			
			context.library.addDisplayObject(textField);
			//context.shapeLibrary.addShape(shapeView, shape);
		}
		
		public function clear():void 
		{
			context = null;
		}
	}
}