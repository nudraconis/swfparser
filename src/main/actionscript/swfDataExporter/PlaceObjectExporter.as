package swfDataExporter 
{
	import fastByteArray.Constants;
	import fastByteArray.IByteArray;
	import swfDataExporter.ExporerTypes;
	import swfdata.dataTags.SwfPackerTag;
	import swfdata.dataTags.SwfPackerTagPlaceObject;
	import utils.BitMask;

	public class PlaceObjectExporter extends SwfPackerTagExporter
	{
		private static var bitMask:BitMask = new BitMask();
		
		public function PlaceObjectExporter() 
		{
			super(ExporerTypes.PLACE_OBJECT);
		}
		
		public final function readMATRIX(input:IByteArray, tagAsPlaceObject:SwfPackerTagPlaceObject):void
		{
			var scaleX:Number = 1;
			var scaleY:Number = 1;
			
			//if (input.readBits(1) == 1) 
			if (input.readInt8() == 1) 
			{
				//var scaleBits:uint = input.readBits(5);
				//scaleX = input.readFixedBits(scaleBits);
				//scaleY = input.readFixedBits(scaleBits);
				
				scaleX = input.readInt32() / Constants.FIXED_PRECISSION_VALUE; 
				scaleY = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			}
			
			var rotateSkew0:Number = 0;
			var rotateSkew1:Number = 0;
			
			//if (input.readBits(1) == 1) 
			if (input.readInt8() == 1) 
			{
				//var rotateBits:uint = input.readBits(5);
				//rotateSkew0 = input.readFixedBits(rotateBits);
				//rotateSkew1 = input.readFixedBits(rotateBits);
				
				rotateSkew0 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
				rotateSkew1 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			}
			
			//var translateBits:uint = input.readBits(5);
			
			//var translateX:Number = input.readBits(translateBits);
			//var translateY:Number = input.readBits(translateBits);
			
			var translateX:Number = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			var translateY:Number = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			
			tagAsPlaceObject.setMatrix(scaleX, rotateSkew0, rotateSkew1, scaleY, translateX, translateY);
		}
		
		public function writeMATRIX(output:IByteArray, value:SwfPackerTagPlaceObject):void
		{
			var scaleX:Number = value.a;
			var scaleY:Number = value.d;
			var rotateSkew0:Number = value.b;
			var rotateSkew1:Number = value.c;
			var translateX:int = value.tx * Constants.FIXED_PRECISSION_VALUE;
			var translateY:int = value.ty * Constants.FIXED_PRECISSION_VALUE;

			var hasScale:Boolean = (scaleX != 1) || (scaleY != 1);
			var hasRotate:Boolean = (rotateSkew0 != 0) || (rotateSkew1 != 0);
			
			//output.writeBits(hasScale ? 1 : 0, 1);
			output.writeInt8(hasScale ? 1 : 0);
			
			if (hasScale) 
			{
				//var scaleBits:uint;
				//if (scaleX == 0 && scaleY == 0) 
				//{
				//	scaleBits = 1;
				//} 
				//else 
				//{
				//	scaleBits = ByteArrayUtils.calculateMaxFixedBits(true, scaleX, scaleY);
				//}
				
				//output.writeBits(scaleBits, 5);
				//output.writeFixedBits(scaleX, scaleBits);
				//output.writeFixedBits(scaleY, scaleBits);
				
				output.writeInt32(scaleX * Constants.FIXED_PRECISSION_VALUE);
				output.writeInt32(scaleY * Constants.FIXED_PRECISSION_VALUE);
			}
			
			//output.writeBits(hasRotate ? 1 : 0, 1);
			output.writeInt8(hasRotate ? 1 : 0);
			
			if (hasRotate) 
			{
				//var rotateBits:uint = ByteArrayUtils.calculateMaxFixedBits(true, rotateSkew0, rotateSkew1);
				
				//output.writeBits(rotateBits, 5);
				//output.writeFixedBits(rotateSkew0, rotateBits);
				//output.writeFixedBits(rotateSkew1, rotateBits);
				
				output.writeInt32(rotateSkew0 * Constants.FIXED_PRECISSION_VALUE);
				output.writeInt32(rotateSkew1 * Constants.FIXED_PRECISSION_VALUE);
			}
			
			//var translateBits:uint = ByteArrayUtils.calculateMaxBits(true, translateX, translateY);
			
			//output.writeBits(translateBits, 5);
			//output.writeBits(translateX, translateBits);
			//output.writeBits(translateY, translateBits);
			
			//output.end(false);
			
			output.writeInt32(translateX);
			output.writeInt32(translateY);
		}
		
		public function readColorMatrix(tag:SwfPackerTagPlaceObject, input:IByteArray):void
		{
			tag.redColor0 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.redColor1 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.redColor2 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.redColor3 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.redColorOffset = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			
			tag.greenColor0 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.greenColor1 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.greenColor2 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.greenColor3 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.greenColorOffset = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			
			tag.blueColor0 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.blueColor1 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.blueColor2 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.blueColor3 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.blueColorOffset = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			
			tag.alpha0 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.alpha1 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.alpha2 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.alpha3 = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			tag.alphaOffset = input.readInt32() / Constants.FIXED_PRECISSION_VALUE;
			
			//trace(tag.instanceName, "read color matrix", tag.toColorMatrixString());
		}
		
		public function writeColorMatrix(tag:SwfPackerTagPlaceObject, output:IByteArray):void
		{
			//trace(tag.instanceName, "write color matrix", tag.toColorMatrixString());
			var hasOffset:Boolean = tag.redColorOffset != 0 || tag.greenColorOffset != 0 || tag.blueColorOffset != 0 || tag.alphaOffset != 0;
			var hasRed:Boolean = tag.redColor0 != 0 || tag.redColor1 != 0 || tag.redColor2 != 0 || tag.redColor3 != 0;
			var hasGreen:Boolean = tag.greenColor0 != 0 || tag.greenColor1 != 0 || tag.greenColor2 != 0 || tag.greenColor3 != 0;
			var hasBlue:Boolean = tag.blueColor0 != 0 || tag.blueColor1 != 0 || tag.blueColor2 != 0 || tag.blueColor3 != 0;
			
			var componentsMask:int = 0;
			bitMask.mask = componentsMask;
			
			output.writeInt32(tag.redColor0 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.redColor1 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.redColor2 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.redColor3 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.redColorOffset * Constants.FIXED_PRECISSION_VALUE);
			
			output.writeInt32(tag.greenColor0 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.greenColor1 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.greenColor2 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.greenColor3 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.greenColorOffset * Constants.FIXED_PRECISSION_VALUE);
			
			output.writeInt32(tag.blueColor0 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.blueColor1 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.blueColor2 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.blueColor3 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.blueColorOffset * Constants.FIXED_PRECISSION_VALUE);
			
			output.writeInt32(tag.alpha0 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.alpha1 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.alpha2 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.alpha3 * Constants.FIXED_PRECISSION_VALUE);
			output.writeInt32(tag.alphaOffset * Constants.FIXED_PRECISSION_VALUE);
		}
		
		override public function exportTag(tag:SwfPackerTag, output:IByteArray):void 
		{
			super.exportTag(tag, output);
			
			var tagAsPlaceObject:SwfPackerTagPlaceObject = tag as SwfPackerTagPlaceObject;
			
			
			bitMask.mask = 0;
			
			if (tagAsPlaceObject.hasClipDepth)
				bitMask.setBit(0);
				
			if (tagAsPlaceObject.hasName)
				bitMask.setBit(1);
				
			//if (tagAsPlaceObject.hasRatio)
			//	bitMask.setBit(3);
				
			if (tagAsPlaceObject.hasMatrix)
				bitMask.setBit(2);
				
			if (tagAsPlaceObject.hasCharacter)
				bitMask.setBit(3);
				
			if (tagAsPlaceObject.hasColorTransform)
				bitMask.setBit(4);
			//	
			//if (tagAsPlaceObject.hasMove)
			//	bitMask.setBit(7);
				
			//if (tagAsPlaceObject.hasVisible)
			//	bitMask.setBit(8);
				
			//if (tagAsPlaceObject.hasImage)
			//	bitMask.setBit(9);
				
			//if (tagAsPlaceObject.hasBlendMode)
			//	bitMask.setBit(10);
				
			//if (tagAsPlaceObject.hasFilterList)
			//	bitMask.setBit(11);
			
			output.writeInt8(bitMask.mask);
			
			output.writeInt8(tagAsPlaceObject.placeMode);
			output.writeInt16(tagAsPlaceObject.depth);
			
			if (tagAsPlaceObject.depth > 65535)
				throw new Error('depth range error ' + tagAsPlaceObject.depth);
			
			
			if (tagAsPlaceObject.hasClipDepth)
				output.writeInt8(tagAsPlaceObject.clipDepth);
				
			if (tagAsPlaceObject.hasName)
				output.writeUTF(tagAsPlaceObject.instanceName);
				
			//if (tagAsPlaceObject.hasRatio)
			//	output.writeUnsignedInt(tagAsPlaceObject.ratio);
				
			if (tagAsPlaceObject.hasMatrix)
				writeMATRIX(output, tagAsPlaceObject);
				
			if (tagAsPlaceObject.hasCharacter)
			{
				output.writeInt16(tagAsPlaceObject.characterId);
			}
				
			if (tagAsPlaceObject.hasColorTransform)
			{
				//trace('shood write color');
				writeColorMatrix(tagAsPlaceObject, output);
				//byteArray.writeColorTransform(tagAsPlaceObject.colorTransfo)
			}
				
			//output.end(false);
		}
		
		private var totalTime:Number = 0;
		private var totalTime2:Number = 0;
		override public function importTag(tag:SwfPackerTag, input:IByteArray):void 
		{
			var tagAsPlaceObject:SwfPackerTagPlaceObject = tag as SwfPackerTagPlaceObject;
			
			//var currentTime:Number = getTimer();
			var mask:uint = input.readInt8();
			bitMask.mask = mask;
			
			var placeMode:int = input.readInt8();
			var depth:int = input.readInt16();
			var hasClipDepth:Boolean = bitMask.isBitSet(0);
			var hasName:Boolean = bitMask.isBitSet(1);
			var hasMatrix:Boolean = bitMask.isBitSet(2);
			var hasCharacter:Boolean = bitMask.isBitSet(3);
			var hasColorTransform:Boolean = bitMask.isBitSet(4);
			
			var instanceName:String;
			var clipDepth:int;
			var characterId:int;
			//totalTime += getTimer() - currentTime;
			//trace("total time", totalTime);
			if (hasClipDepth)
			{
				clipDepth = input.readInt8();
			}
			
			if (hasName)
			{
				instanceName = input.readUTF();
			}
			
			if (hasMatrix)
			{
				//currentTime = getTimer()
				readMATRIX(input, tagAsPlaceObject);
				//totalTime2 += getTimer() - currentTime;
				//trace("total time 2", totalTime2);
			}
			
			if (hasCharacter)
			{
				characterId = input.readInt16();
			}
			
			tagAsPlaceObject.fillData(placeMode, depth, hasClipDepth, hasName, hasMatrix, hasCharacter, instanceName, clipDepth, characterId);
			
			if (hasColorTransform)
			{
				
				tagAsPlaceObject.hasColorTransform = true;
				readColorMatrix(tagAsPlaceObject, input);
				//tagAsPlaceObject.hasColorTransform = true;
				//tagAsPlaceObject.colorTransform = bitOperator.readColorTransform();
			}
		}
	}
}