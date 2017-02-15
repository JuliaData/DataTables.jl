
"""
An abstract type for which all concrete types expose a database-like
interface.

**Common methods**

An AbstractDataTable is a two-dimensional table with Symbols for
column names. An AbstractDataTable is also similar to an Associative
type in that it allows indexing by a key (the columns).

The following are normally implemented for AbstractDataTables:

* [`describe`](@ref) : summarize columns
* [`dump`](@ref) : show structure
* `hcat` : horizontal concatenation
* `vcat` : vertical concatenation
* `names` : columns names
* [`names!`](@ref) : set columns names
* [`rename!`](@ref) : rename columns names based on keyword arguments
* [`eltypes`](@ref) : `eltype` of each column
* `length` : number of columns
* `size` : (nrows, ncols)
* [`head`](@ref) : first `n` rows
* [`tail`](@ref) : last `n` rows
* `convert` : convert to an array
* `NullableArray` : convert to a NullableArray
* [`completecases`](@ref) : boolean vector of complete cases (null-free rows)
* [`dropnull`](@ref) : remove rows with null values
* [`dropnull!`](@ref) : remove rows with null values in-place
* [`nonunique`](@ref) : indexes of duplicate rows
* [`unique!`](@ref) : remove duplicate rows
* `similar` : a DataTable with similar columns as `d`

**Indexing**

Table columns are accessed (`getindex`) by a single index that can be
a symbol identifier, an integer, or a vector of each. If a single
column is selected, just the column object is returned. If multiple
columns are selected, some AbstractDataTable is returned.

```julia
d[:colA]
d[3]
d[[:colA, :colB]]
d[[1:3; 5]]
```

Rows and columns can be indexed like a `Matrix` with the added feature
of indexing columns by name.

```julia
d[1:3, :colA]
d[3,3]
d[3,:]
d[3,[:colA, :colB]]
d[:, [:colA, :colB]]
d[[1:3; 5], :]
```

`setindex` works similarly.
"""
abstract AbstractDataTable

##############################################################################
##
## Interface (not final)
##
##############################################################################

# index(df) => AbstractIndex
# nrow(df) => Int
# ncol(df) => Int
# getindex(...)
# setindex!(...) exclusive of methods that add new columns

##############################################################################
##
## Basic properties of a DataTable
##
##############################################################################

immutable Cols{T <: AbstractDataTable} <: AbstractVector{Any}
    df::T
end
Base.start(::Cols) = 1
Base.done(itr::Cols, st) = st > length(itr.df)
Base.next(itr::Cols, st) = (itr.df[st], st + 1)
Base.length(itr::Cols) = length(itr.df)
Base.size(itr::Cols, ix) = ix==1 ? length(itr) : throw(ArgumentError("Incorrect dimension"))
Base.size(itr::Cols) = (length(itr.df),)
Base.linearindexing{T}(::Type{Cols{T}}) = Base.LinearFast()
Base.getindex(itr::Cols, inds...) = getindex(itr.df, inds...)

# N.B. where stored as a vector, 'columns(x) = x.vector' is a bit cheaper
columns{T <: AbstractDataTable}(df::T) = Cols{T}(df)

Base.names(df::AbstractDataTable) = names(index(df))
_names(df::AbstractDataTable) = _names(index(df))

"""
Set column names


```julia
names!(df::AbstractDataTable, vals)
```

**Arguments**

* `df` : the AbstractDataTable
* `vals` : column names, normally a Vector{Symbol} the same length as
  the number of columns in `df`
* `allow_duplicates` : if `false` (the default), an error will be raised
  if duplicate names are found; if `true`, duplicate names will be suffixed
  with `_i` (`i` starting at 1 for the first duplicate).

**Result**

* `::AbstractDataTable` : the updated result


**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
names!(df, [:a, :b, :c])
names!(df, [:a, :b, :a])  # throws ArgumentError
names!(df, [:a, :b, :a], allow_duplicates=true)  # renames second :a to :a_1
```

"""
function names!(df::AbstractDataTable, vals; allow_duplicates=false)
    names!(index(df), vals; allow_duplicates=allow_duplicates)
    return df
end

function rename!(df::AbstractDataTable, args...)
    rename!(index(df), args...)
    return df
end
rename!(f::Function, df::AbstractDataTable) = rename!(df, f)

rename(df::AbstractDataTable, args...) = rename!(copy(df), args...)
rename(f::Function, df::AbstractDataTable) = rename(df, f)

