function anim_pageout()
    anim = Animation("page_in")
    anim[:from] = "opacity" => "0%"
    anim[:from] = "transform" => "translateY(100%)"
    anim[:to] = "opacity" => "100%"
    anim[:to] = "transform" => "translateY(0%)"
    anim
end

function anim_pagein()
    anim = Animation("page_in")
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
    title::String
    function DashBoard(pages::Vector{Servable};
        anim_in::Function = anim_pagein,
        anim_out::Function = anim_pageout,
        name::String = "Prrty Dashboard",
        nav::Function = prrty_nav1,
        stylesheet::Vector{Servable} = components(h1_style()))
        push!(stylesheet, anim_in(), anim_out())
        f(c::Connection) = begin
            boardtitle::Component = title("boardtitle", text = name)
            page_div::Component = divider("page_div")
            stylesvs::Vector{Servable} = Vector{Servable}(
                                                [sty for sty in stylesheet])
            on(c, page_div, "animationend") do cm::ComponentModifier
                if cm[page_div]["out"] == "true"
                    active = page_div["active"]
                    set_children!(page_div, components(pages[active]))
                    cm[page_div] = "out" => "false"
                    animate!(cm, page_div, anim_in)
                end
            end
            style!(page_div, "background-color" => "#1c2e4a")
            push!(page_div, components(pages[1]))
            navbar::Component = nav(pages, c, anim_out())
            write!(c, stylesvs)
            write!(c, navbar, page_div)
        end
        new(pages, f, nav, stylesheet, title)::Dashboard
    end
end

function page(name::String, contents::Vector{Servable})
    pagediv::Component = divider("page$name")
    pagediv[:children] = contents
    pagediv::Component
end

function prrty_nav1(pages::Vector{Servable}, c::Connection, animout::Animation)
    navdiv::Component = div("navdiv", align = "center")
    style!(navdiv, "background-color" => "lightblue")
    for p in pages
        pagebutton::Component = button("nav$(p.name)", padding = "10px",
        color = "white")
        style!(pagebutton, "background-color" => "#23395d", "color" => "white",
        "font-size" => "15pt", "bold" => "true")
        on(c, pagebutton, "click") do cm::ComponentModifier
            cm["page_div"] = "out" => "true"
            cm["boardtitle"] = "text" => p.name
            cm["page_div"] = "active" => p.name
            animate!(cm, "page_div", animout)
        end
        push!(navdiv, pagebutton)
    end
    navdiv::Component
end
