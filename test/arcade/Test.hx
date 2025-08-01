package arcade;

import arcade.Body;
import arcade.Group;
import arcade.World;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.KeyboardEvent;
import js.html.MouseEvent;

class Test {
    static var canvas:CanvasElement;
    static var ctx:CanvasRenderingContext2D;
    static var world:World;
    static var tests:Array<TestCase> = [];
    static var currentTest:Int = 0;
    static var lastTime:Float = 0;

    // Input state
    static var keys:Map<Int, Bool> = new Map();
    public static var keyChars:Map<String, Bool> = new Map();
    static var mouseX:Float = 0;
    static var mouseY:Float = 0;
    static var mouseDown:Bool = false;
    static var ctrlPressed:Bool = false;
    static var cmdPressed:Bool = false;

    public static function main():Void {
        // Initialize canvas
        canvas = Browser.document.createCanvasElement();
        canvas.width = 800;
        canvas.height = 600;
        canvas.style.border = "1px solid #333";
        canvas.style.display = "block";
        canvas.tabIndex = 1; // Make canvas focusable

        // Create a container div for canvas and navigation buttons
        var container = Browser.document.createDivElement();
        container.style.position = "relative";
        container.style.display = "inline-block";
        container.style.margin = "0 auto";

        // Create wrapper for centering
        var wrapper = Browser.document.createDivElement();
        wrapper.style.textAlign = "center";
        wrapper.style.marginTop = "20px";

        Browser.document.body.appendChild(wrapper);
        wrapper.appendChild(container);
        container.appendChild(canvas);

        ctx = canvas.getContext2d();

        // Create world
        world = new World(0, 0, 800, 600);

        // Setup tests
        setupTests();

        // Setup controls
        setupControls();

        // Create navigation buttons
        createNavigationButtons(container);

        // Start first test
        if (tests.length > 0) {
            tests[currentTest].setup();
        }

        // Focus canvas by default
        canvas.focus();

        // Start animation loop
        lastTime = Browser.window.performance.now();
        Browser.window.requestAnimationFrame(update);
    }

    static function setupTests():Void {
        tests = [
            new GravityBounceTest(world),
            new CollisionTest(world),
            new GroupCollisionTest(world),
            new CircleCollisionTest(world),
            new PlatformerTest(world),
            new AngularMotionTest(world),
            new VelocityDragTest(world),
            new OneWayPlatformTest(world),
            new QuadTreeTest(world),
            new MassCollisionTest(world)
        ];
    }

    static function createNavigationButtons(container:js.html.DivElement):Void {
        // Left button
        var leftBtn = Browser.document.createButtonElement();
        leftBtn.innerHTML = "◀";
        leftBtn.style.position = "absolute";
        leftBtn.style.left = "-50px";
        leftBtn.style.top = "50%";
        leftBtn.style.transform = "translateY(-50%)";
        leftBtn.style.width = "40px";
        leftBtn.style.height = "40px";
        leftBtn.style.fontSize = "20px";
        leftBtn.style.cursor = "pointer";
        leftBtn.onclick = function(e) {
            previousTest();
            canvas.focus(); // Return focus to canvas
        };
        container.appendChild(leftBtn);

        // Right button
        var rightBtn = Browser.document.createButtonElement();
        rightBtn.innerHTML = "▶";
        rightBtn.style.position = "absolute";
        rightBtn.style.right = "-50px";
        rightBtn.style.top = "50%";
        rightBtn.style.transform = "translateY(-50%)";
        rightBtn.style.width = "40px";
        rightBtn.style.height = "40px";
        rightBtn.style.fontSize = "20px";
        rightBtn.style.cursor = "pointer";
        rightBtn.onclick = function(e) {
            nextTest();
            canvas.focus(); // Return focus to canvas
        };
        container.appendChild(rightBtn);
    }

