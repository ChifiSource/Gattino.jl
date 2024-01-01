"""
Created in December, 2023 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
- This software is MIT-licensed.
### Gattino
`Gattino` is a **hyper-composable** SVG visualization library for Julia built using the `Toolips` 
web-development framework. Usage centers around the `Context`, which can be created using the `context` method.
```julia
mycon = context(200, 200) do con::Context

end
```
For more information on creating and editing visualizations, use `?context`
#### High-level plotting methods
All high-level plots in `Gattino` share the same methods. We do not need to provide a `Context`, instead these functions 
create an entire visualization directly from a data structure.
####### functions

- `scatter` (`?scatter`)
- `line`
- `hist`

####### methods

- `(x::Vector{<:Any}, args ...; keyargs ...)` - Two features from Vectors.
- `(features::Dict{String, <:AbstractVector}, x::String, y::String, colors::Vector{String} = [randcolor() for e in 1:length(features)]; width::Int64 = 500, 
height::Int64 = 500, keyargs ...)` -- More than two features from a dictionary.
- `(features::Any, args ...; keyargs ...)` -- More than two features from `Base`-compliant data structures. (Uses `names`, `eachcol`).

####### key-word arguments

####### crucial information
All of these dispatches are simply calls which translate data into arguments for these functions' 
    mutating equivalents. The mutating equivalents are just the functions with `_plot!` after them:
```julia
scatter_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; 
    divisions::Int64 = 4, title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))

```
"""
module Gattino
using Toolips
import Toolips: style!, write!, animate!
import Base: getindex, setindex!, show, display, vcat, push!, hcat, size, reshape
using ToolipsDefaults
using ToolipsSVG
import ToolipsSVG: position, set_position!, set_size!
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
    colors = ["#FF6633", "#FFB399", "#FF33FF", "#FFFF99", "#00B3E6", 
    "#E6B333", "#3366E6", "#999966", "#99FF99", "#B34D4D",
    "#80B300", "#809900", "#E6B3B3", "#6680B3", "#66991A", 
    "#FF99E6", "#CCFF1A", "#FF1A66", "#E6331A", "#33FFCC",
    "#66994D", "#B366CC", "#4D8000", "#B33300", "#CC80CC", 
    "#66664D", "#991AFF", "#E666FF", "#4DB3FF", "#1AB399",
    "#E666B3", "#33991A", "#CC9999", "#B3B31A", "#00E680", 
    "#4D8066", "#809980", "#E6FF80", "#1AFF33", "#999933",
    "#FF3380", "#CCCC00", "#66E64D", "#4D80CC", "#9900B3", 
    "#E64D66", "#4DB380", "#FF4D4D", "#99E6E6", "#6666FF"]
    colors[rand(1:length(colors))]::String
end

