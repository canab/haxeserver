package haxe.remoting {
	public interface AsyncConnection {
		function resolve(name : String) : haxe.remoting.AsyncConnection ;
		function call(params : Array,result : Function = null) : void ;
		function setErrorHandler(error : Function) : void ;
	}
}
