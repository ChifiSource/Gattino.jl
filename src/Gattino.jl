"""
Created in December, 2023 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
- This software is MIT-licensed.
### Gattino
`Gattino` is a **hyper-composable** SVG visualization library for Julia built using the `Toolips` 
web-development framework's HTML templating (`ToolipsSVG`). Usage centers around the `Context`, 
which is provided to translate data into Scalable Vector Graphics and scale it onto a window. A 
`Context` is usually created via the `context` function:
```julia
mycon = context(200, 200) do con::Context
    text!(con, 250, 250, "hello world!")
    points!(con, [1, 2, 3, 4], [1, 2, 3, 4])
end
```
`Gattino`
- For more information on creating and editing visualizations, use `?context`.
###### export list
- **visualizations** (exported)
```julia
# plot   | context plotting equivalent
scatter #| scatter_plot!
line    #| line_plot!
hist    #| hist_plot!
```
- **contexts** (exported)
```julia
AbstractContext
compose
vcat(comp::AbstractContext, cons::AbstractContext ...)
hcat(comp::AbstractContext, cons::AbstractContext ...)
vcat(comp::Component{:div}, cons::AbstractContext ...)
hcat(comp::Component{:div}, cons::AbstractContext ...)
Context
context
layers
draw!
Group
group
group!
style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)
ToolipsServables.animate!(con::AbstractContext, layer::String, animation::ToolipsSVG.KeyFrames)
merge!(c::AbstractContext, c2::AbstractContext)
delete_layer!
rename_layer!
move_layer!
set_shape!
open_layer!
set!
set_gradient!
style!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.AbstractComponent}, vec::Vector{<:Number}, stylep::Pair{String, Int64} ...)
```
- **context plotting** (not exported)
```julia
text!
line!
gridlabels!
grid!
labeled_grid!
points!
axes!
axislabels!
bars!
barlabels!
v_bars!
v_barlabels!
legend!
append_legend!
make_legend_preview
```
"""
module Gattino
using ToolipsSVG
import Base: getindex, setindex!, show, display, vcat, push!, hcat, size, reshape, string
import ToolipsSVG: position, set_position!, set_size!, style!, set_shape, SVGShape
import ToolipsSVG.ToolipsServables: Servable, Component, AbstractComponent, br
using Random: randstring

include("context_plotting.jl")

"""
```julia
randcolor() -> ::String
```
---
Generates a random color.
```example
color = randcolor()
```
"""
function randcolor()
    colors = ("#FF6633", "#FFB399", "#FF33FF", "#FFFF99", "#00B3E6", 
    "#E6B333", "#3366E6", "#999966", "#99FF99", "#B34D4D",
    "#80B300", "#809900", "#E6B3B3", "#6680B3", "#66991A", 
    "#FF99E6", "#CCFF1A", "#FF1A66", "#E6331A", "#33FFCC",
    "#66994D", "#B366CC", "#4D8000", "#B33300", "#CC80CC", 
    "#66664D", "#991AFF", "#E666FF", "#4DB3FF", "#1AB399",
    "#E666B3", "#33991A", "#CC9999", "#B3B31A", "#00E680", 
    "#4D8066", "#809980", "#E6FF80", "#1AFF33", "#999933",
    "#FF3380", "#CCCC00", "#66E64D", "#4D80CC", "#9900B3", 
    "#E64D66", "#4DB380", "#FF4D4D", "#99E6E6", "#6666FF")
    colors[rand(1:length(colors))]::String
end

