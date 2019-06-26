package arcade;

/**
 * @author       Timo Hausmann
 * @author       Richard Davey <rich@photonstorm.com>
 * @copyright    2016 Photon Storm Ltd.
 * @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
 */

/**
* A QuadTree implementation. The original code was a conversion of the Java code posted to GameDevTuts.
* However I've tweaked it massively to add node indexing, removed lots of temp. var creation and significantly increased performance as a result.
* Original version at https://github.com/timohausmann/quadtree-js/
*
* @class Phaser.QuadTree
* @constructor
* @param {number} x - The top left coordinate of the quadtree.
* @param {number} y - The top left coordinate of the quadtree.
* @param {number} width - The width of the quadtree in pixels.
* @param {number} height - The height of the quadtree in pixels.
* @param {number} [maxObjects=10] - The maximum number of objects per node.
* @param {number} [maxLevels=4] - The maximum number of levels to iterate to.
* @param {number} [level=0] - Which level is this?
*/
class QuadTree
{

    /**
    * @property {number} maxObjects - The maximum number of objects per node.
    * @default
    */
    public var maxObjects:Int = 10;

    /**
    * @property {number} maxLevels - The maximum number of levels to break down to.
    * @default
    */
    public var maxLevels:Int = 4;

    /**
    * @property {number} level - The current level.
    */
    public var level:Int = 0;

    // @property {object} bounds - Object that contains the quadtree bounds.
    public var boundsX:Float = 0;
    public var boundsY:Float = 0;
    public var boundsWidth:Float = 0;
    public var boundsHeight:Float = 0;
    public var boundsSubWidth:Float = 0;
    public var boundsSubHeight:Float = 0;
    public var boundsRight:Float = 0;
    public var boundsBottom:Float = 0;

    /**
    * @property {array} objects - Array of quadtree children.
    */
    public var objects:Array<Body> = [];

    /**
    * @property {array} nodes - Array of associated child nodes.
    */
    public var nodes:Array<QuadTree> = [];

    /**
    * @property {array} _empty - Internal empty array.
    * @private
    */
    private var _empty:Array<Body> = [];

    public function new(x:Float, y:Float, width:Float, height:Float, maxObjects:Int = 10, maxLevels:Int = 4, level:Int = 0) {

        reset(x, y, width, height, maxObjects, maxLevels, level);

    } //new

    public function recycle():Void {

        clear();

    } //recycle

    /**
    * Resets the QuadTree.
    *
    * @method Phaser.QuadTree#reset
    * @param {number} x - The top left coordinate of the quadtree.
    * @param {number} y - The top left coordinate of the quadtree.
    * @param {number} width - The width of the quadtree in pixels.
    * @param {number} height - The height of the quadtree in pixels.
    * @param {number} [maxObjects=10] - The maximum number of objects per node.
    * @param {number} [maxLevels=4] - The maximum number of levels to iterate to.
    * @param {number} [level=0] - Which level is this?
    */
    public function reset(x:Float, y:Float, width:Float, height:Float, maxObjects:Int = 10, maxLevels:Int = 4, level:Int = 0)
    {

        boundsX = Math.round(x);
        boundsY = Math.round(y);
        boundsWidth = width;
        boundsHeight = height;
        boundsSubWidth = Math.floor(width / 2);
        boundsSubHeight = Math.floor(height / 2);
        boundsRight = Math.round(x) + Math.floor(width / 2);
        boundsBottom = Math.round(y) + Math.floor(height / 2);

        for (i in 0...nodes.length) {
            nodes[i].recycle();
        }

        #if cpp
        untyped objects.__SetSize(0);
        untyped nodes.__SetSize(0);
        #else
        objects.splice(0, objects.length);
        nodes.splice(0, nodes.length);
        #end

    } //reset

    /**
    * Populates this quadtree with the children of the given Group. In order to be added the child must exist and have a body property.
    *
    * @method Phaser.QuadTree#populate
    * @param {Phaser.Group} group - The Group to add to the quadtree.
    */
    public function populate(group:Group):Void
    {

        for (i in 0...group.objects.length) {
            insert(group.objects[i]);
        }

    } //populate

    /**
    * Split the node into 4 subnodes
    *
    * @method Phaser.QuadTree#split
    */
    public function split():Void
    {

        //  top right node
        this.nodes[0] = QuadTree.create(this.boundsRight, this.boundsY, this.boundsSubWidth, this.boundsSubHeight, this.maxObjects, this.maxLevels, (this.level + 1));

        //  top left node
        this.nodes[1] = QuadTree.create(this.boundsX, this.boundsY, this.boundsSubWidth, this.boundsSubHeight, this.maxObjects, this.maxLevels, (this.level + 1));

        //  bottom left node
        this.nodes[2] = QuadTree.create(this.boundsX, this.boundsBottom, this.boundsSubWidth, this.boundsSubHeight, this.maxObjects, this.maxLevels, (this.level + 1));

        //  bottom right node
        this.nodes[3] = QuadTree.create(this.boundsRight, this.boundsBottom, this.boundsSubWidth, this.boundsSubHeight, this.maxObjects, this.maxLevels, (this.level + 1));

    } //split

