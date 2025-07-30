package arcade;

/**
 * Represents axis constants for physics calculations and collision detection.
 */
enum abstract Axis(Int) from Int to Int {

    /** No axis. */
    var NONE:Int = 0;

    /** Horizontal axis (x-axis). */
    var HORIZONTAL:Int = 1;

    /** Vertical axis (y-axis). */
    var VERTICAL:Int = 2;

}