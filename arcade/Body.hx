package arcade;

/**
 * The Physics Body is linked to a single game object. All physics operations should be performed against the body rather than
 * the object itself. For example you can set the velocity, acceleration, bounce values etc all on the Body.
 */
@:allow(arcade.World)
class Body implements Collidable
{
    /** A property to hold any data related to this body. Can be useful if building a larger system on top of this one. */
    public var data:Dynamic = null;

    /** A property to hold any index value related to this body. Can be useful if building a larger system on top of this one. */
    public var index:Int = -1;

    /** The list of groups that contain this body (can be null if there are no groups). */
    @:allow(arcade.Group)
    public var groups(default, null):Array<Group> = null;

    /** A "main" group associated with this body. */
    public var group(default, set):Group = null;
    function set_group(group:Group):Group {
        if (this.group == group) return group;
        if (this.group != null) {
            this.group.remove(this);
        }
        this.group = group;
        if (this.group != null) {
            this.group.add(this);
        }
        return group;
    }

    /** A disabled body won't be checked for any form of collision or overlap or have its pre/post updates run. */
    public var enable:Bool = true;

    /**
    * If `true` World.separate will always separate on the X axis before Y when this body is involved. Otherwise it will check gravity totals first.
    */
    public var forceX:Bool = false;

    /**
     * If `true` this Body is using circular collision detection. If `false` it is using rectangular.
     * Use `Body.setCircle` to control the collision shape this Body uses.
     */
    public var isCircle:Bool = false;

    /**
     * The radius of the circular collision shape this Body is using if Body.setCircle has been enabled.
     * If you wish to change the radius then call `setCircle` again with the new value.
     * If you wish to stop the Body using a circle then call `setCircle` with a radius of zero (or undefined).
     * The actual radius of the Body is equal to `halfWidth` and the diameter is equal to `width`.
     */
    public var radius:Float = 0;

    /** The x position of the physics body. */
    public var x:Float = 0;
    /** The y position of the physics body. */
    public var y:Float = 0;

    /** The previous x position of the physics body. */
    public var prevX:Float = 0;
    /** The previous y position of the physics body. */
    public var prevY:Float = 0;

    /** Allow this Body to be rotated? (via angularVelocity, etc) */
    public var allowRotation:Bool = true;

    /**
     * The Body's rotation in degrees, as calculated by its angularVelocity and angularAcceleration. Please understand that the collision Body
     * itself never rotates, it is always axis-aligned. However these values are passed up to the parent object and updates its rotation.
     */
    public var rotation:Float = 0;

    /** The previous rotation of the physics body, in degrees. */
    public var preRotation:Float = 0;

    /** The calculated width of the physics body. */
    public var width:Float = 0;

    /** The calculated height of the physics body. */
    public var height:Float = 0;

    /** The calculated width / 2 of the physics body. */
    public var halfWidth:Float = 0;

    /** The calculated height / 2 of the physics body. */
    public var halfHeight:Float = 0;

    /** The center x coordinate of the Physics Body. */
    public var centerX:Float = 0;
    /** The center y coordinate of the Physics Body. */
    public var centerY:Float = 0;

    /** The x velocity, or rate of change of the Body's x position. Measured in pixels per second. */
    public var velocityX:Float = 0;
    /** The y velocity, or rate of change of the Body's y position. Measured in pixels per second. */
    public var velocityY:Float = 0;

    /** The x distance traveled during the last update, equal to `velocityX * physicsElapsed`. Calculated during the Body.preUpdate and applied to its position. */
    public var newVelocityX:Float = 0;
    /** The y distance traveled during the last update, equal to `velocityY * physicsElapsed`. Calculated during the Body.preUpdate and applied to its position. */
    public var newVelocityY:Float = 0;

    /** The maximum x delta value. The Body position is updated based on the delta x/y values. You can set a cap on those (both +-) using maxDeltaX. */
    public var maxDeltaX:Float = 0;
    /** The maximum y delta value. The Body position is updated based on the delta x/y values. You can set a cap on those (both +-) using maxDeltaY. */
    public var maxDeltaY:Float = 0;

    /** The x acceleration is the rate of change of the x velocity. Measured in pixels per second squared. */
    public var accelerationX:Float = 0;
    /** The y acceleration is the rate of change of the y velocity. Measured in pixels per second squared. */
    public var accelerationY:Float = 0;

    /** Allow this Body to be influenced by drag? */
    public var allowDrag:Bool = true;

