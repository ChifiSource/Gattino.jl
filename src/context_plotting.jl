function grid!(con::Context, n::Int64 = 4, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "lightblue", "stroke-width" => "1", "opacity" => 80percent)
    end
    division_amountx::Int64 = round(con.dim[1] / n)
    division_amounty::Int64 = round(con.dim[2] / n)
    [begin
        line!(con, xcoord => 0, xcoord => con.dim[2], styles ...)
        line!(con, 0 => ycoord, con.dim[1] => ycoord, styles ...)
    end for (xcoord, ycoord) in zip(
    range(1 + con.margin[1], con.dim[1],
    step = division_amountx), range(1 + con.margin[2], con.dim[2], step = division_amounty))]
end

function points!(context::Context, x::Vector{<:Number}, y::Vector{<:Number},
     p::Pair{String, Any} ...; args ...)
     percvec_x = map(n::Number -> n / xmax, x)
     percvec_y = map(n::Number -> n / ymax, y)
     xmax::Number, ymax::Number = maximum(x), maximum(y)
    circs::Vector{Servable} = Vector{Servable}([begin
        context.n += 1
        circle("context$(context.n)", cx = string(pointx), cy = string(pointy), p...,
        args ...)
    end for (pointx, pointy) in zip(x, y)])
    context.window[:children] = vcat(context.window[:children], circs)
end

function axes!(con::AbstractContext, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    line!(con, 0 => con.dim[2], con.dim[1] => con.dim[2], styles ...)
    println(con.window[:children])
    line!(con, 0 => 0, 0 => con.dim[2], styles ...)
end

function trendline!(context::Context, styles::Pair{String, String} ...)

end

function edit!(c::Context)

end

function drop!(c::Context)

end

function histo!(x::)

end