"""
Rename columns

```julia
rename!(df::AbstractDataTable, from::Symbol, to::Symbol)
rename!(df::AbstractDataTable, d::Associative)
rename!(f::Function, df::AbstractDataTable)
rename(df::AbstractDataTable, from::Symbol, to::Symbol)
rename(f::Function, df::AbstractDataTable)
```

**Arguments**

* `df` : the AbstractDataTable
* `d` : an Associative type that maps the original name to a new name
* `f` : a function that has the old column name (a symbol) as input
  and new column name (a symbol) as output

**Result**

* `::AbstractDataTable` : the updated result

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
rename(x -> @compat(Symbol)(uppercase(string(x))), df)
rename(df, @compat(Dict(:i=>:A, :x=>:X)))
rename(df, :y, :Y)
rename!(df, @compat(Dict(:i=>:A, :x=>:X)))
```

"""
(rename!, rename)

"""
Return element types of columns

```julia
eltypes(df::AbstractDataTable)
```

**Arguments**

* `df` : the AbstractDataTable

**Result**

* `::Vector{Type}` : the element type of each column

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
eltypes(df)
```

"""
eltypes(df::AbstractDataTable) = map!(eltype, Vector{Type}(size(df,2)), columns(df))

Base.size(df::AbstractDataTable) = (nrow(df), ncol(df))
function Base.size(df::AbstractDataTable, i::Integer)
    if i == 1
        nrow(df)
    elseif i == 2
        ncol(df)
    else
        throw(ArgumentError("DataTables only have two dimensions"))
    end
end

Base.length(df::AbstractDataTable) = ncol(df)
Base.endof(df::AbstractDataTable) = ncol(df)

Base.ndims(::AbstractDataTable) = 2

##############################################################################
##
## Similar
##
##############################################################################

Base.similar(df::AbstractDataTable, dims::Int) =
    DataTable(Any[similar(x, dims) for x in columns(df)], copy(index(df)))

##############################################################################
##
## Equality
##
##############################################################################

# Imported in DataTables.jl for compatibility across Julia 0.4 and 0.5
@compat(Base.:(==))(df1::AbstractDataTable, df2::AbstractDataTable) = isequal(df1, df2)

function Base.isequal(df1::AbstractDataTable, df2::AbstractDataTable)
    size(df1, 2) == size(df2, 2) || return false
    isequal(index(df1), index(df2)) || return false
    for idx in 1:size(df1, 2)
        isequal(df1[idx], df2[idx]) || return false
    end
    return true
end

##############################################################################
##
## Associative methods
##
##############################################################################

Base.haskey(df::AbstractDataTable, key::Any) = haskey(index(df), key)
Base.get(df::AbstractDataTable, key::Any, default::Any) = haskey(df, key) ? df[key] : default
Base.isempty(df::AbstractDataTable) = ncol(df) == 0

##############################################################################
##
## Description
##
##############################################################################

head(df::AbstractDataTable, r::Int) = df[1:min(r,nrow(df)), :]
head(df::AbstractDataTable) = head(df, 6)
tail(df::AbstractDataTable, r::Int) = df[max(1,nrow(df)-r+1):nrow(df), :]
tail(df::AbstractDataTable) = tail(df, 6)

"""
Show the first or last part of an AbstractDataTable

```julia
head(df::AbstractDataTable, r::Int = 6)
tail(df::AbstractDataTable, r::Int = 6)
```

**Arguments**

* `df` : the AbstractDataTable
* `r` : the number of rows to show

**Result**

* `::AbstractDataTable` : the first or last part of `df`

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
head(df)
tail(df)
```

"""
(head, tail)

# get the structure of a DF
"""
Show the structure of an AbstractDataTable, in a tree-like format

```julia
dump(df::AbstractDataTable, n::Int = 5)
dump(io::IO, df::AbstractDataTable, n::Int = 5)
```

**Arguments**

* `df` : the AbstractDataTable
* `n` : the number of levels to show
* `io` : optional output descriptor

**Result**

* nothing

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
dump(df)
```

"""
function Base.dump(io::IO, df::AbstractDataTable, n::Int, indent)
    println(io, typeof(df), "  $(nrow(df)) observations of $(ncol(df)) variables")
    if n > 0
        for (name, col) in eachcol(df)
            print(io, indent, "  ", name, ": ")
            dump(io, col, n - 1, string(indent, "  "))
        end
    end
end

