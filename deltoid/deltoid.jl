###############################################################################
# Deltoid — Hypocycloid Construction Animation
# Using Luxor.jl
#
# Author:      Igo da Costa Andrade
# GitHub:      https://github.com/costandrad
# TikTok:      https://www.tiktok.com/@costandrad.pi
# Repository:  https://github.com/costandrad/drawing-special-curves
# Date:        2025-12-10
#
# DESCRIPTION
#   Generates a vertical-format animation (1080×1920, TikTok/Reels friendly)
#   illustrating the geometric construction of the **Deltoid**,
#   a three-cusped hypocycloid.
#
#   Visual flow:
#     1) Background, title and Cartesian axes
#     2) Hypocycloid geometric construction
#     3) Progressive tracing of the deltoid curve
#
# LICENSE
#   MIT License
###############################################################################

using Luxor
using Colors
using Printf
using MathTeXEngine

###############################################################################
# GLOBAL SETTINGS — CANVAS, TIMING, NAMING
###############################################################################

const WIDTH  = 1080
const HEIGHT = 1920

const DURATION     = 10          # seconds
const FRAME_RATE   = 30          # frames per second
const TOTAL_FRAMES = DURATION * FRAME_RATE

const CURVE_NAME = "deltoid"

###############################################################################
# GEOMETRIC PARAMETERS
###############################################################################

const R = 0.35 * WIDTH     # radius of the fixed circle
const r = R / 3           # radius of the rolling circle (R = 3r)

const O = Point(0, 0)     # origin

###############################################################################
# MATHEMATICAL MODEL — HYPOCYCLOID
# -----------------------------------------------------------------------------
# Given:
#   R → radius of the fixed circle
#   r → radius of the rolling circle
#   t → parameter
#
# Returns:
#   C → center of the rolling circle
#   P → generating point (Deltoid)
#
# Note:
#   The negative sign in y-coordinates accounts for Luxor's coordinate system
#   (positive y-axis pointing downwards).
###############################################################################

function hypocycloid(R::Real, r::Real, t::Real)
    # Center of the rolling circle
    xc = (R - r) * cos(t)
    yc = -(R - r) * sin(t)

    # Generating point on the rolling circle
    x = xc + r * cos(((R - r) / r) * t)
    y = yc + r * sin(((R - r) / r) * t)

    return Point(xc, yc), Point(x, y)
end

###############################################################################
# SCENE 1 — BACKGROUND, TITLE AND CARTESIAN AXES
###############################################################################

function draw_backdrop(scene, frame)

    background("gray10")
    setcolor("white")
    setline(5)

    # -------------------------------------------------------------------------
    # Title
    # -------------------------------------------------------------------------
    fontface("Open Sans Extrabold")
    fontsize(80)

    text(
        "Deltoid",
        Point(0, -0.42 * HEIGHT),
        halign = :center,
        valign = :center
    )

    # -------------------------------------------------------------------------
    # Cartesian axes
    # -------------------------------------------------------------------------
    fontface("Open Sans")
    fontsize(42)

    arrow(Point(-0.4WIDTH, 0), Point(0.4WIDTH, 0),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{x}", Point(0.4WIDTH, 45),
         halign = :center, valign = :center)

    arrow(Point(0, 0.4WIDTH), Point(0, -0.4WIDTH),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{y}", Point(-45, -0.4WIDTH),
         halign = :center, valign = :center)
end

###############################################################################
# SCENE 2 — GEOMETRIC CONSTRUCTION AND ANNOTATIONS
###############################################################################

