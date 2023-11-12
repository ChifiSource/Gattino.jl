include("Contexts.jl")

function line!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number},
        styles::Pair{String, <:Any} ...; ymax::Number = maximum(y))
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    if length(x) != length(y)
        throw(DimensionMismatch("x and y, of lengths $(length(x)) and $(length(y)) are not equal!"))
    end
    # Convert unique string values in x to numerical values
    unique_strings = unique(x)
    string_map = Dict(unique_strings[i] => i for i in 1:length(unique_strings))
    numeric_x = [string_map[s] for s in x]
    xmax::Number = maximum(numeric_x)
    percvec_x = map(n::Number -> n / xmax, numeric_x)
    percvec_y = map(n::Number -> n / ymax, y)
    line_data = join([begin
                    scaled_x::Int64 = round(con.dim[1] * xper)  + con.margin[1]
                    scaled_y::Int64 = con.dim[2] - round(con.dim[2] * yper)  + con.margin[2]
                    "$(scaled_x)&#32;$(scaled_y),"
                end for (xper, yper) in zip(percvec_x, percvec_y)])
    line_comp = ToolipsSVG.polyline("newline", points = line_data)
    style!(line_comp, styles ...)
    draw!(con, [line_comp])
end

function line!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number},
    styles::Pair{String, <:Any} ...)
    line!(con, [string(d) for d in x], y, styles ...)
end

function gridlabels!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
                      n::Int64 = 4, styles::Pair{String, <:Any}...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 10pt)
    end
    mx = con.margin[1]
    my = con.margin[2]
    division_amountx::Int64 = round((con.dim[1]) / n)
    division_amounty::Int64 = round((con.dim[2]) / n)
    x_offset = division_amountx * .30
    y_offset = division_amounty * .30
    cx = 0
    xstep = round(maximum(x) / n)
    ystep = round(maximum(y) / n)
    cy = maximum(y)
        [begin
        text!(con, xcoord + mx, con.dim[2] - 10 + my, string(cx), styles ...)
        text!(con, 0 + mx, ycoord + my, string(cy), styles ...)
        cx += xstep
        cy -= ystep
        end for (xcoord, ycoord) in zip(
    range(1, con.dim[1],
    step = division_amountx), range(1, con.dim[2], step = division_amounty))]
end

function gridlabels!(con::AbstractContext, y::Vector{<:Number}, n::Int64 = 4, styles::Pair{String, String} ...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 10pt)
    end
    my = con.margin[2]
    mx = con.margin[1]
    division_amounty::Int64 = Int64(round((con.dim[2]) / n))
    y_offset = Int64(round(division_amounty * .3))
    ystep = Int64(round(maximum(y) / n))
    permx = Int64(round(con.dim[1] * .05))
    cy = maximum(y)
        [begin
        text!(con, permx + mx, ycoord + my + y_offset, string(cy), styles ...)
        cy -= ystep
        end for ycoord in range(1, con.dim[2], step = division_amounty)]
end

function gridlabels!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number},
                      n::Int64 = 4, styles::Pair{String, <:Any}...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 10pt)
    end
    unique_strings = unique(x)
    mx = con.margin[1]
    my = con.margin[2]
    division_amountx::Int64 = round((con.dim[1]) / n)
    division_amounty::Int64 = round((con.dim[2]) / n)
    x_offset = Int64(round(division_amountx * .75))
    y_offset = Int64(round(division_amounty * .10))
    cx = 1
    xstep = 1
    ystep = round(maximum(y) / n)
    cy = maximum(y)
    [begin
        if cx <= length(unique_strings)
            text!(con, xcoord + mx - x_offset, con.dim[2] - 10 + my, unique_strings[Int64(round(cx))], styles ...)
        end
        text!(con, 0 + mx, ycoord + my - y_offset, string(cy), styles ...)
        cx += xstep
        cy -= ystep
    end for (xcoord, ycoord) in zip(
            range(division_amountx, con.dim[1], step = division_amountx),
            range(1, con.dim[2], step = division_amounty))]
end

function gridlabels!(con::AbstractContext, x::Vector{<:Any}, y::Vector{<:Number},
    n::Int64 = 4, styles::Pair{String, <:Any} ...)
    gridlabels!(con, [string(v) for v in x], y, n, styles ...)
end

function line!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
        styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    if length(x) != length(y)
        throw(DimensionMismatch("x and y, of lengths $(length(x)) and $(length(y)) are not equal!"))
    end
    xmax::Number, ymax::Number = maximum(x), maximum(y)
    percvec_x = map(n::Number -> n / xmax, x)
    percvec_y = map(n::Number -> n / ymax, y)
    line_data = join([begin
                    scaled_x::Int64 = round(con.dim[1] * xper)  + con.margin[1]
                    scaled_y::Int64 = con.dim[2] - round(con.dim[2] * yper)  + con.margin[2]
                    "$(scaled_x)&#32;$(scaled_y),"
                end for (xper, yper) in zip(percvec_x, percvec_y)])
    line_comp = ToolipsSVG.polyline("newline", points = line_data)
    style!(line_comp, styles ...)
    draw!(con, [line_comp])
