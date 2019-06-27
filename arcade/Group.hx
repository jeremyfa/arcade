package arcade;

import arcade.SortBodies;

class Group #if ceramic_arcade_physics extends ceramic.Entity #end {

    public var objects:Array<Body> = [];

    public var sortDirection:SortDirection = SortDirection.INHERIT;

    public function new() {

    } //new

    public function remove(body:Body):Void {

        var index = objects.indexOf(body);
        if (index != -1) {
            objects.splice(index, 1);
        }
        else {
            trace('[warning] Cannot remove body $body from group, index is -1');
        }

    } //remove

    public function sortLeftRight() {

        SortBodiesLeftRight.sort(objects);

    } //sortLeftRight

    public function sortRightLeft() {

        SortBodiesRightLeft.sort(objects);

    } //sortRightLeft

    public function sortTopBottom() {

        SortBodiesTopBottom.sort(objects);

    } //sortTopBottom

    public function sortBottomTop() {

        SortBodiesBottomTop.sort(objects);

    } //sortBottomTop

} //Group
