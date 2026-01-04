
using Luxor, Colors, Printf, MathTeXEngine

const WIDTH  = 1080
const HEIGHT = 1920

const DURATION   = 15        # seconds
const FRAME_RATE = 60        # frames per second
const TOTAL_FRAMES = DURATION * FRAME_RATE

const CURVE_NAME = "butterfly_curve"

function butterfly(θ) 
    r = (WIDTH/10) * (exp(sin(θ)) - 2 * cos(4θ) - (sin((2θ - π)/24))^5)
    x = r * cos(θ)
    y = -r * sin(θ)
    return Point(x, y)
end


# @draw begin
#     dt = 12π/10001
#     for i in 0:10000
#         t1 = dt * i
#         t2 = t1 + dt
#         p1, p2 = butterfly(t1), butterfly(t2)
#         setcolor(HSV(i, 0.5, 1.0))
#         line(p1, p2, :stroke)
#     end
# end

function draw_backdrop(scene, frame)
    background("gray10")

    setcolor("white")
    setline(5)
    fontsize(60)
    fontface("Open Sans Extrabold")

    text(
        "Butterfly Curve",
        Point(0, -HEIGHT/3),
        halign=:center, valign=:center
    )

    fontface("Open Sans")
    fontsize(45)
    text(
        "The butterfly curve is a transcendental plane",
        Point(0, -HEIGHT/3 + 100),
        halign=:center, valign=:center
    )
    text(
        "curve discovered by Temple H. Fay in 1989.",
        Point(0, -HEIGHT/3 + 160),
        halign=:center, valign=:center
    )

    
    if frame < TOTAL_FRAMES/2
        fontface("Open Sans Extrabold")
        text(
            "Parametric Equations",
            Point(0, HEIGHT/5),
            halign=:center, valign=:center
        )
        text(
            L"\mathrm{x(t) = \sin\ t \ \left(e^{\cos\ t} \ - 2\ \cos\ 4t \ - \sin^5 \ \left(t/12\right)\right)}",
            Point(0, HEIGHT/5 + 100),
            halign=:center, valign=:center
        )
        text(
            L"\mathrm{y(t) = \cos\ t \ \left(e^{\cos\ t}\ - 2\ \cos\ 4t \ - \sin^5 \ \left(t/12\right)\right)}",
            Point(0, HEIGHT/5 + 160),
            halign=:center, valign=:center
        )
        # text(
        #     L"\mathrm{0 $(≤) t $(≤) 12\pi}",
        #     Point(0, HEIGHT/5 + 220),
        #     halign=:center, valign=:center
        # )
    else 
        fontface("Open Sans Extrabold")
        text(
            "Polar Equation",
            Point(0, HEIGHT/5),
            halign=:center, valign=:center
        )
        text(
            L"\mathrm{r(\theta) = e^{\sin\ \theta}\ - 2\ cos\ 4 \theta \ + \sin^5\left(\frac{2\theta - \pi}{24}\right)}",
            Point(0, HEIGHT/5 + 100),
            halign=:center, valign=:center
        )
    end

    arrow(
        Point(-0.4 * WIDTH, 0), Point(0.4 * WIDTH, 0),
        linewidth = 5,
        arrowheadlength = 25
    )
    text(L"\mathrm{x}",
         Point(0.4 * WIDTH, 50),
         halign = :center, valign = :center)

    arrow(
        Point(0, 0.3 * WIDTH), Point(0, -0.4 * WIDTH),
        linewidth = 5,
        arrowheadlength = 25
    )
    text(L"\mathrm{y}",
         Point(-50, -0.4 * WIDTH + 25),
         halign = :center, valign = :center)
end

function draw_pattern(scene, frame)
    dθ = 12π/(TOTAL_FRAMES)
    for i in 1:frame
        θ₁ = dθ * (i - 1)
        θ₂ = dθ * i
        P1, P2 = butterfly(θ₁), butterfly(θ₂)
        setcolor(HSV(rad2deg(θ₁), 0.5, 1.0))
        line(P1, P2, :stroke)
    end
end

movie = Movie(WIDTH, HEIGHT, CURVE_NAME, 1:TOTAL_FRAMES)

frames_dir = joinpath(pwd(), "$(CURVE_NAME)/outputs/frames")
if isdir(frames_dir)
    rm(frames_dir; force=true, recursive=true)
end
mkdir(frames_dir)

animate(
    movie,
    [
        Scene(movie, draw_backdrop, 1:TOTAL_FRAMES),
        Scene(movie, draw_pattern, 1:TOTAL_FRAMES)
    ],
    creategif       = true,
    framerate       = FRAME_RATE,
    tempdirectory   = frames_dir,
    pathname        = joinpath(
        pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).gif"
    )
)

mp4_path = joinpath(pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).mp4")

cmd = `ffmpeg -y -r $FRAME_RATE -i "$(frames_dir)/%10d.png" -c:v h264 -crf 0 "$(mp4_path)"`

println("\nGenerating MP4 using ffmpeg...\n")
println(cmd)

run(cmd)

println("\nMP4 generated at: $(mp4_path)")