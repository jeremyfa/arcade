# arcade

An arcade-oriented physics engine for Haxe - a framework-agnostic port of [Phaser v2 arcade physics](https://phaser.io/examples/v2/category/arcade-physics).

## Features

- **Fast 2D arcade physics** - Optimized for performance with AABB collision detection
- **Framework agnostic** - Use with any Haxe game framework or custom engine
- **Groups & batch operations** - Efficiently manage and collide collections of bodies
- **QuadTree optimization** - Automatic spatial partitioning for large numbers of objects
- **Flexible collision callbacks** - Process and respond to collisions with custom logic
- **World bounds** - Define and collide with world boundaries
- **Rich physics properties** - Velocity, acceleration, drag, bounce, gravity, and more
- **Circle collision** - Support for both rectangular and circular collision bodies
- **Angular motion** - Rotation with angular velocity and acceleration

## Installation

Add to your Haxe project:

```bash
haxelib install arcade
```

Or use the development version:

```bash
haxelib git arcade https://github.com/jeremyfa/arcade.git
```

## Quick Start

```haxe
import arcade.World;
import arcade.Body;
import arcade.Group;

class Main {
    var world:World;
    var player:Body;
    var platforms:Group;
    
    static function main() {
        new Main();
    }
    
    public function new() {
        // Create a physics world
        world = new World(0, 0, 800, 600);
        world.gravityY = 300;
        
        // Create player body
        player = new Body(400, 100, 32, 32);
        player.velocityX = 100;
        player.bounceY = 0.8;
        player.collideWorldBounds = true;
        
        // Create platforms
        platforms = new Group();
        var ground = new Body(400, 550, 800, 100);
        ground.immovable = true;
        platforms.add(ground);
    }
    
    public function update(deltaTime:Float) {
        world.elapsed = deltaTime;
        
        // Step 1: Pre-update all bodies
        player.preUpdate(world, player.x, player.y, player.width, player.height, player.rotation);
        for (platform in platforms.objects) {
            platform.preUpdate(world, platform.x, platform.y, platform.width, platform.height, platform.rotation);
        }
        
        // Step 2: Perform collision detection
        world.collide(player, platforms);
        
        // Step 3: Post-update all bodies
        player.postUpdate(world);
        for (platform in platforms.objects) {
            platform.postUpdate(world);
        }
    }
}
```

## Core Concepts

### Physics Update Cycle

The arcade physics engine requires a specific update sequence each frame:

1. **Pre-Update Phase** (`preUpdate()`) - Updates velocities and calculates new positions
2. **Collision Phase** (`collide()`/`overlap()`) - Detects and resolves collisions
3. **Post-Update Phase** (`postUpdate()`) - Finalizes positions and updates state

**Important:** All bodies must complete each phase before moving to the next. Never mix these phases!

```haxe
// CORRECT - Proper update sequence
public function update(delta:Float) {
    world.elapsed = delta;
    
    // Phase 1: Pre-update ALL bodies
    for (body in allBodies) {
        body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
    }
    
    // Phase 2: Perform ALL collision checks
    world.collide(player, platforms);
    world.collide(enemies, platforms);
    world.overlap(player, pickups, collectPickup);
    
    // Phase 3: Post-update ALL bodies
    for (body in allBodies) {
        body.postUpdate(world);
    }
}

// WRONG - Don't do this!
public function badUpdate(delta:Float) {
    player.preUpdate(world, player.x, player.y, player.width, player.height, player.rotation);
    world.collide(player, platforms);
    player.postUpdate(world);  // NO! Other bodies haven't pre-updated yet
    
    enemy.preUpdate(world, enemy.x, enemy.y, enemy.width, enemy.height, enemy.rotation);    // Too late, player already post-updated
    // This will cause incorrect collision behavior
}
```

### Integrating with Visual Objects

Since arcade physics is framework-agnostic, you'll need to sync physics bodies with your visual objects (sprites, images, etc.). Here's a pattern for managing this relationship:

```haxe
// Example: Physics-enabled game object
class GameObject {
    public var body:Body;
    public var visual:YourVisualObject; // Could be a sprite, image, etc.
    
    public function new(x:Float, y:Float, width:Float, height:Float) {
        // Create physics body
        body = new Body(x, y, width, height);
        
        // Create visual representation
        visual = new YourVisualObject();
        visual.x = x;
        visual.y = y;
        visual.width = width;
        visual.height = height;
    }
    
    public function syncVisualToBody() {
        // Update visual position from body
        visual.x = body.x;
        visual.y = body.y;
        
        // Update rotation if needed
        if (body.allowRotation) {
            visual.rotation = body.rotation;
        }
    }
}

// Complete game update example
class Game {
    var world:World;
    var gameObjects:Array<GameObject> = [];
    
    public function update(delta:Float) {
        world.elapsed = delta;
        
        // Phase 1: Sync visuals TO bodies (for input/AI movement)
        for (obj in gameObjects) {
            // Update body from visual if needed (e.g., mouse dragging)
            if (obj.visual.beingDragged) {
                obj.body.x = obj.visual.x;
                obj.body.y = obj.visual.y;
            }
        }
        
        // Phase 2: Pre-update physics
        for (obj in gameObjects) {
            var body = obj.body;
            body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
        }
        
        // Phase 3: Collision detection
        // Bodies are now at their new positions, resolve collisions
        for (i in 0...gameObjects.length) {
            for (j in i+1...gameObjects.length) {
                world.collide(gameObjects[i].body, gameObjects[j].body);
            }
        }
        
        // Phase 4: Post-update physics
        for (obj in gameObjects) {
            obj.body.postUpdate(world);
        }
        
        // Phase 5: Sync bodies TO visuals
        for (obj in gameObjects) {
            obj.syncVisualToBody();
        }
    }
}
```

### Advanced Integration Pattern

The Body class provides `dx` and `dy` properties that track position changes during the physics update:

```haxe
class PhysicsVisual {
    public var body:Body;
    public var visual:Dynamic;
    
    public function preUpdate(world:World) {
        // Sync body position from visual (e.g., after manual movement)
        body.x = visual.x;
        body.y = visual.y;
        
        // Run physics pre-update
        body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
    }
    
    public function postUpdate(world:World) {
        // Run physics post-update
        body.postUpdate(world);
        
        // Apply physics deltas to visual
        // dx and dy contain the position change from this frame
        visual.x += body.dx;
        visual.y += body.dy;
        
        // Apply rotation delta if needed
        if (body.allowRotation) {
            visual.rotation += body.deltaZ();
        }
    }
}

// Example with a complete physics-enabled sprite system
class Sprite {
    public var x:Float;
    public var y:Float;
    public var rotation:Float;
    public var scaleX:Float = 1;
    public var scaleY:Float = 1;
    public var anchorX:Float = 0.5;
    public var anchorY:Float = 0.5;
    public var width:Float;
    public var height:Float;
    
    // Add any rendering-specific properties
}

class PhysicsSprite {
    public var sprite:Sprite;
    public var body:Body;
    
    public function new(x:Float, y:Float, width:Float, height:Float) {
        sprite = new Sprite();
        sprite.x = x;
        sprite.y = y;
        sprite.width = width;
        sprite.height = height;
        
        body = new Body(x, y, width, height);
    }
    
    public function updatePhysics(world:World) {
        // Account for anchor and scale when syncing position
        var scaleX = Math.abs(sprite.scaleX);
        var scaleY = Math.abs(sprite.scaleY);
        var anchorX = sprite.scaleX < 0 ? 1 - sprite.anchorX : sprite.anchorX;
        var anchorY = sprite.scaleY < 0 ? 1 - sprite.anchorY : sprite.anchorY;
        
        // Pre-update: sync body to sprite position
        body.x = sprite.x - sprite.width * scaleX * anchorX;
        body.y = sprite.y - sprite.height * scaleY * anchorY;
        body.width = sprite.width * scaleX;
        body.height = sprite.height * scaleY;
        body.rotation = sprite.rotation;
        
        body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
    }
    
    public function applyPhysics(world:World) {
        body.postUpdate(world);
        
        // Post-update: apply physics deltas to sprite
        sprite.x += body.dx;
        sprite.y += body.dy;
        
        if (body.allowRotation) {
            sprite.rotation += body.deltaZ();
        }
    }
}
```

### World

The `World` class manages the physics simulation, including gravity, bounds, and collision detection.

```haxe
// Create a world with bounds
var world = new World(0, 0, 800, 600);

// Set gravity
world.gravityX = 0;
world.gravityY = 500;

// Configure world bounds collision
world.checkCollisionDown = true;
world.checkCollisionUp = true;
world.checkCollisionLeft = true;
world.checkCollisionRight = true;

// Set elapsed time for physics calculations
world.elapsed = 1.0 / 60.0; // 60 FPS
```

### Body

The `Body` class represents a physics-enabled object with position, velocity, and collision properties.

```haxe
// Create a body
var body = new Body(x, y, width, height);

// Set velocity
body.velocityX = 150;
body.velocityY = -200;

// Set acceleration
body.accelerationX = 0;
body.accelerationY = 300; // Gravity

// Configure collision properties
body.bounceX = 0.5;
body.bounceY = 0.8;
body.collideWorldBounds = true;
body.immovable = false;

// Set mass and drag
body.mass = 1.0;
body.dragX = 50;
body.dragY = 0;

// Angular motion
body.angularVelocity = 45; // degrees per second
body.angularAcceleration = 10;
body.angularDrag = 20;

// Physics update sequence (call each frame):
// 1. preUpdate() - Updates velocity and position
// 2. collision detection - Resolve collisions
// 3. postUpdate() - Finalize position and state
```

### Groups

Groups allow you to manage collections of bodies and perform batch operations.

```haxe
// Create groups
var enemies = new Group();
var bullets = new Group();

// Add bodies to groups
for (i in 0...10) {
    var enemy = new Body(100 + i * 50, 200, 32, 32);
    enemies.add(enemy);
}

// Sort bodies for optimized collision
enemies.sortLeftRight();
```

### Collision Detection

The library provides two main collision methods:

- **`collide`** - Bodies physically push each other and transfer velocity
- **`overlap`** - Detects overlaps without affecting motion

```haxe
// Collide two bodies (with physics response)
if (world.collide(body1, body2)) {
    trace("Collision detected!");
}

// Check overlap without physics response
if (world.overlap(body1, body2)) {
    trace("Bodies are overlapping!");
}

// Collide with callbacks
world.collide(player, enemies, function(player:Body, enemy:Body) {
    trace("Player hit enemy!");
});

// Group vs Group collision
world.collide(bullets, enemies, function(bullet:Body, enemy:Body) {
    bullet.enable = false; // Disable bullet
    enemy.enable = false;  // Disable enemy
});

// Process callback for conditional collisions
world.collide(player, platforms, null, function(player:Body, platform:Body):Bool {
    // Only collide if player is falling
    return player.velocityY > 0;
});
```

## Examples

### Basic Movement

```haxe
class Player {
    var body:Body;
    
    public function new(x:Float, y:Float) {
        body = new Body(x, y, 32, 48);
        body.maxVelocityX = 200;
        body.maxVelocityY = 400;
        body.dragX = 100;
    }
    
    public function updateInput(left:Bool, right:Bool, jump:Bool) {
        // Horizontal movement
        if (left) {
            body.velocityX = -150;
        } else if (right) {
            body.velocityX = 150;
        }
        
        // Jump (only if on ground)
        if (jump && body.blockedDown) {
            body.velocityY = -300;
        }
    }
}

// In your game loop:
class Game {
    var world:World;
    var player:Player;
    var platforms:Group;
    
    public function update(delta:Float) {
        world.elapsed = delta;
        
        // Step 1: Handle input
        player.updateInput(leftPressed, rightPressed, jumpPressed);
        
        // Step 2: Pre-update physics
        player.body.preUpdate(world, player.body.x, player.body.y, player.body.width, player.body.height, player.body.rotation);
        for (platform in platforms.objects) {
            platform.preUpdate(world, platform.x, platform.y, platform.width, platform.height, platform.rotation);
        }
        
        // Step 3: Collision detection
        world.collide(player.body, platforms);
        
        // Step 4: Post-update physics
        player.body.postUpdate(world);
        for (platform in platforms.objects) {
            platform.postUpdate(world);
        }
    }
}
```

### Bouncing Balls

```haxe
class BouncingBalls {
    var world:World;
    var balls:Group;
    
    public function new() {
        world = new World(0, 0, 800, 600);
        world.gravityY = 500;
        
        // Create bouncing balls
        balls = new Group();
        
        for (i in 0...5) {
            var ball = new Body(
                100 + i * 100,  // x position
                100,            // y position  
                16, 16          // size
            );
            
            ball.velocityX = -100 + Math.random() * 200;
            ball.velocityY = -100 + Math.random() * 200;
            ball.bounceX = 1.0;  // Perfect elastic bounce
            ball.bounceY = 1.0;
            ball.collideWorldBounds = true;
            
            balls.add(ball);
        }
    }
    
    public function update(delta:Float) {
        world.elapsed = delta;
        
        // Step 1: Pre-update all balls
        for (ball in balls.objects) {
            ball.preUpdate(world, ball.x, ball.y, ball.width, ball.height, ball.rotation);
        }
        
        // Step 2: Collision detection
        world.collide(balls, balls);
        
        // Step 3: Post-update all balls
        for (ball in balls.objects) {
            ball.postUpdate(world);
        }
    }
}
```

### Platformer Example

```haxe
class PlatformerGame {
    var world:World;
    var player:Body;
    var platforms:Group;
    var enemies:Group;
    
    public function new() {
        // Setup world
        world = new World(0, 0, 800, 600);
        world.gravityY = 800;
        
        // Create player
        player = new Body(100, 400, 32, 48);
        player.bounceY = 0.1;
        player.collideWorldBounds = true;
        player.dragX = 100;
        
        // Create platforms
        platforms = new Group();
        
        // Ground
        var ground = new Body(400, 580, 800, 40);
        ground.immovable = true;
        platforms.add(ground);
        
        // Floating platforms
        var platform1 = new Body(200, 400, 200, 20);
        platform1.immovable = true;
        platforms.add(platform1);
        
        var platform2 = new Body(500, 300, 150, 20);
        platform2.immovable = true;
        platforms.add(platform2);
        
        // Create enemies
        enemies = new Group();
        var enemy = new Body(500, 250, 24, 24);
        enemy.velocityX = 50;
        enemy.bounceX = 1;
        enemies.add(enemy);
    }
    
    public function update(deltaTime:Float) {
        world.elapsed = deltaTime;
        
        // Handle player input
        handlePlayerInput();
        
        // Step 1: Pre-update all bodies
        player.preUpdate(world, player.x, player.y, player.width, player.height, player.rotation);
        
        for (enemy in enemies.objects) {
            enemy.preUpdate(world, enemy.x, enemy.y, enemy.width, enemy.height, enemy.rotation);
        }
        
        // Immovable platforms still need preUpdate
        for (platform in platforms.objects) {
            platform.preUpdate(world, platform.x, platform.y, platform.width, platform.height, platform.rotation);
        }
        
        // Step 2: Collision detection
        world.collide(player, platforms);
        world.collide(enemies, platforms);
        world.collide(player, enemies, onPlayerHitEnemy);
        
        // Step 3: Post-update all bodies
        player.postUpdate(world);
        
        for (enemy in enemies.objects) {
            enemy.postUpdate(world);
        }
        
        for (platform in platforms.objects) {
            platform.postUpdate(world);
        }
    }
    
    function handlePlayerInput() {
        // Example input handling
        if (leftKey) player.velocityX = -200;
        else if (rightKey) player.velocityX = 200;
        
        if (jumpKey && player.blockedDown) {
            player.velocityY = -400;
        }
    }
    
    function onPlayerHitEnemy(player:Body, enemy:Body) {
        if (player.velocityY > 0 && player.y < enemy.y) {
            // Player jumped on enemy
            enemy.enable = false;
            player.velocityY = -200; // Bounce
        } else {
            // Player hit by enemy
            trace("Game Over!");
        }
    }
}
```

### Circular Bodies

```haxe
// Create a circular body
var circle = new Body(400, 300, 32, 32);
circle.setCircle(16); // Radius of 16 pixels

// Circle vs Rectangle collision works automatically
var rect = new Body(450, 300, 40, 40);

world.collide(circle, rect);
```

### Using Callbacks

```haxe
class CollisionExample {
    var world:World;
    var player:Body;
    var coins:Group;
    var platforms:Group;
    var score:Int = 0;
    
    public function update(delta:Float) {
        world.elapsed = delta;
        
        // Step 1: Pre-update all bodies
        player.preUpdate(world, player.x, player.y, player.width, player.height, player.rotation);
        for (coin in coins.objects) {
            coin.preUpdate(world, coin.x, coin.y, coin.width, coin.height, coin.rotation);
        }
        for (platform in platforms.objects) {
            platform.preUpdate(world, platform.x, platform.y, platform.width, platform.height, platform.rotation);
        }
        
        // Step 2: Collision detection with callbacks
        world.collide(player, coins, function(player:Body, coin:Body) {
            // Collect coin
            coin.enable = false;
            score++;
        });
        
        // Process callback for one-way platforms
        world.collide(player, platforms, null, function(player:Body, platform:Body):Bool {
            // Only collide from above
            return player.y < platform.y && player.velocityY > 0;
        });
        
        // Step 3: Post-update all bodies
        player.postUpdate(world);
        for (coin in coins.objects) {
            coin.postUpdate(world);
        }
        for (platform in platforms.objects) {
            platform.postUpdate(world);
        }
    }
}
```

### Advanced Physics

```haxe
class AdvancedPhysics {
    var world:World;
    var spinner:Body;
    var seeker:Body;
    var target:Body;
    var projectiles:Group;
    
    public function new() {
        world = new World(0, 0, 800, 600);
        
        // Rotating sprite
        spinner = new Body(400, 300, 64, 64);
        spinner.angularVelocity = 180; // 180 degrees per second
        spinner.immovable = true;
        
        // Seeking missile
        seeker = new Body(100, 100, 24, 24);
        seeker.dragX = 50;
        seeker.dragY = 50;
        
        // Target
        target = new Body(700, 500, 32, 32);
        target.immovable = true;
        
        // Projectiles group
        projectiles = new Group();
    }
    
    public function update(delta:Float) {
        world.elapsed = delta;
        
        // Update seeker AI
        updateSeekerAI();
        
        // Step 1: Pre-update
        spinner.preUpdate(world, spinner.x, spinner.y, spinner.width, spinner.height, spinner.rotation);
        seeker.preUpdate(world, seeker.x, seeker.y, seeker.width, seeker.height, seeker.rotation);
        target.preUpdate(world, target.x, target.y, target.width, target.height, target.rotation);
        
        for (proj in projectiles.objects) {
            proj.preUpdate(world, proj.x, proj.y, proj.width, proj.height, proj.rotation);
        }
        
        // Step 2: Collisions
        world.collide(seeker, target, function(s:Body, t:Body) {
            trace("Target hit!");
            s.enable = false;
        });
        
        world.collide(projectiles, spinner, function(proj:Body, spin:Body) {
            // Projectile bounces off spinner
            var angle = Math.atan2(proj.y - spin.y, proj.x - spin.x);
            var speed = Math.sqrt(proj.velocityX * proj.velocityX + proj.velocityY * proj.velocityY);
            proj.velocityX = Math.cos(angle) * speed;
            proj.velocityY = Math.sin(angle) * speed;
        });
        
        // Step 3: Post-update
        spinner.postUpdate(world);
        seeker.postUpdate(world);
        target.postUpdate(world);
        
        for (proj in projectiles.objects) {
            proj.postUpdate(world);
        }
    }
    
    function updateSeekerAI() {
        var angle = Math.atan2(
            target.y - seeker.y,
            target.x - seeker.x
        );
        
        var speed = 200;
        seeker.accelerationX = Math.cos(angle) * speed;
        seeker.accelerationY = Math.sin(angle) * speed;
        seeker.maxVelocityX = 150;
        seeker.maxVelocityY = 150;
        
        // Face the target
        seeker.rotation = angle * 180 / Math.PI;
    }
    
    public function fireProjectile(x:Float, y:Float, velocityX:Float, velocityY:Float) {
        var proj = new Body(x, y, 8, 8);
        proj.velocityX = velocityX;
        proj.velocityY = velocityY;
        proj.collideWorldBounds = true;
        proj.bounceX = 1;
        proj.bounceY = 1;
        projectiles.add(proj);
    }
}
```

## Performance Optimization

### QuadTree

The physics engine automatically uses QuadTree spatial partitioning when groups contain more than 10 objects:

```haxe
// Configure QuadTree settings
world.maxObjects = 10;  // Max objects per quad
world.maxLevels = 4;    // Max subdivision levels

// Adjust threshold for automatic QuadTree usage
world.maxObjectsWithoutQuadTree = 10;

// Disable QuadTree globally
world.skipQuadTree = true;

// Disable QuadTree for specific body
body.skipQuadTree = true;
```

### Optimization Tips

1. **Use Groups** - Always group similar objects for efficient collision checks
2. **Sort Groups** - Use appropriate sort direction for your game layout
3. **Limit Active Bodies** - Disable bodies outside the view with `body.enable = false`
4. **Immovable Objects** - Set `immovable = true` for static platforms and walls
5. **Follow Update Order** - Always: preUpdate → collisions → postUpdate
6. **Batch Operations** - Process all bodies in each phase before moving to the next

## API Reference

### World

**Properties:**
- `gravityX/Y: Float` - Global gravity
- `boundsX/Y/Width/Height: Float` - World boundaries
- `checkCollisionUp/Down/Left/Right: Bool` - Enable world bounds collision per edge
- `overlapBias: Float` - Separation bias to prevent tunneling (default: 4)
- `forceX: Bool` - Always separate on X axis first
- `sortDirection: SortDirection` - Default sort for groups
- `isPaused: Bool` - Pause all physics updates
- `elapsed: Float` - Time step in seconds
- `elapsedMS: Float` - Time step in milliseconds

**Methods:**
- `collide(obj1, ?obj2, ?callback, ?processCallback): Bool`
- `overlap(obj1, ?obj2, ?callback, ?processCallback): Bool`
- `sort(group): Void` - Sort group bodies

### Body

**Properties:**
- `x/y: Float` - Position
- `width/height: Float` - Size
- `velocityX/Y: Float` - Current velocity
- `accelerationX/Y: Float` - Acceleration
- `dragX/Y: Float` - Drag coefficient
- `maxVelocityX/Y: Float` - Velocity limits
- `bounceX/Y: Float` - Bounce coefficient (0-1)
- `mass: Float` - Mass for collision
- `gravityX/Y: Float` - Body-specific gravity
- `gravityScaleX/Y: Float` - Gravity multiplier
- `rotation: Float` - Rotation in degrees
- `angularVelocity: Float` - Rotation speed
- `angularAcceleration: Float` - Rotation acceleration
- `angularDrag: Float` - Rotation drag
- `enable: Bool` - Enable/disable body
- `immovable: Bool` - Prevent movement from collisions
- `collideWorldBounds: Bool` - Collide with world edges
- `blockedUp/Down/Left/Right: Bool` - Blocked directions
- `touchingUp/Down/Left/Right: Bool` - Current touches
- `dx/dy: Float` (readonly) - Position change this frame
- `prevX/prevY: Float` - Previous frame position
- `isCircle: Bool` - Whether using circular collision
- `radius: Float` - Radius when using circular collision

**Methods:**
- `preUpdate(world): Void` - Update velocity and position (call before collisions)
- `postUpdate(world): Void` - Finalize position and state (call after collisions)
- `setCircle(radius): Void` - Use circular collision
- `deltaX(): Float` - Get X position change this frame
- `deltaY(): Float` - Get Y position change this frame
- `deltaZ(): Float` - Get rotation change this frame
- `destroy(): Void` - Clean up body

### Group

**Properties:**
- `objects: Array<Body>` - Array of bodies in group
- `sortDirection: SortDirection` - Sort direction override

**Methods:**
- `add(body): Void` - Add body to group
- `remove(body): Void` - Remove body from group
- `sortLeftRight(): Void` - Sort by X position
- `sortRightLeft(): Void` - Sort by X position (reverse)
- `sortTopBottom(): Void` - Sort by Y position
- `sortBottomTop(): Void` - Sort by Y position (reverse)

## Credits

This library was ported and modified for Haxe by **Jérémy Faivre** from the existing work of:

* **Richard Davey <rich@photonstorm.com>**, author of the original arcade physics library for Phaser v2
* **Timo Hausmann**, author of the initial [QuadTree implementation](https://github.com/timohausmann/quadtree-js)
