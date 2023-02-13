mutable struct Context <: Toolips.Modifier
    window::Component{:svg}
    n::Int64
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(window::Component{:svg}, margin::Pair{Int64, Int644}) = new(window,
    parse(window[:width], Int64) => parse(window[:height], int64), margin)
    function Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0)
        window::Component{:svg} = svg(randstring(10), width = width,
        height = height)
        Context(window, 0, 1280 => 720,  margin)::Context
    end
end

function context!(f::Function, window::Component{:svg},
    margin::Pair{Int64, Int64} = 0 => 0)
    context::Context = Context(window, margin)
    f(context)
end

function line!(context::Context, name)

end

function grid!(context::Context, n::Int64 = 4)
    division_amountx::Int64 = context.dim[1] / n
    division_amounty::Int64 = context.dim[2] / n
    [begin
    line("context$(context.n)", "x1" => string(context.dim))
    context.n += 1
    end for (xcoord, ycoord) in zip(
    range(1 + context.margin[1], context.dim[1], step = division_amountx),
     range(1 + context.margin[2], context.dim[2]), step = divisionamounty)]
end

function points!(context::Context, x::Vector{<:Number}, y::Vector{<:Number},
     p::Pair{String, Any} ...; args ...)
    circs::Vector{Servable} = Vector{Servable}([begin
        context.n += 1
        circle("context$(context.n)", cx = string(pointx), cy = string(pointy), p...,
        args ...)
    end for (pointx, pointy) in zip(x, y)])
    context.window[:children] = vcat(context.window[:children], circs)
end

function trendline!(context::Context, styles::Pair{String, String} ...)

end


function histo!(x::)

end
