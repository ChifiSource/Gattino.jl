module Gattino
using Toolips
import Toolips: style!, write!
import Base: getindex, setindex!, show, display
using ToolipsDefaults
using ToolipsSVG
using Random: randstring

include("context_plotting.jl")

scatter(x::Vector{<:Number}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = 4,
    title::String = "", args ...) = begin
    cont::Context = context(width, height, margin) do con::Context
        group!(con, "axes") do g::Group
            axes!(g)
        end
        group!(con, "grid") do g::Group
            grid!(g, divisions)
        end
        group!(con, "points") do g::Group
            points!(g, x, y)
        end
        group!(con, "labels") do g::Group
            gridlabels!(g, x, y, divisions)
        end
    end
    con::Context
end

line(x::Vector{<:Number}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = 4,
    title::String = "", args ...) = begin
    con::Context = Context(width, height, margin)
    group!(con, "axes") do g::Group
        axes!(g)
    end
    group!(con, "grid") do g::Group
        grid!(g, divisions)
    end
    group!(con, "line") do g::Group
        line!(g, x, y)
    end
    group!(con, "labels") do g::Group
        gridlabels!(g, x, y, divisions)
    end
    con
end

line(x::Vector{<:Any}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0;
    divisions::Int64 = length(x), title::String = "") = begin
    if length(x) != length(y)
        throw(
            DimensionMismatch("x and y must be of the same length! got ($(length(x)), $(length(y)))")
        )
    end
    con::Context = Context(width, height, margin)
    w::Int64, h::Int64 = width, height
    ml::Int64, mt::Int64 = margin[1], margin[2]
    if title != ""
        group!(con, "title") do titlegroup::Group
            posx = Int64(round(con.dim[1] * .35))
            posy = Int64(round(con.dim[2] * .08))
            text!(con, posx, posy, title, "fill" => "black", "font-size" => 15pt)
        end
        w, h = Int64(round(con.dim[1] * .75)), Int64(round(con.dim[2] * .75))
        ml, mt = Int64(round(con.dim[1] * .12)), Int64(round(con.dim[2] * .12))
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
        group!(con, "axislabels") do axesgroup::Group

        end
    end
    con::Context
end

hist(x::Vector{<:Any}, y::Vector{<:Number}, width::Int64 = 500, height::Int64 = 500,
    margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = length(x)) = begin
    con::Context = Context(width, height, margin)
    group!(con, "axes") do g::Group
        axes!(g)
    end
    group!(con, "grid") do g::Group
        grid!(g, divisions)
    end
    group!(con, "bars") do g::Group
        bars!(g, x, y)
    end
    group!(con, "labels") do g::Group
        gridlabels!(g, x, y, divisions)
    end
    con
end

export Group, group!, style!, px_str, pt_str, group, layers, context, move_layer
end # module
