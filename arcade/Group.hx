package arcade;

import arcade.SortBodies;

/**
 * A Group is a container for multiple physics bodies.
 * Groups can be used for efficient collision detection between sets of bodies.
 */
class Group implements Collidable {

    /** Array of Body objects contained in this group. */
    public var objects:Array<Body> = [];

    /** The sorting direction for bodies in this group. */
    public var sortDirection:SortDirection = SortDirection.INHERIT;

    public function new() {

    }

    /**
     * Adds a body to this group.
     *
     * @param body The body to add to the group.
     */
    public function add(body:Body):Void {

        var index = objects.indexOf(body);
        if (index != -1) {
            trace('[warning] Cannot add body $body to group, already inside group');
        }
        else {
            objects.push(body);
        }

        if (body.groups != null) {
            var groupIndex = body.groups.indexOf(this);
            if (groupIndex == -1) {
                body.groups.push(this);
            }
        }
        else {
            body.groups = [this];
        }

    }

    /**
     * Removes a body from this group.
     *
     * @param body The body to remove from the group.
     */
    public function remove(body:Body):Void {

        var index = objects.indexOf(body);
        if (index != -1) {
            objects.splice(index, 1);
        }
        else {
            trace('[warning] Cannot remove body $body from group, index is -1');
        }

        if (body.groups != null) {
            var groupIndex = body.groups.indexOf(this);
            if (groupIndex != -1) {
                body.groups.splice(groupIndex, 1);
            }
        }

    }

    /**
     * Sorts the bodies in this group from left to right based on their x position.
     */
    public function sortLeftRight() {

        SortBodiesLeftRight.sort(objects);

    }

    /**
     * Sorts the bodies in this group from right to left based on their x position.
     */
    public function sortRightLeft() {

        SortBodiesRightLeft.sort(objects);

    }

    /**
     * Sorts the bodies in this group from top to bottom based on their y position.
     */
    public function sortTopBottom() {

        SortBodiesTopBottom.sort(objects);

    }

    /**
     * Sorts the bodies in this group from bottom to top based on their y position.
     */
    public function sortBottomTop() {

        SortBodiesBottomTop.sort(objects);

    }

}