    static function setupControls():Void {
        // Create UI
        var info = Browser.document.createDivElement();
        info.innerHTML = '<h2>Arcade Physics Tests</h2>' +
            '<p>Press Ctrl/Cmd + LEFT/RIGHT arrows or use buttons to switch tests | Current test: <span id="testName"></span></p>' +
            '<p id="testInfo"></p>';
        info.style.textAlign = "center";
        Browser.document.body.insertBefore(info, Browser.document.body.firstChild);

        // Canvas-focused keyboard events
        canvas.addEventListener("keydown", function(e:KeyboardEvent) {
            keys.set(e.keyCode, true);

            // Track Ctrl/Cmd state
            if (e.keyCode == 17) ctrlPressed = true; // Ctrl
            if (e.keyCode == 91 || e.keyCode == 93) cmdPressed = true; // Cmd

            // Store the actual key character for layout-agnostic input
            if (e.key != null) {
                keyChars.set(e.key.toLowerCase(), true);
            }

            // Switch tests with Ctrl/Cmd + arrows
            if (ctrlPressed || cmdPressed) {
                if (e.keyCode == 37) { // Left arrow
                    previousTest();
                    e.preventDefault();
                } else if (e.keyCode == 39) { // Right arrow
                    nextTest();
                    e.preventDefault();
                }
            }

            // Prevent default for game keys to avoid scrolling
            var gameKeys = [32, 37, 38, 39, 40]; // Space, arrows
            if (gameKeys.indexOf(e.keyCode) != -1) {
                e.preventDefault();
            }
        });

        canvas.addEventListener("keyup", function(e:KeyboardEvent) {
            keys.set(e.keyCode, false);

            // Track Ctrl/Cmd state
            if (e.keyCode == 17) ctrlPressed = false; // Ctrl
            if (e.keyCode == 91 || e.keyCode == 93) cmdPressed = false; // Cmd

            // Clear the key character
            if (e.key != null) {
                keyChars.set(e.key.toLowerCase(), false);
            }

            // Prevent default for game keys
            var gameKeys = [32, 37, 38, 39, 40]; // Space, arrows
            if (gameKeys.indexOf(e.keyCode) != -1) {
                e.preventDefault();
            }
        });

        // Also handle document-level key events but only when canvas has focus
        Browser.document.addEventListener("keydown", function(e:KeyboardEvent) {
            if (Browser.document.activeElement == canvas) {
                // Track Ctrl/Cmd state globally
                if (e.keyCode == 17) ctrlPressed = true;
                if (e.keyCode == 91 || e.keyCode == 93) cmdPressed = true;
            }
        });

        Browser.document.addEventListener("keyup", function(e:KeyboardEvent) {
            if (Browser.document.activeElement == canvas) {
                // Track Ctrl/Cmd state globally
                if (e.keyCode == 17) ctrlPressed = false;
                if (e.keyCode == 91 || e.keyCode == 93) cmdPressed = false;
            }
        });

        // Mouse events
        canvas.addEventListener("mousemove", function(e:MouseEvent) {
            var rect = canvas.getBoundingClientRect();
            mouseX = e.clientX - rect.left;
            mouseY = e.clientY - rect.top;
        });

        canvas.addEventListener("mousedown", function(e:MouseEvent) {
            mouseDown = true;
            canvas.focus(); // Ensure canvas has focus when clicked
        });

        canvas.addEventListener("mouseup", function(e:MouseEvent) {
            mouseDown = false;
        });

        // Click anywhere on canvas to focus it
        canvas.addEventListener("click", function(e:MouseEvent) {
            canvas.focus();
        });
    }

    static function nextTest():Void {
        if (tests.length == 0) return;

        tests[currentTest].cleanup();
        currentTest = (currentTest + 1) % tests.length;
        tests[currentTest].setup();
        updateTestInfo();

        // Clear all key states to prevent stuck keys
        keys.clear();
        keyChars.clear();
    }

    static function previousTest():Void {
        if (tests.length == 0) return;

        tests[currentTest].cleanup();
        currentTest--;
        if (currentTest < 0) currentTest = tests.length - 1;
        tests[currentTest].setup();
        updateTestInfo();

        // Clear all key states to prevent stuck keys
        keys.clear();
        keyChars.clear();
    }

