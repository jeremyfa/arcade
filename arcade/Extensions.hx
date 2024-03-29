package arcade;

/** A bunch of static extensions to make life easier. */
class Extensions<T> {

/// Array extensions

    #if !arcade_debug_unsafe inline #end public static function unsafeGet<T>(array:Array<T>, index:Int):T {
#if arcade_debug_unsafe
        if (index < 0 || index >= array.length) throw 'Invalid unsafeGet: index=$index length=${array.length}';
#end
#if cpp
        #if app_cpp_nativearray_unsafe
        return cpp.NativeArray.unsafeGet(array, index);
        #else
        return untyped array.__unsafe_get(index);
        #end
#elseif cs
        return cast untyped __cs__('{0}.__a[{1}]', array, index);
#else
        return array[index];
#end
    }

    #if !arcade_debug_unsafe inline #end public static function unsafeSet<T>(array:Array<T>, index:Int, value:T):Void {
#if arcade_debug_unsafe
        if (index < 0 || index >= array.length) throw 'Invalid unsafeSet: index=$index length=${array.length}';
#end
#if cpp
        #if app_cpp_nativearray_unsafe
        cpp.NativeArray.unsafeSet(array, index, value);
        #else
        untyped array.__unsafe_set(index, value);
        #end
#elseif cs
        return cast untyped __cs__('{0}.__a[{1}] = {2}', array, index, value);
#else
        array[index] = value;
#end
    }

    #if !debug inline #end public static function setArrayLength<T>(array:Array<T>, length:Int):Void {
        if (array.length != length) {
#if cpp
            untyped array.__SetSize(length);
#else
            if (array.length > length) {
                array.splice(length, array.length - length);
            }
            else {
                var dArray:Array<Dynamic> = array;
                while (dArray.length < length)
                    dArray.push(null);
            }
#end
        }
    }
}
