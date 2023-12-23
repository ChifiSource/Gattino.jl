module Gattino
using Toolips
import Toolips: style!, write!, animate!
import Base: getindex, setindex!, show, display, vcat, push!, hcat, size, reshape
using ToolipsDefaults
using ToolipsSVG
import ToolipsSVG: position, set_position!, set_size!
using Random: randstring

include("context_plotting.jl")


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
        group!(plotgroup, "$orlabel") do g::Group
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


scatter(x::Vector{<:Any}, args ...; keyargs ...) = scatter_plot!(Context(500, 500), x, args ...; keyargs ...)

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

function line_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}; divisions::Int64 = 4, title::String = "")
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
        group!(plotgroup, "line") do g::Group
            line!(g, x, y)
        end
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions)
        end
     #==   group!(plotgroup, "axislabels") do g::Group

        end ==#
    end
    con::AbstractContext
end

function line_plot!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number}; divisions::Int64 = length(x), title::String = "")
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
        group!(plotgroup, "line") do g::Group
            line!(g, x, y)
        end
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions)
        end
#==        group!(plotgroup, "axislabels") do axesgroup::Group

        end ==#
    end
    con::AbstractContext
end

function line_plot!(con::AbstractContext, x::Vector{<:Number}; keyargs ...)
    line_plot!(con, x, [e for e in 1:length(x)], keyargs ...)::AbstractContext
end

function line(args ...; keyargs ...)
    context(500, 500) do con::Context
        line_plot!(con, args ...; keyargs ...)
    end
end

function hist!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number}; divisions::Int64 = length(x), title::String = "")
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
        group!(plotgroup, "bars") do g::Group
            bars!(g, x, y)
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

hist(x::Vector{<:Any}, args ...; keyargs ...) = hist!(Context(500, 500), x, args ...; keyargs ...)

export Group, group!, style!, px, pt, group, layers, context, move_layer!, seconds, percent, Context, Animation
export compose, delete_layer!, open_layer!, merge!, set!, set_gradient!, set_shape!
export hist, scatter, line
end # module