    static function updateTestInfo():Void {
        var nameEl = Browser.document.getElementById("testName");
        var infoEl = Browser.document.getElementById("testInfo");

        if (nameEl != null) {
            nameEl.innerHTML = tests[currentTest].name;
        }
        if (infoEl != null) {
            infoEl.innerHTML = tests[currentTest].description;
        }
    }

    static function update(time:Float):Void {
        var delta = (time - lastTime) / 1000.0; // Convert to seconds
        lastTime = time;

        // Cap delta to prevent spiral of death
        if (delta > 0.1) delta = 0.1;

        world.elapsed = delta;

        // Update current test
        if (tests.length > 0) {
            tests[currentTest].update(delta, keys, mouseX, mouseY, mouseDown);
        }

        // Clear canvas
        ctx.fillStyle = "#f0f0f0";
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Render current test
        if (tests.length > 0) {
            tests[currentTest].render(ctx);
        }

        // Update info
        updateTestInfo();

        // Continue loop
        Browser.window.requestAnimationFrame(update);
    }

    // Helper function to check keys in a layout-agnostic way
    public static function isKeyPressed(char:String):Bool {
        return keyChars.get(char.toLowerCase()) == true;
    }
}

// Base test case class
class TestCase {
    public var name:String = "Test";
    public var description:String = "";
    public var world:World;
    public var bodies:Array<Body> = [];
    public var groups:Array<Group> = [];

    public function new(world:World) {
        this.world = world;
    }

    public function setup():Void {
        // Override in subclasses
    }

    public function cleanup():Void {
        // Clean up all bodies
        for (body in bodies) {
            body.enable = false;
        }
        bodies = [];
        groups = [];
    }

    public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Pre-update all bodies
        for (body in bodies) {
            if (body.enable) {
                body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
            }
        }

        // Override in subclasses for collision detection

        // Post-update all bodies
        for (body in bodies) {
            if (body.enable) {
                body.postUpdate(world);
            }
        }
    }

    public function render(ctx:CanvasRenderingContext2D):Void {
        // Render all bodies
        for (body in bodies) {
            if (body.enable) {
                renderBody(ctx, body);
            }
        }
    }

    function renderBody(ctx:CanvasRenderingContext2D, body:Body, color:String = "#4444ff"):Void {
        ctx.save();

        if (body.isCircle) {
            // Draw circle
            ctx.beginPath();
            ctx.arc(body.x + body.radius, body.y + body.radius, body.radius, 0, Math.PI * 2);
            ctx.fillStyle = color;
            ctx.fill();
            ctx.strokeStyle = "#000";
            ctx.stroke();
        } else {
            // Draw rectangle
            ctx.translate(body.x + body.width / 2, body.y + body.height / 2);
            ctx.rotate(body.rotation * Math.PI / 180);

            ctx.fillStyle = color;
            ctx.fillRect(-body.width / 2, -body.height / 2, body.width, body.height);

            ctx.strokeStyle = "#000";
            ctx.strokeRect(-body.width / 2, -body.height / 2, body.width, body.height);
        }

        ctx.restore();

        // Draw velocity vector
        if (Math.abs(body.velocityX) > 1 || Math.abs(body.velocityY) > 1) {
            ctx.strokeStyle = "#ff0000";
            ctx.beginPath();
            ctx.moveTo(body.x + body.width / 2, body.y + body.height / 2);
            ctx.lineTo(
                body.x + body.width / 2 + body.velocityX * 0.1,
                body.y + body.height / 2 + body.velocityY * 0.1
            );
            ctx.stroke();
        }
    }
}

// Test 1: Basic gravity and bounce
class GravityBounceTest extends TestCase {
    var balls:Array<Body>;

    public function new(world:World) {
        super(world);
        name = "Gravity & Bounce";
        description = "Balls with different bounce values. Click to add more balls.";
    }

