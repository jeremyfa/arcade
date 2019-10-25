package arcade;

/**
* @author       Richard Davey <rich@photonstorm.com>
* @copyright    2016 Photon Storm Ltd.
* @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
*/

/**
* The Physics Body is linked to a single Sprite. All physics operations should be performed against the body rather than
* the Sprite itself. For example you can set the velocity, acceleration, bounce values etc all on the Body.
*
* @class Phaser.Physics.Arcade.Body
* @constructor
* @param {Phaser.Sprite} sprite - The Sprite object this physics body belongs to.
*/
@:allow(arcade.World)
class Body
{

    public var group:Group = null;

    /**
    * @property {boolean} enable - A disabled body won't be checked for any form of collision or overlap or have its pre/post updates run.
    * @default
    */
    public var enable:Bool = true;

    /**
    * If `true` this Body is using circular collision detection. If `false` it is using rectangular.
    * Use `Body.setCircle` to control the collision shape this Body uses.
    * @property {boolean} isCircle
    * @default
    * @readOnly
    */
    public var isCircle:Bool = false;

    /**
    * The radius of the circular collision shape this Body is using if Body.setCircle has been enabled, relative to the Sprite's _texture_.
    * If you wish to change the radius then call {@link #setCircle} again with the new value.
    * If you wish to stop the Body using a circle then call {@link #setCircle} with a radius of zero (or undefined).
    * The actual radius of the Body (at any Sprite scale) is equal to {@link #halfWidth} and the diameter is equal to {@link #width}.
    * @property {number} radius
    * @default
    * @readOnly
    */
    public var radius:Float = 0;

    // @property {Phaser.Point} position - The position of the physics body, equivalent to ({@link #left}, {@link #top}).
    public var x:Float = 0;
    public var y:Float = 0;

    // @property {Phaser.Point} prev - The previous position of the physics body.
    public var prevX:Float = 0;
    public var prevY:Float = 0;

    /**
    * @property {boolean} allowRotation - Allow this Body to be rotated? (via angularVelocity, etc)
    * @default
    */
    public var allowRotation:Bool = true;

    /**
    * The Body's rotation in degrees, as calculated by its angularVelocity and angularAcceleration. Please understand that the collision Body
    * itself never rotates, it is always axis-aligned. However these values are passed up to the parent Sprite and updates its rotation.
    * @property {number} rotation
    */
    public var rotation:Float = 0;

    /**
    * @property {number} preRotation - The previous rotation of the physics body, in degrees.
    * @readonly
    */
    public var preRotation:Float = 0;

    /**
    * @property {number} width - The calculated width of the physics body.
    * @readonly
    */
    public var width:Float = 0;

    /**
    * @property {number} height - The calculated height of the physics body.
    * @readonly
    */
    public var height:Float = 0;

    /**
    * @property {number} halfWidth - The calculated width / 2 of the physics body.
    * @readonly
    */
    public var halfWidth:Float = 0;

    /**
    * @property {number} halfHeight - The calculated height / 2 of the physics body.
    * @readonly
    */
    public var halfHeight:Float = 0;

    // @property {Phaser.Point} center - The center coordinate of the Physics Body.
    public var centerX:Float = 0;
    public var centerY:Float = 0;

    // @property {Phaser.Point} velocity - The velocity, or rate of change the Body's position. Measured in pixels per second.
    public var velocityX:Float = 0;
    public var velocityY:Float = 0;

    /**
    * @property {Phaser.Point} newVelocity - The distanced traveled during the last update, equal to `velocity * physicsElapsed`. Calculated during the Body.preUpdate and applied to its position.
    * @readonly
    */
    public var newVelocityX:Float = 0;
    public var newVelocityY:Float = 0;

    // @property {Phaser.Point} deltaMax - The Sprite position is updated based on the delta x/y values. You can set a cap on those (both +-) using deltaMax.
    public var deltaMaxX:Float = 0;
    public var deltaMaxY:Float = 0;

    // @property {Phaser.Point} acceleration - The acceleration is the rate of change of the velocity. Measured in pixels per second squared.
    public var accelerationX:Float = 0;
    public var accelerationY:Float = 0;

    /**
     * @property {boolean} allowDrag - Allow this Body to be influenced by {@link #drag}?
     * @default
     */
    public var allowDrag:Bool = true;