# summarize the columns of a DF
# TODO: clever layout in rows
"""
Summarize the columns of an AbstractDataTable

```julia
describe(df::AbstractDataTable)
describe(io, df::AbstractDataTable)
```

**Arguments**

* `df` : the AbstractDataTable
* `io` : optional output descriptor

**Result**

* nothing

**Details**

If the column's base type derives from Number, compute the minimum, first
quantile, median, mean, third quantile, and maximum. Nulls are filtered and
reported separately.

For boolean columns, report trues, falses, and nulls.

For other types, show column characteristics and number of nulls.

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
describe(df)
```

"""
StatsBase.describe(df::AbstractDataTable) = describe(STDOUT, df)
function StatsBase.describe(io, df::AbstractDataTable)
    for (name, col) in eachcol(df)
        println(io, name)
        describe(io, col)
        println(io, )
    end
end
StatsBase.describe(nv::AbstractArray) = describe(STDOUT, nv)
function StatsBase.describe{T<:Number}(io, nv::AbstractArray{T})
    if all(_isnull, nv)
        println(io, " * All null * ")
        return
    end
    filtered = float(dropnull(nv))
    qs = quantile(filtered, [0, .25, .5, .75, 1])
    statNames = ["Min", "1st Qu.", "Median", "Mean", "3rd Qu.", "Max"]
    statVals = [qs[1:3]; mean(filtered); qs[4:5]]
    for i = 1:6
        println(io, string(rpad(statNames[i], 10, " "), " ", string(statVals[i])))
    end
    nulls = countnull(nv)
    println(io, "NULLs      $(nulls)")
    println(io, "NULL %     $(round(nulls*100/length(nv), 2))%")
    return
end
function StatsBase.describe{T}(io, nv::AbstractArray{T})
    ispooled = isa(nv, CategoricalVector) ? "Pooled " : ""
    nulls = countnull(nv)
    # if nothing else, just give the length and element type and null count
    println(io, "Length    $(length(nv))")
    println(io, "Type      $(ispooled)$(string(eltype(nv)))")
    println(io, "NULLs     $(nulls)")
    println(io, "NULL %    $(round(nulls*100/length(nv), 2))%")
    println(io, "Unique    $(length(unique(nv)))")
    return
end

##############################################################################
##
## Miscellaneous
##
##############################################################################

function _nonnull!(res, col)
    for (i, el) in enumerate(col)
        res[i] &= !_isnull(el)
    end
end

function _nonnull!(res, col::NullableArray)
    for (i, el) in enumerate(col.isnull)
        res[i] &= !el
    end
end

function _nonnull!(res, col::NullableCategoricalArray)
    for (i, el) in enumerate(col.refs)
        res[i] &= el > 0
    end
end


"""
Indexes of complete cases (rows without null values)

```julia
completecases(df::AbstractDataTable)
```

**Arguments**

* `df` : the AbstractDataTable

**Result**

* `::Vector{Bool}` : indexes of complete cases

See also [`dropnull`](@ref) and [`dropnull!`](@ref).

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
df[[1,4,5], :x] = Nullable()
df[[9,10], :y] = Nullable()
completecases(df)
```

"""
function completecases(df::AbstractDataTable)
    res = fill(true, size(df, 1))
    for i in 1:size(df, 2)
        _nonnull!(res, df[i])
    end
    res
end

"""
Remove rows with null values.

```julia
dropnull(df::AbstractDataTable)
```

**Arguments**

* `df` : the AbstractDataTable

**Result**

* `::AbstractDataTable` : the updated copy

See also [`completecases`](@ref) and [`dropnull!`](@ref).

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
df[[1,4,5], :x] = Nullable()
df[[9,10], :y] = Nullable()
dropnull(df)
```

"""
dropnull(df::AbstractDataTable) = deleterows!(copy(df), find(!, completecases(df)))

"""
Remove rows with null values in-place.

```julia
dropnull!(df::AbstractDataTable)
```

**Arguments**

* `df` : the AbstractDataTable

**Result**

* `::AbstractDataTable` : the updated version

See also [`dropnull`](@ref) and [`completecases`](@ref).

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
df[[1,4,5], :x] = Nullable()
df[[9,10], :y] = Nullable()
dropnull!(df)
```

"""
dropnull!(df::AbstractDataTable) = deleterows!(df, find(!, completecases(df)))

function Base.convert(::Type{Array}, df::AbstractDataTable)
    convert(Matrix, df)
