mutable struct Context <: Toolips.Servable
    window::Component{:svg}
    dim::Tuple{Int64}
    margin::Pair{Int64, Int64}
    function Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0)

    end
end

function context!(f::Function, window::Component{:svg})

end

function grid!(window::Component{:svg}; styles::Pair{String, String} ...)

end

function points!(window::Component{:svg}, styles::Pair{String, String} ...)

end

function trendline!(window::Component{:svg}, styles::Pair{String, String} ...)

end
