include("Contexts.jl")

"""
```julia
text!(con::AbstractContext, x::Int64, y::Int64, text::String, styles::Pair{String, <:Any} ...) -> ::Nothing
```
Draws `text` with the text `text` and the styles `styles` at (`x`, `y`) on a `Context` (`con`).
```example

```
"""
function text!(con::AbstractContext, x::Int64, y::Int64, text::String, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 13pt)
    end
    t = ToolipsSVG.text(randstring(), x = x, y = y, text = text)
    style!(t, styles ...)
    draw!(con, [t])
    nothing::Nothing
end

"""
```julia
line!(con::AbstractContext, args ...) -> ::Nothing
```
Draws a line onto a `Context` `styles` may be provided to style the line on creation. 
One thing to note is that the `line!(con::AbstractContext, first::Pair{<:Number, <:Number},
second::Pair{<:Number, <:Number}, styles::Pair{String, <:Any} ...)` method is for drawing an 
**unscaled** line, whereas this is not the case for the other dispatches.
```julia
# draw a non-scaled x -> y line
line!(con::AbstractContext, first::Pair{<:Number, <:Number},
    second::Pair{<:Number, <:Number}, styles::Pair{String, <:Any} ...)
# scaled, line plot line:
line!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
    styles::Pair{String, <:Any} ...)

line!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number},
        styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), ymin::Number = minimum(y))

line!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number},
        styles::Pair{String, <:Any} ...)
```
```example

```
"""
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

function line!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number},
        styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), ymin::Number = minimum(y))
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
    xmax::Number = maximum(numeric_x)
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
    nothing::Nothing
end

function line!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number},
    styles::Pair{String, <:Any} ...)
    line!(con, [string(d) for d in x], y, styles ...)
end

function line!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
    styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), xmax::Number = maximum(x), 
    ymin::Number = minimum(y), xmin::Number = minimum(x))
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

"""
```julia
gridlabels!(con::AbstractContext, args ...) -> ::Nothing
```
Draws grid labels onto `con`.
```julia
gridlabels!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
    n::Int64 = 4, styles::Pair{String, <:Any}...)
gridlabels!(con::AbstractContext, y::Vector{<:Number}, n::Int64 = 4, styles::Pair{String, String} ...)
gridlabels!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number},
    n::Int64 = 4, styles::Pair{String, <:Any}...)
gridlabels!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number},
    n::Int64 = 4, styles::Pair{String, <:Any}...)
```
```example

```
"""
function gridlabels!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
    n::Int64 = 4, styles::Pair{String, <:Any}...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => "10pt")
    end
    mx = con.margin[1]
    my = con.margin[2]
    x_min, x_max = minimum(x), maximum(x)
    y_min, y_max = minimum(y), maximum(y)
    division_amountx::Int64 = round((con.dim[1]) / n)
    division_amounty::Int64 = round((con.dim[2]) / n)
    x_offset = division_amountx * 0.30
    y_offset = division_amounty * 0.30
    cx = x_min
    xstep = (x_max - x_min) / n
    ystep = (y_max - y_min) / n
    cy = y_max
    [begin
        txt = string(cx)
        if length(txt) > 7
            txt = txt[1:6]
        end
        text!(con, xcoord + mx, con.dim[2] - 10 + my, txt, styles...)
        txt = string(cy)
        if length(txt) > 7
            txt = txt[1:6]
        end
        text!(con, 0 + mx, ycoord + my, txt, styles...)
        cx += xstep
        cy -= ystep
    end for (xcoord, ycoord) in zip(
    range(Int64(round(x_min)), con.dim[1], step=division_amountx),
    range(Int64(round(y_min)), con.dim[2], step=division_amounty))]
end

function gridlabels!(con::AbstractContext, y::Vector{<:Number}, n::Int64 = 4, styles::Pair{String, String} ...)
if length(styles) == 0
styles = ("fill" => "black", "font-size" => "10pt")
end
my = con.margin[2]
mx = con.margin[1]
y_min, y_max = minimum(y), maximum(y)
division_amounty::Int64 = Int64(ceil((con.dim[2]) / n))
y_offset = Int64(round(division_amounty * 0.3))
ystep = (y_max - y_min) / n
permx = Int64(round(con.dim[1] * 0.05))
cy = y_max
[begin
txt = string(cy)
if length(txt) > 7
    txt = txt[1:6]
end
text!(con, permx + mx, ycoord + my + y_offset, txt, styles ...)
cy -= ystep
end for ycoord in range(Int64(round(y_min)), con.dim[2], step=division_amounty)]
end

function gridlabels!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number},
    n::Int64 = 4, styles::Pair{String, <:Any}...)