"""
```julia
scatter_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; 
divisions::Int64 = 4, title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))
```
---
Mutates `con` by drawing a scatter plot onto it. `divisions` is the number of rows and columns for the grid and its labels. `features` is optional, and 
will be the labels alongside the 1-dimensional features to plot in `Pair{String, Vector}` form. 
`title`, `xlabel`, and `ylabel` will generate these features on the plot. `legend` being set 
to `true` will generate a legend -- but only if there are `features` beyond `x` and `y`.... 
The idea being that `xlabel`/`ylabel` would be used in place of the legend in those cases.

All of the key-word arguments for `scatter_plot!` are also key-word arguments for `scatter`, as well as 
other plotting functions.
```example
context(250, 250) do con::Context
    Gattino.scatter_plot!(con, [rand(1:10) for x in 1:30], [rand(1:10) for x in 1:30])
end
```
```julia
con = context(100, 100) do con::Context
    Gattino.points!(con, [1, 2, 3, 4, 4, 5], [4, 8, 2, 3, 2, 8, 1])
end
```
"""
function scatter_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; 
    divisions::Int64 = 4, title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = vcat(["#FF6633"], [randcolor() for f in features]), 
    xmax::Number = maximum(x), xmin::Number = minimum(x), ymin::Number = minimum(y), ymax::Number = maximum(y))
      if length(x) != length(y)
        throw(
            DimensionMismatch("x and y must be of the same length! got ($(length(x)), $(length(y)))")
        )
    end
    w::Int64, h::Int64 = con.dim[1], con.dim[2]
    ml::Int64, mt::Int64 = con.margin[1], con.margin[2]
    if title != ""
        group!(con, "title") do titlegroup::Group
            posx = Int64(round(con.dim[1] * .35) + con.margin[1])
            posy = Int64(round(con.dim[2] * .08) + con.margin[2])
            text!(con, posx, posy, title, "fill" => "black", "font-size" => 15pt)
        end
        w, h = Int64(round(con.dim[1] * .75)), Int64(round(con.dim[2] * .75))
        ml, mt = Int64(round(con.dim[1] * .12)) + con.margin[1], Int64(round(con.dim[2] * .12) + con.margin[2])
    end
    lbls::Vector{String} = Vector{String}()
    group(con, w, h, ml => mt) do plotgroup::Group
        group!(plotgroup, "axes") do g::Group
            axes!(g)
        end
        group!(plotgroup, "grid") do g::Group
            grid!(g, divisions)
        end
        orlabel::String = ylabel
        if ylabel == ""
            orlabel = "points"
        end
        group!(plotgroup, orlabel) do g::Group
            points!(g, x, y, "fill" => colors[1], ymax = ymax, xmax = xmax, ymin = ymin, xmin = xmin)
        end
        lbls = [begin
            group!(plotgroup, feature[1]) do g::Group
                points!(g, x, feature[2], "fill" => colors[e], xmax = xmax, ymax = ymax, xmin = xmin, ymin = ymin)
            end
            string(feature[1])::String
        end for (e, feature) in enumerate(filter(fet -> ~(typeof(fet[2]).parameters[1] <: AbstractString), features))]
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions, xmax = xmax, ymax = ymax, xmin = xmin, ymin = ymin)
        end
        if xlabel != "" || ylabel != ""
            group!(plotgroup, "axislabels") do g::Group
                axislabels!(g, xlabel, ylabel)
            end
        end
    end
    if legend
        legend!(con, lbls)
    end
    con::AbstractContext
end