    // @property {Phaser.Point} drag - The drag applied to the motion of the Body (when {@link #allowDrag} is enabled). Measured in pixels per second squared.
    public var dragX:Float = 0;
    public var dragY:Float = 0;

    /**
    * @property {boolean} allowGravity - Allow this Body to be influenced by gravity? Either world or local.
    * @default
    */
    public var allowGravity:Bool = true;

    // @property {Phaser.Point} gravity - This Body's local gravity, **added** to any world gravity, unless Body.allowGravity is set to false.
    public var gravityX:Float = 0;
    public var gravityY:Float = 0;

    // @property {Phaser.Point} bounce - The elasticity of the Body when colliding. bounce.x/y = 1 means full rebound, bounce.x/y = 0.5 means 50% rebound velocity.
    public var bounceX:Float = 0;
    public var bounceY:Float = 0;

    /**
    * The elasticity of the Body when colliding with the World bounds.
    * By default this property is `null`, in which case `Body.bounce` is used instead. Set this property
    * to a Phaser.Point object in order to enable a World bounds specific bounce value.
    * @property {Phaser.Point} worldBounce
    */
    public var worldBounce:Bool = false;
    public var worldBounceX:Float = 0;
    public var worldBounceY:Float = 0;


    /**
    * A Signal that is dispatched when this Body collides with the world bounds.
    * Due to the potentially high volume of signals this could create it is disabled by default.
    * To use this feature set this property to a Phaser.Signal: `sprite.body.onWorldBounds = new Phaser.Signal()`
    * and it will be called when a collision happens, passing five arguments:
    * `onWorldBounds(sprite, up, down, left, right)`
    * where the Sprite is a reference to the Sprite that owns this Body, and the other arguments are booleans
    * indicating on which side of the world the Body collided.
    * @property {Phaser.Signal} onWorldBounds
    */
    public var onWorldBounds:Body->Bool->Bool->Bool->Bool->Void = null;
    @:noCompletion inline public function emitWorldBounds(body:Body, up:Bool, down:Bool, left:Bool, right:Bool):Void {
        if (onWorldBounds != null) {
            onWorldBounds(body, up, down, left, right);
        }
    }

    /**
    * A Signal that is dispatched when this Body collides with another Body.
    *
    * You still need to call `game.physics.arcade.collide` in your `update` method in order
    * for this signal to be dispatched.
    *
    * Usually you'd pass a callback to the `collide` method, but this signal provides for
    * a different level of notification.
    *
    * Due to the potentially high volume of signals this could create it is disabled by default.
    *
    * To use this feature set this property to a Phaser.Signal: `sprite.body.onCollide = new Phaser.Signal()`
    * and it will be called when a collision happens, passing two arguments: the sprites which collided.
    * The first sprite in the argument is always the owner of this Body.
    *
    * If two Bodies with this Signal set collide, both will dispatch the Signal.
    * @property {Phaser.Signal} onCollide
    */
    public var onCollide:Body->Body->Void = null;
    @:noCompletion inline public function emitCollide(body1:Body, body2:Body):Void {
        if (onCollide != null) {
            onCollide(body1, body2);
        }
    }

    /**
    * A Signal that is dispatched when this Body overlaps with another Body.
    *
    * You still need to call `game.physics.arcade.overlap` in your `update` method in order
    * for this signal to be dispatched.
    *
    * Usually you'd pass a callback to the `overlap` method, but this signal provides for
    * a different level of notification.
    *
    * Due to the potentially high volume of signals this could create it is disabled by default.
    *
    * To use this feature set this property to a Phaser.Signal: `sprite.body.onOverlap = new Phaser.Signal()`
    * and it will be called when a collision happens, passing two arguments: the sprites which collided.
    * The first sprite in the argument is always the owner of this Body.
    *
    * If two Bodies with this Signal set collide, both will dispatch the Signal.
    * @property {Phaser.Signal} onOverlap
    */
    public var onOverlap:Body->Body->Void = null;
    @:noCompletion inline public function emitOverlap(body1:Body, body2:Body):Void {
        if (onOverlap != null) {
            onOverlap(body1, body2);
        }
    }

    // @property {Phaser.Point} maxVelocity - The maximum velocity (in pixels per second squared) that the Body can reach.
    public var maxVelocityX:Float = 10000;
    public var maxVelocityY:Float = 10000;

