using Documenter, BoundingBoxes

makedocs(
    modules = [BoundingBoxes],
    format = Documenter.HTML(),
    checkdocs = :exports,
    sitename = "BoundingBoxes.jl",
    pages = Any["index.md"]
)

deploydocs(
    repo = "github.com/goretkin/BoundingBoxes.jl.git",
)