"""
```julia
scatter -> ::AbstractContext
```
---
`scatter`, `line`, and `hist` are all high-level plotting functions used to create a `Context` and display features 
from a data structure using a single function call. These all create a new context and call their respective `_plot!` function. 
    For example, `scatter` will call `scatter_plot!` -- these functions may also be used to add plots to existing contexts. 
    The arguments for the `_plot!` equivalents are passed down from their plot creation functions. As a result, each dispatch 
    of `scatter` is a pass-through to the main dispatch of `scatter_plot!`, and arguments for that `Function` may be used. `width` and `height`
- For a `scatter` plot, both `x` and `y` must be numerical.
```example
using DataFrames
using Gattino

df = DataFrame("A" => [rand(1:1000) for x in 1:1000], "B" => [rand(5:20) for y in 1:1000], "C" => [rand(1:1000) for y in 1:1000], 
"D" => [rand(4:800) for y in 1:1000])
plot1 = scatter(df)
plot2 = scatter([1, 2, 3, 4, 5], [1, 2, 3, 4, 5], title = "straight line", width = 200, height = 200)
                   # x   y
plot3 = scatter(df, "C", "D", xlabel = "C", ylabel = "D")
plot4 = context(250, 250) do con::Context
    group(con, 100, 250, 0 => 0) do lastvis::Group
        group!(lastvis, "scatter1") do g::Group
            Gattino.scatter_plot!(g, [1, 2, 3], [1, 2, 3])
        end
    end
    group(con, 100, 250, 125 => 0) do lastvis::Group
        group!(lastvis, "hist1") do g::Group
            Gattino.hist_plot!(g, ["one", "two", "three", "four", "five"], [2, 7, 5, 5, 3])
        end
    end
end
result = vcat(hcat(plot1, plot2), hcat(plot3, plot4))
```
###### methods
```julia
# arguments are passed through to `scatter_plot!`, all of these key-word arguments can be used with `scatter`:
scatter_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; 
    divisions::Int64 = 4, title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]), 
    xmax::Number = maximum(x), xmin::Number = minimum(x), ymin::Number = minimum(y))

# for vectors
scatter(x::Vector{<:Any}, args ...; width::Int64 = 500, height::Int64 = 500, 
    keyargs ...)
# for dictionaries (secondary for data structures)
scatter(x::String, y::String, features::Dict{<:AbstractString, <:AbstractVector}, colors::Vector{String} = [randcolor() for e in 1:length(features)];
    width::Int64 = 500, height::Int64 = 500, keyargs ...)
# for data structures (binded to `names` and `eachcol`)
scatter(features::Any, x::Any = names(features)[1], y::Any = names(features)[2], 
    args ...; keyargs ...)
```
"""
function scatter end

scatter(x::Vector{<:Any}, args ...; width::Int64 = 500, height::Int64 = 500, 
keyargs ...) = scatter_plot!(Context(width, height), x, args ...; keyargs ...)

function scatter(x::String, y::String, features::Dict{<:AbstractString, <:AbstractVector}, colors::Vector{String} = [randcolor() for e in 1:length(features)];
    width::Int64 = 500, height::Int64 = 500, keyargs ...)
    newfs = filter(k -> ~(string(k[1]) == x || string(k[1]) == y), features)
    context(width, height) do con::Context
        scatter_plot!(con, features[x], features[y], pairs(newfs) ...; colors = colors, keyargs ...)
    end
end

function scatter(features::Any, x::Any = names(features)[1], y::Any = names(features)[2], 
    args ...; keyargs ...)
    try
        features = Dict{String, AbstractVector}(string(name) => Vector(col) for (name, col) in zip(names(features), eachcol(features)))
    catch
        throw("$(typeof(features)) is not compatible with `Gattino`. (Gattino uses `names` and `eachcol`.)")
    end
    scatter(x, y, features, args ...; keyargs ...)
end