    override public function setup():Void {
        world.gravityY = 500;
        balls = [];

        // Create balls with different bounce values
        for (i in 0...5) {
            var ball = new Body(100 + i * 120, 50, 32, 32);
            ball.bounceY = 0.2 + i * 0.2; // 0.2, 0.4, 0.6, 0.8, 1.0
            ball.bounceX = 1;
            ball.velocityX = -50 + Math.random() * 100;
            ball.collideWorldBounds = true;
            ball.setCircle(16);

            bodies.push(ball);
            balls.push(ball);
        }
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Add ball on click
        if (mouseDown) {
            var ball = new Body(mouseX - 16, mouseY - 16, 32, 32);
            ball.bounceY = 0.8;
            ball.bounceX = 0.8;
            ball.velocityX = -100 + Math.random() * 200;
            ball.velocityY = -200;
            ball.collideWorldBounds = true;
            ball.setCircle(16);

            bodies.push(ball);
            balls.push(ball);
        }

        // Update physics
        for (ball in balls) {
            ball.preUpdate(world, ball.x, ball.y, ball.width, ball.height, ball.rotation);
        }

        // Ball to ball collisions
        for (i in 0...balls.length) {
            for (j in i + 1...balls.length) {
                world.collide(balls[i], balls[j]);
            }
        }

        for (ball in balls) {
            ball.postUpdate(world);
        }
    }

    override public function render(ctx:CanvasRenderingContext2D):Void {
        for (i in 0...balls.length) {
            var hue = (i * 60) % 360;
            renderBody(ctx, balls[i], 'hsl($hue, 70%, 50%)');
        }
    }
}

// Test 2: Basic collision
class CollisionTest extends TestCase {
    var player:Body;
    var wall:Body;

    public function new(world:World) {
        super(world);
        name = "Basic Collision";
        description = "Use arrow keys to move the blue box. Red wall is immovable.";
    }

    override public function setup():Void {
        world.gravityY = 0;

        // Player
        player = new Body(100, 300, 48, 48);
        player.dragX = 200;
        player.dragY = 200;
        bodies.push(player);

        // Immovable wall
        wall = new Body(400, 200, 32, 200);
        wall.immovable = true;
        wall.allowGravity = false;
        bodies.push(wall);
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Player movement (Arrow keys)
        if (keys.get(37)) player.velocityX = -200; // Left arrow
        else if (keys.get(39)) player.velocityX = 200; // Right arrow

        if (keys.get(38)) player.velocityY = -200; // Up arrow
        else if (keys.get(40)) player.velocityY = 200; // Down arrow

        // Physics update
        player.preUpdate(world, player.x, player.y, player.width, player.height, player.rotation);
        wall.preUpdate(world, wall.x, wall.y, wall.width, wall.height, wall.rotation);

        world.collide(player, wall);

        player.postUpdate(world);
        wall.postUpdate(world);
    }

    override public function render(ctx:CanvasRenderingContext2D):Void {
        renderBody(ctx, player, "#4444ff");
        renderBody(ctx, wall, "#ff4444");
    }
}

// Test 3: Group collision
class GroupCollisionTest extends TestCase {
    var bullets:Group;
    var enemies:Group;
    var player:Body;
    var shootTimer:Float = 0;

    public function new(world:World) {
        super(world);
        name = "Group Collision";
        description = "Arrow keys to move, SPACE to shoot. Destroy all red enemies!";
    }

