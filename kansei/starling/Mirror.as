package kansei.starling 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import kansei.starling.TextureUpdater;
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Un isleño
	 */
	public class Mirror extends Image 
	{
		
		public var bmp 		: BitmapData
		public var clone 	: BitmapData
		public var object 	: DisplayObject
		public var matrix	: Matrix
		public var scale	: Number
		
		/**
		 * 
		 * @param	object The object to be draw into the Texture
		 * @param	area any an optional alternative reference for the size of the Texture. It can be any object containing width and height properties.
		 * @param	scale A factor used to modify the size of the texture. The greater the scale the greater the texture. This is intented to keep the draw at maximum quality when drawing flash vectors into the bitmapData. 
		 * @param	transparent  A Boolean indicating the 
		 */
		public function Mirror(object:DisplayObject, area:Object=null, scale:Number=1, transparent:Boolean = true) 
		{
			this.object = object;
			area = area || object
			this.scale = scale;
			
			matrix = new Matrix();
			updateMatrix();
			
			bmp = new BitmapData( area.width*scale, area.height*scale, transparent, 0 )
			clone = bmp.clone()
			
			bmp.draw( object )
			
			super( Texture.fromBitmapData(bmp) );
			
			
		}
		
		
		public function updateOnEvent(eventType:String, dispatcher:Object = null):void
		{
			dispatcher = dispatcher || object;
			dispatcher.addEventListener(eventType, update)
		}
		
		public function cancelUpdate(eventType:String, dispatcher:Object = null):void
		{
			dispatcher = dispatcher || object;
			dispatcher.removeEventListener(eventType, update)
		}
		
		private var nullPoint : Point = new Point
		public function update(...e)
		{
			bmp.copyChannel( clone, clone.rect, nullPoint, 1, 1)
			bmp.copyChannel( clone, clone.rect, nullPoint, 1, 2)
			bmp.copyChannel( clone, clone.rect, nullPoint, 1, 4)
			bmp.copyChannel( clone, clone.rect, nullPoint, 1, 8)
			
			bmp.draw( object, matrix )
			TextureUpdater.update(texture, bmp)
		}
		public function updateMatrix():void
		{
			matrix.identity();
			matrix.scale(scale, scale)
		}
		
	}

}