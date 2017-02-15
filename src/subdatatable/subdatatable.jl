##############################################################################
##
## We use SubDataTable's to maintain a reference to a subset of a DataTable
## without making copies.
##
##############################################################################

"""
A view of row subsets of an AbstractDataTable

A `SubDataTable` is meant to be constructed with `sub`.  A
SubDataTable is used frequently in split/apply sorts of operations.

```julia
sub(d::AbstractDataTable, rows)
```

### Arguments

* `d` : an AbstractDataTable
* `rows` : any indexing type for rows, typically an Int,
  AbstractVector{Int}, AbstractVector{Bool}, or a Range

### Notes

A `SubDataTable` is an AbstractDataTable, so expect that most
DataTable functions should work. Such methods include `describe`,
`dump`, `nrow`, `size`, `by`, `stack`, and `join`. Indexing is just
like a DataTable; copies are returned.

To subset along columns, use standard column indexing as that creates
a view to the columns by default. To subset along rows and columns,
use column-based indexing with `sub`.

### Examples

```julia
dt = DataTable(a = repeat([1, 2, 3, 4], outer=[2]),
               b = repeat([2, 1], outer=[4]),
               c = randn(8))
sdt1 = sub(dt, 1:6)
sdt2 = sub(dt, dt[:a] .> 1)
sdt3 = sub(dt[[1,3]], dt[:a] .> 1)  # row and column subsetting
sdt4 = groupby(dt, :a)[1]  # indexing a GroupedDataTable returns a SubDataTable
sdt5 = sub(sdt1, 1:3)
sdt1[:,[:a,:b]]
```

"""
immutable SubDataTable{T <: AbstractVector{Int}} <: AbstractDataTable
    parent::DataTable
    rows::T # maps from subdt row indexes to parent row indexes

    function SubDataTable(parent::DataTable, rows::T)
        if length(rows) > 0
            rmin, rmax = extrema(rows)
            if rmin < 1 || rmax > size(parent, 1)
                throw(BoundsError())
            end
        end
        new(parent, rows)
    end
end

function SubDataTable{T <: AbstractVector{Int}}(parent::DataTable, rows::T)
    return SubDataTable{T}(parent, rows)
end

function SubDataTable(parent::DataTable, row::Integer)
    return SubDataTable(parent, [row])
end

function SubDataTable{S <: Integer}(parent::DataTable, rows::AbstractVector{S})
    return sub(parent, Int(rows))
end


function Base.sub{S <: Real}(dt::DataTable, rowinds::AbstractVector{S})
    return SubDataTable(dt, rowinds)
end

function Base.sub{S <: Real}(sdt::SubDataTable, rowinds::AbstractVector{S})
    return SubDataTable(sdt.parent, sdt.rows[rowinds])
end

function Base.sub(dt::DataTable, rowinds::AbstractVector{Bool})
    return sub(dt, getindex(SimpleIndex(size(dt, 1)), rowinds))
end

function Base.sub(sdt::SubDataTable, rowinds::AbstractVector{Bool})
    return sub(sdt, getindex(SimpleIndex(size(sdt, 1)), rowinds))
end

function Base.sub(adt::AbstractDataTable, rowinds::Integer)
    return SubDataTable(adt, Int[rowinds])
end

function Base.sub(adt::AbstractDataTable, rowinds::Any)
    return sub(adt, getindex(SimpleIndex(size(adt, 1)), rowinds))
end

function Base.sub(adt::AbstractDataTable, rowinds::Any, colinds::Any)
    return sub(adt[[colinds]], rowinds)
end

##############################################################################
##
## AbstractDataTable interface
##
##############################################################################

index(sdt::SubDataTable) = index(sdt.parent)

# TODO: Remove these
nrow(sdt::SubDataTable) = ncol(sdt) > 0 ? length(sdt.rows)::Int : 0
ncol(sdt::SubDataTable) = length(index(sdt))

function Base.getindex(sdt::SubDataTable, colinds::Any)
    return sdt.parent[sdt.rows, colinds]
end

function Base.getindex(sdt::SubDataTable, rowinds::Any, colinds::Any)
    return sdt.parent[sdt.rows[rowinds], colinds]
end

function Base.setindex!(sdt::SubDataTable, val::Any, colinds::Any)
    sdt.parent[sdt.rows, colinds] = val
    return sdt
end

function Base.setindex!(sdt::SubDataTable, val::Any, rowinds::Any, colinds::Any)
    sdt.parent[sdt.rows[rowinds], colinds] = val
    return sdt
end

##############################################################################
##
## Miscellaneous
##
##############################################################################

Base.map(f::Function, sdt::SubDataTable) = f(sdt) # TODO: deprecate

function Base.delete!(sdt::SubDataTable, c::Any) # TODO: deprecate?
    return SubDataTable(delete!(sdt.parent, c), sdt.rows)
end

without(sdt::SubDataTable, c::Vector{Int}) = sub(without(sdt.parent, c), sdt.rows)
without(sdt::SubDataTable, c::Int) = sub(without(sdt.parent, c), sdt.rows)
without(sdt::SubDataTable, c::Any) = sub(without(sdt.parent, c), sdt.rows)