end
function Base.convert(::Type{Matrix}, df::AbstractDataTable)
    T = reduce(promote_type, eltypes(df))
    T <: Nullable && (T = eltype(T))
    convert(Matrix{T}, df)
end
function Base.convert{T}(::Type{Array{T}}, df::AbstractDataTable)
    convert(Matrix{T}, df)
end
function Base.convert{T}(::Type{Matrix{T}}, df::AbstractDataTable)
    n, p = size(df)
    res = Array(T, n, p)
    idx = 1
    for (name, col) in zip(names(df), columns(df))
        anynull(col) && error("cannot convert a DataTable containing null values to array (found for column $name)")
        copy!(res, idx, convert(Vector{T}, col))
        idx += n
    end
    return res
end

function Base.convert(::Type{NullableArray}, df::AbstractDataTable)
    convert(NullableMatrix, df)
end
function Base.convert(::Type{NullableMatrix}, df::AbstractDataTable)
    T = reduce(promote_type, eltypes(df))
    T <: Nullable && (T = eltype(T))
    convert(NullableMatrix{T}, df)
end
function Base.convert{T}(::Type{NullableArray{T}}, df::AbstractDataTable)
    convert(NullableMatrix{T}, df)
end
function Base.convert{T}(::Type{NullableMatrix{T}}, df::AbstractDataTable)
    n, p = size(df)
    res = NullableArray(T, n, p)
    idx = 1
    for col in columns(df)
        copy!(res, idx, col)
        idx += n
    end
    return res
end

"""
Indexes of duplicate rows (a row that is a duplicate of a prior row)

```julia
nonunique(df::AbstractDataTable)
nonunique(df::AbstractDataTable, cols)
```

**Arguments**

* `df` : the AbstractDataTable
* `cols` : a column indicator (Symbol, Int, Vector{Symbol}, etc.) specifying the column(s) to compare

**Result**

* `::Vector{Bool}` : indicates whether the row is a duplicate of some
  prior row

See also [`unique`](@ref) and [`unique!`](@ref).

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
df = vcat(df, df)
nonunique(df)
nonunique(df, 1)
```

"""
function nonunique(df::AbstractDataTable)
    res = fill(false, nrow(df))
    rows = Set{DataTableRow}()
    for i in 1:nrow(df)
        arow = DataTableRow(df, i)
        if in(arow, rows)
            res[i] = true
        else
            push!(rows, arow)
        end
    end
    res
end

nonunique(df::AbstractDataTable, cols::Union{Real, Symbol}) = nonunique(df[[cols]])
nonunique(df::AbstractDataTable, cols::Any) = nonunique(df[cols])

unique!(df::AbstractDataTable) = deleterows!(df, find(nonunique(df)))
unique!(df::AbstractDataTable, cols::Any) = deleterows!(df, find(nonunique(df, cols)))

# Unique rows of an AbstractDataTable.
Base.unique(df::AbstractDataTable) = df[!nonunique(df), :]
Base.unique(df::AbstractDataTable, cols::Any) = df[!nonunique(df, cols), :]

"""
Delete duplicate rows

```julia
unique(df::AbstractDataTable)
unique(df::AbstractDataTable, cols)
unique!(df::AbstractDataTable)
unique!(df::AbstractDataTable, cols)
```

**Arguments**

* `df` : the AbstractDataTable
* `cols` :  column indicator (Symbol, Int, Vector{Symbol}, etc.)
specifying the column(s) to compare.

**Result**

* `::AbstractDataTable` : the updated version of `df` with unique rows.
When `cols` is specified, the return DataTable contains complete rows,
retaining in each case the first instance for which `df[cols]` is unique.

See also [`nonunique`](@ref).

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
df = vcat(df, df)
unique(df)   # doesn't modify df
unique(df, 1)
unique!(df)  # modifies df
```

"""
(unique, unique!)

function nonuniquekey(df::AbstractDataTable)
    # Here's another (probably a lot faster) way to do `nonunique`
    # by grouping on all columns. It will fail if columns cannot be
    # made into CategoricalVector's.
    gd = groupby(df, _names(df))
    idx = [1:length(gd.idx)][gd.idx][gd.starts]
    res = fill(true, nrow(df))
    res[idx] = false
    res
end

# Count the number of missing values in every column of an AbstractDataTable.
function colmissing(df::AbstractDataTable) # -> Vector{Int}
    nrows, ncols = size(df)
    missing = zeros(Int, ncols)
    for j in 1:ncols
        missing[j] = countnull(df[j])
    end
    return missing