function draw_geometry(scene, frame)

    t = (2π / TOTAL_FRAMES) * frame

    # Main geometric entities
    C, P = hypocycloid(R, r, t)
    T = Point(R * cos(t), -R * sin(t))   # contact point

    setcolor("white")
    fontsize(44)
    fontface("Open Sans")

    # -------------------------------------------------------------------------
    # Circles
    # -------------------------------------------------------------------------
    circle(O, R, :stroke)     # fixed circle
    circle(C, r, :stroke)     # rolling circle

    circle(C, 8, :fill)       # center of rolling circle
    circle(T, 8, :fill)       # contact point
    circle(P, 8, :fill)       # generating point

    # Radii and auxiliary lines
    line(O, T, :stroke)
    line(T, P, :stroke)

    # -------------------------------------------------------------------------
    # Labels
    # -------------------------------------------------------------------------
    text(L"\mathrm{T}",
         Point(1.05R * cos(t), -1.05R * sin(t)),
         halign = :center, valign = :bottom)

    text(L"\mathrm{P}",
         Point(P.x + 30, P.y - 30),
         halign = :center, valign = :center)

    text(L"\mathrm{a}",
         Point(5R/6 * cos(t - π/36), -5R/6 * sin(t - π/36)),
         halign = :center, valign = :center)

    text(L"\mathrm{3a}",
         Point(-R/2, - 30),
         halign = :center, valign = :center)

    # -------------------------------------------------------------------------
    # Descriptive text
    # -------------------------------------------------------------------------
    fontface("Open Sans")
    fontsize(46)

    if frame < TOTAL_FRAMES ÷ 2
        text("The Deltoid is a three-cusped hypocycloid:",
             Point(0, -0.34 * HEIGHT), halign = :center)

        text("The locus of a point on a circle rolling",
             Point(0, -0.30 * HEIGHT), halign = :center)

        text("inside another with three times its radius.",
             Point(0, -0.26 * HEIGHT), halign = :center)
    else
        text("It is generated by tracking a fixed point",
             Point(0, -0.34 * HEIGHT), halign = :center)

        text("as the smaller circle rolls",
             Point(0, -0.30 * HEIGHT), halign = :center)

        text("inside the larger one.",
             Point(0, -0.26 * HEIGHT), halign = :center)
    end

    # -------------------------------------------------------------------------
    # Parametric equations
    # -------------------------------------------------------------------------
    fontface("Open Sans Extrabold")
    fontsize(40)

    text("Parametric Equations",
         Point(0, 0.27 * HEIGHT),
         halign = :center)

    text(L"\mathrm{x(t) = a\,(2\cos\ t + \cos\ 2t)}",
         Point(0, 0.32 * HEIGHT),
         halign = :center)

    text(L"\mathrm{y(t) = a\,(2\sin\ t - \sin\ 2t)}",
         Point(0, 0.35 * HEIGHT),
         halign = :center)
end

###############################################################################
# SCENE 3 — PROGRESSIVE TRACE OF THE DELTOID
###############################################################################

function draw_curve(scene, frame)

    setline(5)

    for i in 1:frame
        setcolor(HSV(i % 360, 0.85, 1.0))

        _, P1 = hypocycloid(R, r, (2π / TOTAL_FRAMES) * (i - 1))
        _, P2 = hypocycloid(R, r, (2π / TOTAL_FRAMES) * i)

        line(P1, P2, :stroke)
    end
end

###############################################################################
# ANIMATION SETUP AND GIF EXPORT
###############################################################################

movie = Movie(WIDTH, HEIGHT, CURVE_NAME, 1:TOTAL_FRAMES)

frames_dir = joinpath(pwd(), "$(CURVE_NAME)/outputs/frames")

if isdir(frames_dir)
    rm(frames_dir; force = true, recursive = true)
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

###############################################################################
# OPTIONAL MP4 EXPORT (requires ffmpeg)
###############################################################################

mp4_path = joinpath(pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).mp4")

cmd = `ffmpeg -y -r $FRAME_RATE -i "$(frames_dir)/%10d.png" -c:v h264 -crf 0 "$(mp4_path)"`

println("\nGenerating MP4 using ffmpeg...\n")
run(cmd)

println("\nMP4 generated at: $(mp4_path)")
