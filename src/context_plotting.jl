"""
### abstract type AbstractContext <: Toolips.Modifier
AbstractContexts are `Modifiers` that can be used to draw inside of a given frame.
These contexts can be drawn on using the `draw!` method and keep track of
different elements inside of the Context.
##### Consistencies
- window::Component{<Any}
- uuid::String
- dim::Pair{Int64, Int64}
- margin::Pair{Int64, Int64}
"""
abstract type AbstractContext <: Toolips.Modifier end

"""
### Context <: AbstractContext
- window::Component{:svg}
- uuid::String
- dim::Int64{Int64, Int64}
- margin::Pair{Int64, Int64}

The `Context` can be used with the `draw!` method in order to create and
draw SVG layers in with scaling functions.
##### example
```
using Contexts

con = Context()
line!(con, [5, 1, 2], [7, 34, 5], "stroke" => "red", "stroke-width" => "10")
display(con)
```
------------------
##### constructors
- Context(::Component{:svg}, margin::Pair{Int64, Int64})
- Context(width::Int64 = 1280, height::Int64 = 720, margin::Pair{Int64, Int64} = 0 => 0)
    """
mutable struct Context <: AbstractContext
    window::Component{:svg}
    uuid::String
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(wind::Component{:svg}, margin::Pair{Int64, Int64}) = begin
        new(wind, randstring(), wind[:width] => wind[:height],
            margin)::Context
    end
    Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:svg} = svg("window", width = width,
        height = height)
        Context(window, margin)::Context
    end
end

write!(c::Toolips.AbstractConnection, con::AbstractContext) = write!(c,
con.window)

function context(f::Function, width::Int64 = 1280, height::Int64= 720, margin::Pair{Int64, Int64} = 1 => 1)
    con = Context(width. height, margin)
    f(con)
    con::Context
end

function context(f::Function, con::Context, width::Int64 = 1280, height::Int64= 720, margin::Pair{Int64, Int64} = 1 => 1)
    con = Context(con.windowwidth. height, margin)
    f(con)
    con::Context
end

function move_layer!(con::Context, layer::String, to::Int64)
    layerpos = findfirster(comp -> comp.name == layer, con.window[:children])
    layercomp::AbstractComponent = con.window[:children][layer]
    deleteat!(con.window[:children], layerpos)
    insert!(con.window[:children], to, layercomp)
end

function show(io::IO, con::AbstractContext)
    display(MIME"text/html"(), con.window)
end

function show(io::Base.TTY, con::AbstractContext)
    println(io, "Context ($(con.dim[1]) x $(con.dim[2]))")
end

getindex(con::AbstractContext, str::String) = con.window[:children][str]

layers(con::AbstractContext) = [e => comp.name for (e, com) in enumerate(con.window[:children])]

function draw!(c::AbstractContext, comps::Vector{<:Servable})
    current_len::Int64 = length(c.window[:children])
    comp_len::Int64 = length(comps)
    c.window[:children] = Vector{Servable}(vcat(c.window[:children], comps))
    nothing
end

function style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)
    [style!(c, spairs ...) for c in con.window[:children][s][:children]]
    nothing
end

function style!(con::AbstractContext, spairs::Pair{String, String} ...)
    style!(con.window, spairs ...)
    nothing
end

mutable struct Group <: AbstractContext
    window::Component{:g}
    uuid::String
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Group(name::String = randstring(), width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:g} = ToolipsSVG.g("$name", width = width, height = height)
        new(window, name, width => height, margin)
    end
end

function group(f::Function, c::Context, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin)
    gr = Group("n", w, h, margin)
    f(gr)
    draw!(c, [child for child in gr.window[:children]])
end

function group!(f::Function, c::AbstractContext, name::String, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin)
    gr = Group(name, w, h, margin)
    f(gr)
    draw!(c, [gr.window])
end

function line!(con::AbstractContext, first::Pair{<:Number, <:Number},
    second::Pair{<:Number, <:Number}, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    ln = ToolipsSVG.line(randstring(), x1 = first[1], y1 = first[2],
    x2 = second[1], y2 = second[2])
    style!(ln, styles ...)
    draw!(con, [ln])
end

function text!(con::AbstractContext, x::Int64, y::Int64, text::String, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 13pt)
    end
    t = ToolipsSVG.text(randstring(), x = x, y = y, text = text)
    style!(t, styles ...)
    draw!(con, [t])
end

function line!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number},
        styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    if length(x) != length(y)
        throw(DimensionMismatch("x and y, of lengths $(length(x)) and $(length(y)) are not equal!"))
    end
    # Convert unique string values in x to numerical values
    unique_strings = unique(x)
    string_map = Dict(unique_strings[i] => i for i in 1:length(unique_strings))
    numeric_x = [string_map[s] for s in x]
    xmax::Number, ymax::Number = maximum(numeric_x), maximum(y)
    percvec_x = map(n::Number -> n / xmax, numeric_x)
    percvec_y = map(n::Number -> n / ymax, y)
    line_data = join([begin
                    scaled_x::Int64 = round(con.dim[1] * xper)  + con.margin[1]
                    scaled_y::Int64 = con.dim[2] - round(con.dim[2] * yper)  + con.margin[2]
                    "$(scaled_x)&#32;$(scaled_y),"
                end for (xper, yper) in zip(percvec_x, percvec_y)])
    line_comp = ToolipsSVG.polyline("newline", points = line_data)
    style!(line_comp, styles ...)
    draw!(con, [line_comp])
end

function line!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number},
    styles::Pair{String, <:Any} ...)
    line!(con, [string(d) for d in x], y, styles ...)