    /** The x drag applied to the motion of the Body (when `allowDrag` is enabled). Measured in pixels per second squared. */
    public var dragX:Float = 0;
    /** The y drag applied to the motion of the Body (when `allowDrag` is enabled). Measured in pixels per second squared. */
    public var dragY:Float = 0;

    /** Allow this Body to be influenced by gravity? Either world or local. */
    public var allowGravity:Bool = true;

    /** This Body's local x gravity, **added** to any world x gravity, unless Body.allowGravity is set to false. */
    public var gravityX:Float = 0;
    /** This Body's local y gravity, **added** to any world y gravity, unless Body.allowGravity is set to false. */
    public var gravityY:Float = 0;

    /** The x elasticity of the Body when colliding. bounceX = 1 means full rebound, bounceX = 0.5 means 50% rebound velocity. */
    public var bounceX:Float = 0;
    /** The y elasticity of the Body when colliding. bounceY = 1 means full rebound, bounceY = 0.5 means 50% rebound velocity. */
    public var bounceY:Float = 0;

    /**
     * The elasticity of the Body when colliding with the World bounds.
     * By default this property is `false`, in which case `Body.bounce` is used instead. Set this property
     * to true in order to enable a World bounds specific bounce value.
     */
    public var useWorldBounce:Bool = false;
    /** The x elasticity of the Body when colliding with the World bounds. */
    public var worldBounceX:Float = 0;
    /** The y elasticity of the Body when colliding with the World bounds. */
    public var worldBounceY:Float = 0;


    /**
     * A callback that is dispatched when this Body collides with the world bounds.
     * Due to the potentially high volume of signals this could create it is disabled by default.
     * To use this feature set this property to a function
     * and it will be called when a collision happens, passing five arguments:
     * `onWorldBounds(body, up, down, left, right)`
     * where the Body is a reference to this Body, and the other arguments are booleans
     * indicating on which side of the world the Body collided.
     */
    public var onWorldBounds:Body->Bool->Bool->Bool->Bool->Void = null;
    @:noCompletion inline public function emitWorldBounds(body:Body, up:Bool, down:Bool, left:Bool, right:Bool):Void {
        if (onWorldBounds != null) {
            onWorldBounds(body, up, down, left, right);
        }
    }

    /**
     * A callback that is dispatched when this Body collides with another Body.
     *
     * You still need to call `world.collide` in your update method in order
     * for this callback to be dispatched.
     *
     * Usually you'd pass a callback to the `collide` method, but this callback provides for
     * a different level of notification.
     *
     * Due to the potentially high volume of callbacks this could create it is disabled by default.
     *
     * To use this feature set this property to a function
     * and it will be called when a collision happens, passing two arguments: the bodies which collided.
     * The first body in the argument is always this Body.
     *
     * If two Bodies with this callback set collide, both will dispatch the callback.
     */
    public var onCollide:Body->Body->Void = null;
    @:noCompletion inline public function emitCollide(body1:Body, body2:Body):Void {
        if (onCollide != null) {
            onCollide(body1, body2);
        }
    }

    /**
     * A callback that is dispatched when this Body overlaps with another Body.
     *
     * You still need to call `world.overlap` in your update method in order
     * for this callback to be dispatched.
     *
     * Usually you'd pass a callback to the `overlap` method, but this callback provides for
     * a different level of notification.
     *
     * Due to the potentially high volume of callbacks this could create it is disabled by default.
     *
     * To use this feature set this property to a function
     * and it will be called when an overlap happens, passing two arguments: the bodies which overlapped.
     * The first body in the argument is always this Body.
     *
     * If two Bodies with this callback set overlap, both will dispatch the callback.
     */
    public var onOverlap:Body->Body->Void = null;
    @:noCompletion inline public function emitOverlap(body1:Body, body2:Body):Void {
        if (onOverlap != null) {
            onOverlap(body1, body2);
        }
    }

    /** The maximum x velocity (in pixels per second) that the Body can reach. */
    public var maxVelocityX:Float = 10000;
    /** The maximum y velocity (in pixels per second) that the Body can reach. */
    public var maxVelocityY:Float = 10000;

    /** If this Body is `immovable` and moving, and another Body is 'riding' this one, this is the amount of x motion the riding Body receives. */
    public var frictionX:Float = 1;
    /** If this Body is `immovable` and moving, and another Body is 'riding' this one, this is the amount of y motion the riding Body receives. */
    public var frictionY:Float = 0;

    /** The angular velocity is the rate of change of the Body's rotation. It is measured in degrees per second. */
    public var angularVelocity:Float = 0;

