module Prrty
using Toolips
using ToolipsDefaults
using ToolipsSVG
using Contexts
import Contexts: line!
include("context_plotting.jl")

scatter(x::Vector{<:Number}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = 4,
    title::String = "", args ...) = begin
    con::Context = Context(width, height, margin)
    group!(con, "plotbase") do g::Group
        axes!(con)
        grid!(con, divisions)
    end
    group!(con, "points") do g::Group
        points!(con, x, y)
    end
    con
end

line(x::Vector{<:Number}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = 4,
title::String = "", args ...) = begin
    con::Context = Context(width, height, margin)
end
include("Dashboards.jl")
end # module
