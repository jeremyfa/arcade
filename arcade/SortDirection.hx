package arcade;

enum abstract SortDirection(Int) from Int to Int {

    /** Inherit from parent */
    var INHERIT:Int = -1;

    /** Use this if you don't wish to perform any pre-collision sorting at all, or will manually sort your Groups. */
    var NONE:Int = 0;

    /** Use this if your game world is wide but short and scrolls from the left to the right (i.e. Mario) */
    var LEFT_RIGHT:Int = 1;

    /** Use this if your game world is wide but short and scrolls from the right to the left (i.e. Mario backwards) */
    var RIGHT_LEFT:Int = 2;

    /** Use this if your game world is narrow but tall and scrolls from the top to the bottom (i.e. Dig Dug) */
    var TOP_BOTTOM:Int = 3;

    /** Use this if your game world is narrow but tall and scrolls from the bottom to the top (i.e. Commando or a vertically scrolling shoot-em-up) */
    var BOTTOM_TOP:Int = 4;

} //SortDirection