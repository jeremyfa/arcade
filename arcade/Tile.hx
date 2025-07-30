package arcade;

#if arcade_tile_physics

/**
 * Represents a physics-enabled tile that can participate in collision detection.
 * Only compiled when the arcade_tile_physics compilation flag is set.
 */
class Tile implements Collidable {

    /** A property to hold any data related to this tile. Can be useful if building a larger system on top of this one. */
    public var data:Dynamic = null;

    /** The index of this tile within the map data corresponding to the tileset, or -1 if this represents a blank/null tile. */
    public var index:Int;

    /** The x map coordinate of this tile. */
    public var x:Float;

    /** The y map coordinate of this tile. */
    public var y:Float;

    /** The x map coordinate of this tile in pixels. */
    public var worldX:Float;

    /** The y map coordinate of this tile in pixels. */
    public var worldY:Float;

    /** The width of the tile in pixels. */
    public var width:Float;

    /** The height of the tile in pixels. */
    public var height:Float;

    /** Is the top of this tile an interesting edge? */
    public var faceTop:Bool = false;

    /** Is the bottom of this tile an interesting edge? */
    public var faceBottom:Bool = false;

    /** Is the left of this tile an interesting edge? */
    public var faceLeft:Bool = false;

    /** Is the right of this tile an interesting edge? */
    public var faceRight:Bool = false;

    /** Indicating collide with any object on the left. */
    public var collideLeft:Bool = false;

    /** Indicating collide with any object on the right. */
    public var collideRight:Bool = false;

    /** Indicating collide with any object on the top. */
    public var collideUp:Bool = false;

    /** Indicating collide with any object on the bottom. */
    public var collideDown:Bool = false;

    /** Tile collision callback. */
    public var collisionCallback:(body:Body, tile:Tile)->Bool = null;

    /** The x value in pixels. */
    public var left(get,never):Float;
    inline function get_left():Float {
        return worldX;
    }

    /** The y value. */
    public var top(get,never):Float;
    inline function get_top():Float {
        return worldY;
    }

    /** The sum of the x and width properties. */
    public var right(get,never):Float;
    inline function get_right():Float {
        return worldX + width;
    }

    /** The sum of the y and height properties. */
    public var bottom(get,never):Float;
    inline function get_bottom():Float {
        return worldY + height;
    }

    /** True if this tile can collide on any of its faces or has a collision callback set. */
    public var canCollide(get,never):Bool;
    inline function get_canCollide():Bool {
        return collideLeft || collideRight || collideUp || collideDown || collisionCallback != null;
    }

    public function new(index:Int, x:Float, y:Float, width:Float, height:Float) {

        update(index, x, y, width, height);

    }

    public function update(index:Int, x:Float, y:Float, width:Float, height:Float) {

        this.index = index;
        this.x = x;
        this.y = y;
        this.worldX = x * width;
        this.worldY = y * height;
        this.width = width;
        this.height = height;

    }

    /**
     * Check if the given x and y world coordinates are within this Tile.
     *
     * @param x The x coordinate to test.
     * @param y The y coordinate to test.
     * @return True if the coordinates are within this Tile, otherwise false.
     */
    inline public function containsPoint(x:Float, y:Float) {

        return !(x < this.worldX || y < this.worldY || x > this.right || y > this.bottom);

    }

    /**
     * Check for intersection with this tile.
     *
     * @param x The x axis in pixels.
     * @param y The y axis in pixels.
     * @param right The right point.
     * @param bottom The bottom point.
     * @return True if the bounds intersect with this tile.
     */
    inline public function intersects(x:Float, y:Float, right:Float, bottom:Float):Bool {

        return (
            right > this.worldX &&
            bottom > this.worldY &&
            x < this.worldX + this.width &&
            y < this.worldY + this.height
        );

    }

    public function destroy():Void {

        collisionCallback = null;

    }

}

#end
