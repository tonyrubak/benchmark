import Formatting
const PI = 3.141592653589793
const SOLAR_MASS = 4. * PI * PI
const DAYS_PER_YEAR = 365.24
const num_bodies = 5
const fmt = "%.9f"

function run_sim(n)
    # Bodies is a 7x5 matrix
    # The columns represent each individual body
    # The rows represent the values
    # 1 = Sun
    # 2 = Jupiter
    # 3 = Saturn
    # 4 = Uranus
    # 5 = Neptune
    bodies = Array{Float64,2}(undef, 7, 5)
    bodies[:,1] = [0., 0., 0., 0., 0., 0., SOLAR_MASS]
    bodies[:,2] = [4.84143144246472090e+00,
                   -1.16032004402742839e+00,
                   -1.03622044471123109e-01,
                   1.66007664274403694e-03 * DAYS_PER_YEAR,
                   7.69901118419740425e-03 * DAYS_PER_YEAR,
                   -6.90460016972063023e-05 * DAYS_PER_YEAR,
                   9.54791938424326609e-04 * SOLAR_MASS]
    bodies[:,3] = [8.34336671824457987e+00,
                   4.12479856412430479e+00,
                   -4.03523417114321381e-01,
                   -2.76742510726862411e-03 * DAYS_PER_YEAR,
                   4.99852801234917238e-03 * DAYS_PER_YEAR,
                   2.30417297573763929e-05 * DAYS_PER_YEAR,
                   2.85885980666130812e-04 * SOLAR_MASS]
    bodies[:,4] = [1.28943695621391310e+01,
                   -1.51111514016986312e+01,
                   -2.23307578892655734e-01,
                   2.96460137564761618e-03 * DAYS_PER_YEAR,
                   2.37847173959480950e-03 * DAYS_PER_YEAR,
                   -2.96589568540237556e-05 * DAYS_PER_YEAR,
                   4.36624404335156298e-05 * SOLAR_MASS]
    bodies[:,5] = [1.53796971148509165e+01,
                   -2.59193146099879641e+01,
                   1.79258772950371181e-01,
                   2.68067772490389322e-03 * DAYS_PER_YEAR,
                   1.62824170038242295e-03 * DAYS_PER_YEAR,
                   -9.51592254519715870e-05 * DAYS_PER_YEAR,
                   5.15138902046611451e-05 * SOLAR_MASS]

    offset_momentum!(bodies)

    println(Formatting.sprintf1(fmt, energy(bodies)))
    for i in 1:n
        advance!(bodies, 0.01)
    end
    println(Formatting.sprintf1(fmt, energy(bodies)))
end

function offset_momentum!(bodies)
    px = py = pz = 0.
    for i in 1:num_bodies
        px += bodies[4,i] * bodies[7,i]
        py += bodies[5,i] * bodies[7,i]
        pz += bodies[6,i] * bodies[7,i]
    end
    bodies[4,1] = - px / SOLAR_MASS
    bodies[5,1] = - py / SOLAR_MASS
    bodies[6,1] = - pz / SOLAR_MASS
end

function advance!(bodies, dt)
    dx = dy = dz = 0.
    dsq = 0.
    dist = 0.
    mag = 0.
    for i in 1:num_bodies
        for j in i+1:num_bodies
            dx = bodies[1,i] - bodies[1,j]
            dy = bodies[2,i] - bodies[2,j]
            dz = bodies[3,i] - bodies[3,j]
            dsq = dx * dx + dy * dy + dz * dz
            dist = sqrt(dsq)
            mag = dt / (dsq * dist)

            bodies[4,i] = bodies[4,i] - dx * bodies[7,j] * mag
            bodies[5,i] = bodies[5,i] - dy * bodies[7,j] * mag
            bodies[6,i] = bodies[6,i] - dz * bodies[7,j] * mag
            bodies[4,j] = bodies[4,j] + dx * bodies[7,i] * mag
            bodies[5,j] = bodies[5,j] + dy * bodies[7,i] * mag
            bodies[6,j] = bodies[6,j] + dz * bodies[7,i] * mag
        end
    end
    for i in 1:num_bodies
        bodies[1,i] = bodies[1,i] + dt * bodies[4,i]
        bodies[2,i] = bodies[2,i] + dt * bodies[5,i]
        bodies[3,i] = bodies[3,i] + dt * bodies[6,i]
    end
end

function energy(bodies)
    dx = dy = dz = d = 0.
    e = 0.

    for i in 1:num_bodies
        e += 0.5 * bodies[7,i] * (bodies[4,i] * bodies[4,i] +
                                  bodies[5,i] * bodies[5,i] +
                                  bodies[6,i] * bodies[6,i])
        for j in i+1:num_bodies
            dx = bodies[1,i] - bodies[1,j]
            dy = bodies[2,i] - bodies[2,j]
            dz = bodies[3,i] - bodies[3,j]
            d = sqrt(dx * dx + dy * dy + dz * dz)
            e -= (bodies[7,i] * bodies[7,j]) / d
        end
    end
    e
end