    /** The angular acceleration is the rate of change of the angular velocity. Measured in degrees per second squared. */
    public var angularAcceleration:Float = 0;

    /** The drag applied during the rotation of the Body. Measured in degrees per second squared. */
    public var angularDrag:Float = 0;

    /** The maximum angular velocity in degrees per second that the Body can reach. */
    public var maxAngularVelocity:Float = 1000;

    /** The mass of the Body. When two bodies collide their mass is used in the calculation to determine the exchange of velocity. */
    public var mass:Float = 1;

    /** The angle of the Body's **velocity** in radians. */
    public var angle:Float = 0;

    /** The speed of the Body in pixels per second, equal to the magnitude of the velocity. */
    public var speed:Float = 0;

    /** A const reference to the direction the Body is traveling or facing: NONE, LEFT, RIGHT, UP, or DOWN. If the Body is moving on both axes, UP and DOWN take precedence. */
    public var facing:Direction = Direction.NONE;

    /** An immovable Body will not receive any impacts from other bodies. **Two** immovable Bodies can't separate or exchange momentum and will pass through each other. */
    public var immovable:Bool = false;

    /**
     * Whether the physics system should update the Body's position and rotation based on its velocity, acceleration, drag, and gravity.
     *
     * If you have a Body that is being moved around the world via a tween or a Group motion, but its local x/y position never
     * actually changes, then you should set Body.moves = false. Otherwise it will most likely fly off the screen.
     * If you want the physics system to move the body around, then set moves to true.
     *
     * A Body with moves = false can still be moved slightly (but not accelerated) during collision separation unless you set `immovable` as well.
     */
    public var moves:Bool = true;

    /**
     * This flag allows you to disable the custom x separation that takes place by World.separate.
     * Used in combination with your own collision processHandler you can create whatever type of collision response you need.
     */
    public var customSeparateX:Bool = false;

    /**
     * This flag allows you to disable the custom y separation that takes place by World.separate.
     * Used in combination with your own collision processHandler you can create whatever type of collision response you need.
     */
    public var customSeparateY:Bool = false;

    /** When this body collides with another, the amount of horizontal overlap is stored here. */
    public var overlapX:Float = 0;

    /** When this body collides with another, the amount of vertical overlap is stored here. */
    public var overlapY:Float = 0;

    /** If `Body.isCircle` is true, and this body collides with another circular body, the amount of overlap is stored here. */
    public var overlapR:Float = 0;

    /** If a body is overlapping with another body, but neither of them are moving (maybe they spawned on-top of each other?) this is set to true. */
    public var embedded:Bool = false;

    /** A Body can be set to collide against the World bounds automatically and rebound back into the World if this is set to true. Otherwise it will leave the World. */
    public var collideWorldBounds:Bool = false;

    /** If true, collision and overlap checks are disabled for this Body, but motion is retained. */
    public var checkCollisionNone:Bool = false;
    /** Whether this body processes collisions on its top edge. */
    public var checkCollisionUp:Bool = true;
    /** Whether this body processes collisions on its bottom edge. */
    public var checkCollisionDown:Bool = true;
    /** Whether this body processes collisions on its left edge. */
    public var checkCollisionLeft:Bool = true;
    /** Whether this body processes collisions on its right edge. */
    public var checkCollisionRight:Bool = true;


    /** True if the Body is not touching any other Body. */
    public var touchingNone:Bool = true;
    /** True if the Body is touching another Body on its top edge. */
    public var touchingUp:Bool = false;
    /** True if the Body is touching another Body on its bottom edge. */
    public var touchingDown:Bool = false;
    /** True if the Body is touching another Body on its left edge. */
    public var touchingLeft:Bool = false;
    /** True if the Body is touching another Body on its right edge. */
    public var touchingRight:Bool = false;

    /** True if the Body was not touching any other Body in the previous collision check. */
    public var wasTouchingNone:Bool = true;
    /** True if the Body was touching another Body on its top edge in the previous collision check. */
    public var wasTouchingUp:Bool = false;
    /** True if the Body was touching another Body on its bottom edge in the previous collision check. */
    public var wasTouchingDown:Bool = false;
    /** True if the Body was touching another Body on its left edge in the previous collision check. */
    public var wasTouchingLeft:Bool = false;
    /** True if the Body was touching another Body on its right edge in the previous collision check. */
    public var wasTouchingRight:Bool = false;