    override public function setup():Void {
        world.gravityY = 0;

        // Player
        player = new Body(400, 500, 32, 32);
        player.dragX = 300;
        bodies.push(player);

        // Groups
        bullets = new Group();
        enemies = new Group();
        groups.push(bullets);
        groups.push(enemies);

        // Create enemies
        for (i in 0...5) {
            for (j in 0...3) {
                var enemy = new Body(200 + i * 80, 50 + j * 60, 40, 40);
                enemy.immovable = true;
                enemy.allowGravity = false;
                bodies.push(enemy);
                enemies.add(enemy);
            }
        }
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        shootTimer -= delta;

        // Player movement
        if (keys.get(37)) player.velocityX = -300; // Left arrow
        else if (keys.get(39)) player.velocityX = 300; // Right arrow
        else player.velocityX = 0;

        if (keys.get(38)) player.velocityY = -300; // Up arrow
        else if (keys.get(40)) player.velocityY = 300; // Down arrow
        else player.velocityY = 0;

        // Shooting
        if (Test.isKeyPressed(" ") && shootTimer <= 0) { // Space
            var bullet = new Body(player.x + 12, player.y - 10, 8, 16);
            bullet.velocityY = -400;
            bodies.push(bullet);
            bullets.add(bullet);
            shootTimer = 0.2;
        }

        // Pre-update
        super.update(delta, keys, mouseX, mouseY, mouseDown);

        // Collisions
        world.overlap(bullets, enemies, function(bullet:Body, enemy:Body) {
            bullet.enable = false;
            enemy.enable = false;
            bullets.remove(bullet);
            enemies.remove(enemy);
        });

        // Remove off-screen bullets
        var toRemove = [];
        for (bullet in bullets.objects) {
            if (bullet.y < -50) {
                toRemove.push(bullet);
            }
        }
        for (bullet in toRemove) {
            bullet.enable = false;
            bullets.remove(bullet);
        }
    }

    override public function render(ctx:CanvasRenderingContext2D):Void {
        renderBody(ctx, player, "#4444ff");

        for (enemy in enemies.objects) {
            if (enemy.enable) {
                renderBody(ctx, enemy, "#ff4444");
            }
        }

        for (bullet in bullets.objects) {
            if (bullet.enable) {
                renderBody(ctx, bullet, "#ffff44");
            }
        }
    }
}

// Test 4: Circle collision
class CircleCollisionTest extends TestCase {
    var circles:Array<Body>;
    var rectangle:Body;

    public function new(world:World) {
        super(world);
        name = "Circle Collision";
        description = "Circles vs rectangles collision. Click to add circles.";
    }

    override public function setup():Void {
        world.gravityY = 300;
        circles = [];

        // Create ground rectangle
        rectangle = new Body(200, 400, 400, 40);
        rectangle.immovable = true;
        rectangle.allowGravity = false;
        bodies.push(rectangle);

        // Create some circles
        for (i in 0...3) {
            var circle = new Body(300 + i * 60, 100, 40, 40);
            circle.setCircle(20);
            circle.bounceY = 0.8;
            circle.bounceX = 0.8;
            circle.collideWorldBounds = true;
            bodies.push(circle);
            circles.push(circle);
        }
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Add circle on click
        if (mouseDown) {
            var circle = new Body(mouseX - 20, mouseY - 20, 40, 40);
            circle.setCircle(20);
            circle.bounceY = 0.7;
            circle.bounceX = 0.7;
            circle.velocityX = -50 + Math.random() * 100;
            circle.collideWorldBounds = true;
            bodies.push(circle);
            circles.push(circle);
        }

        // Pre-update
        for (body in bodies) {
            body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
        }

        // Collisions
        for (circle in circles) {
            world.collide(circle, rectangle);
        }

        for (i in 0...circles.length) {
            for (j in i + 1...circles.length) {
                world.collide(circles[i], circles[j]);
            }
        }

        // Post-update
        for (body in bodies) {
            body.postUpdate(world);
        }
    }
}

// Test 5: Platformer mechanics
class PlatformerTest extends TestCase {
    var player:Body;
    var platforms:Group;
    var onGround:Bool = false;

    public function new(world:World) {
        super(world);
        name = "Platformer Test";
        description = "Left/Right arrows to move, Up arrow to jump. Basic platformer mechanics.";
    }

