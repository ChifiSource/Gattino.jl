function anim_pagein()
    anim = Animation("page_in", length = 1.5)
    anim[:from] = "opacity" => "0%"
    anim[:from] = "transform" => "translateY(100%)"
    anim[:to] = "opacity" => "100%"
    anim[:to] = "transform" => "translateY(0%)"
    anim
end

function anim_pageout()
    anim = Animation("page_out", length = 1.5)
    anim[:from] = "opacity" => "100%"
    anim[:from] = "transform" => "translateY(0%)"
    anim[:to] = "opacity" => "0%"
    anim[:to] = "transform" => "translateY(100%)"
    anim
end
function h1_style()
    s = Style("h1")
    s["color"] = "white"
    s
end

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
        f(c::Connection) = begin
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
            "border-radius" => "15px", "padding" => "20px")
            push!(page_div, pages[1])
            navbar::Component = nav(pages, c, anim_out())
            write!(c, stylesvs)
            push!(body, header, navbar, page_div)
            write!(c, body)
        end
        new(pages, f, nav, stylesheet, name)::DashBoard
    end
end

function page(name::String, contents::Vector{Servable})
    pagediv::Component = divider(name)
    pagediv[:children] = contents
    pagediv::Component
end

mutable struct PrrtyPlot <: Servable
    plot::Any
    f::Function
    function PrrtyPlot(plot)
        f(c::Connection) = begin
            write!(c, sprint(show, "text/html", p))
        end
        new(plot, f)
    end
end

function plotpane(name::String, plot)
    plot_div = divider(name)
    style!(plot_div, "float" => "left", "margin" => "5px")
    plot_div[:children] = Vector{Servable}(PrrtyPlot(plot))
    plot_div
end

function pane(name::String)
    pane_div = divider(name)
    style!(pane_div, "float" => "left", "margin" => "5px")
    pane_div
end

function update!(cm::ComponentModifier, ppane::Component, plot)
    set_children!(cm, ppane.name, components(PrrtyPlot(plot)))
end

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