if length(styles) == 0
styles = ("fill" => "black", "font-size" => "10pt")
end
unique_strings = unique(x)
mx = con.margin[1]
my = con.margin[2]
y_min, y_max = minimum(y), maximum(y)
division_amountx::Int64 = round((con.dim[1]) / n)
division_amounty::Int64 = round((con.dim[2]) / n)
x_offset = Int64(round(division_amountx * 0.75))
y_offset = Int64(round(division_amounty * 0.10))
cx = 1
xstep = 1
ystep = (y_max - y_min) / n
cy = y_max
[begin
    if cx <= length(unique_strings)
        text!(con, xcoord + mx - x_offset, con.dim[2] - 10 + my, unique_strings[Int64(round(cx))], styles ...)
    end
    txt = string(cy)
    if length(txt) > 7
        txt = txt[1:6]
    end
    text!(con, 0 + mx, ycoord + my - y_offset, txt, styles ...)
    cx += xstep
    cy -= ystep
    end for (xcoord, ycoord) in zip(
    range(0, con.dim[1], step=division_amountx),
    range(y_min, con.dim[2], step=division_amounty))]
end

function gridlabels!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number},
    n::Int64 = 4, styles::Pair{String, <:Any}...)
    gridlabels!(con, [string(v) for v in x], y, n, styles...)
end

"""
```julia
grid!(con::AbstractContext, n::Int64 = 4, styles::Pair{String, <:Any} ...) -> ::Nothing
```
Creates a simple grid, with `n` divisions.
```example

```
"""
function grid!(con::AbstractContext, n::Int64 = 4, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "lightblue", "stroke-width" => "1", "opacity" => 80percent)
    end
    mx = con.margin[1]
    my = con.margin[2]
    division_amountx::Int64 = ceil((con.dim[1]) / n)
    division_amounty::Int64 = ceil((con.dim[2]) / n)
    [begin
        line!(con, xcoord + mx => 0 + my, xcoord + mx => con.dim[2] + my, styles ...)
        line!(con, 0 + mx => ycoord + my, con.dim[1] + mx => ycoord + my, styles ...)
    end for (xcoord, ycoord) in zip(
    range(1, con.dim[1],
    step = division_amountx), range(1, con.dim[2], step = division_amounty))]
end


"""
```julia
points!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
    styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), xmax::Number = maximum(x), 
    xmin::Number = minimum(x), ymin::Number = minimum(y), r::Int64 = 5) -> ::Nothing
```
Draws scaled "scatter points" onto `con`. Providing `ymax`/`xmax` (etc.) will set the minimum and maximum from 
which the points are drawn, which will usually be the top and bottom of your data. These can also be provided to 
ascending plotting functions, e.g. `scatter` or `scatter_plot!`.
```example
con = context(100, 100) do con::Context
    Gattino.points!(con, [1, 2, 3, 4, 4, 5], [4, 8, 2, 3, 2, 8, 1])
end
```
"""
function points!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
    styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), xmax::Number = maximum(x), 
    xmin::Number = minimum(x), ymin::Number = minimum(y), r::Int64 = 5)
   if length(styles) == 0
       styles = ("fill" => "orange", "stroke" => "lightblue", "stroke-width" => "0")
   end
   percvec_x::Vector{<:Number} = map(n::Number -> (n - xmin) / (xmax - xmin), x)
   percvec_y::Vector{<:Number} = map(n::Number -> (n - ymin) / (ymax - ymin), y)
   draw!(con, Vector{Servable}([begin
       cx = Int64(round(percvec_x[i] * (con.dim[1] - 1) + con.margin[1]))
       cy = Int64(round(con.dim[2] - percvec_y[i] * (con.dim[2] - 1) + con.margin[2]))
       c = circle(randstring(), cx = cx, cy = cy, r = r)
       style!(c, styles...)
       c
   end for i in 1:length(x)]))
end