"""
```julia
line_plot!(con::AbstractContext, ...) -> ::Context
```
---
Mutates `con` by drawing a line plot onto it. `divisions` is the number of rows and columns for the grid and its labels. `features` is optional, and 
will be the labels alongside the 1-dimensional features to plot in `Pair{String, Vector}` form. 
`title`, `xlabel`, and `ylabel` will generate these features on the plot. `legend` being set 
to `true` will generate a legend -- but only if there are `features` beyond `x` and `y`.
- For a `line` plot, the `y` must be numerical -- the `x` can be non-numerical.
```julia
line_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; divisions::Int64 = 4, xlabel::String = "", 
    ylabel::String = "", legend::Bool = true, title::String = "", colors::Vector{String} = Vector{String}(["#FF6633"]))

# non-numerical x
line_plot!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; divisions::Int64 = length(x), title::String = "", 
    xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))
```
"""
function line_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; divisions::Int64 = 4, xlabel::String = "", 
    ylabel::String = "", legend::Bool = true, title::String = "", colors::Vector{String} = Vector{String}(["#FF6633"]), ymin::Number = minimum(y), ymax::Number = maximum(y), 
    xmin::Number = minimum(x), xmax::Number = maximum(x))
    if length(x) != length(y)
        throw(DimensionMismatch("x and y must be of the same length! got ($(length(x)), $(length(y)))"))
    end
    w::Int64, h::Int64 = con.dim[1], con.dim[2]
    ml::Int64, mt::Int64 = con.margin[1], con.margin[2]
    if title != ""
        group!(con, "title") do titlegroup::Group
            posx = Int64(round(con.dim[1] * .35) + con.margin[1])
            posy = Int64(round(con.dim[2] * .08) + con.margin[2])
            text!(con, posx, posy, title, "fill" => "black", "font-size" => 15pt)
        end
        w, h = Int64(round(con.dim[1] * .75)), Int64(round(con.dim[2] * .75))
        ml, mt = Int64(round(con.dim[1] * .12)) + con.margin[1], Int64(round(con.dim[2] * .12)) + con.margin[2]
    end
    lbls::Vector{String} = Vector{String}()
    group(con, w, h, ml => mt) do plotgroup::Group
        group!(plotgroup, "axes") do g::Group
            axes!(g)
        end
        group!(plotgroup, "grid") do g::Group
            grid!(g, divisions)
        end
        orlabel::String = ylabel
        if ylabel == ""
            orlabel = "line"
        end
        group!(plotgroup, orlabel) do g::Group
            line!(g, x, y, xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax)
        end
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions, ymax = ymax, xmax = xmax, ymin = ymin, xmin = xmin)
        end
        lbls = [begin
            group!(plotgroup, feature[1]) do g::Group
                line!(g, x, feature[2], "stroke" => colors[e], "stroke-width" => 3px, "fill" => "none", xmax = xmax, ymax = ymax, xmin = xmin, ymin = ymin)
            end
            string(feature[1])::String
        end for (e, feature) in enumerate(features)]
        if xlabel != "" || ylabel != ""
            group!(plotgroup, "axislabels") do g::Group
                axislabels!(g, xlabel, ylabel)
            end
        end
    end
    if legend
        legend!(con, lbls)
    end
    con::AbstractContext
end

"""
```julia
plot_margins(f::Function, con::AbstractContext) -> ::Group
```
---
Will draw the changes in `f` into the default plot margins `Gattino` calculates 
for `con`. This does some scaling math to determine the optimal size for the plot 
    depending on the size of the window.
```julia
mycon = context() do con::Context
    scatter_plot!(con, [1, 2, 3], [1, 2, 3], ymax = 6, ymin = 0, xmax = 6, xmin = 0, title = "my plot")
    plot_margins(con) do g::Group
        # we are now back to the same scaling our scatter plot is on (because we provided `title`).
    end
end
```
"""
plot_margins(f::Function, con::AbstractContext) = begin
    w::Int64, h::Int64 = Int64(round(con.dim[1] * .75)), Int64(round(con.dim[2] * .75))
    ml::Int64, mt::Int64 = Int64(round(con.dim[1] * .12)) + con.margin[1], Int64(round(con.dim[2] * .12)) + con.margin[2]
    group(f, con, w, h, ml => mt)
end

