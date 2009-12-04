package haxe.remoting {
	import flash.Boot;
	public class Context {
		public function Context() : void { if( !flash.Boot.skip_constructor ) {
			this.objects = new Hash();
		}}
		
		protected var objects : Hash;
		public function addObject(name : String,obj : *,recursive : * = null) : void {
			this.objects.set(name,{ obj : obj, rec : recursive});
		}
		
		public function call(path : Array,params : Array) : * {
			if(path.length < 2) throw "Invalid path '" + path.join(".") + "'";
			var inf : * = this.objects.get(path[0]);
			if(inf == null) throw "No such object " + path[0];
			var o : * = inf.obj;
			var m : * = Reflect.field(o,path[1]);
			if(path.length > 2) {
				if(!inf.rec) throw "Can't access " + path.join(".");
				{
					var _g1 : int = 2, _g : int = path.length;
					while(_g1 < _g) {
						var i : int = _g1++;
						o = m;
						m = Reflect.field(o,path[i]);
					}
				}
			}
			if(!Reflect.isFunction(m)) throw "No such method " + path.join(".");
			return Reflect.callMethod(o,m,params);
		}
		
		static public function share(name : String,obj : *) : haxe.remoting.Context {
			var ctx : haxe.remoting.Context = new haxe.remoting.Context();
			ctx.addObject(name,obj);
			return ctx;
		}
		
	}
}
