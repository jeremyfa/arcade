package arcade;

#if arcade_tile_physics

class Tile implements Collidable {

    /** A property to hold any data related to this tile. Can be useful if building a larger system on top of this one. */
    public var data:Dynamic = null;

    /**
    * @property {number} index - The index of this tile within the map data corresponding to the tileset, or -1 if this represents a blank/null tile.
    */
    public var index:Int;

    /**
    * @property {number} x - The x map coordinate of this tile.
    */
    public var x:Float;

    /**
    * @property {number} y - The y map coordinate of this tile.
    */
    public var y:Float;

    /**
    * @property {number} x - The x map coordinate of this tile in pixels.
    */
    public var worldX:Float;

    /**
    * @property {number} y - The y map coordinate of this tile in pixels.
    */
    public var worldY:Float;

    /**
    * @property {number} width - The width of the tile in pixels.
    */
    public var width:Float;

    /**
    * @property {number} height - The height of the tile in pixels.
    */
    public var height:Float;

    /**
    * @property {boolean} faceTop - Is the top of this tile an interesting edge?
    */
    public var faceTop:Bool = false;

    /**
    * @property {boolean} faceBottom - Is the bottom of this tile an interesting edge?
    */
    public var faceBottom:Bool = false;

    /**
    * @property {boolean} faceLeft - Is the left of this tile an interesting edge?
    */
    public var faceLeft:Bool = false;

    /**
    * @property {boolean} faceRight - Is the right of this tile an interesting edge?
    */
    public var faceRight:Bool = false;

    /**
    * @property {boolean} collideLeft - Indicating collide with any object on the left.
    * @default
    */
    public var collideLeft:Bool = false;

    /**
    * @property {boolean} collideRight - Indicating collide with any object on the right.
    * @default
    */
    public var collideRight:Bool = false;

    /**
    * @property {boolean} collideUp - Indicating collide with any object on the top.
    * @default
    */
    public var collideUp:Bool = false;

    /**
    * @property {boolean} collideDown - Indicating collide with any object on the bottom.
    * @default
    */
    public var collideDown:Bool = false;

    /**
    * @property {function} collisionCallback - Tile collision callback.
    * @default
    */
    public var collisionCallback:(body:Body, tile:Tile)->Bool = null;

    /**
    * @name Phaser.Tile#left
    * @property {number} left - The x value in pixels.
    * @readonly
    */
    public var left(get,never):Float;
    inline function get_left():Float {
        return worldX;
    }

    /**
    * @name Phaser.Tile#right
    * @property {number} right - The sum of the x and width properties.
    * @readonly
    */
    public var top(get,never):Float;
    inline function get_top():Float {
        return worldY;
    }

    /**
    * @name Phaser.Tile#top
    * @property {number} top - The y value.
    * @readonly
    */
    public var right(get,never):Float;
    inline function get_right():Float {
        return worldX + width;
    }

    /**
    * @name Phaser.Tile#bottom
    * @property {number} bottom - The sum of the y and height properties.
    * @readonly
    */
    public var bottom(get,never):Float;
    inline function get_bottom():Float {
        return worldY + height;
    }

    /**
    * @name Phaser.Tile#canCollide
    * @property {boolean} canCollide - True if this tile can collide on any of its faces or has a collision callback set.
    * @readonly
    */
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
    * @method Phaser.Tile#containsPoint
    * @param {number} x - The x coordinate to test.
    * @param {number} y - The y coordinate to test.
    * @return {boolean} True if the coordinates are within this Tile, otherwise false.
    */
    inline public function containsPoint(x:Float, y:Float) {

        return !(x < this.worldX || y < this.worldY || x > this.right || y > this.bottom);

    }

    /**
    * Check for intersection with this tile.
    *
    * @method Phaser.Tile#intersects
    * @param {number} x - The x axis in pixels.
    * @param {number} y - The y axis in pixels.
    * @param {number} right - The right point.
    * @param {number} bottom - The bottom point.
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
