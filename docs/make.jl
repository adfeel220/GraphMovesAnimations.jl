using GraphMovesAnimations
using Documenter

DocMeta.setdocmeta!(
    GraphMovesAnimations, :DocTestSetup, :(using GraphMovesAnimations); recursive=true
)

makedocs(;
    modules=[GraphMovesAnimations],
    authors="Chun-Tso Tsai <adfeel220@gmail.com> and contributors",
    repo="https://github.com/adfeel220/GraphMovesAnimations.jl/blob/{commit}{path}#{line}",
    sitename="GraphMovesAnimations.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true", edit_link="main", assets=String[]
    ),
    pages=["Home" => "index.md"],
)
