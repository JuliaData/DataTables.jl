##############################################################################
##
## Reshaping
##
## Also, see issue # ??
##
##############################################################################

##############################################################################
##
## stack()
## melt()
##
##############################################################################

"""
Stacks a DataTable; convert from a wide to long format


```julia
stack(dt::AbstractDataTable, [measure_vars], [id_vars];
      variable_name::Symbol=:variable, value_name::Symbol=:value)
melt(dt::AbstractDataTable, [id_vars], [measure_vars];
     variable_name::Symbol=:variable, value_name::Symbol=:value)
```

### Arguments

* `dt` : the AbstractDataTable to be stacked

* `measure_vars` : the columns to be stacked (the measurement
  variables), a normal column indexing type, like a Symbol,
  Vector{Symbol}, Int, etc.; for `melt`, defaults to all
  variables that are not `id_vars`. If neither `measure_vars`
  or `id_vars` are given, `measure_vars` defaults to all
  floating point columns.

* `id_vars` : the identifier columns that are repeated during
  stacking, a normal column indexing type; for `stack` defaults to all
  variables that are not `measure_vars`

* `variable_name` : the name of the new stacked column that shall hold the names
  of each of `measure_vars`

* `value_name` : the name of the new stacked column containing the values from
  each of `measure_vars`


### Result

* `::DataTable` : the long-format datatable with column `:value`
  holding the values of the stacked columns (`measure_vars`), with
  column `:variable` a Vector of Symbols with the `measure_vars` name,
  and with columns for each of the `id_vars`.

### Examples

```julia
d1 = DataTable(a = repeat([1:3;], inner = [4]),
               b = repeat([1:4;], inner = [3]),
               c = randn(12),
               d = randn(12),
               e = map(string, 'a':'l'))

d1s = stack(d1, [:c, :d])
d1s2 = stack(d1, [:c, :d], [:a])
d1m = melt(d1, [:a, :b, :e])
d1s_name = melt(d1, [:a, :b, :e], variable_name=:somemeasure)
```

"""
function stack(dt::AbstractDataTable, measure_vars::Vector{Int},
               id_vars::Vector{Int}; variable_name::Symbol=:variable,
               value_name::Symbol=:value)
    N = length(measure_vars)
    cnames = names(dt)[id_vars]
    insert!(cnames, 1, value_name)
    insert!(cnames, 1, variable_name)
    DataTable(Any[repeat(_names(dt)[measure_vars], inner=nrow(dt)), # variable
                  vcat([dt[c] for c in measure_vars]...),           # value
                  [repeat(dt[c], outer=N) for c in id_vars]...],    # id_var columns
              cnames)
end
function stack(dt::AbstractDataTable, measure_var::Int, id_var::Int;
               variable_name::Symbol=:variable, value_name::Symbol=:value)
    stack(dt, [measure_var], [id_var];
          variable_name=variable_name, value_name=value_name)
end
function stack(dt::AbstractDataTable, measure_vars::Vector{Int}, id_var::Int;
               variable_name::Symbol=:variable, value_name::Symbol=:value)
    stack(dt, measure_vars, [id_var];
          variable_name=variable_name, value_name=value_name)
end
function stack(dt::AbstractDataTable, measure_var::Int, id_vars::Vector{Int};
               variable_name::Symbol=:variable, value_name::Symbol=:value)
    stack(dt, [measure_var], id_vars;
            variable_name=variable_name, value_name=value_name)
end
function stack(dt::AbstractDataTable, measure_vars, id_vars;
               variable_name::Symbol=:variable, value_name::Symbol=:value)
    stack(dt, index(dt)[measure_vars], index(dt)[id_vars];
          variable_name=variable_name, value_name=value_name)
end
# no vars specified, by default select only numeric columns
numeric_vars(dt::AbstractDataTable) =
    [T <: AbstractFloat || (T <: Nullable && eltype(T) <: AbstractFloat)
     for T in eltypes(dt)]

function stack(dt::AbstractDataTable, measure_vars = numeric_vars(dt);
               variable_name::Symbol=:variable, value_name::Symbol=:value)
    mv_inds = index(dt)[measure_vars]
    stack(dt, mv_inds, _setdiff(1:ncol(dt), mv_inds);
          variable_name=variable_name, value_name=value_name)
