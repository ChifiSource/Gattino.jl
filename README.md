<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/gattino.png" width = 250 />
  <h4>gattino</h4>
</div>
<div align="left">

Gattino is Toolips-based plotting for Julia. This project's base package is still in early development, but gattino plans to feature
- An extension **ecosystem**.
- Introspectable, mutable **high-level plotting**.
- **Animated** visualizations.
- **Interactive** visualizations.
- **easy** styling syntax
- In-ecosystem **dashboard toolkits**.
- In-server **deployment**.
- **Scaling** graphics.

There is currently a lot underway when it comes to [Chifi](https://github.com/ChifiSource/) packages, so this package is currently a **work in progress**.
##### map
- [getting started](#getting-started)
   - [adding gattino](#adding-gattino)
   - [resources](#resources)
- [visualizations](#visualizations)
  - [creating visualizations](#creating-visualizations)
  - [layouts](#layouts)
  - [working with layers](#working-with-layers)
  - [annotations](#annotations)
  - [animation](#animation)
- [context plotting](#context-plotting)
  - [lines](#plotting-lines)
  - [shapes](#plotting-shapes)
  - [other](#plotting-other-stuff)
- [examples](#examples)
- [adding more](#adding-more)
## getting started
##### adding gattino
Before `Gattino` is merged to the Julia `General` `Pkg` registry, `Gattino will need to be added by URL.
```julia
using Pkg; Pkg.add(url = "https://github.com/ChifiSource/Gattino.jl")
using Gattino
```
If you would like to use the `Unstable` version of Gattino, which will have more features but be less stable, set the `rev` key-word argument to `Unstable`.
```julia
using Pkg; Pkg.add(url = "https://github.com/ChifiSource/Gattino.jl", rev = "Unstable")
using Gattino
```
###### resources
[chifi](https://github.com/ChifiSource) is currently working an in-ecosystem [Olive](https://github.com/ChifiSource/Olive.jl)-based documentation (and notebook) webapp which will hold the documentation for this project as well as other modules from this organization. While this new interactive documentation is still in the works, the resources for information on `Gattino` will be limited to
- this `README`
- [gattino notebooks](https://github.com/ChifiSource/OliveNotebooks.jl/tree/main/gattino)

Fortunately, we have a lot of plans for resources coming in the future and if this `README` is on the main branch it probably means that these plans are pretty well in motion; `Gattino` is meant to be coming at around the same time as these new resources.
## visualizations
- [notebook]()
##### creating visualizations
While `Gattino` plots are completely composable and can be made by composing [context plotting](#context-plotting) elements together, the module also comes with some high-level functions which may be used to produce standard visualizations we are likely familiar with. These examples currently include `scatter`, `line`, and `hist`.
```julia
scatter(x::Vector, y::Vector, divisions::Int64 = 4, title::String = "")

line(x::Vector, y::Vector, divisions::Int64 = 4, title::String = "")

hist(x::Vector, y::Vector, divisions::Int64 = 4, title::String = "")
```
These methods are used to create a minimalistic visualization which can be further mutated with other `Gattino` methods. In each of these examples,the return type will be an `AbstractContext`. Let's make our first histogram with `Gattino`.
```julia
myhist = hist(["emma", "emmy", "em"], [22, 25, 14], title = "votes for names")
```

<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/docsc/firsthist.png"></img></div>

The `hist` function is just a passthrough to `hist!`, which is a [context plotting](#context-plotting) function that creates a histogram. Notably, `hist` will create a new `Context` for us and `hist!` expects us to provide an `AbstractContext` as an argument. The `line` and `scatter` equivalence to this is found in `scatter_plot!` and `line_plot!`. That being said, if we want to add a visualization to a `Context` that already exists, we would use these methods, rather than the high-level method. When using `hist!` we will want to add our histogram to an old plot, when using `hist` we will be making a new plot with a new window. Here, I will use the `context` and `group!` functions to compose a scatter with the `scatter_plot!` method.
```julia
myframe = context(500, 500) do con::Context
    group!(con, "scatter", 250, 250) do g::Group
        Gattino.scatter_plot!(g, [1, 2, 3, 4], [1, 2, 3, 4])
    end
end
```

<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/docsc/secondplot.png"></img></div>

Graphics in `Gattino` are scaled using the `Context` and `Group` types. A `Context` represents a window, whereas a `Group` represents an area in that window. To create a context, we use the `context` method.
- `context(f::Function, width::Int64 = 1280, height::Int64= 720, margin::Pair{Int64, Int64} = 0 => 0)`
```julia
mycontext = context(500, 500) do con::Context

end
```
This `Context` can now be used with [context plotting](#context-plotting) methods. There are two different types of `group` which we can use on our project,
` `group!` is the mutating group -- this will add anything drawn to the group to the `Context`.
- `group` is non-mutating group -- anything we draw will not be drawn onto the window.

The methods are

- `group(f::Function, c::AbstractContext, w::Int64, h::Int64, margin::Pair{Int64, Int64})`
- `group!(f::Function, c::AbstractContext, name::String, w::Int64, h::Int64, margin::Pair{Int64, Int64})

These dispatches are for the most part the same as the `context` method. The `width`, `height`, and `margin` will all default to those of the provided `AbstractContext`. Additionally, `group!` will take the name of the layer as the second positional argument.
These two forms of group are used in tandem to organize the layers of our `Context`. `group` is used to define new `AbstractContext` dimensions without adding a layer, whereas `group!` will add a new layer in those dimensions. For example.
```julia
mycon = context(500, 500) do con::Context
    group(con, 500, 250) do gridbox::Group
        group!(gridbox, "grid") do g::Group
            Gattino.grid!(g, 4)
        end
    end
    group(con, 500, 250, 0 => 250) do otherbox::Group
        group!(otherbox, "grid2") do g::Group
            Gattino.grid!(g, 4, "stroke" => "pink")
            
        end
    end
    Gattino.text!(con, 230, 250, "hello!")
end
```

<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/docsc/griddemonstration.png"></img></div>

In this case, I used `group` to create an initial `AbstractContext` with a certain dimensionality so that we could draw a bunch of things onto it. Note the use of `group` in this case, as I do not want this group to be drawn as a layer it is only used to change the dimensions. Next, I used `group!` whenever I actually wanted to draw onto the grid. The advantage to using `group!` like this is that we get all of the elements on different layers. We can access these layers with the `layers` function.
```julia
layers(mycon)

3-element Vector{Pair{Int64, String}}:
 1 => "grid"
 2 => "grid2"
 3 => "la81WFbV"
```
##### layouts
With the last example, we got an idea of how we might stack plots on top of one another. We have two different options which may be used to create layouts. The first of these options was demonstrated prior, this is using the `margin`, `height`, and `width` arguments with `Groups` to draw scaled frames in different portions of our window. Our `width`, `height`, and `margins` are provided to either the `context` method or one of the `group` methods (`group`/`group!`) in that order. Our margins push our frame to the right or down as they increase.
```julia
myframe = context(500, 250) do con::Context
    group(con, 250, 250) do g::Group
        Gattino.scatter_plot!(g, [1, 2, 3, 4], [1, 2, 3, 4])
    end
end
```

<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/docsc/layoutsdemonstration.png"></img></div>

In this case, we have a `Context`, or window, of width **500** and height **250**. The group we created below this is of width **250** and of height **250** -- the full height and half of the width. Let's add a grid with a `margin` of **250** on the X with the same size. This will make it easier to discern the difference between these visualizations.
```julia
group(myframe, 250, 250, 250 => 0) do g::Group
    Gattino.grid!(g, 4, "stroke" => "pink")
end
```

<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/docsc/layoutsdemonstration2.png"></img></div>

The other way we are able to do layouts is by creating a `Vector{<:AbstractContext}`. This `Vector` will display as the totality of itself, concatenated with the shape. In other words a `Vector{Context}` with two `Contexts` of width **200** will display at width **400**.
```julia
TODO; This is still a planned feature.
```
##### styling a layer
The first thing we are going to want to do with our new `Gattino` visualization is probably style it, for this we use the following style dispatch:
- `style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)`

In order to use this dispatch, we will need to provide a layer name as the second argument. In order to check the layers currently in your `Context`, use `layers(::AbstractContext)`. Let's try this on [the histogram we created](#creating-visualizations).
```julia
layers(myhist)
7-element Vector{Pair{Int64, String}}:
1 => "XS3ms8yi"
2 => "title"
3 => "axes"
4 => "grid"
5 => "bars"
6 => "labels"
7 => "axislabels"
```
We are able to style these all individually with the `style!` dispatch we created earlier. These `style!` calls are simply CSS pairs from Toolips. Let's change the `fill` of our bars and make some other adjustmnets to the labels.
```julia
style!(myhist, "bars", "fill" => "orange", "opacity" => 70percent)
style!(myhist, "labels", "stroke-width" => 0px, "fill" => "white", "font-weight" => "bold")
```

<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/docsc/histstyled.png"></img></div>

##### working with layers
An important aspect to `Gattino` is the layering aspect. In `Gattino`, visualizations are premade from the [context plotting](#context-plotting) toolkit and then mutated by making changes to the layers. We are able to access the layers of an `AbstractContext` using the `layers` method.
```julia
layers(con::AbstractContext)
```
We can also index a `Context` with a `String` to retrieve a layer directly.
```julia
getindex(con::AbstractContext, str::String)
```
Let's grab a layer:
```julia
```
We can also mutate layers using the various methods `Gattino` provides to do so. These include
- `style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)`
- `move_layer!(con::Context, layer::String, to::Int64)`
- `delete_layer!(con::Context, layer::String)`
- `merge!(c::AbstractContext, c2::AbstractContext)`

The first in this list of methods is `style!`. There are two ways that we can provide styling to our elements, we are able to either provide the styles at the end of a [context plotting](#context-plotting) function,
```julia
```
or we can use `style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)` to style the layer after it exists. We are unable to provide these styles to the high-level `hist`, `scatter_plot!` or any methods like that, so considering this the use of `style!` will likely be pretty necessary in these cases. the `spairs` here are style `Pairs`, this will style all of the shapes on that layer.
```julia
```
`move_layer!` and `delete_layer!` are both relatively straightforward. `move_layer!` can be used to reorder the drawing of layers, the first layer will always be drawn first and then get drawn over.
```julia
```
```
TODO image here
```julia
```
Finally, `merge!` will combine two different context's layers into the same context. Note that this will not account for scaling in any capacity; if you want to concatenate with scaling, checkout the techniques put forth in [layouts](#layouts) instead.
##### annotations
##### animation
## context plotting
#### plotting lines
#### plotting shapes
#### plotting other stuff

## examples
#### styled multichart
```
TODO styled multichart here
```
