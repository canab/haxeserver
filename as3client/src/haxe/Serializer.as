package haxe {
	import haxe.io.Bytes;
	import flash.utils.describeType;
	import flash.Boot;
	public class Serializer {
		public function Serializer() : void { if( !flash.Boot.skip_constructor ) {
			this.buf = new StringBuf();
			this.cache = new Array();
			this.useCache = USE_CACHE;
			this.useEnumIndex = USE_ENUM_INDEX;
			this.shash = new Hash();
			this.scount = 0;
		}}
		
		protected var buf : StringBuf;
		protected var cache : Array;
		protected var shash : Hash;
		protected var scount : int;
		public var useCache : Boolean;
		public var useEnumIndex : Boolean;
		public function toString() : String {
			return this.buf.toString();
		}
		
		protected function serializeString(s : String) : void {
			var x : * = this.shash.get(s);
			if(x != null) {
				this.buf.add("R");
				this.buf.add(x);
				return;
			}
			this.shash.set(s,this.scount++);
			this.buf.add("y");
			s = StringTools.urlEncode(s);
			this.buf.add(s.length);
			this.buf.add(":");
			this.buf.add(s);
		}
		
		protected function serializeRef(v : *) : Boolean {
			{
				var _g1 : int = 0, _g : int = this.cache.length;
				while(_g1 < _g) {
					var i : int = _g1++;
					if(this.cache[i] == v) {
						this.buf.add("r");
						this.buf.add(i);
						return true;
					}
				}
			}
			this.cache.push(v);
			return false;
		}
		
		protected function serializeClassFields(v : *,c : Class) : void {
			var xml : XML = flash.utils.describeType(c);
			var vars : XMLList = xml.factory[0].child("variable");
			{
				var _g1 : int = 0, _g : int = vars.length();
				while(_g1 < _g) {
					var i : int = _g1++;
					var f : String = vars[i].attribute("name").toString();
					if(!v.hasOwnProperty(f)) continue;
					this.serializeString(f);
					this.serialize(Reflect.field(v,f));
				}
			}
			this.buf.add("g");
		}
		
		protected function serializeFields(v : *) : void {
			{
				var _g : int = 0, _g1 : Array = Reflect.fields(v);
				while(_g < _g1.length) {
					var f : String = _g1[_g];
					++_g;
					this.serializeString(f);
					this.serialize(Reflect.field(v,f));
				}
			}
			this.buf.add("g");
		}
		
		public function serialize(v : *) : void {
			{
				var $e : enum = (Type._typeof(v));
				switch( $e.index ) {
				case 0:
				{
					this.buf.add("n");
				}break;
				case 1:
				{
					if(v == 0) {
						this.buf.add("z");
						return;
					}
					this.buf.add("i");
					this.buf.add(v);
				}break;
				case 2:
				{
					if(Math["isNaN"](v)) this.buf.add("k");
					else if(!Math["isFinite"](v)) this.buf.add((v < 0?"m":"p"));
					else {
						this.buf.add("d");
						this.buf.add(v);
					}
				}break;
				case 3:
				{
					this.buf.add((v?"t":"f"));
				}break;
				case 6:
				var c : Class = $e.params[0];
				{
					if(c == String) {
						this.serializeString(v);
						return;
					}
					if(this.useCache && this.serializeRef(v)) return;
					switch(c) {
					case Array:{
						var ucount : int = 0;
						this.buf.add("a");
						var v1 : Array = v;
						var l : int = v1.length;
						{
							var _g : int = 0;
							while(_g < l) {
								var i : int = _g++;
								if(v1[i] == null) ucount++;
								else {
									if(ucount > 0) {
										if(ucount == 1) this.buf.add("n");
										else {
											this.buf.add("u");
											this.buf.add(ucount);
										}
										ucount = 0;
									}
									this.serialize(v1[i]);
								}
							}
						}
						if(ucount > 0) {
							if(ucount == 1) this.buf.add("n");
							else {
								this.buf.add("u");
								this.buf.add(ucount);
							}
						}
						this.buf.add("h");
					}break;
					case List:{
						this.buf.add("l");
						var v12 : List = v;
						{ var $it : * = v12.iterator();
						while( $it.hasNext() ) { var i2 : * = $it.next();
						this.serialize(i2);
						}}
						this.buf.add("h");
					}break;
					case Date:{
						var d : Date = v;
						this.buf.add("v");
						this.buf.add(d["toString"]());
					}break;
					case Hash:{
						this.buf.add("b");
						var v13 : Hash = v;
						{ var $it2 : * = v13.keys();
						while( $it2.hasNext() ) { var k : String = $it2.next();
						{
							this.serializeString(k);
							this.serialize(v13.get(k));
						}
						}}
						this.buf.add("h");
					}break;
					case IntHash:{
						this.buf.add("q");
						var v14 : IntHash = v;
						{ var $it3 : * = v14.keys();
						while( $it3.hasNext() ) { var k2 : int = $it3.next();
						{
							this.buf.add(":");
							this.buf.add(k2);
							this.serialize(v14.get(k2));
						}
						}}
						this.buf.add("h");
					}break;
					case haxe.io.Bytes:{
						var v15 : haxe.io.Bytes = v;
						var i3 : int = 0;
						var max : int = v15.length - 2;
						var chars : String = "";
						var b64 : String = BASE64;
						while(i3 < max) {
							var b1 : int = v15.get(i3++);
							var b2 : int = v15.get(i3++);
							var b3 : int = v15.get(i3++);
							chars += b64.charAt(b1 >> 2) + b64.charAt(((b1 << 4) | (b2 >> 4)) & 63) + b64.charAt(((b2 << 2) | (b3 >> 6)) & 63) + b64.charAt(b3 & 63);
						}
						if(i3 == max) {
							var b12 : int = v15.get(i3++);
							var b22 : int = v15.get(i3++);
							chars += b64.charAt(b12 >> 2) + b64.charAt(((b12 << 4) | (b22 >> 4)) & 63) + b64.charAt((b22 << 2) & 63);
						}
						else if(i3 == max + 1) {
							var b13 : int = v15.get(i3++);
							chars += b64.charAt(b13 >> 2) + b64.charAt((b13 << 4) & 63);
						}
						this.buf.add("s");
						this.buf.add(chars.length);
						this.buf.add(":");
						this.buf.add(chars);
					}break;
					default:{
						this.cache.pop();
						this.buf.add("c");
						this.serializeString(Type.getClassName(c));
						this.cache.push(v);
						this.serializeClassFields(v,c);
					}break;
					}
				}break;
				case 4:
				{
					if(this.useCache && this.serializeRef(v)) return;
					this.buf.add("o");
					this.serializeFields(v);
				}break;
				case 7:
				var e : Class = $e.params[0];
				{
					if(this.useCache && this.serializeRef(v)) return;
					this.cache.pop();
					this.buf.add((this.useEnumIndex?"j":"w"));
					this.serializeString(Type.getEnumName(e));
					if(this.useEnumIndex) {
						this.buf.add(":");
						this.buf.add(v.index);
					}
					else this.serializeString(v.tag);
					this.buf.add(":");
					var pl : Array = v.params;
					if(pl == null) this.buf.add(0);
					else {
						this.buf.add(pl.length);
						{
							var _g2 : int = 0;
							while(_g2 < pl.length) {
								var p : * = pl[_g2];
								++_g2;
								this.serialize(p);
							}
						}
					}
					this.cache.push(v);
				}break;
				case 5:
				{
					throw "Cannot serialize function";
				}break;
				default:{
					throw "Cannot serialize " + Std.string(v);
				}break;
				}
			}
		}
		
		public function serializeException(e : *) : void {
			this.buf.add("x");
			if(e is Error) {
				var e1 : Error = e;
				var s : String = e1.getStackTrace();
				if(s == null) this.serialize(e1.message);
				else this.serialize(s);
				return;
			}
			this.serialize(e);
		}
		
		static public var USE_CACHE : Boolean = false;
		static public var USE_ENUM_INDEX : Boolean = false;
		static protected var BASE64 : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
		static public function run(v : *) : String {
			var s : haxe.Serializer = new haxe.Serializer();
			s.serialize(v);
			return s.toString();
		}
		
	}
}
