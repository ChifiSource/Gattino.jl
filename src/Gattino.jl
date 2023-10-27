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
    con::Context = Context(width, height, margin)
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
    con
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
    divisions::Int64 = length(x), title::String = "", args ...) = begin
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

export line, hist, scatter, Group, group!, Context, style!
end # module
