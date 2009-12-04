package test {
	import test.ItemData;
	import flash.display.Sprite;
	import flash.Boot;
	public class ItemSprite extends flash.display.Sprite {
		public function ItemSprite(data : test.ItemData = null) : void { if( !flash.Boot.skip_constructor ) {
			super();
			this.data = data;
			this.graphics.beginFill(data.color);
			this.graphics.drawCircle(0,0,10);
			this.graphics.endFill();
			this.x = data.x;
			this.y = data.y;
			this.cacheAsBitmap = true;
			var angle : Number = Math.random() * 2 * Math.PI;
			this.vx = 5 * Math.cos(angle);
			this.vy = 5 * Math.sin(angle);
		}}
		
		public var data : test.ItemData;
		public var vx : Number;
		public var vy : Number;
	}
}
