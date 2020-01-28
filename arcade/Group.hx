package arcade;

import arcade.SortBodies;

class Group {

    public var objects:Array<Body> = [];

    public var sortDirection:SortDirection = SortDirection.INHERIT;

    public function new() {

    }

    public function remove(body:Body):Void {

        var index = objects.indexOf(body);
        if (index != -1) {
            objects.splice(index, 1);
        }
        else {
            trace('[warning] Cannot remove body $body from group, index is -1');
        }

    }

    public function sortLeftRight() {

        SortBodiesLeftRight.sort(objects);

    }

    public function sortRightLeft() {

        SortBodiesRightLeft.sort(objects);

    }

    public function sortTopBottom() {

        SortBodiesTopBottom.sort(objects);

    }

    public function sortBottomTop() {

        SortBodiesBottomTop.sort(objects);

    }

}
