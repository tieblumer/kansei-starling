package kansei.starling 
{
	import flash.display.BitmapData;
	import starling.textures.Texture;
	import flash.display3D.textures.Texture
	/**
	 * ...
	 * @author Un isleño
	 */
	public class TextureUpdater 
	{
		
		
		static public function update(texture:starling.textures.Texture, bmp:BitmapData):void
		{
			flash.display3D.textures.Texture(texture.base).uploadFromBitmapData(bmp)
		}
		
		public function TextureUpdater() 
		{
			
		}
		
	}

}