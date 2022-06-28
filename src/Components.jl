"""
**Prrty Defaults**
### anim_pagein() -> ::Animation
------------------
Produces the default page in animation, which is a fade up of length 1.5s.
#### example
```
anim = anim_pagein()
```
"""
function anim_pagein()
    anim = Animation("page_in", length = 1.5)
    anim[:from] = "opacity" => "0%"
    anim[:from] = "transform" => "translateY(100%)"
    anim[:to] = "opacity" => "100%"
    anim[:to] = "transform" => "translateY(0%)"
    anim
end

"""
**Prrty Defaults**
### anim_pagein() -> ::Animation
------------------
Produces the default page out animation, which is a fade down of length 1.5s.
#### example
```
anim = anim_pageout()
```
"""
function anim_pageout()
    anim = Animation("page_out", length = 1.5)
    anim[:from] = "opacity" => "100%"
    anim[:from] = "transform" => "translateY(0%)"
    anim[:to] = "opacity" => "0%"
    anim[:to] = "transform" => "translateY(100%)"
    anim
end

"""
**Prrty Defaults**
### h1_style() -> ::Style
------------------
Produces a default h1 style.
#### example
```
defaulth1s = h1_style()
```
"""
function h1_style()
    s = Style("h1")
    s["color"] = "white"
    s
end

"""
**Prrty Defaults**
### prrty_nav1(pages::Vector{Servable}, c::Connection, animout::Animation) -> ::Component
------------------
Creates the default Prrty nav. If you would like to create your own navbar, this
would be a great template to start from!
#### example
```
pages = components(page("firstpage"), page("secondpage"))

route("/") do c::Connection
    navbar = prrty_nav1(pages, c)
    write!(c, navbar)
end
```
"""
function prrty_nav1(pages::Vector{Servable}, c::Connection, animout::Animation)
    navdiv::Component = divider("navdiv", align = "center")
    for p in pages
        pagebutton::Component = button("nav$(p.name)", padding = "10px",
        color = "white", text = p.name)
        style!(pagebutton, "background-color" => "#23395d", "color" => "white",
        "font-size" => "20pt", "font-weight" => "bold",
        "border-radius" => "15px")
        on(c, pagebutton, "click") do cm::ComponentModifier
            cm["page_div"] = "out" => "true"
            cm["boardtitle"] = "text" => p.name
            cm["page_div"] = "active" => p.name
            style!(cm, "page_div", "opacity" => "0%")
            set_children!(cm, "page_div", components(p))
            animate!(cm, "page_div", animout)
        end
        push!(navdiv, pagebutton)
    end
    navdiv::Component
end

"""
### Dashboard
- pages::Vector{Servable}
- f::Function
- nav::Function
- stylesheet::Vector{Servable}
- name::String -
Produces a Prrty dashboard servable from pages.
##### example
```
pages = components(page("firstpage"), page("secondpage"))
dash = DashBoard(pages)
route("/") do c::Connection
    write!(c, dash)
end
```
------------------
##### constructors
- Dashboard(pages::Vector{Servable};
    anim_in::Function = anim_pagein,
    anim_out::Function = anim_pageout,
    name::String = "Prrty Dashboard",
    nav::Function = prrty_nav1,
    header_image::String = "/favicon.png",
    stylesheet::Vector{Servable} = components(h1_style())
    bg_color::String = "#DCE8F1"
)
"""
mutable struct DashBoard <: Servable
    pages::Vector{Servable}
    f::Function
    nav::Function
    stylesheet::Vector{Servable}
    name::String
    function DashBoard(pages::Vector{Servable};
        anim_in::Function = anim_pagein,
        anim_out::Function = anim_pageout,
        name::String = "Prrty Dashboard",
        nav::Function = prrty_nav1,
        header_image::String = "/favicon.png",
        stylesheet::Vector{Servable} = components(h1_style()),
        bg_color::String = "#DCE8F1")
        push!(stylesheet, anim_in(), anim_out())
        f(c::AbstractConnection) = begin
            body::Component = Component("mainbody", "body")
            style!(body, "background-color" => bg_color)
            header::Component = divider("head", align = "center")
            push!(header, img("headerimg", src = header_image))
            push!(header, h("pagetitle", 1, text = name))
            boardtitle::Component = title("boardtitle", text = name)
            push!(stylesheet, boardtitle)
            page_div::Component = divider("page_div")
            stylesvs::Vector{Servable} = Vector{Servable}()
            [push!(stylesvs, sty) for sty in stylesheet]
            page_div["out"] = "false"
            page_div["active"] = pages[1].name
            pdivs = Style("div")
            animate!(pdivs, anim_in())
            push!(stylesvs, pdivs)
            on(c, page_div, "animationend") do cm::ComponentModifier
                if cm[page_div]["out"] == "true"
                    active = page_div["active"]
                    cm[page_div] = "out" => "false"
                    animate!(cm, page_div, anim_in())
                    style!(cm, "page_div", "opacity" => "100%")
                end
            end
            style!(page_div, "background-color" => "#1c2e4a",
            "border-radius" => "15px", "padding" => "20px", "float" => "left",
            "width" => "100%")
            push!(page_div, pages[1])
            navbar::Component = nav(pages, c, anim_out())
            write!(c, stylesvs)
            push!(body, header, navbar, page_div)
            write!(c, body)
        end
        new(pages, f, nav, stylesheet, name)::DashBoard
    end
