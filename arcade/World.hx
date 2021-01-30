package arcade;

/**
* @author       Richard Davey <rich@photonstorm.com>
* @copyright    2016 Photon Storm Ltd.
* @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
*/

/**
* The Arcade Physics world. Contains Arcade Physics related collision, overlap and motion methods.
*
* @class Phaser.Physics.Arcade
* @constructor
*/
class World {

    /** The World gravity X setting. Defaults to 0 (no gravity). */
    public var gravityX:Float = 0;

    /** The World gravity Y setting. Defaults to 0 (no gravity). */
    public var gravityY:Float = 0;

    // The bounds inside of which the physics world exists.
    public var boundsX:Float = 0;
    public var boundsY:Float = 0;
    public var boundsWidth:Float = 0;
    public var boundsHeight:Float = 0;

    // Which edges of the World bounds Bodies can collide against when `collideWorldBounds` is `true`.
    // For example checkCollisionDown = false means Bodies cannot collide with the World.bounds.bottom.
    // @property {object} checkCollision - An object containing allowed collision flags (up, down, left, right).
    public var checkCollisionNone:Bool = false;
    public var checkCollisionUp:Bool = true;
    public var checkCollisionDown:Bool = true;
    public var checkCollisionLeft:Bool = true;
    public var checkCollisionRight:Bool = true;

    /** Used by the QuadTree to set the maximum number of objects per quad. */
    public var maxObjects:Int = 10;

    /** Used by the QuadTree to set the maximum number of iteration levels. */
    public var maxLevels:Int = 4;

    /** A value added to the delta values during collision checks. Increase it to prevent sprite tunneling. */
    public var overlapBias:Float = 4;

    /** If true World.separate will always separate on the X axis before Y. Otherwise it will check gravity totals first. */
    public var forceX:Bool = false;

    /** Used when colliding a Sprite vs. a Group, or a Group vs. a Group, this defines the direction the sort is based on. Default is `LEFT_RIGHT`. */
    public var sortDirection:SortDirection = SortDirection.LEFT_RIGHT;

    /** If true the QuadTree will not be used for any collision. QuadTrees are great if objects are well spread out in your game, otherwise they are a performance hit. If you enable this you can disable on a per body basis via `Body.skipQuadTree`. */
    public var skipQuadTree:Bool = true;

    /** If `true` the `Body.preUpdate` method will be skipped, halting all motion for all bodies. Note that other methods such as `collide` will still work, so be careful not to call them on paused bodies. */
    public var isPaused:Bool = false;

    /** The world QuadTree. */
    public var quadTree:QuadTree = null;

    /** Elapsed time since last tick. */
    public var elapsed(default,set):Float = 1.0 / 60.0;
    inline function set_elapsed(elapsed:Float):Float {
        this.elapsed = elapsed;
        this.elapsedMS = Math.round(elapsed * 1000);
        return elapsed;
    }
    public var elapsedMS(default,null):Float = Math.round(1000.0 / 60.0);

    /** Internal cache var. */
    private var _total:Int = 0;

    public function new(boundsX:Float, boundsY:Float, boundsWidth:Float, boundsHeight:Float) {

        this.boundsX = boundsX;
        this.boundsY = boundsY;
        this.boundsWidth = boundsWidth;
        this.boundsHeight = boundsHeight;

        this.quadTree = new QuadTree(this.boundsX, this.boundsY, this.boundsWidth, this.boundsHeight, this.maxObjects, this.maxLevels);

    }

    /**
     * Updates the size of this physics world.
     *
     * @method Phaser.Physics.Arcade#setBounds
     * @param {number} x - Top left most corner of the world.
     * @param {number} y - Top left most corner of the world.
     * @param {number} width - New width of the world. Can never be smaller than the Game.width.
     * @param {number} height - New height of the world. Can never be smaller than the Game.height.
     */
    inline public function setBounds(x:Float, y:Float, width:Float, height:Float):Void {

        this.boundsX = x;
        this.boundsY = y;
        this.boundsWidth = width;
        this.boundsHeight = height;

    }

    /**
     * Creates an Arcade Physics body on the given game object.
     *
     * A game object can only have 1 physics body active at any one time, and it can't be changed until the body is nulled.
     *
     * When you add an Arcade Physics body to an object it will automatically add the object into its parent Groups hash array.
     *
     * @method Phaser.Physics.Arcade#enableBody
     * @param {object} object - The game object to create the physics body on. A body will only be created if this object has a null `body` property.
     */
    public function enableBody(body:Body):Void {

        // TODO?

    }

    /**
     * Called automatically by a Physics body, it updates all motion related values on the Body unless `World.isPaused` is `true`.
     *
     * @method Phaser.Physics.Arcade#updateMotion
     * @param {Phaser.Physics.Arcade.Body} The Body object to be updated.
     */
    inline public function updateMotion(body:Body):Void
    {

        if (body.allowRotation)
        {
            var velocityDelta = computeVelocity(0, body, body.angularVelocity, body.angularAcceleration, body.angularDrag, body.maxAngularVelocity) - body.angularVelocity;
            body.angularVelocity += velocityDelta;
            body.rotation += (body.angularVelocity * elapsed);
        }

        body.velocityX = computeVelocity(1, body, body.velocityX, body.accelerationX, body.dragX, body.maxVelocityX);
        body.velocityY = computeVelocity(2, body, body.velocityY, body.accelerationY, body.dragY, body.maxVelocityY);

    }

    /**
     * A tween-like function that takes a starting velocity and some other factors and returns an altered velocity.
     * Based on a function in Flixel by @ADAMATOMIC
     *
     * @method Phaser.Physics.Arcade#computeVelocity
     * @param {number} axis - 0 for nothing, 1 for horizontal, 2 for vertical.
     * @param {Phaser.Physics.Arcade.Body} body - The Body object to be updated.
     * @param {number} velocity - Any component of velocity (e.g. 20).
     * @param {number} acceleration - Rate at which the velocity is changing.
     * @param {number} drag - Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
     * @param {number} [max=10000] - An absolute value cap for the velocity.
     * @return {number} The altered Velocity value.
     */
    inline public function computeVelocity(axis:Axis, body:Body, velocity:Float, acceleration:Float, drag:Float, max:Float = 10000):Float
    {

        if (axis == Axis.HORIZONTAL && body.allowGravity)
        {
            velocity += (this.gravityX + body.gravityX) * elapsed;
        }
        else if (axis == Axis.VERTICAL && body.allowGravity)
        {
            velocity += (this.gravityY + body.gravityY) * elapsed;
        }

        if (acceleration != 0)
        {
            velocity += acceleration * elapsed;
        }
        if (drag != 0 && body.allowDrag)
        {
            drag *= elapsed;

            if (velocity - drag > 0)
            {
                velocity -= drag;
            }
            else if (velocity + drag < 0)
            {
                velocity += drag;
            }
            else
            {
                velocity = 0;
            }
        }

        if (velocity > max)
        {
            velocity = max;
        }
        else if (velocity < -max)
        {
            velocity = -max;
        }

        return velocity;

    }

