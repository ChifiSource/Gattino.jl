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

function points!(con::Context, x::Vector{<:Number}, y::Vector{<:Number},
     styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "orange", "stroke" => "lightblue", "stroke-width" => "0")
    end
    xmax::Number, ymax::Number = maximum(x), maximum(y)
     percvec_x = map(n::Number -> n / xmax, x)
     percvec_y = map(n::Number -> n / ymax, y)
    [begin
        c = circle(randstring(), cx = string(pointx * con.dim[1]), cy = string(pointy * con.dim[2]), r = "5")
            style!(c, styles ...)
            draw!(con, [c])
        end for (pointx, pointy) in zip(percvec_x, percvec_y)]
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