end

function gridlabels!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
                      n::Int64 = 4, styles::Pair{String, <:Any}...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 10pt)
    end
    mx = con.margin[1]
    my = con.margin[2]
    division_amountx::Int64 = round((con.dim[1]) / n)
    division_amounty::Int64 = round((con.dim[2]) / n)
    x_offset = division_amountx / 2
    y_offset = division_amounty / 2
    cx = 0
    xstep = round(maximum(x) / n)
    ystep = round(maximum(y) / n)
    cy = maximum(y)
        [begin
        text!(con, xcoord + mx, con.dim[2] - 10 + my, string(cx), styles ...)
        text!(con, 0 + mx, ycoord + my, string(cy), styles ...)
        cx += xstep
        cy -= ystep
        end for (xcoord, ycoord) in zip(
    range(1, con.dim[1],
    step = division_amountx), range(1, con.dim[2], step = division_amounty))]
end

function gridlabels!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number},
                      n::Int64 = 4, styles::Pair{String, <:Any}...)

    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 10pt)
    end

    unique_strings = unique(x)
    mx = con.margin[1]
    my = con.margin[2]
    division_amountx::Int64 = round((con.dim[1]) / n)
    division_amounty::Int64 = round((con.dim[2]) / n)
    x_offset = Int64(round(division_amountx / 2))
    y_offset = Int64(round(division_amounty / 2))
    cx = 1
    xstep = 1
    ystep = round(maximum(y) / n)
    cy = maximum(y)

    [begin
        if cx <= length(unique_strings)
            text!(con, xcoord + mx - x_offset, con.dim[2] - 10 + my, unique_strings[Int64(round(cx))], styles ...)
        end
        text!(con, 0 + mx, ycoord + my - y_offset, string(cy), styles ...)
        cx += xstep
        cy -= ystep
    end for (xcoord, ycoord) in zip(
            range(division_amountx, con.dim[1], step = division_amountx),
            range(1, con.dim[2], step = division_amounty))]
end

function gridlabels!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number},
    n::Int64 = 4, styles::Pair{String, <:Any} ...)
    gridlabels!(con, [string(v) for v in x], y, n, styles ...)
end

function line!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
        styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    if length(x) != length(y)
        throw(DimensionMismatch("x and y, of lengths $(length(x)) and $(length(y)) are not equal!"))
    end
    xmax::Number, ymax::Number = maximum(x), maximum(y)
    percvec_x = map(n::Number -> n / xmax, x)
    percvec_y = map(n::Number -> n / ymax, y)
    line_data = join([begin
                    scaled_x::Int64 = round(con.dim[1] * xper)  + con.margin[1]
                    scaled_y::Int64 = con.dim[2] - round(con.dim[2] * yper)  + con.margin[2]
                    "$(scaled_x)&#32;$(scaled_y),"
                end for (xper, yper) in zip(percvec_x, percvec_y)])
    line_comp = ToolipsSVG.polyline("newline", points = line_data)
    style!(line_comp, styles ...)
    draw!(con, [line_comp])
end

function grid!(con::AbstractContext, n::Int64 = 4, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "lightblue", "stroke-width" => "1", "opacity" => 80percent)
    end
    mx = con.margin[1]
    my = con.margin[2]
    division_amountx::Int64 = round((con.dim[1]) / n)
    division_amounty::Int64 = round((con.dim[2]) / n)
    [begin
        line!(con, xcoord + mx => 0 + my, xcoord + mx => con.dim[2] + my, styles ...)
        line!(con, 0 + mx => ycoord + my, con.dim[1] + mx => ycoord + my, styles ...)
    end for (xcoord, ycoord) in zip(
    range(1, con.dim[1],
    step = division_amountx), range(1, con.dim[2], step = division_amounty))]
end

function points!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
     styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "orange", "stroke" => "lightblue", "stroke-width" => "0")
    end
    xmax::Number, ymax::Number = maximum(x), maximum(y)
     percvec_x = map(n::Number -> n / xmax, x)
     percvec_y = map(n::Number -> n / ymax, y)
    [begin
        c = circle(randstring(), cx = string(pointx * con.dim[1] + con.margin[1]),
                cy = string(con.dim[2] - (pointy * con.dim[2] + con.margin[2])), r = "5")
            style!(c, styles ...)
            draw!(con, [c])
        end for (pointx, pointy) in zip(percvec_x, percvec_y)]
end

function axes!(con::AbstractContext, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    line!(con, con.margin[1] => con.dim[2] + con.margin[2],
     con.dim[1] + con.margin[1] => con.dim[2] + con.margin[2], styles ...)
    line!(con, con.margin[1] => con.margin[2],
     con.margin[1] => con.dim[2] + con.margin[2], styles ...)
end

function bars!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    n_features::Int64 = length(x)
    ymax::Number = maximum(y)
    n = 0
    percvec_y = map(n::Number -> n / ymax, y)
    block_width = Int64(round(con.dim[1] / n_features))
    rects = Vector{Servable}([begin
        scaled_y::Number = Int64(round(con.dim[2] * percvec_y[e]))
        rct = ToolipsSVG.rect(randstring(), x = Int64(round(n)) + con.margin[1],  y = con.dim[2] - scaled_y + con.margin[2], 
        width = block_width, height = con.dim[2] - (con.dim[2] - scaled_y) + con.margin[1])
        style!(rct, styles ...)
        n += block_width
        rct
    end for e in 1:n_features])
    draw!(con, rects)
end

bars!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...) = begin
    bars!(con, [string(v) for v in x], y, styles ...)
end
