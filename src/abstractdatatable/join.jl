##
## Join / merge
##

# Like similar, but returns a nullable array
similar_nullable{T}(dv::AbstractArray{T}, dims::@compat(Union{Int, Tuple{Vararg{Int}}})) =
    NullableArray(T, dims)

similar_nullable{T<:Nullable}(dv::AbstractArray{T}, dims::@compat(Union{Int, Tuple{Vararg{Int}}})) =
    NullableArray(eltype(T), dims)

similar_nullable{T,R}(dv::CategoricalArray{T,R}, dims::@compat(Union{Int, Tuple{Vararg{Int}}})) =
    NullableCategoricalArray(T, dims)

similar_nullable(dt::AbstractDataTable, dims::Int) =
    DataTable(Any[similar_nullable(x, dims) for x in columns(dt)], copy(index(dt)))

function sharepools{S,N}(v1::Union{CategoricalArray{S,N}, NullableCategoricalArray{S,N}},
                         v2::Union{CategoricalArray{S,N}, NullableCategoricalArray{S,N}},
                         index::Vector{S},
                         R)
    tidx1 = convert(Vector{R}, indexin(CategoricalArrays.index(v1.pool), index))
    tidx2 = convert(Vector{R}, indexin(CategoricalArrays.index(v2.pool), index))
    refs1 = zeros(R, length(v1))
    refs2 = zeros(R, length(v2))
    for i in 1:length(refs1)
        if v1.refs[i] != 0
            refs1[i] = tidx1[v1.refs[i]]
        end
    end
    for i in 1:length(refs2)
        if v2.refs[i] != 0
            refs2[i] = tidx2[v2.refs[i]]
        end
    end
    pool = CategoricalPool{S, R}(index)
    return (CategoricalArray(refs1, pool),
            CategoricalArray(refs2, pool))
end

function sharepools{S,N}(v1::Union{CategoricalArray{S,N}, NullableCategoricalArray{S,N}},
                         v2::Union{CategoricalArray{S,N}, NullableCategoricalArray{S,N}})
    index = sort(unique([levels(v1); levels(v2)]))
    sz = length(index)

    R = sz <= typemax(UInt8)  ? UInt8 :
        sz <= typemax(UInt16) ? UInt16 :
        sz <= typemax(UInt32) ? UInt32 :
                                UInt64

    # To ensure type stability during actual work
    sharepools(v1, v2, index, R)
end

sharepools{S,N}(v1::Union{CategoricalArray{S,N}, NullableCategoricalArray{S,N}},
                v2::AbstractArray{S,N}) =
    sharepools(v1, oftype(v1, v2))

sharepools{S,N}(v1::AbstractArray{S,N},
                v2::Union{CategoricalArray{S,N}, NullableCategoricalArray{S,N}}) =
    sharepools(oftype(v2, v1), v2)

# TODO: write an optimized version for (Nullable)CategoricalArray
function sharepools{S, T}(v1::AbstractArray{S},
                          v2::AbstractArray{T})
    ## Return two categorical arrays that share the same pool.

    ## TODO: allow specification of R
    R = CategoricalArrays.DefaultRefType
    refs1 = Array{R}(size(v1))
    refs2 = Array{R}(size(v2))
    K = promote_type(S, T)
    poolref = Dict{K, R}()
    maxref = 0

    # loop through once to fill the poolref dict
    for i = 1:length(v1)
        if !_isnull(v1[i])
            poolref[K(v1[i])] = 0
        end
    end
    for i = 1:length(v2)
        if !_isnull(v2[i])
            poolref[K(v2[i])] = 0
        end
    end

    # fill positions in poolref
    pool = sort(collect(keys(poolref)))
    i = 1
    for p in pool
        poolref[p] = i
        i += 1
    end

    # fill in newrefs
    zeroval = zero(R)
    for i = 1:length(v1)
        if _isnull(v1[i])
            refs1[i] = zeroval
        else
            refs1[i] = poolref[K(v1[i])]
        end
    end
    for i = 1:length(v2)
        if _isnull(v2[i])
            refs2[i] = zeroval
        else
            refs2[i] = poolref[K(v2[i])]
        end
    end

    pool = CategoricalPool(pool)
    return (NullableCategoricalArray(refs1, pool),
            NullableCategoricalArray(refs2, pool))
end

