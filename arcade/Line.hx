package arcade;

/**
 * Represents a line segment with a start and end point.
 */
class Line {

    /** The x coordinate of the start point. */
    public var x1:Float = 0;
    /** The y coordinate of the start point. */
    public var y1:Float = 0;
    /** The x coordinate of the end point. */
    public var x2:Float = 0;
    /** The y coordinate of the end point. */
    public var y2:Float = 0;

    /**
     * Creates a new Line instance.
     *
     * @param x1 The x coordinate of the start point.
     * @param y1 The y coordinate of the start point.
     * @param x2 The x coordinate of the end point.
     * @param y2 The y coordinate of the end point.
     */
    public function new(x1:Float, y1:Float, x2:Float, y2:Float) {

        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;

    }

    /**
     * Calculates the length of the line segment.
     *
     * @return The length of the line segment.
     */
    inline public function length():Float {

        return Math.sqrt((this.x2 - this.x1) * (this.x2 - this.x1) + (this.y2 - this.y1) * (this.y2 - this.y1));

    }

    /**
     * Sets this line's start and end points based on the given angle and length.
     *
     * @param x The x coordinate of the start point.
     * @param y The y coordinate of the start point.
     * @param angle The angle in radians.
     * @param length The length of the line.
     */
    inline public function fromAngle(x:Float, y:Float, angle:Float, length:Float):Void
    {

        this.x1 = x;
        this.y1 = y;
        this.x2 = x + (Math.cos(angle) * length);
        this.y2 = y + (Math.sin(angle) * length);

    }

}