"""
```julia
axes!(con::AbstractContext, styles::Pair{String, <:Any} ...) -> ::Nothing
```
Draws axes on `con` with `styles`.
```example
con = context(100, 100) do con::Context
    Gattino.points!(con, [1, 2, 3, 4, 4, 5], [4, 8, 2, 3, 2, 8, 1])
    Gattino.axes!(con)
    # Gattino.axes!(con, "stroke" => "purple")
end
```
"""
function axes!(con::AbstractContext, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    line!(con, con.margin[1] => con.dim[2] + con.margin[2],
     con.dim[1] + con.margin[1] => con.dim[2] + con.margin[2], styles ...)
    line!(con, con.margin[1] => con.margin[2],
    con.margin[1] => con.dim[2] + con.margin[2], styles ...)
    nothing::Nothing
end

"""
```julia
axislabels!(con::AbstractContext, xlabel::AbstractString, ylabel::AbstractString,
    styles::Pair{String, <:Any}...) -> ::Nothing
```
Draws axis labels onto `con`.
```example
con = context(100, 100) do con::Context
    Gattino.points!(con, [1, 2, 3, 4, 4, 5], [4, 8, 2, 3, 2, 8, 1])
    Gattino.axes!(con)
    Gattino.axislabels!(con, "x", "y", "fill" => "blue")
end
```
"""
function axislabels!(con::AbstractContext, xlabel::AbstractString, ylabel::AbstractString,
    styles::Pair{String, <:Any}...)
    if length(styles) == 0
        styles = ("stroke" => "darkgray", "font-size" => "12pt")
    end
    x_label_offset = Int64(round(con.dim[1] / 2) + con.margin[1])
    text!(con, x_label_offset, con.dim[2] + con.margin[2] - 30, xlabel, styles...)
    y_label_offset = Int64(round(con.dim[2] / 2) + con.margin[2])
    text!(con, con.margin[1] - 60, y_label_offset, ylabel, styles...)
    nothing
end

"""
```julia
bars!(con::AbstractContext, args ...; ymax::Number = maximum(y), ymin::Number = maximum(y)) -> ::Nothing
```
Draws scaled "bars" onto `con` according to the data of `x` and `y`. `ymin` and `ymax` are provided to change the numerical scaling. 
There is also a vertical equivalent, `v_bars!`.
```julia
bars!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), 
    ymin::Number = minimum(y))
bars!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), ymin::Number = minimum(y))
```
```example
con = context(100, 100) do con::Context
    Gattino.grid!(con)
    Gattino.bars!(con, ["one", "two", "three"], [50, 20, 30], ymin = 0, ymax = 50)
    Gattino.axes!(con)
end
```
"""
function bars!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), 
    ymin::Number = minimum(y))
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    n_features::Int64 = length(x)
    n = 0
    percvec_y = map(n::Number -> (n - ymin) / (ymax - ymin), y)
    block_width = Int64(round(con.dim[1] / n_features))
    rects = Vector{Servable}([begin
        scaled_y::Number = Int64(round(con.dim[2] * percvec_y[e]))
        rct = ToolipsSVG.rect(randstring(), x = Int64(round(n)) + con.margin[1],  y = con.dim[2] - scaled_y + con.margin[2], 
        width = block_width, height = con.dim[2] - (con.dim[2] - scaled_y))
        style!(rct, styles ...)
        n += block_width
        rct
    end for e in 1:n_features])
    draw!(con, rects)
end

function bars!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), ymin::Number = minimum(y))
    bars!(con, [string(v) for v in x], y, styles ..., ymax = ymax, ymin = ymin)
end

"""
```julia
barlabels!(con::AbstractContext, x::Vector{<:Any}, styles::Pair{String, String} ...) -> ::Nothing
```
Draws labels for the "bars" created by `bars!`. Also has a `v_bars!` equivalent in `v_barlabels!`.
```example
con = context(100, 100) do con::Context
    Gattino.grid!(con)
    x = ["one", "two", "three"]
    Gattino.bars!(con, x, [50, 20, 30], ymin = 0, ymax = 50)
    Gattino.barlabels!(con, x)
    Gattino.axes!(con)
end
```
"""
function barlabels!(con::AbstractContext, x::Vector{<:Any}, styles::Pair{String, String} ...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => "11pt")
    end
    n_features::Int64 = length(x)
    block_width = Int64(ceil(con.dim[1] / n_features))
    offset::Int64 = Int64(ceil(block_width * 0.15))
    perm_y = Int64(round(con.dim[2] - con.dim[2] * 0.20))
    [begin
        text!(con, xval + con.margin[1] + offset, perm_y, string(x[e]), styles ...)
    end for (e, xval) in enumerate(range(1, n_features * block_width, step = block_width))]
    return
end

function v_bars!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...; 
    ymax::Number = maximum(y), ymin::Number = minimum(y))
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    n_features::Int64 = length(x)
    n = 0
    percvec_y = map(n::Number -> (n - ymin) / (ymax - ymin), y)
    block_width = Int64(round(con.dim[2] / n_features))
    rects = Vector{Servable}([begin
        scaled_y::Number = Int64(round(con.dim[2] * percvec_y[e]))
        rct = ToolipsSVG.rect(randstring(), x = 0, y = n, 
        width = con.dim[1] - (con.dim[1] - scaled_y), height = block_width)
        style!(rct, styles ...)
        n += block_width
        rct
    end for e in 1:n_features])
    draw!(con, rects)
end

function v_bars!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), ymin::Number = minimum(y))
    v_bars!(con, [string(v) for v in x], y, styles ..., ymax = ymax, ymin = ymin)
