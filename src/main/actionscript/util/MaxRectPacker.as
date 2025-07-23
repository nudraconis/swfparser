package util {
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class MaxRectPacker {
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		static public var BOTTOM_LEFT:int = 0;

		static public var SHORT_SIDE_FIT:int = 1;

		static public var LONG_SIDE_FIT:int = 2;

		static public var AREA_FIT:int = 3;

		static public var SORT_NONE:int = 0;

		static public var SORT_ASCENDING:int = 1;

		static public var SORT_DESCENDING:int = 2;

		static public var nonValidTextureSizePrecision:int = 5;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function MaxRectPacker(maxWidth:int = 4096, maxHeight:int = 4096, autoExpand:Boolean = true, heuristics:int = 0):void 
		{
			this._maxWidth = maxWidth;
			this._maxHeight = maxHeight;
			this._autoExpand = autoExpand;
			//this.clear(atlasDatas[0]);
			this._newBoundingArea = PackerRectangle.get(0, 0, 0, 0);
			this._heuristics = heuristics;
			
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected var _heuristics:int = 0;

		/**
		 * @private
		 */
		protected var _firstAvailableArea:PackerRectangle;

		/**
		 * @private
		 */
		protected var _lastAvailableArea:PackerRectangle;

		/**
		 * @private
		 */
		protected var _firstNewArea:PackerRectangle;

		/**
		 * @private
		 */
		protected var _lastNewArea:PackerRectangle;

		/**
		 * @private
		 */
		protected var _newBoundingArea:PackerRectangle;

		/**
		 * @private
		 */
		protected var _negativeArea:PackerRectangle;

		/**
		 * @private
		 */
		protected var _maxWidth:int;

		/**
		 * @private
		 */
		protected var _maxHeight:int;

		/**
		 * @private
		 */
		protected var _autoExpand:Boolean = false;

		/**
		 * @private
		 */
		protected var _sortOnExpand:int = 2;

		/**
		 * @private
		 */
		protected var _forceValidTextureSizeOnExpand:Boolean = true;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		
		private var totalPacketRectangles:int  = 0;
		public var atlasUsed:int = 0;
		public var atlasDatas:Vector.<AtlasRectanglesData>;//atlas buffer
	
		
		public function clearData():void
		{
			totalPacketRectangles = 0;
			atlasUsed = 0;
			alreadyPackedMap = {};
			
			//if (_negativeArea)
			//	_negativeArea.dispose();
				
			_negativeArea = null;
			
			//if (_newBoundingArea)
			//	_newBoundingArea.dispose();
				
			_newBoundingArea = PackerRectangle.get(0, 0, 0, 0, 0);
			
			//if (_lastNewArea)
			//	_lastNewArea.dispose();
				
			_lastNewArea = null;
			
			//if (_firstNewArea)
			//	_firstNewArea.dispose();
			
			_firstNewArea = null;
			
			//if (_lastAvailableArea)
			//	_lastAvailableArea.dispose();
			
			_lastAvailableArea = null;
			
			//if (_firstAvailableArea)
			//	_firstAvailableArea.dispose();
			
			_firstAvailableArea = null;
			
			if (atlasDatas)
			{
				for (var i:int = 0; i < atlasDatas.length; i++)
					atlasDatas[i].clear();
			}
			//else
				atlasDatas = new <AtlasRectanglesData>[new AtlasRectanglesData(0), new AtlasRectanglesData(1), new AtlasRectanglesData(2), new AtlasRectanglesData(3), new AtlasRectanglesData(4)];
				
			//clear(atlasDatas[0]);
		}
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------

		//public function packRectangle(rect:PackerRectangle, padding:int = 0, forceValidTextureSize:Boolean = true):Boolean {
		//	var success:Boolean = this.addRectangle(rect, padding);
		//	if (!success && this._autoExpand) {
		//		var storedRectangles:Vector.<PackerRectangle> = this.rectangles;
		//		storedRectangles.push(rect);
		//		this.clear();
		//		trace('pack');
		//		trace("packed#", this.packRectangles(storedRectangles, padding, this._sortOnExpand));
		//		success = true;
		///	}
		//	return success;
		//}

		private var alreadyPackedMap:Object;
		
		public function packRectangles(rectangles:Vector.<PackerRectangle>, padding:int = 0, sort:int = 2):Boolean 
		{
			if (sort != 0) 
				rectangles.sort(((sort == 1) ? this.sortOnHeightAscending : this.sortOnHeightDescending));
				
			totalPacketRectangles = 0;
			atlasUsed = 0;
			var failedRectangles:Vector.<PackerRectangle> = new Vector.<PackerRectangle>();
			var currentAtlasData:AtlasRectanglesData;
				
			while (rectangles.length > totalPacketRectangles)
			{
				var count:int = rectangles.length;
				var success:Boolean = false;
				
				//failedRectangles.length = 0;
				
				currentAtlasData = atlasDatas[atlasUsed];
				atlasUsed++;
				
				//никогда не будет работать пок аесть авто экспанд, т.к атлас экспандится с 1х1
				/*var _g:int = 0;
				while (_g < count) 
				{
					var i:int = _g++;
					var rect:PackerRectangle = rectangles[i];
					
					if (alreadyPackedMap[rect.id] != null)
						continue;
					
					var s:Boolean = this.addRectangle(rect, padding, currentAtlasData);

					if (!s && this._autoExpand) 
						failedRectangles.push(rectangles[i]);
						
					success = success && s;
				}*/
				failedRectangles = rectangles;
				
				if (!success && this._autoExpand) 
				{
					var storedRectangles:Vector.<PackerRectangle> = currentAtlasData.rectangles.slice(0);
					storedRectangles = storedRectangles.concat(failedRectangles);
					
					if (this._sortOnExpand != 0) 
						storedRectangles.sort(((this._sortOnExpand == 1) ? this.sortOnHeightAscending : this.sortOnHeightDescending));
						
					var minimalArea:int = this.getRectanglesArea(storedRectangles);
					trace("minimal area", minimalArea);
					
					var isMaxAreaUsed:Boolean = minimalArea >= _maxWidth * _maxHeight;
					
					//если минимал арея больше или равна мксимальному размеру атласа то можно срзу атлас делать максимального размера
					if (isMaxAreaUsed) {
						currentAtlasData.width = _maxWidth;
						currentAtlasData.height = _maxHeight;
					} else {
						//смотрит площадь minimalArea и если она меньше уже заданной _width, _height расширает ее вплоть до maxWidth, maxHeight
						do 
						{
							if ((currentAtlasData.width <= currentAtlasData.height || currentAtlasData.height == this._maxHeight) && currentAtlasData.width < this._maxWidth) 
							{	
								if (this._forceValidTextureSizeOnExpand) 
									currentAtlasData.width = currentAtlasData.width * 2;
								else 
									currentAtlasData.width = currentAtlasData.width + 1;
							}
							else
							{
								if (this._forceValidTextureSizeOnExpand) 
									currentAtlasData.height = currentAtlasData.height * 2;
								else 
									currentAtlasData.height = currentAtlasData.height + 1
							}
							
							
						}
						while (currentAtlasData.width * currentAtlasData.height < minimalArea && (currentAtlasData.width < this._maxWidth || currentAtlasData.height < this._maxHeight));
					}
					
					trace("expand atlas", currentAtlasData.width, currentAtlasData.height);
					
					this.clear(currentAtlasData);
					success = this.addRectangles(storedRectangles, currentAtlasData, padding);
					
					//Если атлас уже был увеличен до макисмальных размреов то нет мысла его расширять второй раз
					if (!isMaxAreaUsed) {
						if (!success) {
							trace('second expand', _maxWidth, _maxHeight);
						}
						
						//если изначальная оценка оказалось не вреной и не смогли добавится все субтекстуры но еще есть место то расширяем атлас и добавляем еще
						while (!success && (currentAtlasData.width < this._maxWidth || currentAtlasData.height < this._maxHeight)) 
						{
							if ((currentAtlasData.width <= currentAtlasData.height || currentAtlasData.height == this._maxHeight) && currentAtlasData.width < this._maxWidth) 
							{
								if (this._forceValidTextureSizeOnExpand) 
									currentAtlasData.width = currentAtlasData.width * 2;
								else
									currentAtlasData.width = currentAtlasData.width + MaxRectPacker.nonValidTextureSizePrecision;
							}
							else
							{	
								if (this._forceValidTextureSizeOnExpand) 
									currentAtlasData.height = currentAtlasData.height * 2;
								else
									currentAtlasData.height = currentAtlasData.height + MaxRectPacker.nonValidTextureSizePrecision;
							}	
							
							this.clear(currentAtlasData);
							success = this.addRectangles(storedRectangles, currentAtlasData, padding);
						}
					}
					
					success = currentAtlasData.width <= this._maxWidth && currentAtlasData.height <= this._maxHeight;
				}
				
				trace("success: " + (success? "атлас заполнен":"атлас прееполнен"));
				
				var length:int = currentAtlasData.rectangles.length;
				totalPacketRectangles += length;
				for (var k:int = 0; k < length; k++)
				{
					if (alreadyPackedMap[currentAtlasData.rectangles[k].id] != null) {
						trace("reactangle is already packed", currentAtlasData.rectangles[k].id);
					}
					alreadyPackedMap[currentAtlasData.rectangles[k].id] = true;
				}
			}
			
			return success;
		}

		public function clear(atlasData:AtlasRectanglesData):void 
		{
			var rects:int = atlasData.rectangles.length;
			
			atlasData.rectangles.length = 0;
			
			while (this._firstAvailableArea != null) 
			{
				var area:PackerRectangle = this._firstAvailableArea;
				this._firstAvailableArea = area.next;
				area.dispose();
			}

			this._firstAvailableArea = this._lastAvailableArea = PackerRectangle.get(0, 0, atlasData.width, atlasData.height);
			this._negativeArea = PackerRectangle.get(atlasData.width + 1, atlasData.height + 1, atlasData.width + 1, atlasData.height + 1);
		}

		public function drawAtlas(atlasIndex:int):BitmapData
		{
			var currentAtlasData:AtlasRectanglesData = atlasDatas[atlasIndex];
			
			var w:Number = currentAtlasData.width;
			var h:Number = currentAtlasData.height;
			
			var atlasBitmap:BitmapData = new BitmapData(w, h, true, 0x0);
			
			draw(atlasBitmap, currentAtlasData);
			
			return atlasBitmap;
		}
		
		private static var DRWAING_RECT:Rectangle = new Rectangle();
		private static var DRAWING_POINT:Point = new Point();
		
		private function draw(bitmapData:BitmapData, atlasData:AtlasRectanglesData):void 
		{
			var rectangles:Vector.<PackerRectangle> = atlasData.rectangles;
			
			var _g1:int = 0;
			var _g:int = rectangles.length;
			
			bitmapData.lock();
			
			while (_g1 < _g) 
			{
				var i:int = _g1++;
				var rect:PackerRectangle = rectangles[i];
				
				DRWAING_RECT.setTo(rect.originX, rect.originY, rect.width, rect.height);
				DRAWING_POINT.setTo(rect.x, rect.y);
				
				bitmapData.copyPixels(rect.bitmapData, DRWAING_RECT, DRAWING_POINT);
			}
			
			bitmapData.unlock();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function getRectanglesArea(rectangles:Vector.<PackerRectangle>):int {
			var area:int = 0;
			var i:int = rectangles.length - 1;
			while (i >= 0) {
				var rect:PackerRectangle = rectangles[i--];
				if (alreadyPackedMap[rect.id] != null)
					continue;
				area += rect.width * rect.height;
			}
			return area;
		}

		/**
		 * @private
		 */
		protected function addRectangles(rectangles:Vector.<PackerRectangle>, atlasData:AtlasRectanglesData, padding:int = 0):Boolean 
		{
			var count:int = rectangles.length;
			var success:Boolean = true;
			
			var _g:int = 0;
			while (_g < count) 
			{
				var i:int = _g++;
				var rect:PackerRectangle = rectangles[i];
				
				if (alreadyPackedMap[rect.id] != null)
					continue;
						
				success = success && this.addRectangle(rect, padding, atlasData);
				
				if (!success) 
					return false;
			}
			
			return success;
		}

		/**
		 * @private
		 */
		protected function addRectangle(rect:PackerRectangle, padding:int, atlasData:AtlasRectanglesData):Boolean 
		{
			var area:PackerRectangle = this.getAvailableArea(rect.width + (padding - rect.padding) * 2, rect.height + (padding - rect.padding) * 2, atlasData);
			
			if (area != null) 
			{
				//trace("add rectangle", rect.id, area);
				rect.set(area.x, area.y, rect.width + (padding - rect.padding) * 2, rect.height + (padding - rect.padding) * 2);
				rect.padding = padding;
				this.splitAvailableAreas(rect);
				this.pushNewAreas();
				if (padding != 0) rect.setPadding(0);
				
				atlasData.rectangles.push(rect);
			} else {
				//trace("fail to add rectangle", rect.id, rect.width, rect.height);
			}
			
			return area != null;
		}

		/**
		 * @private
		 */
		protected function createNewArea(x:int, y:int, width:int, height:int):PackerRectangle 
		{
			var valid:Boolean = true;
			var area:PackerRectangle = this._firstNewArea;
			
			while (area != null) 
			{
				var next:PackerRectangle = area.next;
				
				if (!(area.x > x || area.y > y || area.right < x + width || area.bottom < y + height)) 
				{
					valid = false;
					break;
				}
				else if (!(area.x < x || area.y < y || area.right > x + width || area.bottom > y + height)) 
				{
					if (area.next != null) 
						area.next.previous = area.previous;
					else 
						this._lastNewArea = area.previous;
						
					if (area.previous != null) 
						area.previous.next = area.next;
					else 
						this._firstNewArea = area.next;
						
					area.dispose();
				}

				area = next;
			}

			if (valid) 
			{
				area = PackerRectangle.get(x, y, width, height);
				if (this._newBoundingArea.x < x) this._newBoundingArea.x = x;
				if (this._newBoundingArea.right > area.right) this._newBoundingArea.right = area.right;
				if (this._newBoundingArea.y < y) this._newBoundingArea.y = y;
				if (this._newBoundingArea.bottom < area.bottom) this._newBoundingArea.bottom = area.bottom;
				if (this._lastNewArea != null) {
					area.previous = this._lastNewArea;
					this._lastNewArea.next = area;
					this._lastNewArea = area;
				}
				else {
					this._lastNewArea = area;
					this._firstNewArea = area;
				}
			}
			else area = null;
			return area;
		}

		/**
		 * @private
		 */
		protected function splitAvailableAreas(splitter:PackerRectangle):void {
			var sx:int = splitter.x;
			var sy:int = splitter.y;
			var sright:int = splitter.right;
			var sbottom:int = splitter.bottom;
			var area:PackerRectangle = this._firstAvailableArea;
			while (area != null) {
				var next:PackerRectangle = area.next;
				if (!(sx >= area.right || sright <= area.x || sy >= area.bottom || sbottom <= area.y)) {
					if (sx > area.x) this.createNewArea(area.x, area.y, sx - area.x, area.height);
					if (sright < area.right) this.createNewArea(sright, area.y, area.right - sright, area.height);
					if (sy > area.y) this.createNewArea(area.x, area.y, area.width, sy - area.y);
					if (sbottom < area.bottom) this.createNewArea(area.x, sbottom, area.width, area.bottom - sbottom);
					if (area.next != null) area.next.previous = area.previous;
					else this._lastAvailableArea = area.previous;
					if (area.previous != null) area.previous.next = area.next;
					else this._firstAvailableArea = area.next;
					area.dispose();
				}

				area = next;
			}
		}

		/**
		 * @private
		 */
		protected function pushNewAreas():void {
			while (this._firstNewArea != null) {
				var area:PackerRectangle = this._firstNewArea;
				if (area.next != null) {
					this._firstNewArea = area.next;
					this._firstNewArea.previous = null;
				}
				else this._firstNewArea = null;
				area.previous = null;
				area.next = null;
				if (this._lastAvailableArea != null) {
					area.previous = this._lastAvailableArea;
					this._lastAvailableArea.next = area;
					this._lastAvailableArea = area;
				}
				else {
					this._lastAvailableArea = area;
					this._firstAvailableArea = area;
				}
			}

			this._lastNewArea = null;
			this._newBoundingArea.set(0, 0, 0, 0);
		}

		/**
		 * @private
		 */
		protected function getAvailableArea(width:int, height:int, atlasData:AtlasRectanglesData):PackerRectangle {
			var available:PackerRectangle = this._negativeArea;
			var index:int = -1;
			var area:PackerRectangle;
			var w:int;
			var h:int;
			var m1:int;
			var m2:int;
			if (this._heuristics == 0) {
				area = this._firstAvailableArea;
				while (area != null) {
					if (area.width >= width && area.height >= height) {
						if (area.y < available.y || area.y == available.y && area.x < available.x) available = area;
					}

					area = area.next;
				}
			}
			else if (this._heuristics == 1) {
				available.width = atlasData.width + 1;
				area = this._firstAvailableArea;
				while (area != null) {
					if (area.width >= width && area.height >= height) {
						w = area.width - width;
						h = area.height - height;
						if (w < h) m1 = w;
						else m1 = h;
						w = available.width - width;
						h = available.height - height;
						if (w < h) m2 = w;
						else m2 = h;
						if (m1 < m2) available = area;
					}

					area = area.next;
				}
			}
			else if (this._heuristics == 2) {
				available.width = atlasData.width + 1;
				area = this._firstAvailableArea;
				while (area != null) {
					if (area.width >= width && area.height >= height) {
						w = area.width - width;
						h = area.height - height;
						if (w > h) m1 = w;
						else m1 = h;
						w = available.width - width;
						h = available.height - height;
						if (w > h) m2 = w;
						else m2 = h;
						if (m1 < m2) available = area;
					}

					area = area.next;
				}
			}
			else if (this._heuristics == 3) {
				available.width = atlasData.width + 1;
				area = this._firstAvailableArea;
				while (area != null) {
					if (area.width >= width && area.height >= height) {
						var a1:int = area.width * area.height;
						var a2:int = available.width * available.height;
						if (a1 < a2 || a1 == a2 && area.width < available.width) available = area;
					}
					area = area.next;
				}
			}
			if (available != this._negativeArea) return available;
			else return null;
		}

		/**
		 * @private
		 */
		protected function sortOnAreaAscending(a:PackerRectangle, b:PackerRectangle):int {
			var aa:int = a.width * a.height;
			var ba:int = b.width * b.height;
			if (aa < ba) return -1;
			else if (aa > ba) return 1;
			return 1;
		}

		/**
		 * @private
		 */
		protected function sortOnAreaDescending(a:PackerRectangle, b:PackerRectangle):int {
			var aa:int = a.width * a.height;
			var ba:int = b.width * b.height;
			if (aa > ba) return -1;
			else if (aa < ba) return 1;
			
			return 1;
		}

		/**
		 * @private
		 */
		protected function sortOnHeightAscending(a:PackerRectangle, b:PackerRectangle):int {
			if (a.height < b.height) return -1;
			else if (a.height > b.height) return 1;
			
			return 1;
		}

		/**
		 * @private
		 */
		protected function sortOnHeightDescending(a:PackerRectangle, b:PackerRectangle):int {
			if (a.height > b.height) return -1;
			else if (a.height < b.height) return 1;
			return 1;
		}
	}
}
