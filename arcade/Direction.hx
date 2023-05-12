package arcade;

@:enum abstract Direction(Int) from Int to Int {

    var NONE:Int = 0;

    var LEFT:Int = 1;

    var RIGHT:Int = 2;

    var UP:Int = 3;

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

} //Direction