function line_plot!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; divisions::Int64 = length(x), title::String = "", 
    xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]), ymin::Number = minimum(y), ymax = maximum(y))
    if length(x) != length(y)
        throw(DimensionMismatch("x and y must be of the same length! got ($(length(x)), $(length(y)))"))
    end
    w::Int64, h::Int64 = con.dim[1], con.dim[2]
    ml::Int64, mt::Int64 = con.margin[1], con.margin[2]
    if title != ""
        group!(con, "title") do titlegroup::Group
            posx = Int64(round(con.dim[1] * .35) + con.margin[1])
            posy = Int64(round(con.dim[2] * .08) + con.margin[2])
            text!(con, posx, posy, title, "fill" => "black", "font-size" => 15pt)
        end
        w, h = Int64(round(con.dim[1] * .75)), Int64(round(con.dim[2] * .75))
        ml, mt = Int64(round(con.dim[1] * .12)) + con.margin[1], Int64(round(con.dim[2] * .12)) + con.margin[2]
    end
    lbls::Vector{String} = Vector{String}()
    group(con, w, h, ml => mt) do plotgroup::Group
        group!(plotgroup, "axes") do g::Group
            axes!(g)
        end
        group!(plotgroup, "grid") do g::Group
            grid!(g, divisions)
        end
        orlabel::String = ylabel
        if ylabel == ""
            orlabel = "line"
        end
        group!(plotgroup, orlabel) do g::Group
            line!(g, x, y, ymax = ymax, ymin = ymin)
        end
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions, ymax = ymax, ymin = ymin)
        end
        ymax = maximum(y)
        lbls = [begin
            group!(plotgroup, feature[1]) do g::Group
                line!(g, x, feature[2], "fill" => colors[e], ymax = ymax, ymin = ymin)
            end
            string(feature[1])::String
        end for (e, feature) in enumerate(features)]
        if xlabel != "" || ylabel != ""
            group!(plotgroup, "axislabels") do g::Group
                axislabels!(g, xlabel, ylabel)
            end
        end
    end
    if legend
        legend!(con, lbls)
    end
    con::AbstractContext
end

function line_plot!(con::AbstractContext, x::Vector{<:Number}; keyargs ...)
    line_plot!(con, x, [e for e in 1:length(x)], keyargs ...)::AbstractContext
end

"""
```julia
`line` -> ::AbstractContext
```
`line`, `scatter`, and `hist` are all high-level plotting functions used to create a `Context` and display features 
from a data structure using a single function call. `line` takes the same arguments as `line_plot!`, like the other plotting functions. 
    A `line` plot can be created using both a numberical and a non-numerical X.
```julia
```
###### methods
```julia
# from vectors
line(x::Vector{<:Any}, y::Vector{<:Any}, args ...; keyargs ...)
line(x::String, y::String, features::Dict{String, <:AbstractVector}, colors::Vector{String} = [randcolor() for e in 1:length(features)]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
line(features::Any, x::Any = names(features)[1], y::Any = names(features)[2], args ...; keyargs ...)
```
"""
function line end

function line(x::Vector{<:Any}, y::Vector{<:Any}, args ...; keyargs ...)
    context(500, 500) do con::Context
        line_plot!(con, x, y, args ...; keyargs ...)
    end
end