    function getCollidableType(element:Collidable):Class<Dynamic> {

        var clazz = Type.getClass(element);
        switch clazz {
            case Body: return Body;
            case Group: return Group;
            default:
                if (Std.is(element, Body))
                    return Body;
                if (Std.is(element, Group))
                    return Group;
                return clazz;
        }

    }

    public function overlap(element1:Collidable, ?element2:Collidable, ?collideCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool {

        if (element2 == null) {
            return switch getCollidableType(element1) {
                case Group: overlapGroupVsItself(cast element1, collideCallback, processCallback);
                default: false;
            }
        }
        else {
            return switch [getCollidableType(element1), getCollidableType(element2)] {
                case [Body, Body]: overlapBodyVsBody(cast element1, cast element2, collideCallback, processCallback);
                case [Body, Group]: overlapBodyVsGroup(cast element1, cast element2, collideCallback, processCallback);
                case [Group, Body]: overlapBodyVsGroup(cast element2, cast element1, collideCallback, processCallback);
                case [Group, Group]: overlapGroupVsGroup(cast element1, cast element2, collideCallback, processCallback);
                default: false;
            }
        }

    }

    /**
     * Checks for overlaps between two bodies. The objects can be Sprites, Groups or Emitters.
     * Unlike {@link #collide} the objects are NOT automatically separated or have any physics applied, they merely test for overlap results.
     * @return {boolean} True if an overlap occurred otherwise false.
     */
    public function overlapBodyVsBody(body1:Body, body2:Body, ?overlapCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool
    {

        _total = 0;

        if (separate(body1, body2, processCallback, true))
        {
            if (overlapCallback != null)
            {
                overlapCallback(body1, body2);
            }

            _total++;
        }

        return (_total > 0);

    }

    public function overlapGroupVsGroup(group1:Group, group2:Group, ?overlapCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool {

        if (group1.sortDirection != NONE && (group1.sortDirection != INHERIT || sortDirection != NONE)) {
            sort(group1);
        }
        if (group2.sortDirection != NONE && (group2.sortDirection != INHERIT || sortDirection != NONE)) {
            sort(group2);
        }

        _total = 0;

        var objects1 = group1.objects;
        var objects2 = group2.objects;
        for (i in 0...objects1.length) {
            var body1 = objects1[i];
            for (j in 0...objects2.length) {
                var body2 = objects2[j];

                if (body1 != body2) {
                    if (separate(body1, body2, processCallback, true))
                    {
                        if (overlapCallback != null)
                        {
                            overlapCallback(body1, body2);
                        }
            
                        _total++;
                    }
                }
            }
        }

        return (_total > 0);

    }

    public function overlapGroupVsItself(group:Group, ?overlapCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool {

        if (group.sortDirection != NONE && (group.sortDirection != INHERIT || sortDirection != NONE)) {
            sort(group);
        }

        _total = 0;

        var objects = group.objects;
        for (i in 0...objects.length) {
            var body1 = objects[i];
            for (j in 0...objects.length) {
                var body2 = objects[j];

                if (body1 != body2) {
                    if (separate(body1, body2, processCallback, true))
                    {
                        if (overlapCallback != null)
                        {
                            overlapCallback(body1, body2);
                        }
            
                        _total++;
                    }
                }
            }
        }

        return (_total > 0);

    }

    public function overlapBodyVsGroup(body:Body, group:Group, ?overlapCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool {

        if (group.sortDirection != NONE && (group.sortDirection != INHERIT || sortDirection != NONE)) {
            sort(group);
        }

        _total = 0;

        var objects = group.objects;
        for (i in 0...objects.length) {
            var body2 = objects[i];

            if (body != body2) {
                if (separate(body, body2, processCallback, true))
                {
                    if (overlapCallback != null)
                    {
                        overlapCallback(body, body2);
                    }
        
                    _total++;
                }
            }
        }

        return (_total > 0);

    }

    public function collide(element1:Collidable, ?element2:Collidable, ?collideCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool {

        if (element2 == null) {
            return switch getCollidableType(element1) {
                case Group: collideGroupVsItself(cast element1, collideCallback, processCallback);
                default: false;
            }
        }
        else {
            return switch [getCollidableType(element1), getCollidableType(element2)] {
                case [Body, Body]: collideBodyVsBody(cast element1, cast element2, collideCallback, processCallback);
                case [Body, Group]: collideBodyVsGroup(cast element1, cast element2, collideCallback, processCallback);
                case [Group, Body]: collideBodyVsGroup(cast element2, cast element1, collideCallback, processCallback);
                case [Group, Group]: collideGroupVsGroup(cast element1, cast element2, collideCallback, processCallback);
                default: false;
            }
        }

    }

    /**
     * Checks for collision between two bodies and separates them if colliding ({@link https://gist.github.com/samme/cbb81dd19f564dcfe2232761e575063d details}). If you don't require separation then use {@link #overlap} instead.
     * @return {boolean} True if a collision occurred otherwise false.
     */
    public function collideBodyVsBody(body1:Body, body2:Body, ?collideCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool
    {

        _total = 0;

        if (separate(body1, body2, processCallback, false))
        {
            if (collideCallback != null)
            {
                collideCallback(body1, body2);
            }

            _total++;
        }

        return (_total > 0);

    }

    public function collideGroupVsGroup(group1:Group, group2:Group, ?collideCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool {

        if (group1.sortDirection != NONE && (group1.sortDirection != INHERIT || sortDirection != NONE)) {
            sort(group1);
        }
        if (group2.sortDirection != NONE && (group2.sortDirection != INHERIT || sortDirection != NONE)) {
            sort(group2);
        }

        _total = 0;

        var objects1 = group1.objects;
        var objects2 = group2.objects;
        for (i in 0...objects1.length) {
            var body1 = objects1[i];
            for (j in 0...objects2.length) {
                var body2 = objects2[j];

                if (body1 != body2) {
                    if (separate(body1, body2, processCallback, false))
                    {
                        if (collideCallback != null)
                        {
                            collideCallback(body1, body2);
                        }
            
                        _total++;
                    }
                }
            }
        }

        return (_total > 0);

    }

    public function collideGroupVsItself(group:Group, ?collideCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool {

        if (group.sortDirection != NONE && (group.sortDirection != INHERIT || sortDirection != NONE)) {
            sort(group);
        }

        _total = 0;

        var objects = group.objects;
        for (i in 0...objects.length) {
            var body1 = objects[i];
            for (j in 0...objects.length) {
                var body2 = objects[j];

                if (body1 != body2) {
                    if (separate(body1, body2, processCallback, false))
                    {
                        if (collideCallback != null)
                        {
                            collideCallback(body1, body2);
                        }
            
                        _total++;
                    }
                }
            }
        }

        return (_total > 0);

    }

    public function collideBodyVsGroup(body:Body, group:Group, ?collideCallback:Body->Body->Void, ?processCallback:Body->Body->Bool):Bool {

        if (group.sortDirection != NONE && (group.sortDirection != INHERIT || sortDirection != NONE)) {
            sort(group);
        }

        _total = 0;

        var objects = group.objects;
        for (i in 0...objects.length) {
            var body2 = objects[i];

            if (body != body2) {
                if (separate(body, body2, processCallback, false))
                {
                    if (collideCallback != null)
                    {
                        collideCallback(body, body2);
                    }
        
                    _total++;
                }
            }
        }

        return (_total > 0);

    }

    /**
     * This method will sort a Groups hash array.
     *
     * If the Group has `physicsSortDirection` set it will use the sort direction defined.
     *
     * Otherwise if the sortDirection parameter is undefined, or Group.physicsSortDirection is null, it will use Phaser.Physics.Arcade.sortDirection.
     *
     * By changing Group.physicsSortDirection you can customise each Group to sort in a different order.
     *
     * @method Phaser.Physics.Arcade#sort
     * @param {Phaser.Group} group - The Group to sort.
     * @param {integer} [sortDirection] - The sort direction used to sort this Group.
     */
    public function sort(group:Group, sortDirection:SortDirection = SortDirection.INHERIT)
    {

        if (group.sortDirection != SortDirection.INHERIT)
        {
            sortDirection = group.sortDirection;
        }
        else if (sortDirection == SortDirection.INHERIT)
        {
            sortDirection = this.sortDirection;
        }

        if (sortDirection == SortDirection.LEFT_RIGHT)
        {
            //  Game world is say 2000x600 and you start at 0
            group.sortLeftRight();
        }
        else if (sortDirection == SortDirection.RIGHT_LEFT)
        {
            //  Game world is say 2000x600 and you start at 2000
            group.sortRightLeft();
        }
        else if (sortDirection == SortDirection.TOP_BOTTOM)
        {
            //  Game world is say 800x2000 and you start at 0
            group.sortTopBottom();
        }
        else if (sortDirection == SortDirection.BOTTOM_TOP)
        {
            //  Game world is say 800x2000 and you start at 2000
            group.sortBottomTop();
        }

    }

    /**
     * The core separation function to separate two physics bodies.
     *
     * @private
     * @method Phaser.Physics.Arcade#separate
     * @param {Phaser.Physics.Arcade.Body} body1 - The first Body object to separate.
     * @param {Phaser.Physics.Arcade.Body} body2 - The second Body object to separate.
     * @param {function} [processCallback=null] - A callback function that lets you perform additional checks against the two objects if they overlap. If this function is set then the sprites will only be collided if it returns true.
     * @param {object} [callbackContext] - The context in which to run the process callback.
     * @param {boolean} overlapOnly - Just run an overlap or a full collision.
     * @return {boolean} Returns true if the bodies collided, otherwise false.
     */
    private function separate(body1:Body, body2:Body, ?processCallback:Body->Body->Bool, overlapOnly:Bool):Bool
    {

        if (
            !body1.enable ||
            !body2.enable ||
            body1.checkCollisionNone ||
            body2.checkCollisionNone ||
            !this.intersects(body1, body2))
        {
            return false;
        }

        //  They overlap. Is there a custom process callback? If it returns true then we can carry on, otherwise we should abort.
        if (processCallback != null && processCallback(body1, body2) == false)
        {
            return false;
        }

        //  Circle vs. Circle quick bail out
        if (body1.isCircle && body2.isCircle)
        {
            return this.separateCircle(body1, body2, overlapOnly);
        }

        // We define the behavior of bodies in a collision circle and rectangle
        // If a collision occurs in the corner points of the rectangle, the body behave like circles

        //  Either body1 or body2 is a circle
        if (body1.isCircle != body2.isCircle)
        {
            var bodyRect = (body1.isCircle) ? body2 : body1;
            var bodyCircle = (body1.isCircle) ? body1 : body2;

            var rectLeft = bodyRect.left;
            var rectTop = bodyRect.top;
            var rectRight = bodyRect.right;
            var rectBottom = bodyRect.bottom;

            var circleX = bodyCircle.centerX;
            var circleY = bodyCircle.centerY;

            if (circleY < rectTop || circleY > rectBottom)
            {
                if (circleX < rectLeft || circleX > rectRight)
                {
                    return this.separateCircle(body1, body2, overlapOnly);
                }
            }
        }

        var resultX = false;
        var resultY = false;

        //  Do we separate on x or y first?
        if (this.forceX || Math.abs(this.gravityY + body1.gravityY) < Math.abs(this.gravityX + body1.gravityX))
        {
            resultX = this.separateX(body1, body2, overlapOnly);

            //  Are they still intersecting? Let's do the other axis then
            if (this.intersects(body1, body2))
            {
                resultY = this.separateY(body1, body2, overlapOnly);
            }
        }
        else
        {
            resultY = this.separateY(body1, body2, overlapOnly);

            //  Are they still intersecting? Let's do the other axis then
            if (this.intersects(body1, body2))
            {
                resultX = this.separateX(body1, body2, overlapOnly);
            }
        }

        var result = (resultX || resultY);

        if (result)
        {
            if (overlapOnly)
            {
                body1.emitOverlap(body1, body2);
                body2.emitOverlap(body2, body1);
            }
            else
            {
                body1.emitCollide(body1, body2);
                body2.emitCollide(body2, body1);
            }
        }

        return result;

    }

    /**
     * Check for intersection against two bodies.
     *
     * @method Phaser.Physics.Arcade#intersects
     * @param {Phaser.Physics.Arcade.Body} body1 - The first Body object to check.
     * @param {Phaser.Physics.Arcade.Body} body2 - The second Body object to check.
     * @return {boolean} True if they intersect, otherwise false.
     */
    public function intersects(body1:Body, body2:Body):Bool
    {

        if (body1 == body2)
        {
            return false;
        }

        if (body1.isCircle)
        {
            if (body2.isCircle)
            {
                //  Circle vs. Circle
                return distance(body1.centerX, body1.centerY, body2.centerX, body2.centerY) <= (body1.halfWidth + body2.halfWidth);
            }
            else
            {
                //  Circle vs. Rect
                return this.circleBodyIntersects(body1, body2);
            }
        }
        else if (body2.isCircle)
        {
            //  Rect vs. Circle
            return this.circleBodyIntersects(body2, body1);
        }
        else
        {

            //  Rect vs. Rect
            if (body1.right <= body2.left)
            {
                return false;
            }

            if (body1.bottom <= body2.top)
            {
                return false;
            }

            if (body1.left >= body2.right)
            {
                return false;
            }

            if (body1.top >= body2.bottom)
            {
                return false;
            }

            return true;
        }

    }

    /**
     * Checks to see if a circular Body intersects with a Rectangular Body.
     *
     * @method Phaser.Physics.Arcade#circleBodyIntersects
     * @param {Phaser.Physics.Arcade.Body} circle - The Body with `isCircle` set.
     * @param {Phaser.Physics.Arcade.Body} body - The Body with `isCircle` not set (i.e. uses Rectangle shape)
     * @return {boolean} Returns true if the bodies intersect, otherwise false.
     */
    function circleBodyIntersects(circle:Body, body:Body):Bool
    {

        var x = clamp(circle.centerX, body.left, body.right);
        var y = clamp(circle.centerY, body.top, body.bottom);

        var dx = (circle.centerX - x) * (circle.centerX - x);
        var dy = (circle.centerY - y) * (circle.centerY - y);

        return (dx + dy) <= (circle.halfWidth * circle.halfWidth);

    }

    /**
     * The core separation function to separate two circular physics bodies.
     *
     * @method Phaser.Physics.Arcade#separateCircle
     * @private
     * @param {Phaser.Physics.Arcade.Body} body1 - The first Body to separate. Must have `Body.isCircle` true and a positive `radius`.
     * @param {Phaser.Physics.Arcade.Body} body2 - The second Body to separate. Must have `Body.isCircle` true and a positive `radius`.
     * @param {boolean} overlapOnly - If true the bodies will only have their overlap data set, no separation or exchange of velocity will take place.
     * @return {boolean} Returns true if the bodies were separated or overlap, otherwise false.
     */
    function separateCircle(body1:Body, body2:Body, overlapOnly:Bool):Bool
    {

        //  Set the bounding box overlap values
        this.getOverlapX(body1, body2);
        this.getOverlapY(body1, body2);

        var dx = body2.centerX - body1.centerX;
        var dy = body2.centerY - body1.centerY;

        var angleCollision = Math.atan2(dy, dx);

        var overlap:Float = 0;

        if (body1.isCircle != body2.isCircle)
        {
            var rectLeft = (body2.isCircle) ? body1.left : body2.left;
            var rectTop = (body2.isCircle) ? body1.top : body2.top;
            var rectRight = (body2.isCircle) ? body1.right : body2.right;
            var rectBottom = (body2.isCircle) ? body1.bottom : body2.bottom;

            var circleX = (body1.isCircle) ? body1.centerX : body2.centerX;
            var circleY = (body1.isCircle) ? body1.centerY : body2.centerY;
            var circleRadius = (body1.isCircle) ? body1.halfWidth : body2.halfWidth;

            if (circleY < rectTop)
            {
                if (circleX < rectLeft)
                {
                    overlap = distance(circleX, circleY, rectLeft, rectTop) - circleRadius;
                }
                else if (circleX > rectRight)
                {
                    overlap = distance(circleX, circleY, rectRight, rectTop) - circleRadius;
                }
            }
            else if (circleY > rectBottom)
            {
                if (circleX < rectLeft)
                {
                    overlap = distance(circleX, circleY, rectLeft, rectBottom) - circleRadius;
                }
                else if (circleX > rectRight)
                {
                    overlap = distance(circleX, circleY, rectRight, rectBottom) - circleRadius;
                }
            }

            overlap *= -1;
        }
        else
        {
            overlap = (body1.halfWidth + body2.halfWidth) - distance(body1.centerX, body1.centerY, body2.centerX, body2.centerY);
        }

        //  Can't separate two immovable bodies, or a body with its own custom separation logic
        if (overlapOnly || overlap == 0 || (body1.immovable && body2.immovable) || body1.customSeparateX || body2.customSeparateX)
        {
            if (overlap != 0)
            {
                body1.emitOverlap(body1, body2);
                body2.emitOverlap(body2, body1);
            }

            //  return true if there was some overlap, otherwise false
            return (overlap != 0);
        }

        // Transform the velocity vector to the coordinate system oriented along the direction of impact.
        // This is done to eliminate the vertical component of the velocity
        var v1X = body1.velocityX * Math.cos(angleCollision) + body1.velocityY * Math.sin(angleCollision);
        var v1Y = -body1.velocityX * Math.sin(angleCollision) + body1.velocityY * Math.cos(angleCollision);

        var v2X = body2.velocityX * Math.cos(angleCollision) + body2.velocityY * Math.sin(angleCollision);
        var v2Y = -body2.velocityX * Math.sin(angleCollision) + body2.velocityY * Math.cos(angleCollision);

        // We expect the new velocity after impact
        var tempVel1 = ((body1.mass - body2.mass) * v1X + 2 * body2.mass * v2X) / (body1.mass + body2.mass);
        var tempVel2 = (2 * body1.mass * v1X + (body2.mass - body1.mass) * v2X) / (body1.mass + body2.mass);

        // We convert the vector to the original coordinate system and multiplied by factor of rebound
        if (!body1.immovable)
        {
            body1.velocityX = (tempVel1 * Math.cos(angleCollision) - v1Y * Math.sin(angleCollision)) * body1.bounceX;
            body1.velocityY = (v1Y * Math.cos(angleCollision) + tempVel1 * Math.sin(angleCollision)) * body1.bounceY;
        }

        if (!body2.immovable)
        {
            body2.velocityX = (tempVel2 * Math.cos(angleCollision) - v2Y * Math.sin(angleCollision)) * body2.bounceX;
            body2.velocityY = (v2Y * Math.cos(angleCollision) + tempVel2 * Math.sin(angleCollision)) * body2.bounceY;
        }

        // When the collision angle is almost perpendicular to the total initial velocity vector
        // (collision on a tangent) vector direction can be determined incorrectly.
        // This code fixes the problem

        if (Math.abs(angleCollision) < HALF_PI)
        {
            if ((body1.velocityX > 0) && !body1.immovable && (body2.velocityX > body1.velocityX))
            {
                body1.velocityX *= -1;
            }
            else if ((body2.velocityX < 0) && !body2.immovable && (body1.velocityX < body2.velocityX))
            {
                body2.velocityX *= -1;
            }
            else if ((body1.velocityY > 0) && !body1.immovable && (body2.velocityY > body1.velocityY))
            {
                body1.velocityY *= -1;
            }
            else if ((body2.velocityY < 0) && !body2.immovable && (body1.velocityY < body2.velocityY))
            {
                body2.velocityY *= -1;
            }
        }
        else if (Math.abs(angleCollision) > HALF_PI)
        {
            if ((body1.velocityX < 0) && !body1.immovable && (body2.velocityX < body1.velocityX))
            {
                body1.velocityX *= -1;
            }
            else if ((body2.velocityX > 0) && !body2.immovable && (body1.velocityX > body2.velocityX))
            {
                body2.velocityX *= -1;
            }
            else if ((body1.velocityY < 0) && !body1.immovable && (body2.velocityY < body1.velocityY))
            {
                body1.velocityY *= -1;
            }
            else if ((body2.velocityY > 0) && !body2.immovable && (body1.velocityX > body2.velocityY))
            {
                body2.velocityY *= -1;
            }
        }

        if (!body1.immovable)
        {
            body1.x += (body1.velocityX * elapsed) - overlap * Math.cos(angleCollision);
            body1.y += (body1.velocityY * elapsed) - overlap * Math.sin(angleCollision);
        }

        if (!body2.immovable)
        {
            body2.x += (body2.velocityX * elapsed) + overlap * Math.cos(angleCollision);
            body2.y += (body2.velocityY * elapsed) + overlap * Math.sin(angleCollision);
        }

        body1.emitCollide(body1, body2);
        body2.emitCollide(body2, body1);

        return true;

    }

    /**
     * Calculates the horizontal overlap between two Bodies and sets their properties accordingly, including:
     * `touchingLeft`, `touchingRight` and `overlapX`.
     *
     * @method Phaser.Physics.Arcade#getOverlapX
     * @param {Phaser.Physics.Arcade.Body} body1 - The first Body to separate.
     * @param {Phaser.Physics.Arcade.Body} body2 - The second Body to separate.
     * @param {boolean} overlapOnly - Is this an overlap only check, or part of separation?
     * @return {float} Returns the amount of horizontal overlap between the two bodies.
     */
    function getOverlapX(body1:Body, body2:Body, overlapOnly:Bool = false):Float
    {

        var overlap:Float = 0;
        var maxOverlap:Float = body1.deltaAbsX() + body2.deltaAbsX() + this.overlapBias;

        if (body1.deltaX() == 0 && body2.deltaX() == 0)
        {
            //  They overlap but neither of them are moving
            body1.embedded = true;
            body2.embedded = true;
        }
        else if (body1.deltaX() > body2.deltaX())
        {
            //  Body1 is moving right and / or Body2 is moving left
            overlap = body1.right - body2.x;

            if ((overlap > maxOverlap && !overlapOnly) || body1.checkCollisionRight == false || body2.checkCollisionLeft == false)
            {
                overlap = 0;
            }
            else
            {
                body1.touchingNone = false;
                body1.touchingRight = true;
                body2.touchingNone = false;
                body2.touchingLeft = true;

                if (!overlapOnly) {
                    if (body1.immovable) {
                        body2.blockedLeft = true;
                        body2.blockedNone = false;
                    }
                    if (body2.immovable) {
                        body1.blockedRight = true;
                        body1.blockedNone = false;
                    }
                }
            }
        }
        else if (body1.deltaX() < body2.deltaX())
        {
            //  Body1 is moving left and/or Body2 is moving right
            overlap = body1.x - body2.width - body2.x;

            if ((-overlap > maxOverlap && !overlapOnly) || body1.checkCollisionLeft == false || body2.checkCollisionRight == false)
            {
                overlap = 0;
            }
            else
            {
                body1.touchingNone = false;
                body1.touchingLeft = true;
                body2.touchingNone = false;
                body2.touchingRight = true;

                if (!overlapOnly) {
                    if (body1.immovable) {
                        body2.blockedRight = true;
                        body2.blockedNone = false;
                    }
                    if (body2.immovable) {
                        body1.blockedLeft = true;
                        body1.blockedNone = false;
                    }
                }
            }
        }

        //  Resets the overlapX to zero if there is no overlap, or to the actual pixel value if there is
        body1.overlapX = overlap;
        body2.overlapX = overlap;

        return overlap;

    }

    /**
     * Calculates the vertical overlap between two Bodies and sets their properties accordingly, including:
     * `touchingUp`, `touchingDown` and `overlapY`.
     *
     * @method Phaser.Physics.Arcade#getOverlapY
     * @param {Phaser.Physics.Arcade.Body} body1 - The first Body to separate.
     * @param {Phaser.Physics.Arcade.Body} body2 - The second Body to separate.
     * @param {boolean} overlapOnly - Is this an overlap only check, or part of separation?
     * @return {float} Returns the amount of vertical overlap between the two bodies.
     */
    function getOverlapY(body1:Body, body2:Body, overlapOnly:Bool = false):Float
    {

        var overlap:Float = 0;
        var maxOverlap:Float = body1.deltaAbsY() + body2.deltaAbsY() + this.overlapBias;

        if (body1.deltaY() == 0 && body2.deltaY() == 0)
        {
            //  They overlap but neither of them are moving
            body1.embedded = true;
            body2.embedded = true;
        }
        else if (body1.deltaY() > body2.deltaY())
        {
            //  Body1 is moving down and/or Body2 is moving up
            overlap = body1.bottom - body2.y;

            if ((overlap > maxOverlap && !overlapOnly) || body1.checkCollisionDown == false || body2.checkCollisionUp == false)
            {
                overlap = 0;
            }
            else
            {
                body1.touchingNone = false;
                body1.touchingDown = true;
                body2.touchingNone = false;
                body2.touchingUp = true;

                if (!overlapOnly) {
                    if (body1.immovable) {
                        body2.blockedUp = true;
                        body2.blockedNone = false;
                    }
                    if (body2.immovable) {
                        body1.blockedDown = true;
                        body1.blockedNone = false;
                    }
                }
            }
        }
        else if (body1.deltaY() < body2.deltaY())
        {
            //  Body1 is moving up and/or Body2 is moving down
            overlap = body1.y - body2.bottom;

            if ((-overlap > maxOverlap && !overlapOnly) || body1.checkCollisionUp == false || body2.checkCollisionDown == false)
            {
                overlap = 0;
            }
            else
            {
                body1.touchingNone = false;
                body1.touchingUp = true;
                body2.touchingNone = false;
                body2.touchingDown = true;

                if (!overlapOnly) {
                    if (body1.immovable) {
                        body2.blockedDown = true;
                        body2.blockedNone = false;
                    }
                    if (body2.immovable) {
                        body1.blockedUp = true;
                        body1.blockedNone = false;
                    }
                }
            }
        }

        //  Resets the overlapY to zero if there is no overlap, or to the actual pixel value if there is
        body1.overlapY = overlap;
        body2.overlapY = overlap;

        return overlap;

    }

    /**
     * The core separation function to separate two physics bodies on the x axis.
     *
     * @method Phaser.Physics.Arcade#separateX
     * @private
     * @param {Phaser.Physics.Arcade.Body} body1 - The first Body to separate.
     * @param {Phaser.Physics.Arcade.Body} body2 - The second Body to separate.
     * @param {boolean} overlapOnly - If true the bodies will only have their overlap data set, no separation or exchange of velocity will take place.
     * @return {boolean} Returns true if the bodies were separated or overlap, otherwise false.
     */
    function separateX(body1:Body, body2:Body, overlapOnly:Bool):Bool
    {

        var overlap = this.getOverlapX(body1, body2, overlapOnly);

        //  Can't separate two immovable bodies, or a body with its own custom separation logic
        if (overlapOnly || overlap == 0 || (body1.immovable && body2.immovable) || body1.customSeparateX || body2.customSeparateX)
        {
            //  return true if there was some overlap, otherwise false
            return (overlap != 0) || (body1.embedded && body2.embedded);
        }

        //  Adjust their positions and velocities accordingly (if there was any overlap)
        var v1 = body1.velocityX;
        var v2 = body2.velocityX;

        if (!body1.immovable && !body2.immovable)
        {
            overlap *= 0.5;

            body1.x -= overlap;
            body2.x += overlap;

            var nv1 = Math.sqrt((v2 * v2 * body2.mass) / body1.mass) * ((v2 > 0) ? 1 : -1);
            var nv2 = Math.sqrt((v1 * v1 * body1.mass) / body2.mass) * ((v1 > 0) ? 1 : -1);
            var avg = (nv1 + nv2) * 0.5;

            nv1 -= avg;
            nv2 -= avg;

            body1.velocityX = avg + nv1 * body1.bounceX;
            body2.velocityX = avg + nv2 * body2.bounceX;
        }
        else if (!body1.immovable)
        {
            body1.x -= overlap;
            body1.velocityX = v2 - v1 * body1.bounceX;

            //  This is special case code that handles things like vertically moving platforms you can ride
            if (body2.moves)
            {
                body1.y += (body2.y - body2.prevY) * body2.frictionY;
            }
        }
        else
        {
            body2.x += overlap;
            body2.velocityX = v1 - v2 * body2.bounceX;

            //  This is special case code that handles things like vertically moving platforms you can ride
            if (body1.moves)
            {
                body2.y += (body1.y - body1.prevY) * body1.frictionY;
            }
        }

        //  If we got this far then there WAS overlap, and separation is complete, so return true
        return true;

    }

    /**
     * The core separation function to separate two physics bodies on the y axis.
     *
     * @private
     * @method Phaser.Physics.Arcade#separateY
     * @param {Phaser.Physics.Arcade.Body} body1 - The first Body to separate.
     * @param {Phaser.Physics.Arcade.Body} body2 - The second Body to separate.
     * @param {boolean} overlapOnly - If true the bodies will only have their overlap data set, no separation or exchange of velocity will take place.
     * @return {boolean} Returns true if the bodies were separated or overlap, otherwise false.
     */
    function separateY(body1:Body, body2:Body, overlapOnly:Bool):Bool
    {

        var overlap = this.getOverlapY(body1, body2, overlapOnly);

        //  Can't separate two immovable bodies, or a body with its own custom separation logic
        if (overlapOnly || overlap == 0 || (body1.immovable && body2.immovable) || body1.customSeparateY || body2.customSeparateY)
        {
            //  return true if there was some overlap, otherwise false
            return (overlap != 0) || (body1.embedded && body2.embedded);
        }

        //  Adjust their positions and velocities accordingly (if there was any overlap)
        var v1 = body1.velocityY;
        var v2 = body2.velocityY;

        if (!body1.immovable && !body2.immovable)
        {
            overlap *= 0.5;

            body1.y -= overlap;
            body2.y += overlap;

            var nv1 = Math.sqrt((v2 * v2 * body2.mass) / body1.mass) * ((v2 > 0) ? 1 : -1);
            var nv2 = Math.sqrt((v1 * v1 * body1.mass) / body2.mass) * ((v1 > 0) ? 1 : -1);
            var avg = (nv1 + nv2) * 0.5;

            nv1 -= avg;
            nv2 -= avg;

            body1.velocityY = avg + nv1 * body1.bounceY;
            body2.velocityY = avg + nv2 * body2.bounceY;
        }
        else if (!body1.immovable)
        {
            body1.y -= overlap;
            body1.velocityY = v2 - v1 * body1.bounceY;

            //  This is special case code that handles things like horizontal moving platforms you can ride
            if (body2.moves)
            {
                body1.x += (body2.x - body2.prevX) * body2.frictionX;
            }
        }
        else
        {
            body2.y += overlap;
            body2.velocityY = v1 - v2 * body2.bounceY;

            //  This is special case code that handles things like horizontal moving platforms you can ride
            if (body1.moves)
            {
                body2.x += (body1.x - body1.prevX) * body1.frictionX;
            }
        }

        //  If we got this far then there WAS overlap, and separation is complete, so return true
        return true;

    }

    /**
     * Given a Group and a location this will check to see which Group children overlap with the coordinates.
     * Each child will be sent to the given callback for further processing.
     * Note that the children are not checked for depth order, but simply if they overlap the coordinate or not.
     *
     * @method Phaser.Physics.Arcade#getObjectsAtLocation
     * @param {number} x - The x coordinate to check.
     * @param {number} y - The y coordinate to check.
     * @param {Phaser.Group} group - The Group to check.
     * @param {function} [callback] - A callback function that is called if the object overlaps the coordinates. The callback will be sent two parameters: the callbackArg and the Object that overlapped the location.
     * @param {object} [callbackContext] - The context in which to run the callback.
     * @param {object} [callbackArg] - An argument to pass to the callback.
     * @return {PIXI.DisplayObject[]} An array of the Sprites from the Group that overlapped the coordinates.
     */
    public function getObjectsAtLocation<T>(x:Float, y:Float, group:Group, ?callback:T->Body->Void, ?callbackArg:T):Array<Body>
    {

        quadTree.clear();
        quadTree.reset(boundsX, boundsY, boundsWidth, boundsHeight, maxObjects, maxLevels);
        quadTree.populate(group);

        var output:Array<Body> = [];

        var items = quadTree.retrieve(x, y, 1, 1);

        for (i in 0...items.length)
        {
            var item = items[i];

            if (item.hitTest(x, y))
            {
                if (callback != null)
                {
                    callback(callbackArg, item);
                }

                output.push(item);
            }
        }

        return output;

    }

    /**
     * Move the given display object towards the destination object at a steady velocity.
     * If you specify a maxTime then it will adjust the speed (overwriting what you set) so it arrives at the destination in that number of seconds.
     * Timings are approximate due to the way browser timers work. Allow for a variance of +- 50ms.
     * Note: The display object does not continuously track the target. If the target changes location during transit the display object will not modify its course.
     * Note: The display object doesn't stop moving once it reaches the destination coordinates.
     * Note: Doesn't take into account acceleration, maxVelocity or drag (if you've set drag or acceleration too high this object may not move at all)
     *
     * @method Phaser.Physics.Arcade#moveToObject
     * @param {any} displayObject - The display object to move.
     * @param {any} destination - The display object to move towards. Can be any object but must have visible x/y properties.
     * @param {number} [speed=60] - The speed it will move, in pixels per second (default is 60 pixels/sec)
     * @param {number} [maxTime=0] - Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the object will arrive at destination in the given number of ms.
     * @return {number} The angle (in radians) that the object should be visually set to in order to match its new velocity.
     */
    public function moveToDestination(body:Body, destination:Body, speed:Float = 60, maxTime:Float = 0)
    {

        //Math.atan2(y - body.y, x - body.x);
        var angle = Math.atan2(destination.y - body.y, destination.x - body.x);

        if (maxTime > 0)
        {
            //  We know how many pixels we need to move, but how fast?
            speed = distanceBetween(body, destination) / (maxTime / 1000);
        }

        body.setVelocityToPolar(angle, speed);

        return angle;

    }

    /**
     * Move the given display object towards the x/y coordinates at a steady velocity.
     * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
     * Timings are approximate due to the way browser timers work. Allow for a variance of +- 50ms.
     * Note: The display object does not continuously track the target. If the target changes location during transit the display object will not modify its course.
     * Note: The display object doesn't stop moving once it reaches the destination coordinates.
     * Note: Doesn't take into account acceleration, maxVelocity or drag (if you've set drag or acceleration too high this object may not move at all)
     *
     * @method Phaser.Physics.Arcade#moveToXY
     * @param {any} displayObject - The display object to move.
     * @param {number} x - The x coordinate to move towards.
     * @param {number} y - The y coordinate to move towards.
     * @param {number} [speed=60] - The speed it will move, in pixels per second (default is 60 pixels/sec)
     * @param {number} [maxTime=0] - Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the object will arrive at destination in the given number of ms.
     * @return {number} The angle (in radians) that the object should be visually set to in order to match its new velocity.
     */
    public function moveToXY(body:Body, x:Float, y:Float, speed:Float = 60, maxTime:Float = 0)
    {

        var angle = Math.atan2(y - body.y, x - body.x);

        if (maxTime > 0)
        {
            //  We know how many pixels we need to move, but how fast?
            speed = distanceToXY(body, x, y) / (maxTime / 1000);
        }

        body.setVelocityToPolar(angle, speed);

        return angle;

    }

    /**
     * Given the angle (in degrees) and speed calculate the velocity and return it as a Point object, or set it to the given point object.
     * One way to use this is: velocityFromAngle(angle, 200, sprite.velocity) which will set the values directly to the sprites velocity and not create a new Point object.
     *
     * @method Phaser.Physics.Arcade#velocityFromAngle
     * @param {number} angle - The angle in degrees calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
     * @param {number} [speed=60] - The speed it will move, in pixels per second sq.
     * @param {Phaser.Point|object} [point] - The Point object in which the x and y properties will be set to the calculated velocity.
     * @return {Phaser.Point} - A Point where point.x contains the velocity x value and point.y contains the velocity y value.
     */
    public function velocityFromAngle(angle:Float, speed:Float = 60, ?point:Point):Point
    {

        if (point == null) point = new Point(0, 0);

        point.setToPolar(angle, speed, true);

        return point;

    }

    /**
     * Given the rotation (in radians) and speed calculate the velocity and return it as a Point object, or set it to the given point object.
     * One way to use this is: velocityFromRotation(rotation, 200, sprite.velocity) which will set the values directly to the sprites velocity and not create a new Point object.
     *
     * @method Phaser.Physics.Arcade#velocityFromRotation
     * @param {number} rotation - The angle in radians.
     * @param {number} [speed=60] - The speed it will move, in pixels per second sq.
     * @param {Phaser.Point|object} [point] - The Point object in which the x and y properties will be set to the calculated velocity.
     * @return {Phaser.Point} - A Point where point.x contains the velocity x value and point.y contains the velocity y value.
     */
    public function velocityFromRotation(rotation:Float, speed:Float = 60, ?point:Point):Point
    {

        if (point == null) point = new Point(0, 0);

        point.setToPolar(rotation, speed);

        return point;

    }

    /**
     * Given the rotation (in radians) and speed calculate the acceleration and return it as a Point object, or set it to the given point object.
     * One way to use this is: accelerationFromRotation(rotation, 200, sprite.acceleration) which will set the values directly to the sprites acceleration and not create a new Point object.
     *
     * @method Phaser.Physics.Arcade#accelerationFromRotation
     * @param {number} rotation - The angle in radians.
     * @param {number} [speed=60] - The speed it will move, in pixels per second sq.
     * @param {Phaser.Point|object} [point] - The Point object in which the x and y properties will be set to the calculated acceleration.
     * @return {Phaser.Point} - A Point where point.x contains the acceleration x value and point.y contains the acceleration y value.
     */
    public function accelerationFromRotation(rotation:Float, speed:Float = 60, ?point:Point):Point
    {

        if (point == null) point = new Point(0, 0);

        point.setToPolar(rotation, speed);

        return point;

    }

    /**
     * Sets the acceleration.x/y property on the display object so it will move towards the target at the given speed (in pixels per second sq.)
     * You must give a maximum speed value, beyond which the display object won't go any faster.
     * Note: The display object does not continuously track the target. If the target changes location during transit the display object will not modify its course.
     * Note: The display object doesn't stop moving once it reaches the destination coordinates.
     *
     * @method Phaser.Physics.Arcade#accelerateToObject
     * @param {any} displayObject - The display object to move.
     * @param {any} destination - The display object to move towards. Can be any object but must have visible x/y properties.
     * @param {number} [speed=60] - The speed it will accelerate in pixels per second.
     * @param {number} [xSpeedMax=1000] - The maximum x velocity the display object can reach.
     * @param {number} [ySpeedMax=1000] - The maximum y velocity the display object can reach.
     * @return {number} The angle (in radians) that the object should be visually set to in order to match its new trajectory.
     */
    public function accelerateToDestination(body:Body, destination:Body, speed:Float = 60, xSpeedMax:Float = 1000, ySpeedMax:Float = 1000):Float
    {

        var angle = angleBetween(body, destination);

        body.setAccelerationToPolar(angle, speed);
        body.maxVelocityX = xSpeedMax;
        body.maxVelocityY = ySpeedMax;

        return angle;

    }

    /**
     * Sets the acceleration.x/y property on the display object so it will move towards the x/y coordinates at the given speed (in pixels per second sq.)
     * You must give a maximum speed value, beyond which the display object won't go any faster.
     * Note: The display object does not continuously track the target. If the target changes location during transit the display object will not modify its course.
     * Note: The display object doesn't stop moving once it reaches the destination coordinates.
     *
     * @method Phaser.Physics.Arcade#accelerateToXY
     * @param {any} displayObject - The display object to move.
     * @param {number} x - The x coordinate to accelerate towards.
     * @param {number} y - The y coordinate to accelerate towards.
     * @param {number} [speed=60] - The speed it will accelerate in pixels per second.
     * @param {number} [xSpeedMax=1000] - The maximum x velocity the display object can reach.
     * @param {number} [ySpeedMax=1000] - The maximum y velocity the display object can reach.
     * @return {number} The angle (in radians) that the object should be visually set to in order to match its new trajectory.
     */
    public function accelerateToXY(body:Body, x:Float, y:Float, speed:Float = 60, xSpeedMax:Float = 1000, ySpeedMax:Float = 1000):Float
    {

        var angle = angleToXY(body, x, y);

        body.setAccelerationToPolar(angle, speed);
        body.maxVelocityX = xSpeedMax;
        body.maxVelocityY = ySpeedMax;

        return angle;

    }

    /**
     * Find the distance between two display objects (like Sprites).
     *
     * The optional `world` argument allows you to return the result based on the Game Objects `world` property,
     * instead of its `x` and `y` values. This is useful of the object has been nested inside an offset Group,
     * or parent Game Object.
     *
     * If you have nested objects and need to calculate the distance between their centers in World coordinates,
     * set their anchors to (0.5, 0.5) and use the `world` argument.
     *
     * If objects aren't nested or they share a parent's offset, you can calculate the distance between their
     * centers with the `useCenter` argument, regardless of their anchor values.
     *
     * @method Phaser.Physics.Arcade#distanceBetween
     * @param {any} source - The Display Object to test from.
     * @param {any} target - The Display Object to test to.
     * @param {boolean} [world=false] - Calculate the distance using World coordinates (true), or Object coordinates (false, the default). If `useCenter` is true, this value is ignored.
     * @param {boolean} [useCenter=false] - Calculate the distance using the {@link Phaser.Sprite#centerX} and {@link Phaser.Sprite#centerY} coordinates. If true, this value overrides the `world` argument.
     * @return {number} The distance between the source and target objects.
     */
    public function distanceBetween(source:Body, target:Body, useCenter:Bool = false):Float
    {

        var dx:Float;
        var dy:Float;

        if (useCenter)
        {
            dx = source.centerX - target.centerX;
            dy = source.centerY - target.centerY;
        }
        else
        {
            dx = source.x - target.x;
            dy = source.y - target.y;
        }

        return Math.sqrt(dx * dx + dy * dy);

    }

    /**
     * Find the distance between a display object (like a Sprite) and the given x/y coordinates.
     * The calculation is made from the display objects x/y coordinate. This may be the top-left if its anchor hasn't been changed.
     * If you need to calculate from the center of a display object instead use {@link #distanceBetween} with the `useCenter` argument.
     *
     * The optional `world` argument allows you to return the result based on the Game Objects `world` property,
     * instead of its `x` and `y` values. This is useful of the object has been nested inside an offset Group,
     * or parent Game Object.
     *
     * @method Phaser.Physics.Arcade#distanceToXY
     * @param {any} displayObject - The Display Object to test from.
     * @param {number} x - The x coordinate to move towards.
     * @param {number} y - The y coordinate to move towards.
     * @param {boolean} [world=false] - Calculate the distance using World coordinates (true), or Object coordinates (false, the default)
     * @return {number} The distance between the object and the x/y coordinates.
     */
    inline public function distanceToXY(body:Body, x:Float, y:Float):Float
    {

        var dx = body.x - x;
        var dy = body.y - y;

        return Math.sqrt(dx * dx + dy * dy);

    }


    /**
     * From a set of points or display objects, find the one closest to a source point or object.
     *
     * @method Phaser.Physics.Arcade#closest
     * @param {any} source - The {@link Phaser.Point Point} or Display Object distances will be measured from.
     * @param {any[]} targets - The {@link Phaser.Point Points} or Display Objects whose distances to the source will be compared.
     * @param {boolean} [world=false] - Calculate the distance using World coordinates (true), or Object coordinates (false, the default). If `useCenter` is true, this value is ignored.
     * @param {boolean} [useCenter=false] - Calculate the distance using the {@link Phaser.Sprite#centerX} and {@link Phaser.Sprite#centerY} coordinates. If true, this value overrides the `world` argument.
     * @return {any} - The first target closest to the origin.
     */
    public function closest(source:Body, targets:Array<Body>, world:Bool = false, useCenter:Bool = false):Body
    {
        var min:Float = 999999999;
        var closest:Body = null;

        for (i in 0...targets.length)
        {
            var target = targets[i];
            var distance = distanceBetween(source, target, useCenter);

            if (distance < min)
            {
                closest = target;
                min = distance;
            }
        }

        return closest;

    }

    /**
     * From a set of points or display objects, find the one farthest from a source point or object.
     *
     * @method Phaser.Physics.Arcade#farthest
     * @param {any} source - The {@link Phaser.Point Point} or Display Object distances will be measured from.
     * @param {any[]} targets - The {@link Phaser.Point Points} or Display Objects whose distances to the source will be compared.
     * @param {boolean} [world=false] - Calculate the distance using World coordinates (true), or Object coordinates (false, the default). If `useCenter` is true, this value is ignored.
     * @param {boolean} [useCenter=false] - Calculate the distance using the {@link Phaser.Sprite#centerX} and {@link Phaser.Sprite#centerY} coordinates. If true, this value overrides the `world` argument.
     * @return {any} - The target closest to the origin.
     */
    public function farthest(source:Body, targets:Array<Body>, useCenter:Bool = false):Body
    {
        var max:Float = -1;
        var farthest:Body = null;

        for (i in 0...targets.length)
        {
            var target = targets[i];
            var distance = this.distanceBetween(source, target, useCenter);

            if (distance > max)
            {
                farthest = target;
                max = distance;
            }
        }

        return farthest;

    }

    /**
     * Find the angle in radians between two display objects (like Sprites).
     *
     * The optional `world` argument allows you to return the result based on the Game Objects `world` property,
     * instead of its `x` and `y` values. This is useful of the object has been nested inside an offset Group,
     * or parent Game Object.
     *
     * @method Phaser.Physics.Arcade#angleBetween
     * @param {any} source - The Display Object to test from.
     * @param {any} target - The Display Object to test to.
     * @param {boolean} [world=false] - Calculate the angle using World coordinates (true), or Object coordinates (false, the default)
     * @return {number} The angle in radians between the source and target display objects.
     */
    inline public function angleBetween(source:Body, target:Body):Float
    {

        return Math.atan2(target.y - source.y, target.x - source.x);

    }

    /**
     * Find the angle in radians between centers of two display objects (like Sprites).
     *
     * @method Phaser.Physics.Arcade#angleBetweenCenters
     * @param {any} source - The Display Object to test from.
     * @param {any} target - The Display Object to test to.
     * @return {number} The angle in radians between the source and target display objects.
     */
    public function angleBetweenCenters(source:Body, target:Body):Float
    {

        var dx = target.centerX - source.centerX;
        var dy = target.centerY - source.centerY;

        return Math.atan2(dy, dx);

    }

    /**
     * Find the angle in radians between a display object (like a Sprite) and the given x/y coordinate.
     *
     * The optional `world` argument allows you to return the result based on the Game Objects `world` property,
     * instead of its `x` and `y` values. This is useful of the object has been nested inside an offset Group,
     * or parent Game Object.
     *
     * @method Phaser.Physics.Arcade#angleToXY
     * @param {any} displayObject - The Display Object to test from.
     * @param {number} x - The x coordinate to get the angle to.
     * @param {number} y - The y coordinate to get the angle to.
     * @param {boolean} [world=false] - Calculate the angle using World coordinates (true), or Object coordinates (false, the default)
     * @return {number} The angle in radians between displayObject.x/y to Pointer.x/y
     */
    inline public function angleToXY(body:Body, x:Float, y:Float):Float
    {

        return Math.atan2(y - body.y, x - body.x);

    }

/// Internal

    inline static function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {

        var dx:Float = x2 - x1;
        var dy:Float = y2 - y1;

        return Math.sqrt(dx * dx + dy * dy);

    }

    inline static function clamp(v:Float, min:Float, max:Float):Float
    {

        if (v < min)
        {
            return min;
        }
        else if (max < v)
        {
            return max;
        }
        else
        {
            return v;
        }

    }

    function toString():String {

        return 'World($boundsX,$boundsY,$boundsWidth,$boundsHeight)';

    }

    inline static var HALF_PI:Float = 1.5707963267948966;

}
