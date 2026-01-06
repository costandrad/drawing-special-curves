###############################################################################
# GENERIC CURVE TEMPLATE — Parametric / Polar Curves
# Using Luxor.jl
#
# Author:      Igo da Costa Andrade
# GitHub:      https://github.com/costandrad
# Repository:  https://github.com/costandrad/drawing-special-curves
#
# DESCRIPTION
#   Vertical-format animation (1080×1920) for visualizing
#   parametric or polar curves.
#
#   Structure:
#     1) Background, title and axes
#     2) Optional geometric construction / guides
#     3) Progressive curve tracing
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

const DURATION     = 10        # seconds
const FRAME_RATE   = 30
const TOTAL_FRAMES = DURATION * FRAME_RATE

const CURVE_NAME = "generic_curve"

###############################################################################
# COORDINATE SYSTEM
###############################################################################

const O = Point(0, 0)

###############################################################################
# CURVE PARAMETERS (EDIT FOR EACH CURVE)
###############################################################################

const SCALE = 0.35 * WIDTH     # global scale factor

###############################################################################
# MATHEMATICAL MODEL — CURVE DEFINITION
# -----------------------------------------------------------------------------
# Replace this function to define a new curve.
#
# PARAMETRIC EXAMPLE:
#   x(t), y(t)
#
# POLAR EXAMPLE:
#   r(t) → x = r cos t, y = r sin t
#
# IMPORTANT:
#   Luxor's y-axis is inverted (positive downwards),
#   so use y = -(...)
###############################################################################

function curve_model(t::Real)
    # -------------------------------
    # Example: Lissajous-like curve
    # -------------------------------
    x = SCALE * cos(2t)
    y = -SCALE * sin(3t)

    return Point(x, y)
end

###############################################################################
# SCENE 1 — BACKGROUND, TITLE AND AXES
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
        "Generic Curve",
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
         halign = :center)

    arrow(Point(0, 0.4WIDTH), Point(0, -0.4WIDTH),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{y}", Point(-45, -0.4WIDTH),
         halign = :center)
end

###############################################################################
# SCENE 2 — GEOMETRIC GUIDES / ANNOTATIONS (OPTIONAL)
###############################################################################

function draw_geometry(scene, frame)

    t = (2π / TOTAL_FRAMES) * frame
    P = curve_model(t)

    setcolor("white")
    setline(3)

    # Example guide: radius vector
    line(O, P, :stroke)
    circle(P, 8, :fill)

    # -------------------------------------------------------------------------
    # Descriptive text
    # -------------------------------------------------------------------------
    fontface("Open Sans")
    fontsize(46)

    text("Parametric / Polar Curve Visualization",
         Point(0, -0.34 * HEIGHT),
         halign = :center)

    text("The curve is traced as the parameter evolves.",
         Point(0, -0.30 * HEIGHT),
         halign = :center)

    # -------------------------------------------------------------------------
    # Equations (edit for each curve)
    # -------------------------------------------------------------------------
    fontface("Open Sans Extrabold")
    fontsize(40)

    text("Equations",
         Point(0, 0.27 * HEIGHT),
         halign = :center)

    text(L"\mathrm{x(t) = a\cos(2t)}",
         Point(0, 0.32 * HEIGHT),
         halign = :center)

    text(L"\mathrm{y(t) = a\sin(3t)}",
         Point(0, 0.35 * HEIGHT),
         halign = :center)
end

###############################################################################
# SCENE 3 — PROGRESSIVE CURVE TRACE
###############################################################################

function draw_curve(scene, frame)

    setline(5)

    for i in 2:frame
        setcolor(HSV(i % 360, 0.85, 1.0))

        t1 = (2π / TOTAL_FRAMES) * (i - 1)
        t2 = (2π / TOTAL_FRAMES) * i

        P1 = curve_model(t1)
        P2 = curve_model(t2)

        line(P1, P2, :stroke)
    end
end

###############################################################################
# ANIMATION SETUP AND EXPORT
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