    /** If this Body being blocked by world bounds or another immovable object? */
    public var blockedNone:Bool = true;
    /** If this Body being blocked by upper world bounds or another immovable object above it? */
    public var blockedUp:Bool = false;
    /** If this Body being blocked by lower world bounds or another immovable object below it? */
    public var blockedDown:Bool = false;
    /** If this Body being blocked by left world bounds or another immovable object on the left? */
    public var blockedLeft:Bool = false;
    /** If this Body being blocked by right world bounds or another immovable object on the right? */
    public var blockedRight:Bool = false;

    /** If this Body in a preUpdate (true) or postUpdate (false) state? */
    public var dirty:Bool = false;

    /** If true and you collide this Body against a Group, it will disable the collision check from using a QuadTree. */
    public var skipQuadTree:Bool = false;

    /** Set by the `moveTo` and `moveFrom` methods. */
    public var isMoving:Bool = false;

    /** Set by the `moveTo` and `moveFrom` methods. */
    public var stopVelocityOnCollide:Bool = true;

    /** Internal time used by the `moveTo` and `moveFrom` methods. */
    private var moveTimer:Float = 0;

    /** Internal distance value, used by the `moveTo` and `moveFrom` methods. */
    private var moveDistance:Int = 0;

    /** Internal duration value, used by the `moveTo` and `moveFrom` methods. */
    private var moveDuration:Float = 0;

    /** Set by the `moveTo` method, and updated each frame. */
    private var moveTarget:Line = null;

    /** Set by the `moveTo` method, and updated each frame. */
    private var moveEnd:Point = null;

    /** Listen for the completion of `moveTo` or `moveFrom` events. */
    public var onMoveComplete:Body->Bool->Void = null;
    @:noCompletion inline public function emitMoveComplete(body:Body, fromCollision:Bool):Void {
        if (onMoveComplete != null) {
            onMoveComplete(body, fromCollision);
        }
    }

    /**
     * Optional callback. If set, invoked during the running of `moveTo` or `moveFrom` events.
     * Note: this is not an event (emit{X}) because we are expecting a boolean return value.
     */
    public var movementCallback:(body:Body,velocityX:Float,velocityY:Float,percent:Float)->Bool = null;

    /** Internal cache var. */
    private var _reset:Bool = true;

    /** Internal cache var. */
    private var _sx:Float = 1;

    /** Internal cache var. */
    private var _sy:Float = 1;

    /** Internal cache var. */
    private var _dx:Float = 0;

    /** Internal cache var. */
    private var _dy:Float = 0;

    public function new(x:Float, y:Float, width:Float, height:Float, rotation:Float = 0) {

        this.x = x;
        this.y = y;
        this.prevX = x;
        this.prevY = y;
        this.rotation = rotation;
        this.preRotation = rotation;
        this.width = width;
        this.height = height;

        updateHalfSize();
        updateCenter();

    }

    inline public function updateHalfSize()
    {

        this.halfWidth = Math.floor(this.width * 0.5);
        this.halfHeight = Math.floor(this.height * 0.5);

    }

    /**
     * Update the Body's center from its position.
     */
    inline public function updateCenter()
    {

        this.centerX = this.x + this.halfWidth;
        this.centerY = this.y + this.halfHeight;

    }

    inline public function updateSize(width:Float, height:Float) {

        if (this.width != width || this.height != height) {
            this.width = width;
            this.height = height;
            updateHalfSize();
            this._reset = true;
        }

    }

    /**
     * Internal method.
     */
    @:noCompletion
    inline public function preUpdate(world:World, x:Float, y:Float, width:Float, height:Float, rotation:Float = 0)
    {

        if (this.enable)
        {

            this.dirty = true;

            //  Store and reset collision flags
            this.wasTouchingNone = this.touchingNone;
            this.wasTouchingUp = this.touchingUp;
            this.wasTouchingDown = this.touchingDown;
            this.wasTouchingLeft = this.touchingLeft;
            this.wasTouchingRight = this.touchingRight;

            this.touchingNone = true;
            this.touchingUp = false;
            this.touchingDown = false;
            this.touchingLeft = false;
            this.touchingRight = false;

            this.blockedNone = true;
            this.blockedUp = false;
            this.blockedDown = false;
            this.blockedLeft = false;
            this.blockedRight = false;

            this.overlapR = 0;
            this.overlapX = 0;
            this.overlapY = 0;

            this.embedded = false;

            this.updateSize(width, height);

            this.x = x;
            this.y = y;

            this.updateCenter();

            this.rotation = rotation;

            this.preRotation = this.rotation;

            if (this._reset)
            {
                this.prevX = this.x;
                this.prevY = this.y;
            }

            if (this.moves)
            {
                world.updateMotion(this);

                this.newVelocityX = this.velocityX * world.elapsed;
                this.newVelocityY = this.velocityY * world.elapsed;

                this.x += this.newVelocityX;
                this.y += this.newVelocityY;
                this.updateCenter();

                if (this.x != this.prevX || this.y != this.prevY)
                {
                    this.angle = Math.atan2(this.velocityY, this.velocityX);
                }

                this.speed = Math.sqrt(this.velocityX * this.velocityX + this.velocityY * this.velocityY);

                //  Now the State update will throw collision checks at the Body
                //  And finally we'll integrate the new position back to the parent object in postUpdate

                if (this.collideWorldBounds)
                {
                    if (this.checkWorldBounds(world))
                    {
                        this.emitWorldBounds(this, this.blockedUp, this.blockedDown, this.blockedLeft, this.blockedRight);
                    }
                }
            }

            this._dx = this.deltaX();
            this._dy = this.deltaY();

            this._reset = false;

        }

    }

