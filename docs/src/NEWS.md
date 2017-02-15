## DataTables v0.6.11 Release Notes

##### Changes
* New documentation based on Documenter ([#929])
* Support new fit indicator functions for statistical models ([#921]).
* Add string literals csv, csv2, wsv, and tsv ([#918])
* Add a readtable argument for optional name normalization ([#896])

## DataTables v0.6.6 Release Notes

##### Deprecations
* Deprecates `array(dt, ...)` in favor of `convert(Array, dt, ...)` ([#806])
* Deprecates `DataArray(dt, T)` in favor of `convert(DataArray{T}, dt)` ([#806])

## DataTables v0.6.3 Release Notes

##### Deprecations
* Removes `save` and `loaddt`, since the format was not compatible
  across Julia and DataTables versions ([#790]). Use `writetable` or
  [JLD](https://github.com/timholy/HDF5.jl) to save DataTables

## DataTables v0.6.1 Release Notes

##### New features
* `writetable` supports `append` option ([#755])

##### Changes
* Faster `read_rda` ([#754], [#759])

## DataTables v0.6.0 Release Notes

Focus on performance improvements and rooting out bugs in corner cases.

##### New features
* Constructor for empty DataTables allows specifying PDAs ([#725])
* `stack(dt)` and `melt(dt)`, which take FloatingPoint vars as measure vars ([#734])
* New convenience methods for `unstack` ([#734])
* `convertdataframes` option added to `read_rda` ([#751])

##### Changes
* `vcat(dts)` handles container and eltype promotion ([#747])
* `join` finally handles DataTables with no non-key columns ([#749])
* sorting methods throw an error when args meant for `cols` are passed to `by` ([#749])
* `rename!` and `rename` throw when column to be renamed does not exist ([#749])
* `names!`, `rename!`, and `rename` for DataTables now return DataTables ([#749])

##### Deprecations
* Deprecates `by(dt, cols, [symbol(s)])` in favor of `aggregate(dt, cols, [function(s)])` ([#726])
* Removes `pivottable` in favor of other reshaping methods ([#734])
* Deprecates `nullable!(..., ::AbstractDataTable)` in favor of `nullable!(::DataTable, ...)` ([#752])
* Deprecates `keys(dt)`, `values(dt)` ([#752])
* Renames `insert!(dt, dt)` to `merge!(dt, dts...)` ([#752])

## DataTables v0.5.12 Release Notes

Track changes to JuliaLang/julia

## DataTables v0.5.11 Release Notes

Track changes to JuliaLang/julia

## DataTables v0.5.10 Release Notes

##### New features

* Formulas handle three-way (and higher) interactions ([#700])

##### Changes

* Now using ReadTheDocs for documentation

## DataTables v0.5.9 Release Notes

Track changes to JuliaLang/julia

## DataTables v0.5.8 Release Notes

##### New features

* Extends `StatsBase.predict` to take a DataTable as a predictor ([#679])
* `coefnames` handles random-effect terms ([#662])

##### Deprecations

* Deprecates `DataTable(::Dict, ...)` in favor of `convert` ([#626])

## DataTables v0.5.7 Release Notes

##### New features

* `deleterows!(dt::DataTable, inds)` ([#635])

##### Changes

* `empty!(::DataTable)` and `insert!(::DataTable, ...)` now operate in place ([#634])
* All exported higher-order functions now handle do-block syntax ([#643])

## DataTables v0.5.6 Release Notes

Track changes to JuliaLang/julia

## DataTables v0.5.5 Release Notes

##### New features

* Support fitting arbitrary StatisticalModels ([#571])
* Test coverage now tracked via Coveralls.io ([#597])

##### Changes
* `show(::AbstractDataTable)` now shows all columns by default

##### Deprecations

* Deprecates `DataTable(::Any...)`, `DataTable(::Associative)` ([#610])

## DataTables v0.5.4 Release Notes

##### New features

* `push!` methods add a row to a DataTable ([#621])
* Test coverage now tracked via Coveralls.io ([#597])

##### Changes

* IO functions ensure column names are valid symbols ([#563])
* `setindex!` methods now return the updated DataTable

##### Deprecations

* Deprecates `DataTable(::Int, ::Int)` ([#561])

## DataTables v0.5.3 Release Notes

Internal changes to adjust to [JuliaLang/julia#5897]

## DataTables v0.5.2 Release Notes

Continues trend of stripping down features and improving core functionality.

##### New features

* `append!(::AbstractDataTable, ::AbstractDataTable)` ([#506])
* `join` supports `:semi`-, `:anti`- and `:cross`-joins ([#524], [#536])
* Implement `eltypes` argument in `readtable` ([#497])
* Read from generic IO objects ([#499])

##### Changes

* Convert to using only symbols (no more strings) for column names ([#509])
* Renames `stack_dt`, `melt_dt`, `pivot_table` to `stackdt`, `meltdt`, `pivottable` ([#538])
* Renames `duplicated`, `drop_duplicates!` to `nonunique`, `unique!` ([#538])
* Renames `load_dt` to `loaddt` ([#538])
* Renames `types` to `eltypes` ([#539])
* Renames `readtable` argument `colnames` to `names` ([#497])

##### Deprecations

* Removes expression-based indexing, including `with`, `within!`, `based_on`, etc. ([#492])
* Removes `DataStream` ([#492])
* Removes `NamedArray` ([#492])
* Removes column groupings (`set_groups`, `get_groups`, etc.)  ([#492])
* Removes specific colwise and rowwise functions (`rowsums`, `colnorms`, etc.) ([#492])
* Removes `@DataTable` and `@transform` ([#492])
* Deprecates natural `join`s: the key must be specified now ([#536])

## DataTables v0.5.1 Release Notes

Removing prototype features until core functionality is farther along.

##### Changes

* Write `Formula`s without quoting, thanks to the `@~` macro ([JuliaLang/julia#4882])
* Renames `EachCol`, `EachRow` to `eachcol`, `eachrow` ([#474])
* `eachrow` returns a `DataTableRow` ([#474])
* `SubDataTables` are now immutable ([#474])

##### Deprecations

* Removes `IndexedVector` ([#483])
* Removes `Blocks.jl` functionality ([#483])
* Removes methods that treat DataTable like a matrix, e.g `round`, `sin` ([#484])
* Deprecates `sub`'s alias `subset` ([#474])

## DataTables v0.5.0 Release Notes

Improved I/O and more-Julian idioms.

##### New features

* Write HTML tables via writemime ([#433])
* Read whitespace-delimited input ([#443])
* Read input with C-style escapes ([#454])

##### Changes

* `sort` interface updated to better match mainline Julia ([#389])
* `names!`, `rename!`, and `delete!` now return the updated Index, rather than the names in the Index ([#445])
* Renames `coltypes`, `colnames`, `clean_colnames!` to `types`, `names`, `cleannames!` ([#469])
* Various improvements to `print`/`show` methods

##### Deprecations

* Deprecates `rbind`, `cbind` and `vecbind` deprecated in favor of `hcat` and `vcat` ([#453])

[#389]: https://github.com/JuliaStats/DataTables.jl/issues/389
[#433]: https://github.com/JuliaStats/DataTables.jl/issues/433
[#443]: https://github.com/JuliaStats/DataTables.jl/issues/443
[#445]: https://github.com/JuliaStats/DataTables.jl/issues/445
[#453]: https://github.com/JuliaStats/DataTables.jl/issues/453
[#454]: https://github.com/JuliaStats/DataTables.jl/issues/454
[#469]: https://github.com/JuliaStats/DataTables.jl/issues/469
[#474]: https://github.com/JuliaStats/DataTables.jl/issues/474
[#483]: https://github.com/JuliaStats/DataTables.jl/issues/483
[#484]: https://github.com/JuliaStats/DataTables.jl/issues/484
[#492]: https://github.com/JuliaStats/DataTables.jl/issues/492
[#497]: https://github.com/JuliaStats/DataTables.jl/issues/497
[#499]: https://github.com/JuliaStats/DataTables.jl/issues/499
[#506]: https://github.com/JuliaStats/DataTables.jl/issues/506
[#509]: https://github.com/JuliaStats/DataTables.jl/issues/509
[#524]: https://github.com/JuliaStats/DataTables.jl/issues/524
[#536]: https://github.com/JuliaStats/DataTables.jl/issues/536
[#538]: https://github.com/JuliaStats/DataTables.jl/issues/538
[#539]: https://github.com/JuliaStats/DataTables.jl/issues/539
[#561]: https://github.com/JuliaStats/DataTables.jl/issues/561
[#563]: https://github.com/JuliaStats/DataTables.jl/issues/563
[#571]: https://github.com/JuliaStats/DataTables.jl/issues/571
[#597]: https://github.com/JuliaStats/DataTables.jl/issues/597
[#610]: https://github.com/JuliaStats/DataTables.jl/issues/610
[#621]: https://github.com/JuliaStats/DataTables.jl/issues/621
[#626]: https://github.com/JuliaStats/DataTables.jl/issues/626
[#634]: https://github.com/JuliaStats/DataTables.jl/issues/634
[#635]: https://github.com/JuliaStats/DataTables.jl/issues/635
[#643]: https://github.com/JuliaStats/DataTables.jl/issues/643
[#662]: https://github.com/JuliaStats/DataTables.jl/issues/662
[#679]: https://github.com/JuliaStats/DataTables.jl/issues/679
[#700]: https://github.com/JuliaStats/DataTables.jl/issues/700
[#725]: https://github.com/JuliaStats/DataTables.jl/issues/725
[#726]: https://github.com/JuliaStats/DataTables.jl/issues/726
[#734]: https://github.com/JuliaStats/DataTables.jl/issues/734
[#747]: https://github.com/JuliaStats/DataTables.jl/issues/747
[#749]: https://github.com/JuliaStats/DataTables.jl/issues/749
[#751]: https://github.com/JuliaStats/DataTables.jl/issues/751
[#752]: https://github.com/JuliaStats/DataTables.jl/issues/752
[#754]: https://github.com/JuliaStats/DataTables.jl/issues/754
[#755]: https://github.com/JuliaStats/DataTables.jl/issues/755
[#759]: https://github.com/JuliaStats/DataTables.jl/issues/759
[#790]: https://github.com/JuliaStats/DataTables.jl/issues/790
[#806]: https://github.com/JuliaStats/DataTables.jl/issues/806

[JuliaLang/julia#4882]: https://github.com/JuliaLang/julia/issues/4882
[JuliaLang/julia#5897]: https://github.com/JuliaLang/julia/issues/5897