function line(x::String, y::String, features::Dict{String, <:AbstractVector}, colors::Vector{String} = [randcolor() for e in 1:length(features) + 1]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
    newfs = filter(k -> ~(string(k[1]) == x || string(k[1]) == y), features)
    context(width, height) do con::Context
        line_plot!(con, features[x], features[y], pairs(newfs) ...; colors = colors, keyargs ...)
    end
end

function line(features::Any, x::Any = names(features)[1], y::Any = names(features)[2], args ...; keyargs ...)
    try
        features = Dict{String, AbstractVector}(string(name) => Vector(col) for (name, col) in zip(names(features), eachcol(features)))
    catch
        throw("$(typeof(features)) is not compatible with `Gattino`. (Gattino uses `names` and `eachcol`.)")
    end
    line(x, y, features, args ...; keyargs ...)
end

"""
```julia
hist_plot!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number} = Vector{Int64}(), features::Pair{String, <:AbstractVector} ...; 
    divisions::Int64 = length(x), title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]), 
    ymin::Number = minimum(y), ymax::Number = maximum(y))
```
Mutates `con` by drawing a bar chart onto it. `y` is optional -- not providing a `y` (providing one vector) will create a histogram 
measuring the frequency of `x`. This function is called by the plotting function `hist` to create a histogram on a new `Context`.
```example
color = randcolor()
```
"""
function hist_plot!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number} = Vector{Int64}(), features::Pair{String, <:AbstractVector} ...; 
    divisions::Int64 = length(x), title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = [randcolor() for co in 1:length(x)], 
    ymin::Number = minimum(y), ymax::Number = maximum(y))
    frequency::Bool = false
    n::Int64 = length(y)
    if length(y) == 0
        frequency = true
    elseif length(x) != length(y)
        throw(DimensionMismatch("x and y must be of the same length! got ($(length(x)), $(length(y)))"))
    end
    w::Int64, h::Int64 = con.dim[1], con.dim[2]
    ml::Int64, mt::Int64 = con.margin[1], con.margin[2]
    if title != ""
        group!(con, "title") do titlegroup::Group
            posx = Int64(round(con.dim[1] * .35) + con.margin[1])
            posy = Int64(round(con.dim[2] * .08) + con.margin[2])
            text!(con, posx, posy, title, "fill" => "black", "font-size" => 15pt)
        end
        w, h = Int64(round(con.dim[1] * .75)), Int64(round(con.dim[2] * .75))
        ml, mt = Int64(round(con.dim[1] * .12)) + con.margin[1], Int64(round(con.dim[2] * .12)) + con.margin[2]
    end
    group(con, w, h, ml => mt) do plotgroup::Group
        group!(plotgroup, "axes") do g::Group
            axes!(g)
        end
        group!(plotgroup, "grid") do g::Group
            grid!(g, divisions)
        end
        x = vcat(x, [feature[2] for feature in features] ...)
        y = vcat(y, [y for feature in features] ...)
        diff::Int64 =  length(x) - length(colors)
        push!(colors, [randcolor() for x in 1:diff] ...)
        if ~(frequency)
            group!(plotgroup, "bars") do g::Group
                bars!(g, x, y, ymin = ymin, ymax = ymax)
            end
            group!(plotgroup, "labels") do g::Group
                barlabels!(g, x)
                gridlabels!(g, y, divisions, ymin = ymin, ymax = ymax)
            end
        else
            group!(plotgroup, "bars") do g::Group
                bars!(g, ["" for y in x], x, ymin = ymin, ymax = ymax)
            end
            group!(plotgroup, "labels") do g::Group
                barlabels!(g, x)
                gridlabels!(g, x, divisions)
            end
        end
        group!(plotgroup, "axislabels") do g::Group

        end
    end
    open_layer!(con, "bars") do ecomp
        style!(ecomp, "fill", colors)
    end
    con::AbstractContext
end

"""
```julia
hist -> ::AbstractContext
```
The non-mutating version of `hist_plot!` -- creates a `Context` and then uses `hist_plot!` to draw a histogram/barchart onto it 
(depending on the arguments). Like `scatter` and `line`, the arguments are passed through to the plotting functions and may be used from 
these functions. `width` and `height` may also be provided. For this type of plot, only `x` can be non-numerical. 

In reference to this function, we should also note context_plotting's `vbars!`
"""
hist(x::Vector{<:Any}, args ...; width::Int64 = 500, height::Int64 = 500, keyargs ...) = hist_plot!(Context(width, height), x, args ...; keyargs ...)

function hist(x::String, y::String, features::Dict{String, <:AbstractVector}, colors::Vector{String} = [randcolor() for co in features[x]]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
    newfs = filter(k -> ~(string(k[1]) == x || string(k[1]) == y), features)
    context(width, height) do con::Context
        hist_plot!(con, features[x], features[y], pairs(newfs) ...; colors = colors, keyargs ...)
    end
end

function hist(features::Any, x::Any = names(features)[1], y::Any = names(features)[2], args ...; keyargs ...)
    try
        features = Dict{String, AbstractVector}(string(name) => Vector(col) for (name, col) in zip(names(features), eachcol(features)))
    catch
        throw("$(typeof(features)) is not compatible with `Gattino`. (Gattino uses `names` and `eachcol`.)")
    end
    hist(string(x), string(y), features, args ...; keyargs ...)
end

export Group, group!, style!, px, pt, group, layers, context, move_layer!, seconds, percent, Context, Animation
export compose, delete_layer!, open_layer!, merge!, set!, set_gradient!, set_shape!
export hist, scatter, line
end # module