end

"""
**Prrty Components**
### page(name::String, contents::Vector{Servable}) -> ::Component
------------------
Creates a new Prrty page with the name name.
#### example
```
mypage = page("mypage", components(plotpane(name::String, myplot)))
```
"""
function page(name::String, contents::Vector{Servable})
    pagediv::Component = divider(name)
    pagediv[:children] = contents
    pagediv::Component
end

"""
**Prrty Components**
### plotpane(name::String, plot::Any) -> ::Component
------------------
Writes any Julia type binded to show with the text/html mime into Prrty html.
For example, plots, dataframes, anything of those sorts.
#### example
```
using Plots

myplot = plot(1:10, rand(10))

ppane = Prrty.plotpane("myplot", myplot)
```
"""
function plotpane(name::String, plot)
    plot_div::Component = divider(name)
    style!(plot_div, "float" => "left", "margin" => "5px")
    io::IOBuffer = IOBuffer();
    show(io, "text/html", plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    plot_div[:text] = data
    plot_div
end

"""
**Prrty Components**
### pane(name::String, plot::Any) -> ::Component
------------------
Creates a regular pane with Toolips Components, note that a pane is simply a
Toolips.divider that floats left. If you do not want your content to pack to
the left, then use Toolips.divider instead!
#### example
```
content = components(h("greet", 1, text = "hello!"), p("welcome",
                    text = "Welcome to prrty!"))
p = pane(content)
```
"""
function pane(name::String)
    pane_div::Component = divider(name)
    style!(pane_div, "float" => "left", "margin" => "5px")
    pane_div
end


"""
**Prrty Components**
### textbox(name::String, range::UnitRange = 1:10; text::String = "", size::Integer = 10) -> ::Component
------------------
Creates a textbox component.
#### example
```

```
"""
function textbox(name::String, range::UnitRange = 1:10;
                text::String = "", size::Integer = 10)
        input(name, type = "text", minlength = range[1], maxlength = range[2],
        value = text, size = size)
end

"""
**Prrty Components**
### textbox(name::String, containername::String; text::String = "text") -> ::Component
------------------
Creates a containertextbox component.
#### example
```

```
"""
function containertextbox(name::String, containername::String; text::String = "text")
    container = divider(containername, contenteditable = "true")
    txtbox = a(name, text = text)
    push!(container, txtbox)
    container
end

"""
**Prrty Components**
### numberinput(name::String, range::UnitRange = 1:10; value::Integer = 5) -> ::Component
------------------
Creates a number input component.
#### example
```

```
"""
function numberinput(name::String, range::UnitRange = 1:10; value::Integer = 5)
    input(name, type = "number", min = range[1], max = range[2])
end

"""
**Prrty Components**
### rangeslider(name::String, range::UnitRange = 1:100; value::Integer = 50, step::Integer = 5) -> ::Component
------------------
Creates a range slider component.
#### example
```

```
"""
function rangeslider(name::String, range::UnitRange = 1:100;
                    value::Integer = 50, step::Integer = 5)
    input(name, type = "range", min = string(minimum(range)),
     max = string(maximum(range)), value = value,
            step = step)
end

"""
**Prrty Interface**
### update!(cm::ComponentModifier, ppane::Component, plot::Any) -> _
------------------
updates the contents of a plot pane with anything!
#### example
```
using Plots

myplot = plot(1:10, rand(10))
myotherplot = plot(1:20, 1:20)

ppane = Prrty.plotpane("myplot", myplot)
ppane["plot-selected"] = "plot1"

myroute = route("/") do c::Connection
    write!(c, ppane)
    on(c, ppane, "click") do cm::ComponentModifier
        if cm[ppane]["plot-selected"] == "plot1"
            update!(cm, ppane, myotherplot)
            cm[ppane] = "plot-selected" => "plot2"
        else
            update!(cm, ppane, myplot)
            cm[ppane] = "plot-selected" => "plot1"
        end
    end
end
```
"""
function update!(cm::ComponentModifier, ppane::Component, plot)
    io::IOBuffer = IOBuffer();
    show(io, "text/html", plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    set_text!(cm, ppane.name, data)
end
