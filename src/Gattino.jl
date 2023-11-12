module Gattino
using Toolips
import Toolips: style!, write!, animate!
import Base: getindex, setindex!, show, display, vcat, push!, hcat
using ToolipsDefaults
using ToolipsSVG
import ToolipsSVG: size, position
using Random: randstring

include("context_plotting.jl")

function scatter_plot!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}; divisions::Int64 = 4, title::String = "")
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
    group(con, w, h, ml => mt) do plotgroup::Group
        group!(plotgroup, "axes") do g::Group
            axes!(g)
        end
        group!(plotgroup, "grid") do g::Group
            grid!(g, divisions)
        end
        group!(plotgroup, "points") do g::Group
            points!(g, x, y)
        end
        group!(plotgroup, "labels") do g::Group
            gridlabels!(g, x, y, divisions)
        end
        group!(plotgroup, "axislabels") do g::Group

        end
    end
    con::AbstractContext
end

scatter(args ...; keyargs ...) = scatter_plot!(Context(500, 500), args ...; keyargs ...)

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