    /**
     * Internal method.
     */
    inline function updateMovement(world:World):Bool
    {

        var percent:Float = 0;
        var collided:Bool = (this.overlapX != 0 || this.overlapY != 0);

        //  Duration or Distance based?

        if (this.moveDuration > 0)
        {
            this.moveTimer += world.elapsedMS;

            percent = this.moveTimer / this.moveDuration;
        }
        else
        {
            this.moveTarget.x2 = this.x;
            this.moveTarget.y2 = this.y;

            percent = this.moveTarget.length() / this.moveDistance;
        }

        var callbackResult:Bool = false;
        if (this.movementCallback != null)
        {
            callbackResult = this.movementCallback(this, this.velocityX, this.velocityY, percent);
        }

        var stop = true;

        if (collided || percent >= 1 || callbackResult)
        {
            this.stopMovement((percent >= 1) || (this.stopVelocityOnCollide && collided));
            stop = false;
        }

        return stop;

    }

    /**
     * If this Body is moving as a result of a call to `moveTo` or `moveFrom` (i.e. it
     * has Body.isMoving true), then calling this method will stop the movement before
     * either the duration or distance counters expire.
     *
     * The `onMoveComplete` callback is dispatched.
     *
     * @param stopVelocity Should the Body.velocity be set to zero?
     */
    inline public function stopMovement(stopVelocity:Bool):Void
    {

        if (this.isMoving)
        {
            this.isMoving = false;

            if (stopVelocity)
            {
                this.velocityX = 0;
                this.velocityY = 0;
            }

            //  Send the Body
            //  and a boolean indicating if it stopped because of a collision or not
            emitMoveComplete(this, (this.overlapX != 0 || this.overlapY != 0));
        }

    }

    /**
     * Internal method.
     */
    @:noCompletion
    inline public function postUpdate(world:World)
    {

        //  Only allow postUpdate to be called once per frame
        if (this.enable && this.dirty)
        {

            //  Moving?
            if (this.isMoving)
            {
                this.updateMovement(world);
            }

            this.dirty = false;

            if (this.deltaX() < 0)
            {
                this.facing = Direction.LEFT;
            }
            else if (this.deltaX() > 0)
            {
                this.facing = Direction.RIGHT;
            }

            if (this.deltaY() < 0)
            {
                this.facing = Direction.UP;
            }
            else if (this.deltaY() > 0)
            {
                this.facing = Direction.DOWN;
            }

            if (this.moves)
            {
                this._dx = this.deltaX();
                this._dy = this.deltaY();

                if (this.maxDeltaX != 0 && this._dx != 0)
                {
                    if (this._dx < 0 && this._dx < -this.maxDeltaX)
                    {
                        this._dx = -this.maxDeltaX;
                    }
                    else if (this._dx > 0 && this._dx > this.maxDeltaX)
                    {
                        this._dx = this.maxDeltaX;
                    }
                }

                if (this.maxDeltaY != 0 && this._dy != 0)
                {
                    if (this._dy < 0 && this._dy < -this.maxDeltaY)
                    {
                        this._dy = -this.maxDeltaY;
                    }
                    else if (this._dy > 0 && this._dy > this.maxDeltaY)
                    {
                        this._dy = this.maxDeltaY;
                    }
                }

                this._reset = true;
            }

            this.updateCenter();

            this.prevX = this.x;
            this.prevY = this.y;

        }

    }

    public var dx(get, never):Float;
    inline function get_dx():Float return this._dx;