end

function without(df::AbstractDataTable, icols::Vector{Int})
    newcols = _setdiff(1:ncol(df), icols)
    df[newcols]
end
without(df::AbstractDataTable, i::Int) = without(df, [i])
without(df::AbstractDataTable, c::Any) = without(df, index(df)[c])

##############################################################################
##
## Hcat / vcat
##
##############################################################################

# hcat's first argument must be an AbstractDataTable
# Trailing arguments (currently) may also be NullableVectors, Vectors, or scalars.

# hcat! is defined in datatables/datatables.jl
# Its first argument (currently) must be a DataTable.

# catch-all to cover cases where indexing returns a DataTable and copy doesn't
Base.hcat(df::AbstractDataTable, x) = hcat!(df[:, :], x)

Base.hcat(df::AbstractDataTable, x, y...) = hcat!(hcat(df, x), y...)

# vcat only accepts DataTables. Finds union of columns, maintaining order
# of first df. Missing data become null values.

Base.vcat(df::AbstractDataTable) = df

Base.vcat(dfs::AbstractDataTable...) = vcat(AbstractDataTable[dfs...])

Base.vcat(dfs::Vector{Void}) = dfs
function Base.vcat{T<:AbstractDataTable}(dfs::Vector{T})
    isempty(dfs) && return DataTable()
    coltyps, colnams, similars = _colinfo(dfs)

    res = DataTable()
    Nrow = sum(nrow, dfs)
    for j in 1:length(colnams)
        colnam = colnams[j]
        col = similar(similars[j], coltyps[j], Nrow)

        i = 1
        for df in dfs
            if haskey(df, colnam)
                copy!(col, i, df[colnam])
            end
            i += size(df, 1)
        end

        res[colnam] = col
    end
    res
end

_isnullable{T}(::AbstractArray{T}) = T <: Nullable
const EMPTY_DATA = NullableArray(Void, 0)

function _colinfo{T<:AbstractDataTable}(dfs::Vector{T})
    df1 = dfs[1]
    colindex = copy(index(df1))
    coltyps = eltypes(df1)
    similars = collect(columns(df1))
    nonnull_ct = Int[_isnullable(c) for c in columns(df1)]

    for i in 2:length(dfs)
        df = dfs[i]
        for j in 1:size(df, 2)
            col = df[j]
            cn, ct = _names(df)[j], eltype(col)
            if haskey(colindex, cn)
                idx = colindex[cn]

                oldtyp = coltyps[idx]
                if !(ct <: oldtyp)
                    coltyps[idx] = promote_type(oldtyp, ct)
                    # Needed on Julia 0.4 since e.g.
                    # promote_type(Nullable{Int}, Nullable{Float64}) gives Nullable{T},
                    # which is not a usable type: fall back to Nullable{Any}
                    if VERSION < v"0.5.0-dev" &&
                       coltyps[idx] <: Nullable && !isa(coltyps[idx].types[2], DataType)
                        coltyps[idx] = Nullable{Any}
                    end
                end
                nonnull_ct[idx] += !_isnullable(col)
            else # new column
                push!(colindex, cn)
                push!(coltyps, ct)
                push!(similars, col)
                push!(nonnull_ct, !_isnullable(col))
            end
        end
    end

    for j in 1:length(colindex)
        if nonnull_ct[j] < length(dfs) && !_isnullable(similars[j])
            similars[j] = EMPTY_DATA
        end
    end
    colnams = _names(colindex)

    coltyps, colnams, similars
end

##############################################################################
##
## Hashing
##
## Make sure this agrees with isequals()
##
##############################################################################

function Base.hash(df::AbstractDataTable)
    h = hash(size(df)) + 1
    for i in 1:size(df, 2)
        h = hash(df[i], h)
    end
    return @compat UInt(h)
end


## Documentation for methods defined elsewhere

"""
Number of rows or columns in an AbstractDataTable

```julia
nrow(df::AbstractDataTable)
ncol(df::AbstractDataTable)
```

**Arguments**

* `df` : the AbstractDataTable

**Result**

* `::AbstractDataTable` : the updated version

See also [`size`](@ref).

NOTE: these functions may be depreciated for `size`.

**Examples**

```julia
df = DataTable(i = 1:10, x = rand(10), y = rand(["a", "b", "c"], 10))
size(df)
nrow(df)
ncol(df)
```

"""
# nrow, ncol
