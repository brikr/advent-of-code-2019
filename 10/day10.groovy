class Main {
    static void main(String[] args) {
        def asteroids = new LinkedList<Asteroid>()

        new File("input.txt").eachLine { line, y ->
            line.eachWithIndex { c, x ->
                if (c == '#') {
                    asteroids << new Asteroid(x: x, y: y - 1)
                }
            }
        }

        def counts = asteroids.collectEntries {
            [(it): it.countVisible(asteroids)]
        } as Map<Asteroid, Integer>
        def base = counts.max { it.value }
        println "Part 1: ${base.key} sees ${base.value} asteroids"

        def answer = base.key.get200thExploder(asteroids)
        println "Part 2: ${answer.x * 100 + answer.y}"
    }
}

class Asteroid {
    int x, y

    // Key: Delta, Value: Simplified delta (dx/dy simplified)
    private Map<Delta, Delta> buildDeltas(List<Asteroid> asteroids) {
        return asteroids.findResults { other ->
            if (other.x == this.x && other.y == this.y) {
                return null
            }
            int dx = other.x - this.x
            int dy = other.y - this.y
            return new Delta(dx: dx, dy: dy)
        }
        .collectEntries {[(it): it.getSimplified()]}
    }

    int countVisible(List<Asteroid> asteroids) {
        def deltas = this.buildDeltas(asteroids)
        return new ArrayList(deltas.values()).unique().size()
    }

    Asteroid get200thExploder(List<Asteroid> asteroids) {
        def deltas = this.buildDeltas(asteroids).keySet().sort { a, b ->
            float aDeg = a.getDegrees()
            float bDeg = b.getDegrees()
            if (aDeg > bDeg) {
                return 1
            } else if (aDeg < bDeg) {
                return -1
            } else {
                // Closer element should be sorted first. Safe to use Manhattan distance since the angle is equal
                int aDist = Math.abs(a.dx) + Math.abs(a.dy)
                int bDist = Math.abs(b.dx) + Math.abs(b.dy)
                return aDist <=> bDist
            }
        }
        def lastDelta = null as Delta
        int idx = 0
        int explodeCount = 0
        while (explodeCount < 200) {
            if (deltas[idx].getDegrees() == lastDelta?.getDegrees()) {
                // This asteroid was behind the one we just blew up. Move until we find one that is slightly CW from here.
                idx = (idx + 1) % deltas.size()
                continue
            }
            // Blow it up. Don't increment idx since we are at the index of the following element now.
            lastDelta = deltas.remove(idx)
            idx = idx % deltas.size()
            explodeCount++
        }
        return new Asteroid(x: this.x + lastDelta.dx, y: this.y + lastDelta.dy)
    }

    String toString() {
        return "${x},${y}"
    }
}

class Delta {
    int dx, dy

    static int gcd(int a, int b) {
        if (b == 0) {
            return a
        } else {
            return gcd(b, a % b)
        }
    }

    Delta getSimplified() {
        if (this.dx == 0) {
            return new Delta(dx: 0, dy: this.dy / Math.abs(this.dy))
        } else if (this.dy == 0) {
            return new Delta(dx: this.dx / Math.abs(this.dx), dy: 0)
        }

        int d = Math.abs(gcd(this.dx, this.dy))

        return new Delta(dx: this.dx / d, dy: this.dy / d)
    }

    // Straight up is zero, increasing clockwise
    float getDegrees() {
        // These values have zero at 3 o' clock, increasing cw, decreasing ccw
        def rad = Math.atan2(this.dy, this.dx)
        def deg = rad * (180 / Math.PI)

        // Convert to 0-360, 9 o' clock is zero
        deg += 180
        // Convert to noon is zero
        deg -= 90

        if (deg < 0) deg += 360

        return deg % 360
    }

    String toString() {
        return "${dx},${dy} (${this.getDegrees()})"
    }

    boolean equals(Object o) {
        Delta d = (Delta) o
        return d.dx == this.dx && d.dy == this.dy
    }
}
