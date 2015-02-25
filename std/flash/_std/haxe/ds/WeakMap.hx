package haxe.ds;

@:coreApi
class WeakMap<K:{},V> extends flash.utils.Dictionary implements haxe.Constraints.IMap<K,V> {

	public function new() {
		super(true);
	}

	public inline function get( key : K ) : Null<V> {
		return untyped this[key];
	}

	public inline function set( key : K, value : V ):Void {
		untyped this[key] = value;
	}

	public inline function exists( key : K ) : Bool {
		return untyped this[key] != null;
	}

	public function remove( key : K ):Bool {
		var has = exists(key);
		untyped __delete__(this, key);
		return has;
	}

	#if as3

 	public function keys() : Iterator<K> {
		return untyped __keys__(this).iterator();
 	}

 	public function iterator() : Iterator<V> {
		var ret = [];
		for (i in keys())
			ret.push(get(i));
		return ret.iterator();
 	}
	#else

	public function keys() : Iterator<K> {
		return new WeakMapKeysIterator<K>(this);
	}

	public function iterator() : Iterator<V> {
		return new WeakMapValuesIterator<V>(this);
	}

	#end

	public function toString() : String {
		var s = "";
		var it = keys();
		for( i in it ) {
			s += (s == "" ? "" : ",") + Std.string(i);
			s += " => ";
			s += Std.string(get(i));
		}
		return s + "}";
	}
}

#if !as3

// this version uses __has_next__/__forin__ special SWF opcodes for iteration with no allocation

@:allow(haxe.ds.WeakMap)
private class WeakMapKeysIterator<K> {
	var h:Dynamic;
	var index : Int;
	var nextIndex : Int;

	inline function new(h:Dynamic):Void {
		this.h = h;
		this.index = 0;
		hasNext();
	}

	public inline function hasNext():Bool {
		var h = h, index = index; // tmp vars required for __has_next
		var n = untyped __has_next__(h, index);
		this.nextIndex = index; // store next index
		return n;
	}

	public inline function next():K {
		var r : K = untyped __forin__(h, nextIndex);
		index = nextIndex;
		return r;
	}

}

@:allow(haxe.ds.WeakMap)
private class WeakMapValuesIterator<T> {
	var h:Dynamic;
	var index : Int;
	var nextIndex : Int;

	inline function new(h:Dynamic):Void {
		this.h = h;
		this.index = 0;
		hasNext();
	}

	public inline function hasNext():Bool {
		var h = h, index = index; // tmp vars required for __has_next
		var n = untyped __has_next__(h, index);
		this.nextIndex = index; // store next index
		return n;
	}

	public inline function next():T {
		var r = untyped __foreach__(h, nextIndex);
		index = nextIndex;
		return r;
	}

}
#end