end

"""
Stacks a DataTable; convert from a wide to long format; see
`stack`.
"""
function melt(dt::AbstractDataTable, id_vars::@compat(Union{Int,Symbol});
              variable_name::Symbol=:variable, value_name::Symbol=:value)
    melt(dt, [id_vars]; variable_name=variable_name, value_name=value_name)
end
function melt(dt::AbstractDataTable, id_vars;
              variable_name::Symbol=:variable, value_name::Symbol=:value)
    id_inds = index(dt)[id_vars]
    stack(dt, _setdiff(1:ncol(dt), id_inds), id_inds;
          variable_name=variable_name, value_name=value_name)
end
function melt(dt::AbstractDataTable, id_vars, measure_vars;
              variable_name::Symbol=:variable, value_name::Symbol=:value)
    stack(dt, measure_vars, id_vars; variable_name=variable_name,
          value_name=value_name)
end
melt(dt::AbstractDataTable; variable_name::Symbol=:variable, value_name::Symbol=:value) =
    stack(dt; variable_name=variable_name, value_name=value_name)

##############################################################################
##
## unstack()
##
##############################################################################

"""
Unstacks a DataTable; convert from a long to wide format

```julia
unstack(dt::AbstractDataTable, rowkey, colkey, value)
unstack(dt::AbstractDataTable, colkey, value)
unstack(dt::AbstractDataTable)
```

### Arguments

* `dt` : the AbstractDataTable to be unstacked

* `rowkey` : the column with a unique key for each row, if not given,
  find a key by grouping on anything not a `colkey` or `value`

* `colkey` : the column holding the column names in wide format,
  defaults to `:variable`

* `value` : the value column, defaults to `:value`

### Result

* `::DataTable` : the wide-format datatable


### Examples

```julia
wide = DataTable(id = 1:12,
                 a  = repeat([1:3;], inner = [4]),
                 b  = repeat([1:4;], inner = [3]),
                 c  = randn(12),
                 d  = randn(12))

long = stack(wide)
wide0 = unstack(long)
wide1 = unstack(long, :variable, :value)
wide2 = unstack(long, :id, :variable, :value)
```
Note that there are some differences between the widened results above.

"""
function unstack(dt::AbstractDataTable, rowkey::Int, colkey::Int, value::Int)
    # `rowkey` integer indicating which column to place along rows
    # `colkey` integer indicating which column to place along column headers
    # `value` integer indicating which column has values
    values = dt[value]
    newcols = dt[colkey]
    uniquenewcols = unique(newcols)
    ncol = length(uniquenewcols) + 1
    columns = Vector{Any}(ncol)
    columns[1] = unique(dt[rowkey])
    for (i,coli) in enumerate(2:ncol)
        columns[coli] = values[find(newcols .== uniquenewcols[i])]
    end
    colnames = vcat(names(dt)[rowkey], Symbol.(uniquenewcols))
    DataTable(columns, colnames)
end
unstack(dt::AbstractDataTable, rowkey, colkey, value) =
    unstack(dt, index(dt)[rowkey], index(dt)[colkey], index(dt)[value])

# Version of unstack with just the colkey and value columns provided
unstack(dt::AbstractDataTable, colkey, value) =
    unstack(dt, index(dt)[colkey], index(dt)[value])

function unstack(dt::AbstractDataTable, colkey::Int, value::Int)
    anchor = unique(dt[deleteat!(names(dt), [colkey, value])])
    groups = groupby(dt, names(anchor))
    newcolnames = unique(dt[colkey])
    newcols = DataTable(Any[typeof(dt[value])(size(anchor,1)) for n in newcolnames], Symbol.(newcolnames))
    for (i, g) in enumerate(groups)
        for col in newcolnames
            newcols[i, Symbol(col)] = g[g[colkey] .== col, value][1]
        end
    end
    hcat(anchor, newcols)
end

unstack(dt::AbstractDataTable) = unstack(dt, :id, :variable, :value)