    override public function setup():Void {
        world.gravityY = 1200;

        // Player
        player = new Body(100, 400, 32, 48);
        player.bounceY = 0;
        player.dragX = 800;
        player.collideWorldBounds = true;
        bodies.push(player);

        // Platforms
        platforms = new Group();
        groups.push(platforms);

        // Ground
        var ground = new Body(400, 550, 800, 50);
        ground.immovable = true;
        ground.allowGravity = false;
        bodies.push(ground);
        platforms.add(ground);

        // Floating platforms
        var plat1 = new Body(200, 400, 150, 20);
        plat1.immovable = true;
        plat1.allowGravity = false;
        bodies.push(plat1);
        platforms.add(plat1);

        var plat2 = new Body(450, 300, 150, 20);
        plat2.immovable = true;
        plat2.allowGravity = false;
        bodies.push(plat2);
        platforms.add(plat2);

        var plat3 = new Body(250, 200, 100, 20);
        plat3.immovable = true;
        plat3.allowGravity = false;
        bodies.push(plat3);
        platforms.add(plat3);
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Store previous ground state
        var wasOnGround = onGround;
        onGround = player.blockedDown;

        // Horizontal movement
        if (keys.get(37)) { // Left arrow
            player.velocityX = -200;
        } else if (keys.get(39)) { // Right arrow
            player.velocityX = 200;
        }

        // Jump
        if (keys.get(38) && onGround) { // Up arrow
            player.velocityY = -600;
        }

        // Pre-update
        player.preUpdate(world, player.x, player.y, player.width, player.height, player.rotation);
        for (platform in platforms.objects) {
            platform.preUpdate(world, platform.x, platform.y, platform.width, platform.height, platform.rotation);
        }

        // Collisions
        world.collide(player, platforms);

        // Post-update
        player.postUpdate(world);
        for (platform in platforms.objects) {
            platform.postUpdate(world);
        }
    }

    override public function render(ctx:CanvasRenderingContext2D):Void {
        // Render player with different color when on ground
        renderBody(ctx, player, onGround ? "#44ff44" : "#4444ff");

        // Render platforms
        for (platform in platforms.objects) {
            renderBody(ctx, platform, "#666666");
        }
    }
}

// Test 6: Angular motion
class AngularMotionTest extends TestCase {
    var spinners:Array<Body>;

    public function new(world:World) {
        super(world);
        name = "Angular Motion";
        description = "Rotating bodies with different angular velocities and drag.";
    }

    override public function setup():Void {
        world.gravityY = 0;
        spinners = [];

        // Create spinners with different properties
        for (i in 0...4) {
            var spinner = new Body(150 + i * 150, 300, 60, 60);
            spinner.angularVelocity = 30 + i * 60; // Different speeds
            spinner.angularDrag = i * 20; // Different drag
            spinner.immovable = true;
            spinner.allowGravity = false;
            bodies.push(spinner);
            spinners.push(spinner);
        }

        // Add some falling boxes
        for (i in 0...3) {
            var box = new Body(200 + i * 200, 100, 30, 30);
            box.velocityY = 100;
            box.bounceY = 0.8;
            box.bounceX = 0.8;
            box.collideWorldBounds = true;
            bodies.push(box);
        }
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Pre-update
        for (body in bodies) {
            body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
        }

        // Collisions between all bodies
        for (i in 0...bodies.length) {
            for (j in i + 1...bodies.length) {
                if (!bodies[i].immovable || !bodies[j].immovable) {
                    world.collide(bodies[i], bodies[j]);
                }
            }
        }

        // Post-update
        for (body in bodies) {
            body.postUpdate(world);
        }
    }
}

// Test 7: Velocity and drag
class VelocityDragTest extends TestCase {
    var dragBodies:Array<Body>;

    public function new(world:World) {
        super(world);
        name = "Velocity & Drag";
        description = "Bodies with different drag values. Click to launch a body.";
    }

