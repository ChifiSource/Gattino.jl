function grid!(con::AbstractContext, n::Int64 = 4, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "lightblue", "stroke-width" => "1", "opacity" => 80percent)
    end
    mx = con.margin[1]
    my = con.margin[2]
    division_amountx::Int64 = round((con.dim[1]) / n)
    division_amounty::Int64 = round((con.dim[2]) / n)
    (begin
        line!(con, xcoord + mx => 0 + my, xcoord + mx => con.dim[2] + mx, styles ...)
        line!(con, 0 + mx => ycoord + my, con.dim[1] + mx => ycoord + my, styles ...)
    end for (xcoord, ycoord) in zip(
    range(1, con.dim[1],
    step = division_amountx), range(1, con.dim[2], step = division_amounty)))
end

function points!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
     styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "orange", "stroke" => "lightblue", "stroke-width" => "0")
    end
    xmax::Number, ymax::Number = maximum(x), maximum(y)
     percvec_x::Vector{Float64} = map(n::Number -> n / xmax, x)
     percvec_y::Vector{Float64} = map(n::Number -> n / ymax, y)
    (begin
        c = circle(randstring(), cx = string(pointx * con.dim[1] + con.margin[1]),
                cy = string(pointy * con.dim[2] + con.margin[2]), r = "5")
            style!(c, styles ...)
            draw!(con, [c])
        end for (pointx, pointy) in zip(percvec_x, percvec_y))
end

function axes!(con::AbstractContext, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    line!(con, con.margin[1] => con.dim[2] + con.margin[2],
    con.dim[1] + con.margin[1] => con.dim[2] + con.margin[2], styles ...)
    line!(con, con.margin[1] => con.margin[2],
    con.margin[1] => con.dim[2] + con.margin[2], styles ...)
end

function trendline!(context::Context, styles::Pair{String, String} ...)

end

function edit!(c::Context)

end

function drop!(c::Context)

end

function histo!(x::)

end