"""
```julia
scatter_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; 
divisions::Int64 = 4, title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))
```
---
Mutates `con` by drawing a scatter plot onto it. `divisions` is the number of rows and columns for the grid and its labels.
```example
color = randcolor()
```
"""
function scatter_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; 
    divisions::Int64 = 4, title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))
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
            points!(g, x, y, "fill" => colors[1])
        end
        xmax = maximum(x)
        ymax = maximum(y)
        lbls = [begin
            group!(plotgroup, feature[1]) do g::Group
                points!(g, x, feature[2], "fill" => colors[e], xmax = xmax, ymax = ymax)
            end
            string(feature[1])::String
        end for (e, feature) in enumerate(features)]
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions)
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
from a data structure using a single function call. (returns a `Context`)
###### scatter methods
A scatter plot must always take at least an X or Y, which must both be numeric.
```julia
(x::Vector{<:Any}, args ...; width::Int64 = 500, height::Int64 = 500, 
keyargs ...) = scatter_plot!(Context(width, height), x, args ...; keyargs ...)
```
Plots a scatter plot from two features as Vectors.
```julia
(features::Dict{String, <:AbstractVector}, x::String, y::String, colors::Vector{String} = [randcolor() for e in 1:length(features)]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
```
Plots a scatter plot from more than two features from a Dictionary.
```julia
(features::Any, args ...; keyargs ...)
```
Plots a scatter plot from any compatible julia data structure (uses `names` and `eachcol`)
"""
function scatter end

scatter(x::Vector{<:Any}, args ...; width::Int64 = 500, height::Int64 = 500, 
keyargs ...) = scatter_plot!(Context(width, height), x, args ...; keyargs ...)

function scatter(features::Dict{String, <:AbstractVector}, x::String, y::String, colors::Vector{String} = [randcolor() for e in 1:length(features)]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
    newfs = filter(k -> ~(string(k[1]) == x || string(k[1]) == y), features)
    context(width, height) do con::Context
        scatter_plot!(con, features[x], features[y], pairs(newfs) ...; colors = colors, keyargs ...)
    end
end

function scatter(features::Any, args ...; keyargs ...)
    try
        features = Dict{String, AbstractVector}(string(name) => Vector(col) for (name, col) in zip(names(features), eachcol(features)))
    catch
        throw("$(typeof(features)) is not compatible with `Gattino`. (Gattino uses `names` and `eachcol`.)")
    end
    scatter(features, args ...; keyargs ...)
end

function line_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; divisions::Int64 = 4, xlabel::String = "", 
    ylabel::String = "", legend::Bool = true, title::String = "", colors::Vector{String} = Vector{String}(["#FF6633"]))
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
        ml, mt = Int64(round(con.dim[1] * .12)) + con.margin[1], Int64(round(con.dim[2] * .12)) + con.margin[2]
    end
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
            line!(g, x, y)
        end
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions)
        end
        xmax = maximum(x)
        ymax = maximum(y)
        lbls = [begin
            group!(plotgroup, feature[1]) do g::Group
                line!(g, x, feature[2], "fill" => colors[e], xmax = xmax, ymax = ymax)
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
line_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; 
divisions::Int64 = 4, title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))
```
---
Mutates `con` by drawing a scatter plot onto it. `divisions` is the number of rows and columns for the grid and its labels.
```example
color = randcolor()
```
"""
function line_plot!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; divisions::Int64 = length(x), title::String = "", 
    xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))
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
        ml, mt = Int64(round(con.dim[1] * .12)) + con.margin[1], Int64(round(con.dim[2] * .12)) + con.margin[2]
    end
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
            line!(g, x, y)
        end
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions)
        end
        ymax = maximum(y)
        lbls = [begin
            group!(plotgroup, feature[1]) do g::Group
                line!(g, x, feature[2], "fill" => colors[e], ymax = ymax)
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
---
`line`, `scatter`, and `hist` are all high-level plotting functions used to create a `Context` and display features 
from a data structure using a single function call. (returns a `Context`)
###### line
A `line` plot is able to support an X feature which is non-numeric.
```julia
(x::Vector{<:Any}, args ...; width::Int64 = 500, height::Int64 = 500, 
keyargs ...) = scatter_plot!(Context(width, height), x, args ...; keyargs ...)
```
Plots a scatter plot from two features as Vectors.
```julia
(features::Dict{String, <:AbstractVector}, x::String, y::String, colors::Vector{String} = [randcolor() for e in 1:length(features)]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
```
Plots a scatter plot from more than two features from a Dictionary.
```julia
(features::Any, args ...; keyargs ...)
```
Plots a scatter plot from any compatible julia data structure (uses `names` and `eachcol`)
---
"""
function line end

function line(args ...; keyargs ...)
    context(500, 500) do con::Context
        line_plot!(con, args ...; keyargs ...)
    end
end

function line(features::Dict{String, <:AbstractVector}, x::String, y::String, colors::Vector{String} = [randcolor() for e in 1:length(features)]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
    newfs = filter(k -> ~(string(k[1]) == x || string(k[1]) == y), features)
    context(width, height) do con::Context
        line_plot!(con, features[x], features[y], pairs(newfs) ...; colors = colors, keyargs ...)
    end
end

function line(features::Any, args ...; keyargs ...)
    try
        features = Dict{String, AbstractVector}(string(name) => Vector(col) for (name, col) in zip(names(features), eachcol(features)))
    catch
        throw("$(typeof(features)) is not compatible with `Gattino`. (Gattino uses `names` and `eachcol`.)")
    end
    line(features, args ...; keyargs ...)
end

"""
```julia
hist!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, features::Pair{String, <:AbstractVector} ...; 
divisions::Int64 = 4, title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))
```
---
Mutates `con` by drawing a scatter plot onto it. `divisions` is the number of rows and columns for the grid and its labels.
```example
color = randcolor()
```
"""
function hist_plot!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number} = Vector{Int64}(), features::Pair{String, <:AbstractVector} ...; 
    divisions::Int64 = length(x), title::String = "", xlabel::String = "", ylabel::String = "", legend::Bool = true, colors::Vector{String} = Vector{String}(["#FF6633"]))
    hist = false
    if length(y) == 0
        hist = true
    elseif length(x) != length(y)
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
        ml, mt = Int64(round(con.dim[1] * .12)) + con.margin[1], Int64(round(con.dim[2] * .12)) + con.margin[2]
    end
    group(con, w, h, ml => mt) do plotgroup::Group
        group!(plotgroup, "axes") do g::Group
            axes!(g)
        end
        group!(plotgroup, "grid") do g::Group
            grid!(g, divisions)
        end
        group!(plotgroup, "bars") do g::Group
            if ~(hist)
                bars!(g, x, y)
                return
            end
            bars!(g, x)
        end
        group!(plotgroup, "labels") do g::Group
            barlabels!(g, x)
            gridlabels!(g, y, divisions)
        end
        group!(plotgroup, "axislabels") do g::Group

        end
    end
    con::AbstractContext
end

"""
```julia
hist -> ::AbstractContext
```
---
`hist`, `scatter`, and `line` are all high-level plotting functions used to create a `Context` and display features 
from a data structure using a single function call. (returns a `Context`)
###### hist methods
A histogram may be used with a single feature, and when used with multiple features a single (X) feature may be non-numeric.
```julia
(x::Vector{<:Any}, args ...; width::Int64 = 500, height::Int64 = 500, 
keyargs ...) = scatter_plot!(Context(width, height), x, args ...; keyargs ...)
```
Plots a scatter plot from two features as Vectors.
```julia
(features::Dict{String, <:AbstractVector}, x::String, y::String, colors::Vector{String} = [randcolor() for e in 1:length(features)]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
```
Plots a scatter plot from more than two features from a Dictionary.
```julia
(features::Any, args ...; keyargs ...)
```
Plots a scatter plot from any compatible julia data structure (uses `names` and `eachcol`)
"""
hist(x::Vector{<:Any}, args ...; width::Int64 = 500, height::Int64 = 500, keyargs ...) = hist!(Context(width, height), x, args ...; keyargs ...)

function hist(features::Dict{String, <:AbstractVector}, x::String, y::String, colors::Vector{String} = [randcolor() for e in 1:length(features)]; width::Int64 = 500, 
    height::Int64 = 500, keyargs ...)
    newfs = filter(k -> ~(string(k[1]) == x || string(k[1]) == y), features)
    context(width, height) do con::Context
        hist_plot!(con, features[x], features[y], pairs(newfs) ...; colors = colors, keyargs ...)
    end
end

function hist(features::Any, args ...; keyargs ...)
    try
        features = Dict{String, AbstractVector}(string(name) => Vector(col) for (name, col) in zip(names(features), eachcol(features)))
    catch
        throw("$(typeof(features)) is not compatible with `Gattino`. (Gattino uses `names` and `eachcol`.)")
    end
    hist(features, args ...; keyargs ...)
end

export Group, group!, style!, px, pt, group, layers, context, move_layer!, seconds, percent, Context, Animation
export compose, delete_layer!, open_layer!, merge!, set!, set_gradient!, set_shape!
export hist, scatter, line
end # module