    public var dy(get, never):Float;
    inline function get_dy():Float return this._dy;

    /**
     * Internal method.
     *
     * @return True if the Body collided with the world bounds, otherwise false.
     */
    inline function checkWorldBounds(world:World)
    {
        var posX = this.x;
        var posY = this.y;
        var boundsX = world.boundsX;
        var boundsY = world.boundsY;
        var boundsRight = boundsX + world.boundsWidth;
        var boundsBottom = boundsY + world.boundsHeight;
        var checkUp = world.checkCollisionUp;
        var checkDown = world.checkCollisionDown;
        var checkRight = world.checkCollisionRight;
        var checkLeft = world.checkCollisionLeft;

        var bx = (this.useWorldBounce) ? -this.worldBounceX : -this.bounceX;
        var by = (this.useWorldBounce) ? -this.worldBounceY : -this.bounceY;

        if (this.x < boundsX && checkLeft)
        {
            this.x = boundsX;
            this.velocityX *= bx;
            this.blockedLeft = true;
            this.blockedNone = false;
        }
        else if (this.right > boundsRight && checkRight)
        {
            this.x = boundsRight - this.width;
            this.velocityX *= bx;
            this.blockedRight = true;
            this.blockedNone = false;
        }

        if (this.y < boundsY && checkUp)
        {
            this.y = boundsY;
            this.velocityY *= by;
            this.blockedUp = true;
            this.blockedNone = false;
        }
        else if (this.bottom > boundsBottom && checkDown)
        {
            this.y = boundsBottom - this.height;
            this.velocityY *= by;
            this.blockedDown = true;
            this.blockedNone = false;
        }

        return !this.blockedNone;

    }

    /**
     * Note: This method is experimental, and may be changed or removed in a future release.
     *
     * This method moves the Body in the given direction, for the duration specified.
     * It works by setting the velocity on the Body, and an internal timer, and then
     * monitoring the duration each frame. When the duration is up the movement is
     * stopped and the `Body.onMoveComplete` callback is dispatched.
     *
     * Movement also stops if the Body collides or overlaps with any other Body.
     *
     * You can control if the velocity should be reset to zero on collision, by using
     * the property `Body.stopVelocityOnCollide`.
     *
     * Stop the movement at any time by calling `Body.stopMovement`.
     *
     * You can optionally set a speed in pixels per second. If not specified it
     * will use the current `Body.speed` value. If this is zero, the function will return false.
     *
     * Please note that due to browser timings you should allow for a variance in
     * when the duration will actually expire. Depending on system it may be as much as
     * +- 50ms. Also this method doesn't take into consideration any other forces acting
     * on the Body, such as Gravity, drag or maxVelocity, all of which may impact the
     * movement.
     *
     * @param duration The duration of the movement, in seconds.
     * @param speed The speed of the movement, in pixels per second. If not provided `Body.speed` is used.
     * @param direction The angle of movement in degrees. If not provided `Body.angle` is used.
     * @return True if the movement successfully started, otherwise false.
     */
    public function moveFrom(duration:Float, speed:Float = -999999999.0, direction:Float = -999999999.0):Bool
    {

        if (speed == -999999999.0) { speed = this.speed; }

        if (speed == 0)
        {
            return false;
        }

        var angle:Float;

        if (direction == -999999999.0)
        {
            angle = this.angle;
            direction = radToDeg(angle);
        }
        else
        {
            angle = degToRad(direction);
        }

        this.moveTimer = 0;
        this.moveDuration = duration * 1000;

        //  Avoid sin/cos
        if (direction == 0 || direction == 180)
        {
            this.velocityX = Math.cos(angle) * speed;
            this.velocityY = 0;
        }
        else if (direction == 90 || direction == 270)
        {
            this.velocityX = 0;
            this.velocityY = Math.sin(angle) * speed;
        }
        else
        {
            this.setVelocityToPolar(angle, speed);
        }

        this.isMoving = true;

        return true;

    }

