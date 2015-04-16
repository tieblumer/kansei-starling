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
		
		/**
		 * HOW TO USE IT
		 * 
		 * var mirror : Mirror = new Mirror( myFlashTextField ) // creates a Mirror instance, that is basically an Image extension. Pass the flash object you want to reflect.
		 *
		 * mirror.updateOnEvent("textInput") // adds a listener to the flash object. Every time it dispatches this event the texture will be updated.  
		 * 
		 */
		
		public var bmp 		: BitmapData
		public var clone 	: BitmapData
		public var reference 	: DisplayObject
		public var matrix	: Matrix
		public var scale	: Number
		
		
		
		private var dispatcher : Object
		private var updateEventType : String
		
		private var nullPoint : Point = new Point

		
		/**
		 * Used to create an image that reflects any flash.DispayObject and keep it updated.
		 * @param	object The object to be draw into the Texture
		 * @param	area any an optional alternative reference for the size of the Texture. It can be any object containing width and height properties.
		 * @param	scale A factor used to modify the size of the texture. The greater the scale the greater the texture. This is intended to keep the draw at maximum quality when drawing flash vectors into the bitmapData. 
		 * @param	transparent  A Boolean indicating if the bitmapData use to the texture is transparent or not.
		 */
		public function Mirror(object:DisplayObject, area:Object=null, scale:Number=1, transparent:Boolean = true) 
		{
			this.reference = object;
			area = area || object
			this.scale = scale;
			
			matrix = new Matrix();
			updateMatrix();
			
			bmp = new BitmapData( area.width*scale, area.height*scale, transparent, 0 )
			clone = bmp.clone()
			
			bmp.draw( object )
			
			super( Texture.fromBitmapData(bmp) );
			
			
		}
		
		/**
		 * Adds an eventListener to the flash object, or to the object indicated as dispatcher, in order to automatically update Texture.
		 * @param	eventType The type of event dispatched by the flash object
		 * @param	dispatcher An alternative eventDispatcher to listen to.
		 */
		public function updateOnEvent(eventType:String="change", dispatcher:Object = null):void
		{
			dispatcher = dispatcher || reference;
			dispatcher.addEventListener(eventType, update)
			
			updateEventType = eventType
			this.dispatcher = dispatcher
		}
		
		/**
		 * Removes the last listener created with updateOnEvent 
		 */
		public function cancelUpdate():void
		{
			dispatcher.removeEventListener(updateEventType, update)
		}
		
		
		/**
		 * Draw the flashObject to the texture
		 * @param	...e Just accepts anything like an event or nothing at all.
		 */
		public function update(...e)
		{
			bmp.copyChannel( clone, clone.rect, nullPoint, 1, 1)
			bmp.copyChannel( clone, clone.rect, nullPoint, 1, 2)
			bmp.copyChannel( clone, clone.rect, nullPoint, 1, 4)
			bmp.copyChannel( clone, clone.rect, nullPoint, 1, 8)
			
			bmp.draw( reference, matrix )
			TextureUpdater.update(texture, bmp)
		}
		
		/**
		 * Manually updates the drawing matrix if you decide to change any parameter like object or BitmapData after the instance was created.
		 */
		public function updateMatrix():void
		{
			matrix.identity();
			matrix.scale(scale, scale)
		}
		
	}

}