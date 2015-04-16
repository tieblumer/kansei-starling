package kansei.starling 
{
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Un isleño
	 */
	public class AtlasGenerator 
	{
		/** La lista de objetos a ser pintados en el nuevo atlas */
		public var objects : Array
		
		/** La lista de las esquinas disponibles en el atlas para posicionas el siguiente objeto */ 
		private var points : Array
		
		/** Una lista de los objetos ya posicionados*/
		private var placedObjects : Array
		
		/** Un segundo atlas para pintar los objetos que nohan entrado en ese atlas. */
		private var nextAtlas 		: AtlasGenerator
		
		/** Un atlas alternativo utilizando el algoritmo "y" en lugar del atlas */
		private var brother 	: AtlasGenerator
		
		public var margin : int = 2
		
		public var width  		: int = 0
		public var height 		: int = 0
		public var algorithm 	: String = "x"
		public var isUsed 		: Boolean = false
		
		public var atlas : TextureAtlas
		public var bmp : BitmapData
		public var xml : XML
		
		public var collection : Array
		
		/**
		 * Genera un nuevo atlas
		 * @param	size
		 * @param	algorithm
		 */
		public function AtlasGenerator(size:int, algorithm:String="x") 
		{
			objects = [];
			points = [];
			placedObjects = [];
			collection = []
			
			this.algorithm = algorithm;
			if (algorithm === "x") 
			{
				width = size;
				brother = new AtlasGenerator(size, "y")
			}
			else 
			{
				height = size;
			}
			
		}
		
		/**
		 * Añade un objeto a la lista de objetos a ser diseñados en el nuevo atlas.
		 * @param	object El objeto a ser dibujado en el atlas
		 * @param	scale Escala las dimensiones del objeto. Es ignorado si se pasa width y/ o height.
		 * @param	width Define el ancho del objeto. Si height es 0 ajusta el alto proporcionalmente.
		 * @param	height Define el alto del objeto. Si width es 0 ajusta el ancho proporcionalmente.
		 */
		public function addObject( object:Object, scale:Number = 1, width : Number = 0, height:Number = 0 ):void
		{
			
			if (width || height)
			{
				if (!width) return addObject( object, height/object.height)
				if (!height) return addObject( object, width/object.width)
				
				objects.push( { object:object, width:width, height:height, scale:width/object.width } )
				return
			}
			objects.push({
							image:	object, 
							name:	object.name,
							scale: scale,
							width:	Math.ceil(object.width  * scale), 
							height:	Math.ceil(object.height * scale)
						})	
						
			if (brother) brother.addObject(object, scale, width, height);
		}
		
		public function get lastObject():Object
		{
			return objects[ objects.length -1 ];
		}
		
		/** inicia la creación del atlas y del xml */
		public function generate():void
		{
			_generate()
			
			flat(collection);
			
			var matrix : Matrix = new Matrix
			
			for (var loop in collection)
			{
				var g : AtlasGenerator = collection[loop] as AtlasGenerator
				g.bmp = new BitmapData(g.width, g.height, true, 0 /*0x80ff0000 */)
				
				var xml : String = '<?xml version="1.0" encoding="UTF-16"?><TextureAtlas imagePath="atlas' + loop + '.png">'
				for ( var lop in collection[loop].placedObjects )
				{
					var o = collection[loop].placedObjects[lop]
					xml += '<SubTexture name="'+ o.name  +'" x="'+o.x+'" y="'+o.y+'" width="'+o.width+'" height="'+o.height+'"/>'
				
					matrix.identity()
					matrix.a = o.width / o.image.width
					matrix.d = o.height / o.image.height
					matrix.tx = o.x
					matrix.ty = o.y
					
					g.bmp.draw(o.image, matrix, null, null, null, true)
				}
				xml += '</TextureAtlas>'
				g.xml = new XML(xml);
				
				
				
				var texture : Texture = Texture.fromBitmapData(g.bmp)
				atlas = new TextureAtlas( texture, g.xml )
				
				
				g.nextAtlas = null;
				g.brother = null;
			}
			
		}
		private function _generate()
		{
			points[0] = { x:margin, y:margin }
			
			if (algorithm === "x")
			{
				objects.sortOn(["width", "height"],Array.NUMERIC | Array.DESCENDING)
				for ( var loop in objects )
				{
					placeX(objects[loop] )
				}
				brother._generate()
			}
			else
			{
				objects.sortOn(["height","width"],Array.NUMERIC | Array.DESCENDING)
				for ( loop in objects )
				{
					placeY(objects[loop] )
				}
			}
			if (nextAtlas)
			{
				nextAtlas.checkSize()
			}
			
		}		
		
		/** Comprueba que el objeto entra en la página y decide cual es el mejor sitio para posicionarlo utilizando el algoritmo "x" */
		private function placeX(object)
		{
			//trace("")
			//trace("placeObjectX", object.name, object.width, object.height)
			if (object.width > width )
			{
				if (!nextAtlas) nextAtlas = new AtlasGenerator(width*2)
				nextAtlas.addObject( object.image, 1, object.width, object.height )
			}
			
			points.sortOn("y", Array.NUMERIC)
			//tracePoints()
			for (var loop in points)
			{
				var point = points[loop]
				//trace("check point "+loop, point.x, point.y)
				if ( fitsInPageX(object, point) && 	!hitTest(object, point) )
				{
					//trace("ok")
					return placeObject( object, point );
				}
			}
			
		}
		
		/** Comprueba que el objeto entra en la página y decide cual es el mejor sitio para posicionarlo utilizando el algoritmo "y" */
		private function placeY(object)
		{
			if (object.height > height )
			{
				if (!nextAtlas) nextAtlas = new AtlasGenerator( height * 2);
				nextAtlas.addObject( object.image, 1, object.width, object.height )
			}
			
			points.sortOn("x", Array.NUMERIC)
			for (var loop in points)
			{
				var point = points[loop]
				if ( fitsInPageY(object, point) && !hitTest(object, point) )
				{
					return placeObject( object, point );
				}
			}
			
		}
		
		
		private function fitsInPageX(object, point):Boolean
		{
			//trace(point.x + object.width + margin < width ? "fits" : "doesnt fit")
			return point.x + object.width + margin < width
		}
		private function fitsInPageY(object, point):Boolean
		{
			//trace(point.y + object.height + margin < height ? "fits" : "doesnt fit")
			return point.y + object.height + margin < height
		}
		
		private var tempPoint 	: Object = {}
		private var tempObject 	: Object = {}
		private function hitTest(object, point)
		{
			if (algorithm === "x")
			{
				tempPoint.x = Math.round(point.x + object.width + margin);
				tempPoint.y = Math.round(point.y);
			}
			else
			{
				tempPoint.x = Math.round(point.x);
				tempPoint.y = Math.round(point.y + object.height + margin);
			}
			//trace("\thitTest x:"+tempPoint.x,"y:"+tempPoint.y)
			for (var loop in placedObjects)
			{
				tempObject = placedObjects[loop];
				//trace("\t\t",tempObject.name,"x:"+tempObject.x,"y:"+tempObject.y, "r:"+tempObject.right,"b:"+tempObject.bottom)
				if( tempObject.x <= tempPoint.x && tempObject.right  > tempPoint.x &&
					tempObject.y <= tempPoint.y && tempObject.bottom > tempPoint.y
				) {
					//trace("\t\t\thit")
					return true;
				}
			}
			return false;
			
		}
		
		/** Una vez encontrado el punto donde se deba posicionar el objeto en la pagina, se apunta el resultado en la lista de placedObjects */
		private function placeObject(object, point) : void
		{
			
			object = { 	image 	: object.image,
						name	: object.name,
						x 		: Math.round(point.x), 
						y 		: Math.round(point.y), 
						width 	: Math.round(object.width), 
						height 	: Math.round(object.height), 
						right 	: Math.round(point.x + object.width + margin),
						bottom 	: Math.round(point.y + object.height + margin) 
					}
					
			height = Math.max(height, object.bottom);
			width  = Math.max(width, object.right);
			
			points.splice( points.indexOf(point), 1, {x:object.right, y:point.y}, {x:point.x, y:object.bottom} )			
			placedObjects.push( object )
		}
		
		private function flat( atlas:Array ):void
		{
			if (brother && brother.checkSize() < checkSize())
			{
				brother.flat(atlas)
			}
			else
			{
				atlas.push( this )
				if (nextAtlas)
				{
					nextAtlas.flat( atlas )
				}
			}
		}
	
		private function checkSize():Number
		{
			
			var mySize = width * height
			if (nextAtlas)
			{
				mySize += nextAtlas.checkSize()
			}
			
			var brotherSize 
			if (brother && mySize > ( brotherSize = brother.checkSize() ))
			{
				return brotherSize
			}
			return mySize
		}
		
		public function getTexture(name:String):Texture
		{
			for (var loop in collection)
			{
				var texture : Texture = collection[loop].atlas.getTexture(name);
				if(texture) return texture
 			}
			return null;
		}
		
		public function getImage(name:String, pivotX:Number = .5, pivotY:Number = .5, x:Number = 0, y:Number = 0):Image
		{	
			var image : Image = new Image( getTexture(name) )
			image.name = name
			image.pivotX = image.width * pivotX;
			image.pivotY = image.height * pivotY;
			image.x = x
			image.y = y
			
			return image;
		}
		
		
		
		
		private function tracePoints()
		{
			var s = "points: "
			for (var loop in points)
			{
				s+=loop+": "+points[loop].x+","+points[loop].y+"  "
			}
			//trace(s)
		}
	}

}