    /**
     * Note: This method is experimental, and may be changed or removed in a future release.
     *
     * This method moves the Body in the given direction, for the duration specified.
     * It works by setting the velocity on the Body, and an internal distance counter.
     * The distance is monitored each frame. When the distance equals the distance
     * specified in this call, the movement is stopped, and the `Body.onMoveComplete`
     * callback is dispatched.
     *
     * Movement also stops if the Body collides or overlaps with any other Body.
     *
     * You can control if the velocity should be reset to zero on collision, by using
     * the property `Body.stopVelocityOnCollide`.
     *
     * Stop the movement at any time by calling `Body.stopMovement`.
     *
     * Please note that due to browser timings you should allow for a variance in
     * when the distance will actually expire.
     *
     * Note: This method doesn't take into consideration any other forces acting
     * on the Body, such as Gravity, drag or maxVelocity, all of which may impact the
     * movement.
     *
     * @param duration The duration of the movement, in seconds.
     * @param distance The distance, in pixels, the Body will move.
     * @param direction The angle of movement. If not provided `Body.angle` is used.
     * @return True if the movement successfully started, otherwise false.
     */
    public function moveTo(duration:Float, distance:Float, direction:Float = -999999999.0):Bool
    {

        var speed = distance / duration;

        if (speed == 0)
        {
            return false;
        }

        var angle;

        if (direction == -999999999.0)
        {
            angle = this.angle;
            direction = radToDeg(angle);
        }
        else
        {
            angle = degToRad(direction);
        }

        distance = Math.abs(distance);

        this.moveDuration = 0;
        this.moveDistance = Std.int(distance);

        if (this.moveTarget == null)
        {
            this.moveTarget = new Line(0, 0, 0, 0);
            this.moveEnd = new Point(0, 0);
        }

        this.moveTarget.fromAngle(this.x, this.y, angle, distance);

        this.moveEnd.x = this.moveTarget.x2;
        this.moveEnd.y = this.moveTarget.y2;

        this.moveTarget.x1 = this.x;
        this.moveTarget.y1 = this.y;
        this.moveTarget.x2 = this.x;
        this.moveTarget.y2 = this.y;

        //  Avoid sin/cos
        if (direction == 0 || direction == 180)
        {
            this.velocityX = Math.cos(angle) * speed;
            this.velocityY = 0;
        }
        else if (direction == 90 || direction == 270)
        {
            this.velocityX = 0;
            this.velocityY = Math.sin(angle) * speed;
        }
        else
        {
            this.setVelocityToPolar(angle, speed);
        }

        this.isMoving = true;

        return true;

    }

    /**
     * Sets this Body as using a circle, of the given radius, for all collision detection instead of a rectangle.
     * The radius is given in pixels and is the distance from the center of the circle to the edge.
     *
     * To change a Body back to being rectangular again call `setSize`.
     *
     * Note: Circular collision only happens with other Arcade Physics bodies, it does not
     * work against tile maps, where rectangular collision is the only method supported.
     *
     * @param radius The radius of the Body in pixels. Pass a value of zero / undefined, to stop the Body using a circle for collision.
     */
    public function setCircle(radius:Float):Void
    {

        if (radius > 0)
        {
            this.isCircle = true;
            this.radius = radius;

            this.width = radius * 2;
            this.height = radius * 2;

            this.updateHalfSize();
            this.updateCenter();
        }
        else
        {
            this.isCircle = false;
        }

    }

    /**
     * Resets all Body values (velocity, acceleration, rotation, etc)
     *
     * @param x The new x position of the Body.
     * @param y The new y position of the Body.
     * @param width The new width of the Body.
     * @param height The new height of the Body.
     * @param rotation The new rotation of the Body.
     */
    inline public function reset(x:Float, y:Float, width:Float, height:Float, rotation:Float = 0):Void
    {

        this.stop();

        this.x = x;
        this.y = y;

        this.prevX = this.x;
        this.prevY = this.y;

        this.rotation = rotation;
        this.preRotation = this.rotation;

        this.updateSize(width, height);
        this.updateCenter();

    }

    /**
     * Sets acceleration, velocity, and speed to 0.
     */
    inline public function stop()
    {

        this.velocityX = 0;
        this.velocityY = 0;
        this.accelerationX = 0;
        this.accelerationY = 0;
        this.speed = 0;
        this.angularVelocity = 0;
        this.angularAcceleration = 0;

    }

    /**
     * Tests if a world point lies within this Body.
     *
     * @param x The world x coordinate to test.
     * @param y The world y coordinate to test.
     * @return True if the given coordinates are inside this Body, otherwise false.
     */
    inline public function hitTest(x:Float, y:Float):Bool
    {

        return (this.isCircle) ? circleContains(this, x, y) : rectangleContains(this, x, y);

    }

    /**
     * Returns true if the bottom of this Body is in contact with either the world bounds or a tile.
     *
     * @return True if in contact with either the world bounds or a tile.
     */
    inline public function isOnFloor():Bool
    {

        return this.blockedDown;

    }