function sharepools(dt1::AbstractDataTable, dt2::AbstractDataTable)
    # This method exists to allow merge to work with multiple columns.
    # It takes the columns of each DataTable and returns a categorical array
    # with a merged pool that "keys" the combination of column values.
    # The pools of the result don't really mean anything.
    dv1, dv2 = sharepools(dt1[1], dt2[1])
    # use UInt32 instead of the minimum integer size chosen by sharepools
    # since the number of levels can be high
    refs1 = Vector{UInt32}(dv1.refs)
    refs2 = Vector{UInt32}(dv2.refs)
    # the + 1 handles nulls
    refs1[:] += 1
    refs2[:] += 1
    ngroups = length(levels(dv1)) + 1
    for j = 2:ncol(dt1)
        dv1, dv2 = sharepools(dt1[j], dt2[j])
        for i = 1:length(refs1)
            refs1[i] += (dv1.refs[i]) * ngroups
        end
        for i = 1:length(refs2)
            refs2[i] += (dv2.refs[i]) * ngroups
        end
        ngroups *= length(levels(dv1)) + 1
    end
    # recode refs1 and refs2 to drop the unused column combinations and
    # limit the pool size
    sharepools(refs1, refs2)
end

# helper structure for DataTables joining
immutable DataTableJoiner{DT1<:AbstractDataTable, DT2<:AbstractDataTable}
    dtl::DT1
    dtr::DT2
    dtl_on::DT1
    dtr_on::DT2
    on_cols::Vector{Symbol}

    function DataTableJoiner(dtl::DT1, dtr::DT2, on::Union{Symbol,Vector{Symbol}})
        on_cols = (isa(on, Symbol) ? fill(on, 1) : on)
        new(dtl, dtr, dtl[on_cols], dtr[on_cols], on_cols)
    end
end

DataTableJoiner{DT1<:AbstractDataTable, DT2<:AbstractDataTable}(dtl::DT1, dtr::DT2, on::Union{Symbol,Vector{Symbol}}) =
    DataTableJoiner{DT1,DT2}(dtl, dtr, on)

# helper map between the row indices in original and joined table
immutable _RowIndexMap
    orig::Vector{Int} # row indices in the original table
    join::Vector{Int} # row indices in the resulting joined table
end

Base.length(x::_RowIndexMap) = length(x.orig)

# fix the result of the rightjoin by taking the nonnull values from the right table
function fix_rightjoin_column!(res_col::AbstractArray, col_ix::Int, joiner::DataTableJoiner,
                               all_orig_left_ixs::Vector{Int}, rightonly_ixs::_RowIndexMap)
    res_col[rightonly_ixs.join] = joiner.dtr_on[rightonly_ixs.orig, col_ix]
    res_col
end

# composes the joined data table using the maps between the left and right
# table rows and the indices of rows in the result
function compose_joined_table(joiner::DataTableJoiner,
                left_ixs::_RowIndexMap, leftonly_ixs::_RowIndexMap,
                right_ixs::_RowIndexMap, rightonly_ixs::_RowIndexMap)
    @assert length(left_ixs) == length(right_ixs)
    # compose left half of the result taking all left columns
    all_orig_left_ixs = vcat(left_ixs.orig, leftonly_ixs.orig)
    if length(leftonly_ixs) > 0
        # permute the indices to restore left table rows order
        all_orig_left_ixs[[left_ixs.join; leftonly_ixs.join]] = all_orig_left_ixs
    end
    left_dt = DataTable(Any[resize!(col[all_orig_left_ixs], length(all_orig_left_ixs)+length(rightonly_ixs))
                            for col in columns(joiner.dtl)],
                        names(joiner.dtl))

    # compose right half of the result taking all right columns excluding on
    dtr_noon = without(joiner.dtr, joiner.on_cols)
    # permutation to swap rightonly and leftonly rows
    right_perm = vcat(1:length(right_ixs),
                  ((length(right_ixs)+length(rightonly_ixs)+1):
                   (length(right_ixs)+length(rightonly_ixs)+length(leftonly_ixs))),
                  ((length(right_ixs)+1):(length(right_ixs)+length(rightonly_ixs))))
    if length(leftonly_ixs) > 0
        # compose right_perm with the permutation that restores left rows order
        right_perm[[right_ixs.join; leftonly_ixs.join]] = right_perm[1:(length(right_ixs)+length(leftonly_ixs))]
    end
    all_orig_right_ixs = [right_ixs.orig; rightonly_ixs.orig]
    right_dt = DataTable(Any[resize!(col[all_orig_right_ixs], length(all_orig_right_ixs)+length(leftonly_ixs))[right_perm]
                             for col in columns(dtr_noon)],
                         names(dtr_noon))
    # merge left and right parts of the joined table
    res = hcat!(left_dt, right_dt)

    if length(rightonly_ixs.join) > 0
        # some left rows are nulls, so the values of the "on" columns
        # need to be taken from the right
        for (on_col_ix, on_col) in enumerate(joiner.on_cols)
            res[on_col] = fix_rightjoin_column!(res[on_col], on_col_ix, joiner, all_orig_left_ixs, rightonly_ixs)
        end
    end
    return res