    override public function setup():Void {
        world.gravityY = 0;
        dragBodies = [];

        // Create bodies with different drag
        for (i in 0...5) {
            var body = new Body(100, 100 + i * 80, 40, 40);
            body.velocityX = 400;
            body.dragX = i * 50; // 0, 50, 100, 150, 200
            body.collideWorldBounds = true;
            body.bounceX = 1;
            dragBodies.push(body);
            bodies.push(body);
        }
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Launch body on click
        if (mouseDown) {
            var body = new Body(50, mouseY, 30, 30);
            body.velocityX = 500;
            body.dragX = 100;
            body.collideWorldBounds = true;
            body.bounceX = 0.8;
            body.setCircle(15);
            bodies.push(body);
        }

        super.update(delta, keys, mouseX, mouseY, mouseDown);
    }

    override public function render(ctx:CanvasRenderingContext2D):Void {
        for (i in 0...bodies.length) {
            var color = "#ff00ff";
            for (j in 0...dragBodies.length) {
                if (bodies[i] == dragBodies[j]) {
                    color = 'hsl(${j * 60}, 70%, 50%)';
                    break;
                }
            }
            renderBody(ctx, bodies[i], color);
        }
    }
}

// Test 8: One-way platforms
class OneWayPlatformTest extends TestCase {
    var player:Body;
    var platforms:Group;

    public function new(world:World) {
        super(world);
        name = "One-Way Platforms";
        description = "Left/Right arrows to move, Up arrow to jump. Down arrow to drop through platforms.";
    }

    override public function setup():Void {
        world.gravityY = 800;

        // Player
        player = new Body(400, 100, 32, 48);
        player.dragX = 800;
        player.collideWorldBounds = true;
        bodies.push(player);

        // Platforms
        platforms = new Group();
        groups.push(platforms);

        // One-way platforms
        for (i in 0...4) {
            var plat = new Body(200 + (i % 2) * 200, 150 + i * 100, 200, 10);
            plat.immovable = true;
            plat.allowGravity = false;
            plat.data = { oneWay: true }; // Mark as one-way
            bodies.push(plat);
            platforms.add(plat);
        }
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        var onGround = player.blockedDown;

        // Movement
        if (keys.get(37)) player.velocityX = -200; // Left arrow
        else if (keys.get(39)) player.velocityX = 200; // Right arrow

        if (keys.get(38) && onGround) player.velocityY = -400; // Jump (Up arrow)

        var dropThrough = keys.get(40); // Drop through (Down arrow)

        // Pre-update
        player.preUpdate(world, player.x, player.y, player.width, player.height, player.rotation);
        for (platform in platforms.objects) {
            platform.preUpdate(world, platform.x, platform.y, platform.width, platform.height, platform.rotation);
        }

        // One-way platform collision
        world.collide(player, platforms, null, function(player:Body, platform:Body):Bool {
            // Only collide if player is above platform and moving down
            if (platform.data != null && platform.data.oneWay) {
                return player.y < platform.y && player.velocityY > 0 && !dropThrough;
            }
            return true;
        });

        // Post-update
        player.postUpdate(world);
        for (platform in platforms.objects) {
            platform.postUpdate(world);
        }
    }

    override public function render(ctx:CanvasRenderingContext2D):Void {
        renderBody(ctx, player, "#4444ff");

        // Render one-way platforms with dashed line
        for (platform in platforms.objects) {
            ctx.save();
            ctx.setLineDash([5, 5]);
            renderBody(ctx, platform, "#44ff44");
            ctx.restore();
        }
    }
}

// Test 9: QuadTree performance
class QuadTreeTest extends TestCase {
    var quadBodies:Array<Body>;
    var useQuadTree:Bool = true;
    var qPressed:Bool = false;

    public function new(world:World) {
        super(world);
        name = "QuadTree Performance";
        description = "Press Q to toggle QuadTree. Many objects collision test.";
    }

