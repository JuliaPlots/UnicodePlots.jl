using Pkg
if !Base.get_bool_env("CI", false)
    Pkg.resolve(); Pkg.instantiate()
end
using Documenter, UnicodePlots

format = Documenter.HTML(
    prettyurls = Base.get_bool_env("CI", false),
    size_threshold = nothing,
    edit_link = "main",
    ansicolor = true,
)

pages = [
    "Getting Started" => "getting-started.md",
    "Manual" => "manual.md",
    "Development" => "dev.md",
    "API" => "api.md",
]

makedocs(; modules = [UnicodePlots], sitename = "UnicodePlots.jl", format, pages)
deploydocs(; repo = "github.com/JuliaPlots/UnicodePlots.jl.git")
