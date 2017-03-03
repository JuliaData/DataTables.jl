##
## Join / merge
##

# Like similar, but returns a nullable array
similar_nullable{T<:Nullable}(dv::AbstractArray{T}, dims::@compat(Union{Int, Tuple{Vararg{Int}}})) =
    NullableArray(eltype(T), dims)

similar_nullable(dt::AbstractDataTable, dims::Int) =
    DataTable(Any[similar_nullable(x, dims) for x in columns(dt)], copy(index(dt)))

# helper structure for DataTables joining
immutable DataTableJoiner{DT1<:AbstractDataTable, DT2<:AbstractDataTable}
    dtl::DT1
    dtr::DT2
    dtl_on::DT1
    dtr_on::DT2
    on_cols::Vector{Symbol}

    function DataTableJoiner(dtl::DT1, dtr::DT2, on::Union{Symbol,Vector{Symbol}})
        on_cols = isa(on, Symbol) ? [on] : on
        new(dtl, dtr, dtl[on_cols], dtr[on_cols], on_cols)
    end
end

DataTableJoiner{DT1<:AbstractDataTable, DT2<:AbstractDataTable}(dtl::DT1, dtr::DT2, on::Union{Symbol,Vector{Symbol}}) =
    DataTableJoiner{DT1,DT2}(dtl, dtr, on)

# helper map between the row indices in original and joined table
immutable RowIndexMap
    "row indices in the original table"
    orig::Vector{Int}
    "row indices in the resulting joined table"
    join::Vector{Int}
end

Base.length(x::RowIndexMap) = length(x.orig)

# composes the joined data table using the maps between the left and right
# table rows and the indices of rows in the result
function compose_joined_table(joiner::DataTableJoiner,
                              left_ixs::RowIndexMap, leftonly_ixs::RowIndexMap,
                              right_ixs::RowIndexMap, rightonly_ixs::RowIndexMap)
    @assert length(left_ixs) == length(right_ixs)
    # compose left half of the result taking all left columns
    all_orig_left_ixs = vcat(left_ixs.orig, leftonly_ixs.orig)
    if length(leftonly_ixs) > 0
        # permute the indices to restore left table rows order
        all_orig_left_ixs[vcat(left_ixs.join, leftonly_ixs.join)] = all_orig_left_ixs
    end
    ril = length(right_ixs)
    loil = length(leftonly_ixs)
    roil = length(rightonly_ixs)
    left_dt = DataTable(Any[resize!(col[all_orig_left_ixs], length(all_orig_left_ixs)+roil)
                            for col in columns(joiner.dtl)],
                        names(joiner.dtl))

    # compose right half of the result taking all right columns excluding on
    dtr_noon = without(joiner.dtr, joiner.on_cols)
    # permutation to swap rightonly and leftonly rows
    right_perm = vcat(1:ril, ril+roil+1:ril+roil+loil, ril+1:ril+roil)
    if length(leftonly_ixs) > 0
        # compose right_perm with the permutation that restores left rows order
        right_perm[vcat(right_ixs.join, leftonly_ixs.join)] = right_perm[1:ril+loil]
    end
    all_orig_right_ixs = vcat(right_ixs.orig, rightonly_ixs.orig)
    right_dt = DataTable(Any[resize!(col[all_orig_right_ixs], length(all_orig_right_ixs)+loil)[right_perm]
                            for col in columns(dtr_noon)],
                         names(dtr_noon))
    # merge left and right parts of the joined table
    res = hcat!(left_dt, right_dt)

    if length(rightonly_ixs.join) > 0
        # some left rows are nulls, so the values of the "on" columns
        # need to be taken from the right
        for (on_col_ix, on_col) in enumerate(joiner.on_cols)
            # fix the result of the rightjoin by taking the nonnull values from the right table
            res[on_col][rightonly_ixs.join] = joiner.dtr_on[rightonly_ixs.orig, on_col_ix]
        end
    end
    return res
end