    // @property {Phaser.Point} friction - If this Body is {@link #immovable} and moving, and another Body is 'riding' this one, this is the amount of motion the riding Body receives on each axis.
    public var frictionX:Float = 1;
    public var frictionY:Float = 0;

    /**
    * @property {number} angularVelocity - The angular velocity is the rate of change of the Body's rotation. It is measured in degrees per second.
    * @default
    */
    public var angularVelocity:Float = 0;

    /**
    * @property {number} angularAcceleration - The angular acceleration is the rate of change of the angular velocity. Measured in degrees per second squared.
    * @default
    */
    public var angularAcceleration:Float = 0;

    /**
    * @property {number} angularDrag - The drag applied during the rotation of the Body. Measured in degrees per second squared.
    * @default
    */
    public var angularDrag:Float = 0;

    /**
    * @property {number} maxAngular - The maximum angular velocity in degrees per second that the Body can reach.
    * @default
    */
    public var maxAngular:Float = 1000;

    /**
    * @property {number} mass - The mass of the Body. When two bodies collide their mass is used in the calculation to determine the exchange of velocity.
    * @default
    */
    public var mass:Float = 1;

    /**
    * @property {number} angle - The angle of the Body's **velocity** in radians.
    * @readonly
    */
    public var angle:Float = 0;

    /**
    * @property {number} speed - The speed of the Body in pixels per second, equal to the magnitude of the velocity.
    * @readonly
    */
    public var speed:Float = 0;

    /**
    * @property {number} facing - A const reference to the direction the Body is traveling or facing: Phaser.NONE, Phaser.LEFT, Phaser.RIGHT, Phaser.UP, or Phaser.DOWN. If the Body is moving on both axes, UP and DOWN take precedence.
    * @default
    */
    public var facing:Direction = Direction.NONE;

    /**
    * @property {boolean} immovable - An immovable Body will not receive any impacts from other bodies. **Two** immovable Bodies can't separate or exchange momentum and will pass through each other.
    * @default
    */
    public var immovable:Bool = false;

    /**
    * Whether the physics system should update the Body's position and rotation based on its velocity, acceleration, drag, and gravity.
    *
    * If you have a Body that is being moved around the world via a tween or a Group motion, but its local x/y position never
    * actually changes, then you should set Body.moves = false. Otherwise it will most likely fly off the screen.
    * If you want the physics system to move the body around, then set moves to true.
    *
    * A Body with moves = false can still be moved slightly (but not accelerated) during collision separation unless you set {@link #immovable} as well.
    *
    * @property {boolean} moves - Set to true to allow the Physics system to move this Body, otherwise false to move it manually.
    * @default
    */
    public var moves:Bool = true;

    /**
    * This flag allows you to disable the custom x separation that takes place by Physics.Arcade.separate.
    * Used in combination with your own collision processHandler you can create whatever type of collision response you need.
    * @property {boolean} customSeparateX - Use a custom separation system or the built-in one?
    * @default
    */
    public var customSeparateX:Bool = false;

    /**
    * This flag allows you to disable the custom y separation that takes place by Physics.Arcade.separate.
    * Used in combination with your own collision processHandler you can create whatever type of collision response you need.
    * @property {boolean} customSeparateY - Use a custom separation system or the built-in one?
    * @default
    */
    public var customSeparateY:Bool = false;

    /**
    * When this body collides with another, the amount of overlap is stored here.
    * @property {number} overlapX - The amount of horizontal overlap during the collision.
    */
    public var overlapX:Float = 0;

    /**
    * When this body collides with another, the amount of overlap is stored here.
    * @property {number} overlapY - The amount of vertical overlap during the collision.
    */
    public var overlapY:Float = 0;

    /**
    * If `Body.isCircle` is true, and this body collides with another circular body, the amount of overlap is stored here.
    * @property {number} overlapR - The amount of overlap during the collision.
    */
    public var overlapR:Float = 0;

    /**
    * If a body is overlapping with another body, but neither of them are moving (maybe they spawned on-top of each other?) this is set to true.
    * @property {boolean} embedded - Body embed value.
    */
    public var embedded:Bool = false;

    /**
    * A Body can be set to collide against the World bounds automatically and rebound back into the World if this is set to true. Otherwise it will leave the World.
    * @property {boolean} collideWorldBounds - Should the Body collide with the World bounds?
    */
    public var collideWorldBounds:Bool = false;