    /**
     * Returns true if the top of this Body is in contact with either the world bounds or a tile.
     *
     * @return True if in contact with either the world bounds or a tile.
     */
    inline public function isOnCeiling():Bool
    {

        return this.blockedUp;

    }

    /**
     * Returns true if either side of this Body is in contact with either the world bounds or a tile.
     *
     * @return True if in contact with either the world bounds or a tile.
     */
    inline public function isOnWall():Bool
    {

        return (this.blockedLeft || this.blockedRight);

    }

    /**
     * Returns the absolute delta x value.
     *
     * @return The absolute delta value.
     */
    inline public function deltaAbsX():Float
    {

        return (this.deltaX() > 0 ? this.deltaX() : -this.deltaX());

    }

    /**
     * Returns the absolute delta y value.
     *
     * @return The absolute delta value.
     */
    inline public function deltaAbsY():Float
    {

        return (this.deltaY() > 0 ? this.deltaY() : -this.deltaY());

    }

    /**
     * Returns the delta x value. The difference between Body.x now and in the previous step.
     *
     * @return The delta value. Positive if the motion was to the right, negative if to the left.
     */
    inline public function deltaX():Float
    {

        return this.x - this.prevX;

    }

    /**
     * Returns the delta y value. The difference between Body.y now and in the previous step.
     *
     * @return The delta value. Positive if the motion was downwards, negative if upwards.
     */
    inline public function deltaY():Float
    {

        return this.y - this.prevY;

    }

    /**
     * Returns the delta z value. The difference between Body.rotation now and in the previous step.
     *
     * @return The delta value. Positive if the motion was clockwise, negative if anti-clockwise.
     */
    inline public function deltaZ():Float
    {

        return this.rotation - this.preRotation;

    }

    /**
     * Destroys this Body.
     *
     * First it removes this body from any groups it belongs to.
     * Then it nulls the data reference.
     */
    public function destroy():Void
    {

        if (groups != null) {
            for (group in [].concat(groups)) {
                group.remove(this);
            }
            groups = null;
        }

        data = null;

    }

/// Helpers

    inline public function setVelocityToPolar(azimuth:Float, radius:Float = 1, asDegrees:Bool = false):Void
    {

        if (asDegrees) { azimuth = degToRad(azimuth); }

        velocityX = Math.cos(azimuth) * radius;
        velocityY = Math.sin(azimuth) * radius;

    }

    inline public function setAccelerationToPolar(azimuth:Float, radius:Float = 1, asDegrees:Bool = false):Void
    {

        if (asDegrees) { azimuth = degToRad(azimuth); }

        accelerationX = Math.cos(azimuth) * radius;
        accelerationY = Math.sin(azimuth) * radius;

    }

    /**
     * Return true if the given x/y coordinates are within the circular body.
     *
     * @param body The Body to be checked.
     * @param x The X value of the coordinate to test.
     * @param y The Y value of the coordinate to test.
     * @return True if the coordinates are within this circle, otherwise false.
     */
    inline static function circleContains(body:Body, x:Float, y:Float):Bool
    {

        //  Check if x/y are within the bounds first
        if (body.radius > 0 && x >= body.left && x <= body.right && y >= body.top && y <= body.bottom)
        {
            var dx = (body.x - x) * (body.x - x);
            var dy = (body.y - y) * (body.y - y);

            return (dx + dy) <= (body.radius * body.radius);
        }
        else
        {
            return false;
        }

    }

    /**
     * Determines whether the specified coordinates are contained within the region defined by this rectangular body.
     *
     * @param body The Body object.
     * @param x The x coordinate of the point to test.
     * @param y The y coordinate of the point to test.
     * @return A value of true if the Body contains the specified point; otherwise false.
     */
    inline static function rectangleContains(body:Body, x:Float, y:Float):Bool
    {

        if (body.width <= 0 || body.height <= 0)
        {
            return false;
        }

        return (x >= body.x && x < body.right && y >= body.y && y < body.bottom);

    }

/// Additional getters

    public var left(get,never):Float;
    inline function get_left():Float {
        return x;
    }

    public var top(get,never):Float;
    inline function get_top():Float {
        return y;
    }

    public var right(get,never):Float;
    inline function get_right():Float {
        return x + width;
    }

    public var bottom(get,never):Float;
    inline function get_bottom():Float {
        return y + height;
    }

    inline static function degToRad(deg:Float):Float {
        return deg * 0.017453292519943295;
    }

    inline static function radToDeg(rad:Float):Float {
        return rad * 57.29577951308232;
    }

    function toString():String {

        return 'Body($left,$top,$right,$bottom)';

    }

}