end

# map the indices of the left and right joined tables
# to the indices of the rows in the resulting table
# if `nothing` is given, the corresponding map is not built
function update_row_maps!(left_table::AbstractDataTable, right_table::AbstractDataTable,
                    right_dict::RowGroupDict,
                    left_ixs::Union{Void, _RowIndexMap},
                    leftonly_ixs::Union{Void, _RowIndexMap},
                    right_ixs::Union{Void, _RowIndexMap},
                    rightonly_mask::Union{Void, Vector{Bool}})
    # helper functions
    update!(ixs::Void, orig_ix::Int, join_ix::Int, count::Int = 1) = ixs
    function update!(ixs::_RowIndexMap, orig_ix::Int, join_ix::Int, count::Int = 1)
        for i in 1:count
            push!(ixs.orig, orig_ix)
        end
        for i in join_ix:(join_ix+count-1)
            push!(ixs.join, i)
        end
        ixs
    end
    update!(ixs::Void, orig_ixs::AbstractArray, join_ix::Int) = ixs
    function update!(ixs::_RowIndexMap, orig_ixs::AbstractArray, join_ix::Int)
        append!(ixs.orig, orig_ixs)
        for i in join_ix:(join_ix+length(orig_ixs)-1)
            push!(ixs.join, i)
        end
        ixs
    end
    update!(ixs::Void, orig_ixs::AbstractArray) = ixs
    update!(mask::Vector{Bool}, orig_ixs::AbstractArray) = (mask[orig_ixs] = false)

    # iterate over left rows and compose the left<->right index map
    next_join_ix = 1
    for l_ix in 1:nrow(left_table)
        r_ixs = get(right_dict, left_table, l_ix)
        if isempty(r_ixs)
            update!(leftonly_ixs, l_ix, next_join_ix)
            next_join_ix += 1
        else
            update!(left_ixs, l_ix, next_join_ix, length(r_ixs))
            update!(right_ixs, r_ixs, next_join_ix)
            update!(rightonly_mask, r_ixs)
            next_join_ix += length(r_ixs)
        end
    end
end

# map the row indices of the left and right joined tables
# to the indices of rows in the resulting table
# returns the 4-tuple of row indices maps for
# - matching left rows
# - non-matching left rows
# - matching right rows
# - non-matching right rows
# if false is provided, the corresponding map is not built and the
# tuple element is empty _RowIndexMap
function update_row_maps!(
    left_table::AbstractDataTable, right_table::AbstractDataTable,
    right_dict::RowGroupDict,
    map_left::Bool, map_leftonly::Bool,
    map_right::Bool, map_rightonly::Bool)
    init_map(dt::AbstractDataTable, init::Bool) = init ?
        _RowIndexMap(sizehint!(Vector{Int}(), nrow(dt)),
                     sizehint!(Vector{Int}(), nrow(dt))) :
         nothing
    to_bimap(x::_RowIndexMap) = x
    to_bimap(::Void) = _RowIndexMap(Vector{Int}(), Vector{Int}())

    # init maps as requested
    left_ixs = init_map(left_table, map_left)
    leftonly_ixs = init_map(left_table, map_leftonly)
    right_ixs = init_map(right_table, map_right)
    rightonly_mask = map_rightonly ? fill(true, nrow(right_table)) : nothing
    update_row_maps!(left_table, right_table, right_dict,
                     left_ixs, leftonly_ixs, right_ixs, rightonly_mask)
    if map_rightonly
        rightonly_orig_ixs = (1:length(rightonly_mask))[rightonly_mask]
        rightonly_ixs = _RowIndexMap(rightonly_orig_ixs,
                         collect(length(right_ixs.orig)+
                                 (leftonly_ixs === nothing ? 0 : length(leftonly_ixs))+
                                 (1:length(rightonly_orig_ixs))))
    else
        rightonly_ixs = nothing
    end

    return to_bimap(left_ixs), to_bimap(leftonly_ixs),
           to_bimap(right_ixs), to_bimap(rightonly_ixs)
end

