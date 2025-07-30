package arcade;

/**
 * Represents directional constants used for physics body movement and collision detection.
 */
enum abstract Direction(Int) from Int to Int {

    /** No direction. */
    var NONE:Int = 0;

    /** Left direction. */
    var LEFT:Int = 1;

    /** Right direction. */
    var RIGHT:Int = 2;

    /** Up direction. */
    var UP:Int = 3;

    /** Down direction. */
    var DOWN:Int = 4;

    public function toString() {

        final value:Direction = abstract;
        return 'Direction.' + switch value {
            case NONE: 'NONE';
            case LEFT: 'LEFT';
            case RIGHT: 'RIGHT';
            case UP: 'UP';
            case DOWN: 'DOWN';
        }

    }

}