    // Set the checkCollision properties to control which directions collision is processed for this Body.
    // For example checkCollision.up = false means it won't collide when the collision happened while moving up.
    // If you need to disable a Body entirely, use `body.enable = false`, this will also disable motion.
    // If you need to disable just collision and/or overlap checks, but retain motion, set `checkCollision.none = true`.
    // @property {object} checkCollision - An object containing allowed collision (none, up, down, left, right).
    public var checkCollisionNone:Bool = false;
    public var checkCollisionUp:Bool = true;
    public var checkCollisionDown:Bool = true;
    public var checkCollisionLeft:Bool = true;
    public var checkCollisionRight:Bool = true;


    // This object is populated with boolean values when the Body collides with another.
    // touching.up = true means the collision happened to the top of this Body for example.
    // @property {object} touching - An object containing touching results (none, up, down, left, right).
    public var touchingNone:Bool = true;
    public var touchingUp:Bool = false;
    public var touchingDown:Bool = false;
    public var touchingLeft:Bool = false;
    public var touchingRight:Bool = false;

    // This object is populated with previous touching values from the bodies previous collision.
    // @property {object} wasTouching - An object containing previous touching results (none, up, down, left, right).
    public var wasTouchingNone:Bool = true;
    public var wasTouchingUp:Bool = false;
    public var wasTouchingDown:Bool = false;
    public var wasTouchingLeft:Bool = false;
    public var wasTouchingRight:Bool = false;

    /**
    * This object is populated with boolean values when the Body collides with the World bounds or a Tile.
    * For example if blocked.up is true then the Body cannot move up.
    * @property {object} blocked - An object containing on which faces this Body is blocked from moving, if any (none, up, down, left, right).
    */
    public var blockedNone:Bool = true;
    public var blockedUp:Bool = false;
    public var blockedDown:Bool = false;
    public var blockedLeft:Bool = false;
    public var blockedRight:Bool = false;

    /**
    * If this is an especially small or fast moving object then it can sometimes skip over tilemap collisions if it moves through a tile in a step.
    * Set this padding value to add extra padding to its bounds. tilePadding.x applied to its width, y to its height.
    * @property {Phaser.Point} tilePadding - Extra padding to be added to this sprite's dimensions when checking for tile collision.
    */
    public var tilePaddingX:Float = 0;
    public var tilePaddingY:Float = 0;

    /**
    * @property {boolean} dirty - If this Body in a preUpdate (true) or postUpdate (false) state?
    */
    public var dirty:Bool = false;

    /**
    * @property {boolean} skipQuadTree - If true and you collide this Sprite against a Group, it will disable the collision check from using a QuadTree.
    */
    public var skipQuadTree:Bool = false;

    /**
    * If true the Body will check itself against the Sprite.getBounds() dimensions and adjust its width and height accordingly.
    * If false it will compare its dimensions against the Sprite scale instead, and adjust its width height if the scale has changed.
    * Typically you would need to enable syncBounds if your sprite is the child of a responsive display object such as a FlexLayer,
    * or in any situation where the Sprite scale doesn't change, but its parents scale is effecting the dimensions regardless.
    * @property {boolean} syncBounds
    * @default
    */
    public var syncBounds:Bool = false;

    /**
    * @property {boolean} isMoving - Set by the `moveTo` and `moveFrom` methods.
    */
    public var isMoving:Bool = false;

    /**
    * @property {boolean} stopVelocityOnCollide - Set by the `moveTo` and `moveFrom` methods.
    */
    public var stopVelocityOnCollide:Bool = true;

    /**
    * @property {integer} moveTimer - Internal time used by the `moveTo` and `moveFrom` methods.
    * @private
    */
    private var moveTimer:Float = 0;

    /**
    * @property {integer} moveDistance - Internal distance value, used by the `moveTo` and `moveFrom` methods.
    * @private
    */
    private var moveDistance:Int = 0;

    /**
    * @property {integer} moveDuration - Internal duration value, used by the `moveTo` and `moveFrom` methods.
    * @private
    */
    private var moveDuration:Float = 0;

    /**
    * @property {Phaser.Line} moveTarget - Set by the `moveTo` method, and updated each frame.
    * @private
    */
    private var moveTarget:Line = null;

