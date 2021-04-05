using Documenter, Mods

format = Documenter.HTML(
    prettyurls = !isempty(get(ENV, "CI", "")),
    collapselevel = 1,
)

makedocs(
    sitename = "Mods.jl",
    strict = true,
    format = format,
    checkdocs = :exports,
    clean = true,
    doctest = true,
    modules = [Mods],
    pages = Any[
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/scheinerman/Mods.jl.git",
    target = "build",
    push_preview = true,
    devbranch = "master",
    forcepush = true,
)