"""
Join two DataTables

```julia
join(dt1::AbstractDataTable,
     dt2::AbstractDataTable;
     on::Union{Symbol, Vector{Symbol}} = Symbol[],
     kind::Symbol = :inner)
```

### Arguments

* `dt1`, `dt2` : the two AbstractDataTables to be joined

### Keyword Arguments

* `on` : a Symbol or Vector{Symbol}, the column(s) used as keys when
  joining; required argument except for `kind = :cross`

* `kind` : the type of join, options include:

  - `:inner` : only include rows with keys that match in both `dt1`
    and `dt2`, the default
  - `:outer` : include all rows from `dt1` and `dt2`
  - `:left` : include all rows from `dt1`
  - `:right` : include all rows from `dt2`
  - `:semi` : return rows of `dt1` that match with the keys in `dt2`
  - `:anti` : return rows of `dt1` that do not match with the keys in `dt2`
  - `:cross` : a full Cartesian product of the key combinations; every
    row of `dt1` is matched with every row of `dt2`

Null values are filled in where needed to complete joins.

### Result

* `::DataTable` : the joined DataTable

### Examples

```julia
name = DataTable(ID = [1, 2, 3], Name = ["John Doe", "Jane Doe", "Joe Blogs"])
job = DataTable(ID = [1, 2, 4], Job = ["Lawyer", "Doctor", "Farmer"])

join(name, job, on = :ID)
join(name, job, on = :ID, kind = :outer)
join(name, job, on = :ID, kind = :left)
join(name, job, on = :ID, kind = :right)
join(name, job, on = :ID, kind = :semi)
join(name, job, on = :ID, kind = :anti)
join(name, job, kind = :cross)
```

"""
function Base.join(dt1::AbstractDataTable,
                   dt2::AbstractDataTable;
                   on::Union{Symbol, Vector{Symbol}} = Symbol[],
                   kind::Symbol = :inner)
    if kind == :cross
        (on == Symbol[]) || throw(ArgumentError("Cross joins don't use argument 'on'."))
        return crossjoin(dt1, dt2)
    elseif on == Symbol[]
        throw(ArgumentError("Missing join argument 'on'."))
    end

    joiner = DataTableJoiner(dt1, dt2, on)

    if kind == :inner
        compose_joined_table(joiner, update_row_maps!(joiner.dtl_on, joiner.dtr_on,
                             group_rows(joiner.dtr_on),
                             true, false, true, false)...)
    elseif kind == :left
        compose_joined_table(joiner, update_row_maps!(joiner.dtl_on, joiner.dtr_on,
                             group_rows(joiner.dtr_on),
                             true, true, true, false)...)
    elseif kind == :right
        right_ixs, rightonly_ixs, left_ixs, leftonly_ixs =
            update_row_maps!(joiner.dtr_on, joiner.dtl_on,
                            group_rows(joiner.dtl_on),
                            true, true, true, false)
        compose_joined_table(joiner, left_ixs, leftonly_ixs, right_ixs, rightonly_ixs)
    elseif kind == :outer
        compose_joined_table(joiner, update_row_maps!(joiner.dtl_on, joiner.dtr_on,
                             group_rows(joiner.dtr_on),
                             true, true, true, true)...)
    elseif kind == :semi
        # hash the right rows
        dtr_on_grp = group_rows(joiner.dtr_on)
        # iterate over left rows and leave those found in right
        left_ixs = Vector{Int}()
        sizehint!(left_ixs, nrow(joiner.dtl))
        for l_ix in 1:nrow(joiner.dtl_on)
            if in(dtr_on_grp, joiner.dtl_on, l_ix)
                push!(left_ixs, l_ix)
            end
        end
        return joiner.dtl[left_ixs, :]
    elseif kind == :anti
        # hash the right rows
        dtr_on_grp = group_rows(joiner.dtr_on)
        # iterate over left rows and leave those not found in right
        leftonly_ixs = Vector{Int}()
        sizehint!(leftonly_ixs, nrow(joiner.dtl))
        for l_ix in 1:nrow(joiner.dtl_on)
            if !in(dtr_on_grp, joiner.dtl_on, l_ix)
                push!(leftonly_ixs, l_ix)
            end
        end
        return joiner.dtl[leftonly_ixs, :]
    else
        throw(ArgumentError("Unknown kind ($kind) of join requested"))
    end
end

function crossjoin(dt1::AbstractDataTable, dt2::AbstractDataTable)
    r1, r2 = size(dt1, 1), size(dt2, 1)
    cols = Any[[repeat(c, inner=r2) for c in columns(dt1)];
               [repeat(c, outer=r1) for c in columns(dt2)]]
    colindex = merge(index(dt1), index(dt2))
    DataTable(cols, colindex)
end
