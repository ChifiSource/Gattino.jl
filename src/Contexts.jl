mutable struct Context <: Toolips.Modifier
    window::Component{:svg}
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(window::Component{:svg}, margin::Pair{Int64, Int644}) = new(window,
    parse(window[:width], Int64) => parse(window[:height], int64), margin)
    function Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0)
        window::Component{:svg} = svg(randstring(10), width = width,
        height = height)
        Context(window, margin)::Context
    end
end

function context!(f::Function, window::Component{:svg},
    margin::Pair{Int64, Int64} = 0 => 0)
    context::Context = Context(window, margin)
    f(context)
end

function line!(context::Context, n::Int64)

end

function grid!(context::Context, n::Int64;
    styles::Pair{String, String} ...)
    [begin

    end for (xcoord, ycoord) in zip()]
end

function points!(context::Context, x::Vector{<:Number}, y::Vector{<:Number},
     styles::Pair{String, String} ...)
    circs::Vector{Servable} = Vector{Servable}([begin

    end for point in zip(x, y)])
end

function trendline!(context::Context, styles::Pair{String, String} ...)

end


function histo!(x::)

end