end
"""
```julia
barlabels!(con::AbstractContext, x::Vector{<:Any}, styles::Pair{String, String} ...) -> ::Nothing
```
Draws labels for the "bars" created by `bars!`. Also has a `v_bars!` equivalent in `v_barlabels!`.
```example
con = context(100, 100) do con::Context
    Gattino.grid!(con)
    x = ["one", "two", "three"]
    Gattino.bars!(con, x, [50, 20, 30], ymin = 0, ymax = 50)
    Gattino.barlabels!(con, x)
    Gattino.axes!(con)
end
```
"""
function v_barlabels!(con::AbstractContext, x::Vector{<:AbstractString}, styles::Pair{String, String} ...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => "11pt")
    end
    n_features::Int64 = length(x)
    block_width = Int64(round(con.dim[2] / n_features))
    offset::Int64 = Int64(round(block_width * 0.5))
    perm_x = Int64(round(con.dim[1] * 0.14))
    [begin
        text!(con, perm_x + con.margin[1], yval + offset + con.margin[2], x[e], styles ...)
    end for (e, yval) in enumerate(range(1, n_features * block_width, step = block_width))]
    return
end

function legend!(con::AbstractContext, names::Vector{String}, styles::Pair{String, String} ...; align::String = "bottom-right")
    if length(styles) == 0
        styles = ("stroke" => "darkgray", "fill" => "white", "stroke-width" => 2px)
    end
    legg = ToolipsSVG.g("legend")
    positionx = Int64(round(con.dim[1] / 2)) + con.margin[1]
    scaler = Int64(round(con.dim[1] * .24))
    if contains(align, "right")
        positionx += scaler
    elseif contains(align, "left")
        positionx -= scaler
    end
    positiony = Int64(round(con.dim[2] / 2)) + con.margin[2]
    scaler = Int64(round(con.dim[2] * .20))
    if contains(align, "top")
        positiony -= scaler
    elseif contains(align, "bottom")
        positiony += scaler
    end
    ww = Int64(round(con.dim[1]) * .20)
    hh = length(names) * 20
    legbox = ToolipsSVG.rect("legendbg", x = positionx, y = positiony,
    width = ww, height = hh)
    style!(legbox, styles ...)
    sample_width = 20
    sample_height = 20
    sample_margin = 12
    push!(legg, legbox)
    [begin
        samp = con.window[:children][name][:children][1]
        samp.name = "$(name)-preview"
        set_position!(samp, positionx + sample_margin, positiony + sample_margin * e)
        samplabel = ToolipsSVG.text("$(name)-label", x = positionx + (sample_margin * 2), y = positiony + (sample_margin * e * 1.15),
        text = name)
        style!(samplabel, "stroke" => "darkgray", "font-size" => 9pt)
        push!(legg, samp, samplabel)
    end for (e, name) in enumerate(names)]
    push!(con.window, legg)
end

function append_legend!(con::AbstractContext, name::String)
    legend = con["legend"]
    n_features = length(legend[:children]) - 1
    box = legend[:children]["legendbg"]
    positionx, positiony = box[:x], box[:y]
    samp = con.window[:children][name][:children][1]
    box[:height] += 20
    sample_width = 20
    sample_height = 20
    sample_margin = 12
    set_position!(samp, positionx + sample_margin, positiony + sample_margin * (n_features))
    samplabel = ToolipsSVG.text("$(name)-label", x = positionx + (sample_margin * 2), y = positiony + (sample_margin * (n_features) * 1.15),
    text = name)
    style!(samplabel, "stroke" => "darkgray", "font-size" => 9pt)
    push!(legend, samp, samplabel)
    nothing
end

function append_legend!(con::AbstractContext, name::String, samp::Component{<:Any})
    legend = con["legend"]
    n_features = length(legend[:children]) - 1
    box = legend[:children]["legendbg"]
    positionx, positiony = box[:x], box[:y]
    box[:height] += 20
    sample_width = 20
    sample_height = 20
    sample_margin = 12
    if typeof(samp) == Component{:g}
        [set_position!(cmp, positionx + sample_margin * e, positiony + sample_margin * (n_features)) for (e, cmp) in enumerate(samp[:children])]
    else
        set_position!(samp, positionx + sample_margin, positiony + sample_margin * (n_features))
    end
    samplabel = ToolipsSVG.text("$(name)-label", x = positionx + (sample_margin * 2), y = positiony + (sample_margin * (n_features) * 1.15),
    text = name)
    style!(samplabel, "stroke" => "darkgray", "font-size" => 9pt)
    push!(legend, samp, samplabel)
    nothing
end

function remove_legend!(con::AbstractContext, name::String)
    legendcs = con["legend"][:children]
    legendcs["legendbg"][:height] -= 20
    pos = findfirst(comp -> comp.name == name, legendcs)
    deleteat!(legendcs, pos); deleteat!(legendcs, pos + 1)
end