    /**
    * @property {Phaser.Point} moveEnd - Set by the `moveTo` method, and updated each frame.
    * @private
    */
    private var moveEnd:Point = null;

    /**
    * @property {Phaser.Signal} onMoveComplete - Listen for the completion of `moveTo` or `moveFrom` events.
    */
    public var onMoveComplete:Body->Bool->Void = null;
    @:noCompletion inline public function emitMoveComplete(body:Body, fromCollision:Bool):Void {
        if (onMoveComplete != null) {
            onMoveComplete(body, fromCollision);
        }
    }

    /**
    * @property {function} movementCallback - Optional callback. If set, invoked during the running of `moveTo` or `moveFrom` events.
    */
    public var movementCallback:Body->Float->Float->Float->Bool = null;

    /**
    * @property {boolean} _reset - Internal cache var.
    * @private
    */
    private var _reset:Bool = true;

    /**
    * @property {number} _sx - Internal cache var.
    * @private
    */
    private var _sx:Float = 1;

    /**
    * @property {number} _sy - Internal cache var.
    * @private
    */
    private var _sy:Float = 1;

    /**
    * @property {number} _dx - Internal cache var.
    * @private
    */
    private var _dx:Float = 0;

    /**
    * @property {number} _dy - Internal cache var.
    * @private
    */
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

    } //new

    inline public function updateHalfSize()
    {

        this.halfWidth = Math.floor(this.width * 0.5);
        this.halfHeight = Math.floor(this.height * 0.5);

    } //updateHalfSize

    /**
    * Update the Body's center from its position.
    *
    * @method Phaser.Physics.Arcade.Body#updateCenter
    * @protected
    */
    inline public function updateCenter()
    {

        this.centerX = this.x + this.halfWidth;
        this.centerY = this.y + this.halfHeight;

    } //updateCenter

    inline public function updateSize(width:Float, height:Float) {

        if (this.width != width || this.height != height) {
            this.width = width;
            this.height = height;
            updateHalfSize();
            this._reset = true;
        }

    } //updateSize

    /**
    * Internal method.
    *
    * @method Phaser.Physics.Arcade.Body#preUpdate
    * @protected
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
                //  And finally we'll integrate the new position back to the Sprite in postUpdate

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

    } //preUpdate

    /**
    * Internal method.
    *
    * @method Phaser.Physics.Arcade.Body#updateMovement
    * @protected
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

    } //updateMovement

    /**
    * If this Body is moving as a result of a call to `moveTo` or `moveFrom` (i.e. it
    * has Body.isMoving true), then calling this method will stop the movement before
    * either the duration or distance counters expire.
    *
    * The `onMoveComplete` signal is dispatched.
    *
    * @method Phaser.Physics.Arcade.Body#stopMovement
    * @param {boolean} [stopVelocity] - Should the Body.velocity be set to zero?
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

            //  Send the Sprite this Body belongs to
            //  and a boolean indicating if it stopped because of a collision or not
            emitMoveComplete(this, (this.overlapX != 0 || this.overlapY != 0));
        }

    } //stopMovement

    /**
    * Internal method.
    *
    * @method Phaser.Physics.Arcade.Body#postUpdate
    * @protected
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

                if (this.deltaMaxX != 0 && this._dx != 0)
                {
                    if (this._dx < 0 && this._dx < -this.deltaMaxX)
                    {
                        this._dx = -this.deltaMaxX;
                    }
                    else if (this._dx > 0 && this._dx > this.deltaMaxX)
                    {
                        this._dx = this.deltaMaxX;
                    }
                }

                if (this.deltaMaxY != 0 && this._dy != 0)
                {
                    if (this._dy < 0 && this._dy < -this.deltaMaxY)
                    {
                        this._dy = -this.deltaMaxY;
                    }
                    else if (this._dy > 0 && this._dy > this.deltaMaxY)
                    {
                        this._dy = this.deltaMaxY;
                    }
                }

                if (appendXY != null) appendXY(this._dx, this._dy);

                this._reset = true;
            }

            this.updateCenter();

            if (this.allowRotation)
            {
                if (appendAngle != null) appendAngle(this.deltaZ());
            }

            this.prevX = this.x;
            this.prevY = this.y;

        }

    } //postUpdate

    public var dx(get, never):Float;
    inline function get_dx():Float return this._dx;

    public var dy(get, never):Float;
    inline function get_dy():Float return this._dy;

    /**
    * Internal method.
    *
    * @method Phaser.Physics.Arcade.Body#checkWorldBounds
    * @protected
    * @return {boolean} True if the Body collided with the world bounds, otherwise false.
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

        var bx = (this.worldBounce) ? -this.worldBounceX : -this.bounceX;
        var by = (this.worldBounce) ? -this.worldBounceY : -this.bounceY;

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

    } //checkWorldBounds

    /**
    * Note: This method is experimental, and may be changed or removed in a future release.
    *
    * This method moves the Body in the given direction, for the duration specified.
    * It works by setting the velocity on the Body, and an internal timer, and then
    * monitoring the duration each frame. When the duration is up the movement is
    * stopped and the `Body.onMoveComplete` signal is dispatched.
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
    * @method Phaser.Physics.Arcade.Body#moveFrom
    * @param  {number} duration  - The duration of the movement, in seconds.
    * @param  {number} [speed] - The speed of the movement, in pixels per second. If not provided `Body.speed` is used.
    * @param  {number} [direction] - The angle of movement in degrees. If not provided `Body.angle` is used.
    * @return {boolean} True if the movement successfully started, otherwise false.
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

    } //moveFrom

    /**
    * Note: This method is experimental, and may be changed or removed in a future release.
    *
    * This method moves the Body in the given direction, for the duration specified.
    * It works by setting the velocity on the Body, and an internal distance counter.
    * The distance is monitored each frame. When the distance equals the distance
    * specified in this call, the movement is stopped, and the `Body.onMoveComplete`
    * signal is dispatched.
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
    * @method Phaser.Physics.Arcade.Body#moveTo
    * @param  {float} duration - The duration of the movement, in seconds.
    * @param  {float} distance - The distance, in pixels, the Body will move.
    * @param  {float} [direction] - The angle of movement. If not provided `Body.angle` is used.
    * @return {boolean} True if the movement successfully started, otherwise false.
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

    } //moveTo

    /**
    * Sets this Body as using a circle, of the given radius, for all collision detection instead of a rectangle.
    * The radius is given in pixels (relative to the Sprite's _texture_) and is the distance from the center of the circle to the edge.
    *
    * You can also control the x and y offset, which is the position of the Body relative to the top-left of the Sprite's texture.
    *
    * To change a Body back to being rectangular again call `Body.setSize`.
    *
    * Note: Circular collision only happens with other Arcade Physics bodies, it does not
    * work against tile maps, where rectangular collision is the only method supported.
    *
    * @method Phaser.Physics.Arcade.Body#setCircle
    * @param {number} [radius] - The radius of the Body in pixels. Pass a value of zero / undefined, to stop the Body using a circle for collision.
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

    } //setCircle

    /**
    * Resets all Body values (velocity, acceleration, rotation, etc)
    *
    * @method Phaser.Physics.Arcade.Body#reset
    * @param {number} x - The new x position of the Body.
    * @param {number} y - The new y position of the Body.
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

    } //reset

    /**
     * Sets acceleration, velocity, and {@link #speed} to 0.
     *
     * @method Phaser.Physics.Arcade.Body#stop
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

    } //stop

    /**
    * Tests if a world point lies within this Body.
    *
    * @method Phaser.Physics.Arcade.Body#hitTest
    * @param {number} x - The world x coordinate to test.
    * @param {number} y - The world y coordinate to test.
    * @return {boolean} True if the given coordinates are inside this Body, otherwise false.
    */
    inline public function hitTest(x:Float, y:Float):Bool
    {

        return (this.isCircle) ? circleContains(this, x, y) : rectangleContains(this, x, y);

    } //hitTest

    /**
    * Returns true if the bottom of this Body is in contact with either the world bounds or a tile.
    *
    * @method Phaser.Physics.Arcade.Body#onFloor
    * @return {boolean} True if in contact with either the world bounds or a tile.
    */
    inline public function isOnFloor():Bool
    {

        return this.blockedDown;

    } //isOnFloor

    /**
    * Returns true if the top of this Body is in contact with either the world bounds or a tile.
    *
    * @method Phaser.Physics.Arcade.Body#onCeiling
    * @return {boolean} True if in contact with either the world bounds or a tile.
    */
    inline public function isOnCeiling():Bool
    {

        return this.blockedUp;

    } //isOnCeiling

    /**
    * Returns true if either side of this Body is in contact with either the world bounds or a tile.
    *
    * @method Phaser.Physics.Arcade.Body#onWall
    * @return {boolean} True if in contact with either the world bounds or a tile.
    */
    inline public function isOnWall():Bool
    {

        return (this.blockedLeft || this.blockedRight);

    } //isOnWall

    /**
    * Returns the absolute delta x value.
    *
    * @method Phaser.Physics.Arcade.Body#deltaAbsX
    * @return {number} The absolute delta value.
    */
    inline public function deltaAbsX():Float
    {

        return (this.deltaX() > 0 ? this.deltaX() : -this.deltaX());

    } //deltaAbsX

    /**
    * Returns the absolute delta y value.
    *
    * @method Phaser.Physics.Arcade.Body#deltaAbsY
    * @return {number} The absolute delta value.
    */
    inline public function deltaAbsY():Float
    {

        return (this.deltaY() > 0 ? this.deltaY() : -this.deltaY());

    } //deltaAbsY

    /**
    * Returns the delta x value. The difference between Body.x now and in the previous step.
    *
    * @method Phaser.Physics.Arcade.Body#deltaX
    * @return {number} The delta value. Positive if the motion was to the right, negative if to the left.
    */
    inline public function deltaX():Float
    {

        return this.x - this.prevX;

    } //deltaX

    /**
    * Returns the delta y value. The difference between Body.y now and in the previous step.
    *
    * @method Phaser.Physics.Arcade.Body#deltaY
    * @return {number} The delta value. Positive if the motion was downwards, negative if upwards.
    */
    inline public function deltaY():Float
    {

        return this.y - this.prevY;

    } //deltaY

    /**
    * Returns the delta z value. The difference between Body.rotation now and in the previous step.
    *
    * @method Phaser.Physics.Arcade.Body#deltaZ
    * @return {number} The delta value. Positive if the motion was clockwise, negative if anti-clockwise.
    */
    inline public function deltaZ():Float
    {

        return this.rotation - this.preRotation;

    } //deltaZ

    /**
    * Destroys this Body.
    *
    * First it calls Group.removeFromHash if the Game Object this Body belongs to is part of a Group.
    * Then it nulls the Game Objects body reference, and nulls this Body.sprite reference.
    *
    * @method Phaser.Physics.Arcade.Body#destroy
    */
    public function destroy():Void
    {

        if (group != null) {
            group.remove(this);
            group = null;
        }

    } //destroy

