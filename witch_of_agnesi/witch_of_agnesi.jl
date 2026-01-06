###############################################################################
# Witch of Agnesi — Construction Animation
# Using Luxor.jl
#
# Author:      Igo da Costa Andrade
# GitHub:      https://github.com/costandrad
# Repository:  https://github.com/costandrad/drawing-special-curves
#
# DESCRIPTION
#   Vertical-format animation (1080×1920)
#   illustrating the geometric construction and
#   progressive tracing of the Witch of Agnesi.
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

const DURATION     = 10
const FRAME_RATE   = 30
const TOTAL_FRAMES = DURATION * FRAME_RATE

const CURVE_NAME = "witch_of_agnesi"

###############################################################################
# COORDINATE SYSTEM AND SCALE
###############################################################################

const O = Point(0, 0)

const SCALE_X = 0.45 * WIDTH
const SCALE_Y = 0.30 * WIDTH

###############################################################################
# CURVE PARAMETERS
###############################################################################

const a = 0.4 * SCALE_Y

const θ_min =  π / 3
const θ_max = -π / 3
const dθ    = (θ_max - θ_min) / TOTAL_FRAMES

###############################################################################
# MATHEMATICAL MODEL — WITCH OF AGNESI
# -----------------------------------------------------------------------------
# Classical geometric construction based on tangents.
#
# Returns:
#   A → point on auxiliary circle
#   N → intersection with horizontal line
#   P → point on the curve
###############################################################################

function curve_construction(θ::Real)
    A = Point(a * sin(2θ), -2a * cos(θ)^2)
    N = Point(2a * tan(θ), -2a)
    P = Point(N.x, A.y)
    return A, N, P
end

###############################################################################
# CURVE MODEL — POINT ON THE CURVE
###############################################################################

function witch_of_agnesi(θ::Real)
    _, _, P = curve_construction(θ)
    return P
end

###############################################################################
# PRECOMPUTED CURVE POINTS
###############################################################################

curve_points = [
    witch_of_agnesi(θ)
    for θ in θ_min:dθ:θ_max
]

###############################################################################
# SCENE 1 — BACKGROUND, TITLE AND AXES
###############################################################################

function draw_backdrop(scene, frame)

    background("gray13")
    setcolor("white")
    setline(5)

    # -------------------------------------------------------------------------
    # Title
    # -------------------------------------------------------------------------
    fontface("Open Sans Extrabold")
    fontsize(60)

    text("Witch of Agnesi",
         Point(0, -0.3 * HEIGHT),
         halign = :center)

    # -------------------------------------------------------------------------
    # Descriptive text
    # -------------------------------------------------------------------------
    fontsize(38)
    fontface("Open Sans")

    if frame < TOTAL_FRAMES ÷ 2
        text("Plane curve studied by Fermat, Grandi and Newton,",
            Point(0, -0.25 * HEIGHT),
            halign = :center)

        text("popularized by Maria Gaetana Agnesi (1748). It is a",
            Point(0, -0.22 * HEIGHT),
            halign = :center)

        text("rational algebraic curve with a horizontal asymptote.",
            Point(0, -0.19 * HEIGHT),
            halign = :center)
    else
        text("Its name arose from a mistranslation of",
            Point(0, -0.25 * HEIGHT),
            halign = :center)

        text("the Italian word 'versoria' which",
            Point(0, -0.22 * HEIGHT),
            halign = :center)

        text("refers to a turning line used in navigation",
            Point(0, -0.19 * HEIGHT),
            halign = :center)
    end

    # -------------------------------------------------------------------------
    # Cartesian axes
    # -------------------------------------------------------------------------

    fontsize(40)
    arrow(Point(-SCALE_X, 0), Point(SCALE_X, 0),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{x}", Point(SCALE_X - 20, 40),
         halign = :center, valign = :center)

    arrow(Point(0, 0.2SCALE_Y), Point(0, -SCALE_Y),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{y}", Point(-40, -SCALE_Y),
         halign = :center, valign = :center)

    # -------------------------------------------------------------------------
    # Parametric equations
    # -------------------------------------------------------------------------
    fontface("Open Sans Extrabold")
    fontsize(40)

    if frame < TOTAL_FRAMES ÷ 2
        text("Cartesian Equation",
            Point(0, 0.10 * HEIGHT),
            halign = :center)

        text(L"\mathrm{y = \frac{8a^3}{x^2 + 4a^2}}",
            Point(0, 0.15 * HEIGHT),
            halign = :center)

    else
        text("Parametric Equations",
            Point(0, 0.10 * HEIGHT),
            halign = :center)

        text(L"\mathrm{x(\theta) = 2a\ \tan\ \theta}",
            Point(0, 0.15 * HEIGHT),
            halign = :center)

        text(L"\mathrm{y(t) = 2a\ \cos^2\ \theta}",
            Point(0, 0.19 * HEIGHT),
            halign = :center)
    end
end

###############################################################################
# SCENE 2 — GEOMETRIC CONSTRUCTION AND ANNOTATIONS
###############################################################################

function draw_geometry(scene, frame)

    θ = θ_min + dθ * frame
    A, N, P = curve_construction(θ)

    O = Point(0, 0)
    M = Point(0, -2a)

    setline(5)
    fontface("Open Sans")
    fontsize(40)

    # -------------------------------------------------------------------------
    # Geometric guides
    # -------------------------------------------------------------------------
    setcolor("gray")

    circle(Point(0, -a), a, :stroke)                 # auxiliary circle
    line(Point(-SCALE_X, -2a), Point(SCALE_X, -2a))  # horizontal line
    line(O, N, :stroke)
    line(A, P, :stroke)
    line(N, Point(N.x, 0), :stroke)

    # -------------------------------------------------------------------------
    # Key points
    # -------------------------------------------------------------------------
    setcolor("white")
    foreach(p -> circle(p, 8, :fill), [O, M, A, N, P])

    text(L"O", O + Point(-50, 50))
    text(L"M", M + Point(-50, -10))
    text(L"A", A + Point(-50, 0))
    text(L"N", N + Point(-50, -10))
    text(L"P", P + Point(20, -5))

    # -------------------------------------------------------------------------
    # Progressive curve trace
    # -------------------------------------------------------------------------
    for i in 2:min(frame, length(curve_points))
        setcolor(HSV(i % 360, 0.65, 1.0))
        line(curve_points[i-1], curve_points[i], :stroke)
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
        Scene(movie, draw_geometry, 1:TOTAL_FRAMES)
    ],
    creategif     = true,
    framerate     = FRAME_RATE,
    tempdirectory = frames_dir,
    pathname      = joinpath(
        pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).gif"
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