# map the indices of the left and right joined tables
# to the indices of the rows in the resulting table
# if `nothing` is given, the corresponding map is not built
function update_row_maps!(left_table::AbstractDataTable,
                          right_table::AbstractDataTable,
                          right_dict::RowGroupDict,
                          left_ixs::Union{Void, RowIndexMap},
                          leftonly_ixs::Union{Void, RowIndexMap},
                          right_ixs::Union{Void, RowIndexMap},
                          rightonly_mask::Union{Void, Vector{Bool}})
    # helper functions
    @inline update!(ixs::Void, orig_ix::Int, join_ix::Int, count::Int = 1) = nothing
    @inline function update!(ixs::RowIndexMap, orig_ix::Int, join_ix::Int, count::Int = 1)
        for i in 1:count
            push!(ixs.orig, orig_ix)
        end
        for i in join_ix:(join_ix+count-1)
            push!(ixs.join, i)
        end
        ixs
    end
    @inline update!(ixs::Void, orig_ixs::AbstractArray, join_ix::Int) = nothing
    @inline function update!(ixs::RowIndexMap, orig_ixs::AbstractArray, join_ix::Int)
        append!(ixs.orig, orig_ixs)
        for i in join_ix:(join_ix+length(orig_ixs)-1)
            push!(ixs.join, i)
        end
        ixs
    end
    @inline update!(ixs::Void, orig_ixs::AbstractArray) = ixs
    @inline update!(mask::Vector{Bool}, orig_ixs::AbstractArray) = (mask[orig_ixs] = false)

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
# tuple element is empty RowIndexMap
function update_row_maps!(left_table::AbstractDataTable,
                          right_table::AbstractDataTable,
                          right_dict::RowGroupDict,
                          map_left::Bool, map_leftonly::Bool,
                          map_right::Bool, map_rightonly::Bool)
    init_map(dt::AbstractDataTable, init::Bool) = init ?
        RowIndexMap(sizehint!(Vector{Int}(), nrow(dt)),
                    sizehint!(Vector{Int}(), nrow(dt))) : nothing
    to_bimap(x::RowIndexMap) = x
    to_bimap(::Void) = RowIndexMap(Vector{Int}(), Vector{Int}())

    # init maps as requested
    left_ixs = init_map(left_table, map_left)
    leftonly_ixs = init_map(left_table, map_leftonly)
    right_ixs = init_map(right_table, map_right)
    rightonly_mask = map_rightonly ? fill(true, nrow(right_table)) : nothing
    update_row_maps!(left_table, right_table, right_dict, left_ixs, leftonly_ixs, right_ixs, rightonly_mask)
    if map_rightonly
        rightonly_orig_ixs = find(rightonly_mask)
        rightonly_ixs = RowIndexMap(rightonly_orig_ixs,
                                    collect(length(right_ixs.orig) +
                                            (leftonly_ixs === nothing ? 0 : length(leftonly_ixs)) +
                                            (1:length(rightonly_orig_ixs))))
    else
        rightonly_ixs = nothing
    end

    return to_bimap(left_ixs), to_bimap(leftonly_ixs), to_bimap(right_ixs), to_bimap(rightonly_ixs)
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
        right_ixs, rightonly_ixs, left_ixs, leftonly_ixs = update_row_maps!(joiner.dtr_on, joiner.dtl_on,
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
        @inbounds for l_ix in 1:nrow(joiner.dtl_on)
            if findrow(dtr_on_grp, joiner.dtl_on, l_ix) != 0
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
        @inbounds for l_ix in 1:nrow(joiner.dtl_on)
            if findrow(dtr_on_grp, joiner.dtl_on, l_ix) == 0
                push!(leftonly_ixs, l_ix)
            end
        end
        return joiner.dtl[leftonly_ixs, :]
    else
        throw(ArgumentError("Unknown kind of join requested: $kind"))
    end
end

function crossjoin(dt1::AbstractDataTable, dt2::AbstractDataTable)
    r1, r2 = size(dt1, 1), size(dt2, 1)
    cols = Any[[repeat(c, inner=r2) for c in columns(dt1)];
               [repeat(c, outer=r1) for c in columns(dt2)]]
    colindex = merge(index(dt1), index(dt2))
    DataTable(cols, colindex)
end
