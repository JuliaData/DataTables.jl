# Getting Started

## Installation

The DataTables package is available through the Julia package system. Throughout the rest of this tutorial, we will assume that you have installed the DataTables package and have already typed `using DataTables` to bring all of the relevant variables into your current namespace.

## The `Null` Type

To get started, let's examine the `Null` type. `Null` is a type implemented by [Nulls.jl](https://github.com/JuliaData/Nulls.jl) to represent missing data. `null` is an instance of the type `Null` used to represent a missing value.

```julia
julia> using DataTables

julia> null
null

julia> typeof(null)
Nulls.Null

```

The `Null` type lets users create `Vector`s and `DataTable` columns with missing values. Here we create a vector with a null value and the element-type of the returned vector is `Union{Nulls.Null, Int64}`.

```julia
julia> x = [1, 2, null]
3-element Array{Union{Nulls.Null, Int64},1}:
 1
 2
  null

julia> eltype(x)
Union{Nulls.Null, Int64}

julia> Union{Int, Null}
Union{Nulls.Null, Int64}

julia> eltype(x) == Union{Int, Null}
true

```

`null` values can be excluded when performing operations by using `Nulls.skip`, which returns a memory-efficient iterator.

```julia
julia> Nulls.skip(x)
Base.Generator{Base.Iterators.Filter{Nulls.##4#6{Nulls.Null},Array{Union{Nulls.Null, Int64},1}},Nulls.##3#5}(Nulls.#3, Base.Iterators.Filter{Nulls.##4#6{Nulls.Null},Array{Union{Nulls.Null, Int64},1}}(Nulls.#4, Union{Nulls.Null, Int64}[1, 2, null]))

```

The output of `Nulls.skip` can be passed directly into functions as an argument. For example, we can find the `sum` of all non-null values or `collect` the non-null values into a new null-free vector.

```julia
julia> sum(Nulls.skip(x))
3

julia> collect(Nulls.skip(x))
2-element Array{Int64,1}:
 1
 2

```

`null` elements can be replaced with other values via `Nulls.replace`.

```julia
julia> collect(Nulls.replace(x, 1))
3-element Array{Int64,1}:
 1
 2
 1

```

The function `Nulls.T` returns the element-type `T` in `Union{T, Null}`.

```julia
julia> Nulls.T(eltype(x))
Int64

```

Use `nulls` to generate nullable `Vector`s and `Array`s, using the optional first argument to specify the element-type.

```julia
julia> nulls(1)
1-element Array{Nulls.Null,1}:
 null

julia> nulls(3)
3-element Array{Nulls.Null,1}:
 null
 null
 null

julia> nulls(1, 3)
1×3 Array{Nulls.Null,2}:
 null  null  null

julia> nulls(Int, 1, 3)
1×3 Array{Union{Nulls.Null, Int64},2}:
 null  null  null

```

## The `DataTable` Type

The `DataTable` type can be used to represent data tables, each column of which is a vector. You can specify the columns using keyword arguments:

```julia
dt = DataTable(A = 1:4, B = ["M", "F", "F", "M"])
```

It is also possible to construct a `DataTable` in stages:

```julia
dt = DataTable()
dt[:A] = 1:8
dt[:B] = ["M", "F", "F", "M", "F", "M", "M", "F"]
dt
```

The `DataTable` we build in this way has 8 rows and 2 columns. You can check this using `size` function:

```julia
nrows = size(dt, 1)
ncols = size(dt, 2)
```

We can also look at small subsets of the data in a couple of different ways:

```julia
head(dt)
tail(dt)

dt[1:3, :]
```

Having seen what some of the rows look like, we can try to summarize the entire data set using `describe`:

```julia
describe(dt)
```

To focus our search, we start looking at just the means and medians of specific columns. In the example below, we use numeric indexing to access the columns of the `DataTable`:

```julia
mean(Nulls.skip(dt[1]))
median(Nulls.skip(dt[1]))
```

We could also have used column names to access individual columns:

```julia
mean(Nulls.skip(dt[:A]))
median(Nulls.skip(dt[:A]))
```

We can also apply a function to each column of a `DataTable` with the `colwise` function. For example:

```julia
dt = DataTable(A = 1:4, B = randn(4))
colwise(c->cumsum(Nulls.skip(c)), dt)
```

## Importing and Exporting Data (I/O)

For reading and writing tabular data from CSV and other delimited text files, use the [CSV.jl](https://github.com/JuliaData/CSV.jl) package.

If you have not used the CSV.jl package before then you may need to download it first.
```julia
Pkg.add("CSV")
```

The CSV.jl functions are not loaded automatically and must be imported into the session.
```julia
# can be imported separately
using DataTables
using CSV
# or imported together, separated by commas
using DataTables, CSV
```

A dataset can now be read from a CSV file at path `input` using
```julia
CSV.read(input, DataTable)
```

Note the second positional argument of `DataTable`. This instructs the CSV package to output
a `DataTable` rather than the default `DataFrame`. Keyword arguments may be passed to
`CSV.read` after this second argument.

A DataTable can be written to a CSV file at path `output` using
```julia
dt = DataTable(x = 1, y = 2)
CSV.write(output, dt)
```

For more information, use the REPL [help-mode](http://docs.julialang.org/en/stable/manual/interacting-with-julia/#help-mode) or checkout the online [CSV.jl documentation](https://juliadata.github.io/CSV.jl/stable/)!

## Accessing Classic Data Sets

To see more of the functionality for working with `DataTable` objects, we need a more complex data set to work with. We can access Fisher's iris data set using the following functions:

```julia
using CSV
iris = CSV.read(joinpath(Pkg.dir("DataTables"), "test/data/iris.csv"), DataTable)
head(iris)
```

In the next section, we'll discuss generic I/O strategy for reading and writing `DataTable` objects that you can use to import and export your own data files.

## Querying DataTables

While the `DataTables` package provides basic data manipulation capabilities, users are encouraged to use the following packages for more powerful and complete data querying functionality in the spirit of [dplyr](https://github.com/hadley/dplyr) and [LINQ](https://msdn.microsoft.com/en-us/library/bb397926.aspx):

- [Query.jl](https://github.com/davidanthoff/Query.jl) provides a LINQ like interface to a large number of data sources, including `DataTable` instances.
