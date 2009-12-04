package haxe {
	import haxe.io.Bytes;
	import flash.utils.ByteArray;
	import flash.Boot;
	public class Unserializer {
		public function Unserializer(buf : String = null) : void { if( !flash.Boot.skip_constructor ) {
			this.buf = buf;
			this.length = buf.length;
			this.pos = 0;
			this.scache = new Array();
			this.cache = new Array();
			this.setResolver(DEFAULT_RESOLVER);
		}}
		
		protected var buf : String;
		protected var pos : int;
		protected var length : int;
		protected var cache : Array;
		protected var scache : Array;
		protected var resolver : *;
		public function setResolver(r : *) : void {
			if(r == null) this.resolver = { resolveClass : function(_ : String) : Class {
				return null;
			}, resolveEnum : function(_ : String) : Class {
				return null;
			}}
			else this.resolver = r;
		}
		
		protected function get(p : int) : int {
			return this.buf.charCodeAt(p);
		}
		
		protected function readDigits() : int {
			var k : int = 0;
			var s : Boolean = false;
			var fpos : int = this.pos;
			while(true) {
				var c : int = this.get(this.pos);
				if(c == 45) {
					if(this.pos != fpos) break;
					s = true;
					this.pos++;
					continue;
				}
				c -= 48;
				if(c < 0 || c > 9) break;
				k = k * 10 + c;
				this.pos++;
			}
			if(s) k *= -1;
			return k;
		}
		
		protected function unserializeObject(o : *) : void {
			while(true) {
				if(this.pos >= this.length) throw "Invalid object";
				if(this.get(this.pos) == 103) break;
				var k : String = this.unserialize();
				if(!Std._is(k,String)) throw "Invalid object key";
				var v : * = this.unserialize();
				Reflect.setField(o,k,v);
			}
			this.pos++;
		}
		
		protected function unserializeEnum(edecl : Class,tag : String) : * {
			var constr : * = Reflect.field(edecl,tag);
			if(constr == null) throw "Unknown enum tag " + Type.getEnumName(edecl) + "." + tag;
			if(this.get(this.pos++) != 58) throw "Invalid enum format";
			var nargs : int = this.readDigits();
			if(nargs == 0) {
				this.cache.push(constr);
				return constr;
			}
			var args : Array = new Array();
			while(nargs > 0) {
				args.push(this.unserialize());
				nargs -= 1;
			}
			var e : * = Reflect.callMethod(edecl,constr,args);
			this.cache.push(e);
			return e;
		}
		
		public function unserialize() : * {
			switch(this.get(this.pos++)) {
			case 110:{
				return null;
			}break;
			case 116:{
				return true;
			}break;
			case 102:{
				return false;
			}break;
			case 122:{
				return 0;
			}break;
			case 105:{
				return this.readDigits();
			}break;
			case 100:{
				var p1 : int = this.pos;
				while(true) {
					var c : int = this.get(this.pos);
					if((c >= 43 && c < 58) || c == 101 || c == 69) this.pos++;
					else break;
				}
				return Std._parseFloat(this.buf.substr(p1,this.pos - p1));
			}break;
			case 121:{
				var len : int = this.readDigits();
				if(this.buf.charAt(this.pos++) != ":" || this.length - this.pos < len) throw "Invalid string length";
				var s : String = this.buf.substr(this.pos,len);
				this.pos += len;
				s = StringTools.urlDecode(s);
				this.scache.push(s);
				return s;
			}break;
			case 107:{
				return Math["NaN"];
			}break;
			case 109:{
				return Math["NEGATIVE_INFINITY"];
			}break;
			case 112:{
				return Math["POSITIVE_INFINITY"];
			}break;
			case 97:{
				var buf : String = this.buf;
				var a : Array = new Array();
				this.cache.push(a);
				while(true) {
					var c2 : int = this.get(this.pos);
					if(c2 == 104) {
						this.pos++;
						break;
					}
					if(c2 == 117) {
						this.pos++;
						var n : int = this.readDigits();
						a[a.length + n - 1] = null;
					}
					else a.push(this.unserialize());
				}
				return a;
			}break;
			case 111:{
				var o : * = { }
				this.cache.push(o);
				this.unserializeObject(o);
				return o;
			}break;
			case 114:{
				var n2 : int = this.readDigits();
				if(n2 < 0 || n2 >= this.cache.length) throw "Invalid reference";
				return this.cache[n2];
			}break;
			case 82:{
				var n3 : int = this.readDigits();
				if(n3 < 0 || n3 >= this.scache.length) throw "Invalid string reference";
				return this.scache[n3];
			}break;
			case 120:{
				throw this.unserialize();
			}break;
			case 99:{
				var name : String = this.unserialize();
				var cl : Class = this.resolver.resolveClass(name);
				if(cl == null) throw "Class not found " + name;
				var o2 : * = Type.createEmptyInstance(cl);
				this.cache.push(o2);
				this.unserializeObject(o2);
				return o2;
			}break;
			case 119:{
				var name2 : String = this.unserialize();
				var edecl : Class = this.resolver.resolveEnum(name2);
				if(edecl == null) throw "Enum not found " + name2;
				return this.unserializeEnum(edecl,this.unserialize());
			}break;
			case 106:{
				var name3 : String = this.unserialize();
				var edecl2 : Class = this.resolver.resolveEnum(name3);
				if(edecl2 == null) throw "Enum not found " + name3;
				this.pos++;
				var index : int = this.readDigits();
				var tag : String = Type.getEnumConstructs(edecl2)[index];
				if(tag == null) throw "Unknown enum index " + name3 + "@" + index;
				return this.unserializeEnum(edecl2,tag);
			}break;
			case 108:{
				var l : List = new List();
				this.cache.push(l);
				var buf2 : String = this.buf;
				while(this.get(this.pos) != 104) l.add(this.unserialize());
				this.pos++;
				return l;
			}break;
			case 98:{
				var h : Hash = new Hash();
				this.cache.push(h);
				var buf3 : String = this.buf;
				while(this.get(this.pos) != 104) {
					var s2 : String = this.unserialize();
					h.set(s2,this.unserialize());
				}
				this.pos++;
				return h;
			}break;
			case 113:{
				var h2 : IntHash = new IntHash();
				this.cache.push(h2);
				var buf4 : String = this.buf;
				var c3 : int = this.get(this.pos++);
				while(c3 == 58) {
					var i : int = this.readDigits();
					h2.set(i,this.unserialize());
					c3 = this.get(this.pos++);
				}
				if(c3 != 104) throw "Invalid IntHash format";
				return h2;
			}break;
			case 118:{
				var d : Date = Date["fromString"](this.buf.substr(this.pos,19));
				this.cache.push(d);
				this.pos += 19;
				return d;
			}break;
			case 115:{
				var len2 : int = this.readDigits();
				var buf5 : String = this.buf;
				if(buf5.charAt(this.pos++) != ":" || this.length - this.pos < len2) throw "Invalid bytes length";
				var codes : flash.utils.ByteArray = CODES;
				if(codes == null) {
					codes = initCodes();
					haxe.Unserializer.CODES = codes;
				}
				var i2 : int = this.pos;
				var rest : int = len2 & 3;
				var size : int = (len2 >> 2) * 3 + (((rest >= 2)?rest - 1:0));
				var max : int = i2 + (len2 - rest);
				var bytes : haxe.io.Bytes = haxe.io.Bytes.alloc(size);
				var bpos : int = 0;
				while(i2 < max) {
					var c1 : int = codes[buf5.charCodeAt(i2++)];
					var c22 : int = codes[buf5.charCodeAt(i2++)];
					bytes.set(bpos++,(c1 << 2) | (c22 >> 4));
					var c32 : int = codes[buf5.charCodeAt(i2++)];
					bytes.set(bpos++,(c22 << 4) | (c32 >> 2));
					var c4 : int = codes[buf5.charCodeAt(i2++)];
					bytes.set(bpos++,(c32 << 6) | c4);
				}
				if(rest >= 2) {
					var c12 : int = codes[buf5.charCodeAt(i2++)];
					var c23 : int = codes[buf5.charCodeAt(i2++)];
					bytes.set(bpos++,(c12 << 2) | (c23 >> 4));
					if(rest == 3) {
						var c33 : int = codes[buf5.charCodeAt(i2++)];
						bytes.set(bpos++,(c23 << 4) | (c33 >> 2));
					}
				}
				this.pos += len2;
				this.cache.push(bytes);
				return bytes;
			}break;
			default:{
				null;
			}break;
			}
			this.pos--;
			throw ("Invalid char " + this.buf.charAt(this.pos) + " at position " + this.pos);
		}
		
		static public var DEFAULT_RESOLVER : * = Type;
		static protected var BASE64 : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
		static protected var CODES : flash.utils.ByteArray = null;
		static protected function initCodes() : flash.utils.ByteArray {
			var codes : flash.utils.ByteArray = new flash.utils.ByteArray();
			{
				var _g1 : int = 0, _g : int = BASE64.length;
				while(_g1 < _g) {
					var i : int = _g1++;
					codes[BASE64.charCodeAt(i)] = i;
				}
			}
			return codes;
		}
		
		static public function run(v : String) : * {
			return new haxe.Unserializer(v).unserialize();
		}
		
	}
}
