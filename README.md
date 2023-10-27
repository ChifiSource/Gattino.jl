<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/gattino.png" width = 250 />
  <h4>gattino</h4>
</div>
<div align="left">

**Gattino.jl** is a new extensible plotting library built atop the SVG templating capabilities of the [Toolips.jl](http://github.com/ChifiSource/Toolips.jl) web-framework. Gattino features toolips-like extensibility, functional programming, and introspectable plotting. This module is in its infancy, but is still able to be used for some things. The high level methods are currently...
```julia
scatter(x::Vector{<:Number}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = 4,
    title::String = "", args ...)

line(x::Vector{<:Number}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = 4,
    title::String = "", args ...)

line(x::Vector{<:Any}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0;
    divisions::Int64 = length(x), title::String = "", args ...)

hist(x::Vector{<:Any}, y::Vector{<:Number}, width::Int64 = 500, height::Int64 = 500,
    margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = length(x))
```
We will be adding more as well as extensions as time goes on, we are still working on a lot of other projects, so this one might be some magnitutude of time.
