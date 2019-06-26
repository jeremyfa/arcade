package arcade;

class Point {

    public var x:Float = 0;
    public var y:Float = 0;

    public function new(x:Float, y:Float) {

        this.x = x;
        this.y = y;

    } //new

    inline public function setToPolar(azimuth:Float, radius:Float = 1, asDegrees:Bool = false):Void
    {

        if (asDegrees) { azimuth = degToRad(azimuth); }

        this.x = Math.cos(azimuth) * radius;
        this.y = Math.sin(azimuth) * radius;

    } //setToPolar

    inline static function degToRad(deg:Float):Float {
        return deg * 0.017453292519943295;
    }

} //Point