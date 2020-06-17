package arcade;

import arcade.SortBodies;

class Group {

    public var objects:Array<Body> = [];

    public var sortDirection:SortDirection = SortDirection.INHERIT;

    public function new() {

    }

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