/// Helpers

    inline public function setVelocityToPolar(azimuth:Float, radius:Float = 1, asDegrees:Bool = false):Void
    {

        if (asDegrees) { azimuth = degToRad(azimuth); }

        velocityX = Math.cos(azimuth) * radius;
        velocityY = Math.sin(azimuth) * radius;

    } //setVelocityToPolar

    inline public function setAccelerationToPolar(azimuth:Float, radius:Float = 1, asDegrees:Bool = false):Void
    {

        if (asDegrees) { azimuth = degToRad(azimuth); }

        accelerationX = Math.cos(azimuth) * radius;
        accelerationY = Math.sin(azimuth) * radius;

    } //setAccelerationToPolar

    /**
     * Return true if the given x/y coordinates are within the Circle object.
     * @method Phaser.Circle.contains
     * @param {Phaser.Circle} a - The Circle to be checked.
     * @param {number} x - The X value of the coordinate to test.
     * @param {number} y - The Y value of the coordinate to test.
     * @return {boolean} True if the coordinates are within this circle, otherwise false.
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

    } //circleContains

    /**
     * Determines whether the specified coordinates are contained within the region defined by this Rectangle object.
     * @method Phaser.Rectangle.contains
     * @param {Phaser.Rectangle} a - The Rectangle object.
     * @param {number} x - The x coordinate of the point to test.
     * @param {number} y - The y coordinate of the point to test.
     * @return {boolean} A value of true if the Rectangle object contains the specified point; otherwise false.
     */
    inline static function rectangleContains(body:Body, x:Float, y:Float):Bool
    {

        if (body.width <= 0 || body.height <= 0)
        {
            return false;
        }

        return (x >= body.x && x < body.right && y >= body.y && y < body.bottom);

    } //rectangleContains

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

    } //toString

} //Body