    /**
    * Insert the object into the node. If the node exceeds the capacity, it will split and add all objects to their corresponding subnodes.
    *
    * @method Phaser.QuadTree#insert
    * @param {Phaser.Physics.Arcade.Body|object} body - The Body object to insert into the quadtree. Can be any object so long as it exposes x, y, right and bottom properties.
    */
    public function insert(body:Body):Void
    {

        var i:Int = 0;
        var index:Int = -1;

        //  if we have subnodes ...
        if (this.nodes.length > 0)
        {
            index = this.getIndex(body.left, body.top, body.right, body.bottom);

            if (index != -1)
            {
                this.nodes[index].insert(body);
                return;
            }
        }

        this.objects.push(body);

        if (this.objects.length > this.maxObjects && this.level < this.maxLevels)
        {
            //  Split if we don't already have subnodes
            if (this.nodes[0] == null)
            {
                this.split();
            }

            //  Add objects to subnodes
            while (i < this.objects.length)
            {
                var item = this.objects[i];
                index = this.getIndex(item.left, item.top, item.right, item.bottom);

                if (index != -1)
                {
                    //  this is expensive - see what we can do about it
                    this.nodes[index].insert(this.objects.splice(i, 1)[0]);
                }
                else
                {
                    i++;
                }
            }
        }

    } //insert

    /**
    * Determine which node the object belongs to.
    *
    * @method Phaser.QuadTree#getIndex
    * @param {Phaser.Rectangle|object} rect - The bounds in which to check.
    * @return {number} index - Index of the subnode (0-3), or -1 if rect cannot completely fit within a subnode and is part of the parent node.
    */
    public function getIndex(left:Float, top:Float, right:Float, bottom:Float):Int
    {

        //  default is that rect doesn't fit, i.e. it straddles the internal quadrants
        var index = -1;

        if (left < this.boundsRight && right < this.boundsRight)
        {
            if (top < this.boundsBottom && bottom < this.boundsBottom)
            {
                //  rect fits within the top-left quadrant of this quadtree
                index = 1;
            }
            else if (top > this.boundsBottom)
            {
                //  rect fits within the bottom-left quadrant of this quadtree
                index = 2;
            }
        }
        else if (left > this.boundsRight)
        {
            //  rect can completely fit within the right quadrants
            if (top < this.boundsBottom && bottom < this.boundsBottom)
            {
                //  rect fits within the top-right quadrant of this quadtree
                index = 0;
            }
            else if (top > this.boundsBottom)
            {
                //  rect fits within the bottom-right quadrant of this quadtree
                index = 3;
            }
        }

        return index;

    } //getIndex

    /**
    * Return all objects that could collide with the given Sprite or Rectangle.
    *
    * @method Phaser.QuadTree#retrieve
    * @param {Phaser.Sprite|Phaser.Rectangle} source - The source object to check the QuadTree against. Either a Sprite or Rectangle.
    * @return {array} - Array with all detected objects.
    */
    public function retrieve(left:Float, top:Float, right:Float, bottom:Float):Array<Body>
    {

        var returnObjects = this.objects;

        var index = this.getIndex(left, top, right, bottom);

        if (this.nodes.length > 0)
        {
            //  If rect fits into a subnode ..
            if (index != -1)
            {
                returnObjects = returnObjects.concat(this.nodes[index].retrieve(left, top, right, bottom));
            }
            else
            {
                //  If rect does not fit into a subnode, check it against all subnodes (unrolled for speed)
                returnObjects = returnObjects.concat(this.nodes[0].retrieve(left, top, right, bottom));
                returnObjects = returnObjects.concat(this.nodes[1].retrieve(left, top, right, bottom));
                returnObjects = returnObjects.concat(this.nodes[2].retrieve(left, top, right, bottom));
                returnObjects = returnObjects.concat(this.nodes[3].retrieve(left, top, right, bottom));
            }
        }

        return returnObjects;

    } //retrieve

    /**
    * Clear the quadtree.
    * @method Phaser.QuadTree#clear
    */
    public function clear()
    {
        for (i in 0...nodes.length) {
            nodes[i].recycle();
        }

        #if cpp
        untyped objects.__SetSize(0);
        untyped nodes.__SetSize(0);
        #else
        objects.splice(0, objects.length);
        nodes.splice(0, nodes.length);
        #end

    } //clear

/// Recycling QuadTree objects

    private static var _pool:Array<QuadTree> = [];
    private static var _nextPoolIndex:Int = 0;

    public static function clearPool():Void {

        _pool = [];
        _nextPoolIndex = 0;

    } //clearPool

    public static function create(x:Float, y:Float, width:Float, height:Float, maxObjects:Int = 10, maxLevels:Int = 4, level:Int = 0):QuadTree {

        if (_nextPoolIndex == _pool.length) {

            // Create new
            var quadTree = new QuadTree(x, y, width, height, maxObjects, maxLevels, level);
            _nextPoolIndex++;
            _pool.push(quadTree);
            return quadTree;
        }
        else {

            // Reuse an available one
            var quadTree = _pool[_nextPoolIndex];
            _nextPoolIndex++;
            return quadTree;
        }

    } //create

    public static function recycleAll():Void {

        _nextPoolIndex = 0;

    } //recycleAll

} //QuadTree

/**
* Javascript QuadTree
* @version 1.0
*
* @version 1.3, March 11th 2014
* @author Richard Davey
* The original code was a conversion of the Java code posted to GameDevTuts. However I've tweaked
* it massively to add node indexing, removed lots of temp. var creation and significantly
* increased performance as a result.
*
* Original version at https://github.com/timohausmann/quadtree-js/
*/

/**
* @copyright © 2012 Timo Hausmann
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
* LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
* WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
