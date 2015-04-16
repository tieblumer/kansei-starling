package kansei.starling 
{
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * @author Tie Blumer
	 */
	public class AtlasGenerator 
	{
		/**
		 * HOW TO USE IT
		 * 
		 * var atlas : AtlasGenerator = new AtlasGenerator()
		 * 
		 * 
		 * 
		 * // Add any objects you want to the list.
		 * 
		 * atlas.addObject(sprite) // adds a flash sprite instance to the list
		 * 
		 * atlas.addObject(shape, 2) // adds a flash shape instance to the list and prepare to draw it with twice it's size
		 * 
		 * atlas.addObjectWithWidth(button, 300) // adds a flash simpleButton instance to the list, and prepare to draw it with 300px width and the correspondent height in order to maintin aspect ratio.
		 * 
		 * atlas.addObjectWithWidth(bitmap, stage.stageWidth, stage.stageHeight) // adds a flash bitmap instance to the list, and prepare to draw it with the stage's dimensions. Aspect ratio is not maintained.
		 * 
		 * atlas.addObject(bitmapData).name = "myImage" // adds a bitmapData to the list. As bitmapDatas don't have a name property you should set one before generating the atlas, in order to retrieve it later.
		 * 
		 * 
		 * 
		 * // when starling is ready you can generate the TextureAtlas
		 * 
		 * atlas.generate()
		 * 
		 * 
		 * // then you're able to retrieve your assets by name.
		 * 
		 * 
		 * var image1 : Image = atlas.getImage("myImage") // get an starling Image reflecting the bitmapData provided before
		 *
		 * var image2 : Image = atlas.getImage("mySprite", 0, 0) // by default pivots X and Y are centered in the image, but you can easily change it. In this example the pivot is aligned with image's top left corner
		 * 
		 * var image3 : Image = atlas.getImage("myBitmap", 0, 0, 100, 200) // as a handy shortcut you can also set x and y position through this function.
		 * 
		 * var texture1 : Texture = atlas.getTexture("myButton") // You can retrieve only a Texture if you want. 
		 * 
		 */
		
		
		
		/** La lista de objetos a ser pintados en el nuevo atlas */
		public var objects : Array
		
		/** La lista de las esquinas disponibles en el atlas para posicionas el siguiente objeto */ 
		private var points : Array
		
		/** Una lista de los objetos ya posicionados*/
		private var placedObjects : Array
		
		/** Un segundo atlas para pintar los objetos que no han entrado en ese atlas. */
		private var nextAtlas 		: AtlasGenerator
		
		/** Un atlas alternativo utilizando el algoritmo "y" en lugar del atlas */
		private var brother 	: AtlasGenerator
		
		public var margin : int = 2
		
		private var width  		: int = 0
		private var height 		: int = 0
		private var algorithm 	: String = "x"
		private var isUsed 		: Boolean = false
		
		public var atlas : TextureAtlas
		public var bmp : BitmapData
		public var xml : XML
		
		private var collection : Array
		
		/**
		 * Creates a new Atlas Generator. Add objects to it using one of the addObject method. Call generate method after starling is initialized. Retrieve an asset using getImage or getTexture methods.
		 * @param	size The size of the Atlas BitmapData. If any image results to be bigger then this number a complementary BitmapData will be created. All of the available algorithms are tested in each BitmapData and that will determine if "size" represents the width or the height of each generated BitmapData. 
		 * @param	margin The minimum distance between any object and other objects or the BitmapData borders.
		 */
		public function AtlasGenerator(size:int=1024, margin:int = 2) 
		{
			objects = [];
			points = [];
			placedObjects = [];
			collection = []
			
			this.margin = Math.max(1, Math.abs(margin));
			
			this.algorithm = margin<0 ? "y" : "x";
			if (algorithm === "x") 
			{
				width = size;
				brother = new AtlasGenerator(size, -this.margin)
			}
			else 
			{
				height = size;
			}
			
		}
		
		/**
		 * Adds an object to be implemented to the TextureAtlas and scales it. The provided object must be compatible with BitmapData.draw method. If the object has no name you should provide one to the returned object.
		 * @param	object The object to be implemented to the TextureAtlas. It  must be compatible with BitmapData.draw method.
		 * @param	scale A number representing the scale factor to use when drawing the object to the atlas.
		 * @return returns an object with the info added to AtlasGenerator. 
		 */
		public function addObject( object:Object, scale:Number=1 ):Object
		{
			return _addObject( object, scale, scale )
		}
		
		/**
		 * Adds an object to be implemented to the TextureAtlas and scales it to reach the desired width maintaining its proportions. The provided object must be compatible with BitmapData.draw method. If the object has no name you should provide one to the returned object.
		 * @param	object The object to be implemented to the TextureAtlas. It  must be compatible with BitmapData.draw method.
		 * @param	width An integer indicating the width of the object at the atlas. Height will be automatically adjusted to maintain the original proportion.
		 * @return returns an object with the info added to AtlasGenerator. 
		 */
		public function addObjectWithWidth( object:Object, width:uint):Object
		{
			return _addObject( object, width/object.width, width/object.width)
		}		
		
		/**
		 * Adds an object to be implemented to the TextureAtlas and scales it to reach the desired height maintaining its proportions. The provided object must be compatible with BitmapData.draw method. If the object has no name you should provide one to the returned object.
		 * @param	object The object to be implemented to the TextureAtlas. It  must be compatible with BitmapData.draw method.
		 * @param	height An integer indicating the height of the object at the atlas. Width will be automatically adjusted to maintain the original proportion.
		 * @return returns an object with the info added to AtlasGenerator. 
		 */
		 public function addObjectWithHeight( object:Object, height:uint):Object
		{
			return _addObject( object, height/object.height, height/object.height)
		}
		
		/**
		 * Adds an object to be implemented to the TextureAtlas and scales it to reach the desired width and the desired height. Proportion may be not the same of the original object. The provided object must be compatible with BitmapData.draw method. If the object has no name you should provide one to the returned object.
		 * @param	object The object to be implemented to the TextureAtlas. It  must be compatible with BitmapData.draw method.
		 * @param	height An integer indicating the width of the object at the atlas. Height will be automatically adjusted.
		 * @return returns an object with the info added to AtlasGenerator. 
		 */
		public function addObjectWithSize( object:Object, width:uint, height:uint):Object
		{
			return _addObject( object, width/object.width, width/object.width)
		}
		

		private function _addObject(object:Object, scaleX:Number, scaleY:Number):Object
		{
			var result : Object = {
							image:	object, 
							name:	object.hasOwnProperty("name") ? object.name : "",
							scaleX: scaleX,
							scaleY: scaleY,
							width:	Math.ceil(object.width  * scaleX), 
							height:	Math.ceil(object.height * scaleY)
						}
			_addResult(result)
			if (brother)  brother._addResult(result)
			return result
		}
		private function _addResult(result:Object):void
		{
			objects.push( result )
		}
		
		public function get lastObject():Object
		{
			return objects[ objects.length -1 ];
		}
		
		/** Converts all the objects into TextureAtlas. After that you can retrieve assets using getImage and getTexture methods. */
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
				nextAtlas._addObject( object.image, object.scaleX, object.scaleY).name = object.name
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
				nextAtlas._addObject( object.image, object.scaleX, object.scaleY).name = object.name
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
		
		/**
		 * Retrieve a Texture from the TextureAtlas by name.
		 * @param	name The name of the desired texture
		 * @return
		 */
		public function getTexture(name:String):Texture
		{
			for (var loop in collection)
			{
				var texture : Texture = collection[loop].atlas.getTexture(name);
				if(texture) return texture
 			}
			return null;
		}
		
		/**
		 * Retrieve an Image from the TextureAtlas.
		 * @param	name The name of the asset.
		 * @param	pivotX Any number indicating the pivot horizontal position. 0 would be left, .5 center and 1 would be right. Smaller or bigger numbers are also accepted.
		 * @param	pivotY Any number indicating the pivot vertical position. 0 would be top, .5 center and 1 would be bottom. Smaller or bigger numbers are also accepted.
		 * @param	x An optional shortcut to define image.x
		 * @param	y An optional shortcut to define image.y
		 * @return
		 */
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