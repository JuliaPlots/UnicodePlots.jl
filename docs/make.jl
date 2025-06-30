using Documenter, UnicodePlots

format = Documenter.HTML(
    prettyurls = Base.get_bool_env("CI", false),
    size_threshold = nothing,
    edit_link = "main",
    ansicolor = true,
)

pages = [
    "Home" => "index.md",
    "API" => "api.md",
]

makedocs(; modules = [UnicodePlots], sitename = "UnicodePlots.jl", format, pages)
deploydocs(; repo = "github.com/JuliaPlots/UnicodePlots.jl.git")
