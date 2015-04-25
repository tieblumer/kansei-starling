package kansei.starling 
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import starling.textures.Texture;
	import flash.display3D.textures.Texture
	/**
	 * ...
	 * @author Un isleño
	 */
	public class TextureUpdater 
	{
		
		static private const resolutions : Array = [1,2,4,8,16,32,64,128,256,512,1024,2048,4096]
		
		static private function findNextPowerOf2(num:Number):int
		{
			for (var loop = 0; loop < resolutions.length; loop++ )
			{
				if (num < resolutions[loop])
				{
					return resolutions[loop]
				}
			}
			return 8192
		}
		
		static private const matrix : Matrix = new Matrix
		
		static public function update(texture:starling.textures.Texture, bmp:BitmapData):void
		{
			matrix.identity()
			matrix.scale(.5, .5)
			
			if (texture.mipMapping)
			{
				var w : uint = findNextPowerOf2( bmp.width )
				var h : uint = findNextPowerOf2( bmp.height )
				var scale = 1;
				var level : int = 0
				var lastBMP : BitmapData
				while (true)
				{
					var mipBMP : BitmapData = new BitmapData(w, h, bmp.transparent, 0)
					
					
					if (level === 0)
					{
						mipBMP.draw(bmp, null,null, null, null, true)
					}
					else
					{
						mipBMP.draw(lastBMP, matrix,null, null, null, true)						
					}
					lastBMP = bmp
					
					flash.display3D.textures.Texture(texture.base).uploadFromBitmapData(mipBMP, level)
					
					level++
					w 		*= .5
					h 		*= .5
					scale 	*= .5
					
					
					if (w === 1 || h === 1)
					{
						return;
					}
				}
			}
			flash.display3D.textures.Texture(texture.base).uploadFromBitmapData(bmp)
		}
		
		public function TextureUpdater() 
		{
			
		}
		
	}

}