end

function grid!(con::AbstractContext, n::Int64 = 4, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "lightblue", "stroke-width" => "1", "opacity" => 80percent)
    end
    mx = con.margin[1]
    my = con.margin[2]
    division_amountx::Int64 = round((con.dim[1]) / n)
    division_amounty::Int64 = round((con.dim[2]) / n)
    [begin
        line!(con, xcoord + mx => 0 + my, xcoord + mx => con.dim[2] + my, styles ...)
        line!(con, 0 + mx => ycoord + my, con.dim[1] + mx => ycoord + my, styles ...)
    end for (xcoord, ycoord) in zip(
    range(1, con.dim[1],
    step = division_amountx), range(1, con.dim[2], step = division_amounty))]
end

function points!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number},
     styles::Pair{String, <:Any} ...; ymax::Number = maximum(y), xmax::Number = maximum(x))
    if length(styles) == 0
        styles = ("fill" => "orange", "stroke" => "lightblue", "stroke-width" => "0")
    end
    percvec_x::Vector{<:Number} = map(n::Number -> n / xmax, x)
    percvec_y::Vector{<:Number} = map(n::Number -> n / ymax, y)
    draw!(con, Vector{Servable}([begin
        c = circle(randstring(), cx = pointx * con.dim[1] + con.margin[1],
                cy = con.dim[2] - (con.dim[2] * pointy) + con.margin[2], r = 5)
            style!(c, styles ...)
            c
        end for (pointx, pointy) in zip(percvec_x, percvec_y)]))
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

function axislabels!(con::AbstractContext, styles::Pair{String, <:Any} ...)

end

function bars!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...; ymax::Number = maximum(y))
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    n_features::Int64 = length(x)
    ymax::Number = maximum(y)
    n = 0
    percvec_y = map(n::Number -> n / ymax, y)
    block_width = Int64(round(con.dim[1] / n_features))
    rects = Vector{Servable}([begin
        scaled_y::Number = Int64(round(con.dim[2] * percvec_y[e]))
        rct = ToolipsSVG.rect(randstring(), x = Int64(round(n)) + con.margin[1],  y = con.dim[2] - scaled_y + con.margin[2], 
        width = block_width, height = con.dim[2] - (con.dim[2] - scaled_y))
        style!(rct, styles ...)
        n += block_width
        rct
    end for e in 1:n_features])
    draw!(con, rects)
end

bars!(con::AbstractContext, x::Vector{<:Number}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...; ymax::Number = maximum(y)) = begin
    bars!(con, [string(v) for v in x], y, styles ...; ymax = ymax)
end

function barlabels!(con::AbstractContext, x::Vector{<:AbstractString}, styles::Pair{String, String} ...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 11pt)
    end
    n_features::Int64 = length(x)
    block_width = Int64(round(con.dim[1] / n_features))
    offset::Int64 = Int64(round(block_width * .15))
    perm_y = Int64(round(con.dim[2] - con.dim[2] * .20))
    [begin
        text!(con, xval + con.margin[1] + offset, perm_y, x[e], styles ...)
    end for (e, xval) in enumerate(range(1, n_features * block_width, step = block_width))]
    return
end

function v_bars!(con::AbstractContext, x::Vector{<:AbstractString}, y::Vector{<:Number}, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    n_features::Int64 = length(x)
    ymax::Number = maximum(y)
    n = 0
    percvec_y = map(n::Number -> n / ymax, y)
    block_width = Int64(round(con.dim[2] / n_features))
    rects = Vector{Servable}([begin
        scaled_y::Number = Int64(round(con.dim[2] * percvec_y[e]))
        rct = ToolipsSVG.rect(randstring(), x = 0, y = n, 
        width = con.dim[1] - (con.dim[1] - scaled_y), height = block_width)
        style!(rct, styles ...)
        n += block_width
        rct
    end for e in 1:n_features])
    draw!(con, rects)
end

function v_barlabels!(con::AbstractContext, x::Vector{<:AbstractString}, styles::Pair{String, String} ...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 11pt)
    end
    n_features::Int64 = length(x)
    block_width = Int64(round(con.dim[2] / n_features))
    offset::Int64 = Int64(round(block_width * .5))
    perm_x = Int64(round(con.dim[1] * .14))
    [begin
        text!(con, perm_x + con.margin[1], yval + offset + con.margin[2], x[e], styles ...)
    end for (e, yval) in enumerate(range(1, n_features * block_width, step = block_width))]
    return
end

function whisker_box!(con::AbstractContext)

end

function vwhisker_boxes!(con::AbstractContext)

end
function legend!(con::AbstractContext, layers::Vector{String}, styles::Pair{String, String})

end