###############################################################################
# Cardioid — Epicycloid Construction Animation
# Using Luxor.jl
#
# Author:      Igo da Costa Andrade
# GitHub:      https://github.com/costandrad
# TikTok:      https://www.tiktok.com/@costandrad.pi
# Repository:  https://github.com/costandrad/drawing-special-curves
# Date:        2025-12-10
#
# DESCRIPTION
#   This script generates a vertical-format animation (1080×1920, suitable for
#   TikTok/Reels) illustrating the geometric construction of the **Cardioid**,
#   a one-cusped epicycloid.
#
#   The cardioid is obtained as the locus of a point on a circle of radius `a`
#   rolling *externally* around another circle of the same radius.
#
#   Visual flow:
#     1) Background and Cartesian axes
#     2) Epicycloid geometric construction
#     3) Progressive tracing of the cardioid curve
#
# LICENSE
#   MIT License
###############################################################################


using Luxor, Colors, Printf, MathTeXEngine

# ============================================================================
# GLOBAL SETTINGS — CANVAS, TIMING, NAMING
# ============================================================================

const WIDTH  = 1080
const HEIGHT = 1920

const DURATION   = 15        # seconds
const FRAME_RATE = 25        # frames per second
const TOTAL_FRAMES = DURATION * FRAME_RATE

const CURVE_NAME = "cardioid"

# ============================================================================
# GEOMETRIC PARAMETERS
# ============================================================================

R = 0.125 * WIDTH       # radius of the fixed circle

# ============================================================================
# MATHEMATICAL MODEL — HYPOCYCLOID
# ----------------------------------------------------------------------------
# Given:
#   R → radius of the fixed circle
#   R → radius of the rolling circle
#   t → parameter
#
# Returns:
#   C → center of the rolling circle
#   P → generating point of the astroid
# ============================================================================

function parametric_equations(R, t)
    # Center of the rolling circle
    xc = 2R * cos(t)
    yc = -(2R * sin(t))

    # Generating point on the rolling circle
    x = xc - R * cos(2t)
    y = yc + R * sin(2t)

    return Point(xc, yc), Point(x, y)
end

# ============================================================================
# SCENE 1 — BACKGROUND AND CARTESIAN AXES
# ============================================================================

function draw_backdrop(scene, frame)

    # Drawing defaults
    setcolor("white")
    setline(5)

    fontsize(50)
    fontface("Open Sans")

    # Background
    background("black")

    # ------------------------------------------------------------------------
    # Cartesian axes
    # ------------------------------------------------------------------------

    arrow(Point(-0.4 * WIDTH, 0), Point(0.4 * WIDTH, 0),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{x}",
         Point(0.4 * WIDTH, 50),
         halign = :center, valign = :center)

    arrow(Point(0, 0.4 * WIDTH), Point(0, -0.4 * WIDTH),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{y}",
         Point(-50, -0.4 * WIDTH),
         halign = :center, valign = :center)
end

# ============================================================================
# SCENE 2 — GEOMETRIC CONSTRUCTION AND ANNOTATIONS
# ============================================================================

function draw_geometry(scene, frame)
    t = (2π / TOTAL_FRAMES) * frame

    # Main geometric entities
    C, P = parametric_equations(R, t)
    T = Point(R * cos(t), -R * sin(t))   # contact point on the fixed circle

    # ------------------------------------------------------------------------
    # Title and descriptive text
    # ------------------------------------------------------------------------

    setfont("Open Sans Extrabold", 81)
    settext("Cardioid",
            Point(0, -0.4 * HEIGHT),
            halign = "center", valign = "center")

    setfont("Open Sans", 48)
    settext("The Cardioid is a one-cusped epicycloid:",
            Point(0, -0.35 * HEIGHT),
            halign = "center", valign = "center")

    settext("The locus of a point (P) on a circle rolling",
            Point(0, -0.31 * HEIGHT),
            halign = "center", valign = "center")

    settext("outside another with equal radius size.",
            Point(0, -0.27 * HEIGHT),
            halign = "center", valign = "center")


    fontsize(50)
    fontface("Open Sans")

    # ------------------------------------------------------------------------
    # Circles and auxiliary geometry
    # ------------------------------------------------------------------------

    circle(O, R, :stroke)     # fixed circle
    circle(C, R, :stroke)     # rolling circle
    circle(C, 8, :fill)       # center of rolling circle

    line(O, C, :stroke)       # radius of fixed circle
    line(C, P, :stroke)       # generating radius

    # Parameter label
    text(L"\mathrm{a}",
         Point(-R / 2, -15),
         halign = :center, valign = :center)

    # ------------------------------------------------------------------------
    # Key points
    # ------------------------------------------------------------------------

    
    setcolor("red")
    circle(T, 8, :fill)
    text(L"\mathrm{T}",
         Point(1.20 * T.x, 1.20 * T.y),
         halign = :center, valign = :center)
    setcolor("white")

    
    setcolor("blue")
    circle(P, 8, :fill)
    text(L"\mathrm{P}",
         Point(C.x - 1.20R * cos(2t),
               C.y + 1.20R * sin(2t)),
         halign = :center, valign = :center)
    setcolor("white")



    # ------------------------------------------------------------------------
    # Equations
    # ------------------------------------------------------------------------
    setfont("Open Sans Extrabold", 50)
    settext(
        "Parametric Equations",
        Point(0, 0.25 * HEIGHT),
        halign = "center", valign = "center"
    )
    text(L"\mathrm{x(t) = a\ (2 \cos\ t - \cos\ 2t)}",
         Point(0, 0.30 * HEIGHT),
         halign = :center, valign = :center)

    text(L"\mathrm{y(t) = a\ (2 \sin\ t - \sin\ 2t)}",
         Point(0, 0.33 * HEIGHT),
         halign = :center, valign = :center)
end

# ============================================================================
# SCENE 3 — PROGRESSIVE TRACE OF THE ASTROID
# ============================================================================

function draw_curve(scene, frame)
    for i in 1:frame
        setcolor(HSV(i, 1.0, 1.0))

        _, P1 = parametric_equations(R, (2π / TOTAL_FRAMES) * (i - 1))
        _, P2 = parametric_equations(R, (2π / TOTAL_FRAMES) * i)

        line(P1, P2, :stroke)
    end
end

# ============================================================================
# ANIMATION SETUP AND GIF EXPORT
# ============================================================================

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
        Scene(movie, draw_geometry, 1:TOTAL_FRAMES),
        Scene(movie, draw_curve,    1:TOTAL_FRAMES)
    ],
    creategif     = true,
    framerate     = FRAME_RATE,
    tempdirectory = frames_dir,
    pathname      = joinpath(
        pwd(),
        "$(CURVE_NAME)/outputs/$(CURVE_NAME).gif"
    )
)

# ============================================================================
# OPTIONAL MP4 EXPORT (requires ffmpeg)
# ============================================================================

mp4_path = joinpath(pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).mp4")

cmd = `ffmpeg -y -r $FRAME_RATE -i "$(frames_dir)/%10d.png" -c:v h264 -crf 0 "$(mp4_path)"`

println("\nGenerating MP4 using ffmpeg...\n")
println(cmd)

run(cmd)

println("\nMP4 generated at: $(mp4_path)")