    override public function setup():Void {
        world.gravityY = 500;
        quadBodies = [];

        // Create many bodies
        for (i in 0...50) {
            var body = new Body(
                100 + Math.random() * 600,
                50 + Math.random() * 200,
                10 + Math.random() * 20,
                10 + Math.random() * 20
            );
            body.velocityX = -100 + Math.random() * 200;
            body.velocityY = -100 + Math.random() * 200;
            body.bounceX = 0.8;
            body.bounceY = 0.8;
            body.collideWorldBounds = true;
            quadBodies.push(body);
            bodies.push(body);
        }
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Toggle QuadTree - use proper toggle logic to prevent rapid switching
        if (Test.isKeyPressed("q") && !qPressed) {
            useQuadTree = !useQuadTree;
            world.skipQuadTree = !useQuadTree;
            qPressed = true;
        } else if (!Test.isKeyPressed("q")) {
            qPressed = false;
        }

        // Pre-update
        for (body in quadBodies) {
            body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
        }

        // Collision between all bodies
        var group = new Group();
        for (body in quadBodies) {
            group.add(body);
        }
        world.collide(group, group);

        // Post-update
        for (body in quadBodies) {
            body.postUpdate(world);
        }
    }

    override public function render(ctx:CanvasRenderingContext2D):Void {
        // Render bodies with color based on velocity
        for (body in quadBodies) {
            var speed = Math.sqrt(body.velocityX * body.velocityX + body.velocityY * body.velocityY);
            var hue = (speed / 3) % 360;
            renderBody(ctx, body, 'hsl($hue, 70%, 50%)');
        }

        // Show QuadTree status
        ctx.fillStyle = "#000";
        ctx.font = "16px Arial";
        ctx.fillText('QuadTree: ${useQuadTree ? "ON" : "OFF"} (Press Q to toggle)', 10, 30);
    }
}

// Test 10: Mass and collision
class MassCollisionTest extends TestCase {
    var heavyBody:Body;
    var lightBodies:Array<Body>;

    public function new(world:World) {
        super(world);
        name = "Mass Collision";
        description = "Heavy vs light bodies. Click to add light bodies.";
    }

    override public function setup():Void {
        world.gravityY = 300;
        lightBodies = [];

        // Heavy body
        heavyBody = new Body(400, 300, 80, 80);
        heavyBody.mass = 10;
        heavyBody.bounceX = 0.5;
        heavyBody.bounceY = 0.5;
        heavyBody.collideWorldBounds = true;
        heavyBody.velocityX = 100;
        bodies.push(heavyBody);

        // Light bodies
        for (i in 0...5) {
            var light = new Body(100 + i * 120, 100, 20, 20);
            light.mass = 0.1;
            light.bounceX = 0.8;
            light.bounceY = 0.8;
            light.collideWorldBounds = true;
            light.velocityX = -50 + Math.random() * 100;
            bodies.push(light);
            lightBodies.push(light);
        }
    }

    override public function update(delta:Float, keys:Map<Int, Bool>, mouseX:Float, mouseY:Float, mouseDown:Bool):Void {
        // Add light body on click
        if (mouseDown) {
            var light = new Body(mouseX - 10, mouseY - 10, 20, 20);
            light.mass = 0.1;
            light.bounceX = 0.8;
            light.bounceY = 0.8;
            light.velocityY = -200;
            light.collideWorldBounds = true;
            bodies.push(light);
            lightBodies.push(light);
        }

        // Pre-update
        for (body in bodies) {
            body.preUpdate(world, body.x, body.y, body.width, body.height, body.rotation);
        }

        // Collisions
        for (light in lightBodies) {
            world.collide(light, heavyBody);
        }

        for (i in 0...lightBodies.length) {
            for (j in i + 1...lightBodies.length) {
                world.collide(lightBodies[i], lightBodies[j]);
            }
        }

        // Post-update
        for (body in bodies) {
            body.postUpdate(world);
        }
    }

    override public function render(ctx:CanvasRenderingContext2D):Void {
        // Render heavy body
        renderBody(ctx, heavyBody, "#ff4444");

        // Add mass text
        ctx.fillStyle = "#fff";
        ctx.font = "12px Arial";
        ctx.fillText("10kg", heavyBody.x + 25, heavyBody.y + 45);

        // Render light bodies
        for (light in lightBodies) {
            renderBody(ctx, light, "#44ff44");
        }
    }
}