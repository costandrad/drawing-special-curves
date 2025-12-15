###############################################################################
# Astroid — Hypocycloid Construction Animation
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
#   TikTok/Reels) illustrating the geometric construction of the **Astroid**,
#   a four-cusped hypocycloid.
#
#   Visual flow:
#     1) Background and Cartesian axes
#     2) Hypocycloid geometric construction
#     3) Progressive tracing of the astroid curve
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

const CURVE_NAME = "astroid"

# ============================================================================
# GEOMETRIC PARAMETERS
# ============================================================================

R = 0.35 * WIDTH       # radius of the fixed circle
r = R / 4             # radius of the rolling circle

# ============================================================================
# MATHEMATICAL MODEL — HYPOCYCLOID
# ----------------------------------------------------------------------------
# Given:
#   R → radius of the fixed circle
#   r → radius of the rolling circle
#   t → parameter
#
# Returns:
#   C → center of the rolling circle
#   P → generating point of the astroid
# ============================================================================

function hypocycloid(R, r, t)
    # Center of the rolling circle
    xc = (R - r) * cos(t)
    yc = -(R - r) * sin(t)

    # Generating point on the rolling circle
    x = xc + r * cos(((R - r) / r) * t)
    y = yc + r * sin(((R - r) / r) * t)

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
    background("grey10")

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
    C, P = hypocycloid(R, r, t)
    T = Point(R * cos(t), -R * sin(t))   # contact point on the fixed circle

    fontsize(50)
    fontface("Open Sans")

    # ------------------------------------------------------------------------
    # Key points
    # ------------------------------------------------------------------------

    circle(T, 8, :fill)
    text(L"\mathrm{T}",
         Point(1.05R * cos(t), -1.05R * sin(t)),
         halign = :center, valign = :center)

    circle(P, 8, :fill)
    text(L"\mathrm{P}",
         Point((R - r) * cos(t) + 1.20r * cos(((R - r) / r) * t),
               -(R - r) * sin(t) + 1.20r * sin(((R - r) / r) * t)),
         halign = :center, valign = :center)

    # ------------------------------------------------------------------------
    # Circles and auxiliary geometry
    # ------------------------------------------------------------------------

    circle(O, R, :stroke)     # fixed circle
    circle(C, r, :stroke)     # rolling circle
    circle(C, 8, :fill)       # center of rolling circle

    line(O, T, :stroke)       # radius of fixed circle
    line(T, P, :stroke)       # generating radius

    # Parameter label
    text(L"\mathrm{a}",
         Point(-R / 2, -25),
         halign = :center, valign = :center)

    # ------------------------------------------------------------------------
    # Title and descriptive text
    # ------------------------------------------------------------------------

    setfont("Open Sans Extrabold", 81)
    settext("Astroid",
            Point(0, -0.4 * HEIGHT),
            halign = "center", valign = "center")

    setfont("Open Sans", 48)
    settext("The Astroid is a four-cusped hypocycloid:",
            Point(0, -0.35 * HEIGHT),
            halign = "center", valign = "center")

    settext("The locus of a point (P) on a circle rolling",
            Point(0, -0.31 * HEIGHT),
            halign = "center", valign = "center")

    settext("inside another with four times its radius.",
            Point(0, -0.27 * HEIGHT),
            halign = "center", valign = "center")

    # ------------------------------------------------------------------------
    # Parametric equations
    # ------------------------------------------------------------------------

    text(L"\mathrm{x(t) = a\ \cos^3(t)}",
         Point(0, 0.25 * HEIGHT),
         halign = :center, valign = :center)

    text(L"\mathrm{y(t) = a\ \sin^3(t)}",
         Point(0, 0.30 * HEIGHT),
         halign = :center, valign = :center)
end

# ============================================================================
# SCENE 3 — PROGRESSIVE TRACE OF THE ASTROID
# ============================================================================

function draw_curve(scene, frame)
    for i in 1:frame
        setcolor(HSV(i, 1.0, 1.0))

        _, P1 = hypocycloid(R, r, (2π / TOTAL_FRAMES) * (i - 1))
        _, P2 = hypocycloid(R, r, (2π / TOTAL_FRAMES) * i)

        line(P1, P2, :stroke)
    end
end

# ============================================================================
# ANIMATION SETUP AND GIF EXPORT
# ============================================================================

movie = Movie(WIDTH, HEIGHT, CURVE_NAME, 1:TOTAL_FRAMES)

frames_dir = joinpath(pwd(), "$(CURVE_NAME)/outputs/frames")

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
