package arcade;

/**
 * A 2D point with x and y coordinates.
 */
class Point {

    /** The x coordinate of this point. */
    public var x:Float = 0;
    /** The y coordinate of this point. */
    public var y:Float = 0;

    /**
     * Creates a new Point instance.
     *
     * @param x The x coordinate.
     * @param y The y coordinate.
     */
    public function new(x:Float, y:Float) {

        this.x = x;
        this.y = y;

    }

    /**
     * Sets the x and y values of this Point based on polar coordinates.
     *
     * @param azimuth The angle in radians (or degrees if asDegrees is true).
     * @param radius The distance from the origin.
     * @param asDegrees Whether the azimuth is given in degrees (true) or radians (false).
     */
    inline public function setToPolar(azimuth:Float, radius:Float = 1, asDegrees:Bool = false):Void
    {

        if (asDegrees) { azimuth = degToRad(azimuth); }

        this.x = Math.cos(azimuth) * radius;
        this.y = Math.sin(azimuth) * radius;

    }

    /**
     * Converts degrees to radians.
     *
     * @param deg The angle in degrees.
     * @return The angle in radians.
     */
    inline static function degToRad(deg:Float):Float {
        return deg * 0.017453292519943295;
    }

}