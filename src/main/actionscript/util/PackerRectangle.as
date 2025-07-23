package util {
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class PackerRectangle {
		

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected static var availableInstance:PackerRectangle;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function get(x:int, y:int, width:int, height:int, id:int = 0, bitmapData:BitmapData = null, originX:int = 0, originY:int = 0, pivotX:Number = 0, pivotY:Number = 0):PackerRectangle 
		{
			var instance:PackerRectangle = PackerRectangle.availableInstance;
			
			if (instance != null) 
			{
				PackerRectangle.availableInstance = instance.nextInstance;
				instance.nextInstance = null;
				instance.disposed = false;
			}
			else 
			{
				instance = new PackerRectangle();
			}
			
			

			instance.x = x;
			instance.y = y;
			instance.width = width;
			instance.height = height;
			instance.right = x + width;
			instance.bottom = y + height;
			instance.id = id;
			instance.bitmapData = bitmapData;
			instance.originX = originX;
			instance.originY = originY;
			instance.pivotX = pivotX;
			instance.pivotY = pivotY;

			return instance;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function PackerRectangle() {
			super();
		}

		public var next:PackerRectangle;

		public var previous:PackerRectangle;

		public var nextInstance:PackerRectangle;
		
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;

		public var x:int = 0;

		public var y:int = 0;

		public var width:int = 0;

		public var height:int = 0;

		public var right:int = 0;

		public var bottom:int = 0;

		public var id:int;

		public var bitmapData:BitmapData;
		
		public var originX:int;
		
		public var originY:int;

		public var pivotX:Number;

		public var pivotY:Number;

		public var padding:int = 0;
		
		private var disposed:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------

		public function set(x:int, y:int, width:int, height:int):void {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.right = x + width;
			this.bottom = y + height;
		}

		public function dispose():void {
			this.next = null;
			this.previous = null;
			this.nextInstance = PackerRectangle.availableInstance;
			PackerRectangle.availableInstance = this;
			this.bitmapData = null;
			
			if (disposed)
				throw new Error("try to dispose alrady disposed object");
			
			disposed = true;
		}

		public function setPadding(p_value:int):void {
			this.x -= p_value - this.padding;
			this.y -= p_value - this.padding;
			this.width += (p_value - this.padding) * 2;
			this.height += (p_value - this.padding) * 2;
			this.right += p_value - this.padding;
			this.bottom += p_value - this.padding;
			this.padding = p_value;
		}

		public function getRect():Rectangle {
			return new Rectangle(this.x, this.y, this.width, this.height);
		}
		
		public function toString():String {
			return "PackerRectangle(" + x + ", " + y + ", " + width + ", " + height + ")";
		}
	}
}
