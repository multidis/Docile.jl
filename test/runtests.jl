using Docile
using Base.Test

const PACKAGE_NAME = "DocileTests"

const DOCS = """
# $(PACKAGE_NAME)

## test_func_1{T <: Number}(a::Float64, b::Array{T,2})

Docile function tests.

Example:

    julia> test_func_1(1.0, [2 2; 3 1])

## @test_macro_1(a, b, c)

Docile function tests.
"""

## Setup git for Pkg use ––––––––––––––––––––––––––––––––––––––––––––––––––––––

## Run Docile on itself –––––––––––––––––––––––––––––––––––––––––––––––––––––––

Docile.generate("Docile")

## Errors –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

@test_throws ErrorException Docile.generate(PACKAGE_NAME)
@test_throws ErrorException Docile.update(PACKAGE_NAME)
@test_throws ErrorException Docile.remove(PACKAGE_NAME)
@test_throws ErrorException Docile.init(PACKAGE_NAME)

## Package creation and documentation generation ––––––––––––––––––––––––––––––

try
    Pkg.generate(PACKAGE_NAME, "MIT")
catch err
    # TODO: look into this.
    run(`git config --global user.email "michaelhatherly@gmail.com"`)
    run(`git config --global user.name "Michael Hatherly"`)
    Pkg.generate(PACKAGE_NAME, "MIT")
end
atexit(() -> Pkg.rm(PACKAGE_NAME)) # Make sure package is removed.

Docile.init(PACKAGE_NAME)

Docile.generate(PACKAGE_NAME)

Docile.update()
Docile.update(PACKAGE_NAME)

open(joinpath(Pkg.dir(PACKAGE_NAME), "doc", "help", "docs.md"), "w") do f
    write(f, DOCS)
end

Docile.generate(PACKAGE_NAME)

Docile.patch!()
Base.Help.init_help()

## Output checks ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# Whitespace must not be removed.

## 1.
expected = """
$(PACKAGE_NAME).test_func_1{T <: Number}(a::Float64, b::Array{T,2})
   
   Docile function tests.
   
   Example:
   
       julia> test_func_1(1.0, [2 2; 3 1])
"""

doc = IOBuffer()
help(doc, "test_func_1")

@test takebuf_string(doc) == expected
##

## 2.
expected = """
$(PACKAGE_NAME).@test_macro_1(a, b, c)
   
   Docile function tests.
"""

doc = IOBuffer()
help(doc, "@test_macro_1")

@test takebuf_string(doc) == expected
##

## Clear test documentation –––––––––––––––––––––––––––––––––––––––––––––––––––

Docile.remove(PACKAGE_NAME)
