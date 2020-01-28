package arcade;

class Line {

    public var x1:Float = 0;
    public var y1:Float = 0;
    public var x2:Float = 0;
    public var y2:Float = 0;

    public function new(x1:Float, y1:Float, x2:Float, y2:Float) {

        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;

    }

    inline public function length():Float {

        return Math.sqrt((this.x2 - this.x1) * (this.x2 - this.x1) + (this.y2 - this.y1) * (this.y2 - this.y1));

    }

    inline public function fromAngle(x:Float, y:Float, angle:Float, length:Float):Void
    {

        this.x1 = x;
        this.y1 = y;
        this.x2 = x + (Math.cos(angle) * length);
        this.y2 = y + (Math.sin(angle) * length);

    }

} //Line