var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#DataTables-Documentation-Outline-1",
    "page": "Introduction",
    "title": "DataTables Documentation Outline",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Package-Manual-1",
    "page": "Introduction",
    "title": "Package Manual",
    "category": "section",
    "text": "Pages = [\"man/getting_started.md\", \"man/joins.md\", \"man/split_apply_combine.md\", \"man/reshaping_and_pivoting.md\", \"man/sorting.md\", \"man/categorical.md\", \"man/querying_frameworks.md\"]\nDepth = 2"
},

{
    "location": "index.html#API-1",
    "page": "Introduction",
    "title": "API",
    "category": "section",
    "text": "Pages = [\"lib/maintypes.md\", \"lib/manipulation.md\", \"lib/utilities.md\"]\nDepth = 2"
},

{
    "location": "index.html#Documentation-Index-1",
    "page": "Introduction",
    "title": "Documentation Index",
    "category": "section",
    "text": "Pages = [\"lib/maintypes.md\", \"lib/manipulation.md\", \"lib/utilities.md\"]"
},

{
    "location": "man/getting_started.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "man/getting_started.html#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": ""
},

{
    "location": "man/getting_started.html#Installation-1",
    "page": "Getting Started",
    "title": "Installation",
    "category": "section",
    "text": "The DataTables package is available through the Julia package system. Throughout the rest of this tutorial, we will assume that you have installed the DataTables package and have already typed using NullableArrays, DataTables to bring all of the relevant variables into your current namespace. In addition, we will make use of the RDatasets package, which provides access to hundreds of classical data sets."
},

{
    "location": "man/getting_started.html#The-Nullable-Type-1",
    "page": "Getting Started",
    "title": "The Nullable Type",
    "category": "section",
    "text": "To get started, let's examine the Nullable type. Objects of this type can either hold a value, or represent a missing value (null). For example, this is a Nullable holding the integer 1:Nullable(1)And this represents a missing value:Nullable()Nullable objects support all standard operators, which return another Nullable. One of the essential properties of null values is that they poison other items. To see this, try to add something like Nullable(1) to Nullable():Nullable(1) + Nullable()The get function can be used to extract the value from the Nullable wrapper when it is not null. For example:julia> a = Nullable(\"14:00:00\")\nNullable{String}(\"14:00:00\")\n\njulia> b = get(a)\n\"14:00:00\"\n\njulia> typeof(b)\nStringNote that operations mixing Nullable and scalars (e.g. 1 + Nullable(1)) are not supported."
},

{
    "location": "man/getting_started.html#The-NullableArray-Type-1",
    "page": "Getting Started",
    "title": "The NullableArray Type",
    "category": "section",
    "text": "Nullable objects can be stored in a standard Array just like any value:v = Nullable{Int}[1, 3, 4, 5, 4]But arrays of Nullable are inefficient, both in terms of computation costs and of memory use. NullableArrays provide a more efficient storage, and behave like Array{Nullable} objects.nv = NullableArray(Nullable{Int}[Nullable(), 3, 2, 5, 4])In many cases we're willing to just ignore missing values and remove them from our vector. We can do that using the dropnull function:dropnull(nv)\nmean(dropnull(nv))Instead of removing null values, you can try to convert the NullableArray into a normal Julia Array using convert:convert(Array, nv)This fails in the presence of null values, but will succeed if there are no null values:nv[1] = 3\nconvert(Array, nv)In addition to removing null values and hoping they won't occur, you can also replace any null values using the convert function, which takes a replacement value as an argument:nv = NullableArray(Nullable{Int}[Nullable(), 3, 2, 5, 4])\nmean(convert(Array, nv, 0))Which strategy for dealing with null values is most appropriate will typically depend on the specific details of your data analysis pathway."
},

{
    "location": "man/getting_started.html#The-DataTable-Type-1",
    "page": "Getting Started",
    "title": "The DataTable Type",
    "category": "section",
    "text": "The DataTable type can be used to represent data tables, each column of which is an array (by default, a NullableArray). You can specify the columns using keyword arguments:dt = DataTable(A = 1:4, B = [\"M\", \"F\", \"F\", \"M\"])It is also possible to construct a DataTable in stages:dt = DataTable()\ndt[:A] = 1:8\ndt[:B] = [\"M\", \"F\", \"F\", \"M\", \"F\", \"M\", \"M\", \"F\"]\ndtThe DataTable we build in this way has 8 rows and 2 columns. You can check this using size function:nrows = size(dt, 1)\nncols = size(dt, 2)We can also look at small subsets of the data in a couple of different ways:head(dt)\ntail(dt)\n\ndt[1:3, :]Having seen what some of the rows look like, we can try to summarize the entire data set using describe:describe(dt)To focus our search, we start looking at just the means and medians of specific columns. In the example below, we use numeric indexing to access the columns of the DataTable:mean(dropnull(dt[1]))\nmedian(dropnull(dt[1]))We could also have used column names to access individual columns:mean(dropnull(dt[:A]))\nmedian(dropnull(dt[:A]))We can also apply a function to each column of a DataTable with the colwise function. For example:dt = DataTable(A = 1:4, B = randn(4))\ncolwise(c->cumsum(dropnull(c)), dt)"
},

{
    "location": "man/getting_started.html#Importing-and-Exporting-Data-(I/O)-1",
    "page": "Getting Started",
    "title": "Importing and Exporting Data (I/O)",
    "category": "section",
    "text": "For reading and writing tabular data from CSV and other delimited text files, use the CSV.jl package.If you have not used the CSV.jl package before then you may need to download it first.Pkg.add(\"CSV\")The CSV.jl functions are not loaded automatically and must be imported into the session.# can be imported separately\nusing DataTables\nusing CSV\n# or imported together, separated by commas\nusing DataTables, CSVA dataset can now be read from a CSV file at path input usingCSV.read(input, DataTable)Note the second positional argument of DataTable. This instructs the CSV package to output a DataTable rather than the default DataFrame. Keyword arguments may be passed to CSV.read after this second argument.A DataTable can be written to a CSV file at path output usingdt = DataTable(x = 1, y = 2)\nCSV.write(output, dt)For more information, use the REPL help-mode or checkout the online CSV.jl documentation!"
},

{
    "location": "man/getting_started.html#Accessing-Classic-Data-Sets-1",
    "page": "Getting Started",
    "title": "Accessing Classic Data Sets",
    "category": "section",
    "text": "To see more of the functionality for working with DataTable objects, we need a more complex data set to work with. We'll use the RDatasets package, which provides access to many of the classical data sets that are available in R.For example, we can access Fisher's iris data set using the following functions:using CSV\niris = CSV.read(joinpath(Pkg.dir(\"DataTables\"), \"test/data/iris.csv\"), DataTable)\nhead(iris)In the next section, we'll discuss generic I/O strategy for reading and writing DataTable objects that you can use to import and export your own data files."
},

{
    "location": "man/getting_started.html#Querying-DataTables-1",
    "page": "Getting Started",
    "title": "Querying DataTables",
    "category": "section",
    "text": "While the DataTables package provides basic data manipulation capabilities, users are encouraged to use the following packages for more powerful and complete data querying functionality in the spirit of dplyr and LINQ:Query.jl provides a LINQ like interface to a large number of data sources, including DataTable instances."
},

{
    "location": "man/joins.html#",
    "page": "Joins",
    "title": "Joins",
    "category": "page",
    "text": ""
},

{
    "location": "man/joins.html#Database-Style-Joins-1",
    "page": "Joins",
    "title": "Database-Style Joins",
    "category": "section",
    "text": "We often need to combine two or more data sets together to provide a complete picture of the topic we are studying. For example, suppose that we have the following two data sets:names = DataTable(ID = [20, 40], Name = [\"John Doe\", \"Jane Doe\"])\njobs = DataTable(ID = [20, 40], Job = [\"Lawyer\", \"Doctor\"])We might want to work with a larger data set that contains both the names and jobs for each ID. We can do this using the join function:full = join(names, jobs, on = :ID)Output:Row ID Name Job\n1 20 \"John Doe\" \"Lawyer\"\n2 40 \"Jane Doe\" \"Doctor\"In relational database theory, this operation is generally referred to as a join. The columns used to determine which rows should be combined during a join are called keys.There are seven kinds of joins supported by the DataTables package:Inner: The output contains rows for values of the key that exist in both the first (left) and second (right) arguments to join.\nLeft: The output contains rows for values of the key that exist in the first (left) argument to join, whether or not that value exists in the second (right) argument.\nRight: The output contains rows for values of the key that exist in the second (right) argument to join, whether or not that value exists in the first (left) argument.\nOuter: The output contains rows for values of the key that exist in the first (left) or second (right) argument to join.\nSemi: Like an inner join, but output is restricted to columns from the first (left) argument to join.\nAnti: The output contains rows for values of the key that exist in the first (left) but not the second (right) argument to join. As with semi joins, output is restricted to columns from the first (left) argument.\nCross: The output is the cartesian product of rows from the first (left) and second (right) arguments to join.You can control the kind of join that join performs using the kind keyword argument:a = DataTable(ID = [20, 40], Name = [\"John Doe\", \"Jane Doe\"])\nb = DataTable(ID = [20, 60], Job = [\"Lawyer\", \"Astronaut\"])\njoin(a, b, on = :ID, kind = :inner)\njoin(a, b, on = :ID, kind = :left)\njoin(a, b, on = :ID, kind = :right)\njoin(a, b, on = :ID, kind = :outer)\njoin(a, b, on = :ID, kind = :semi)\njoin(a, b, on = :ID, kind = :anti)Cross joins are the only kind of join that does not use a key:join(a, b, kind = :cross)In order to join data tables on keys which have different names, you must first rename them so that they match. This can be done using rename!:a = DataTable(ID = [20, 40], Name = [\"John Doe\", \"Jane Doe\"])\nb = DataTable(IDNew = [20, 40], Job = [\"Lawyer\", \"Doctor\"])\nrename!(b, :IDNew, :ID)\njoin(a, b, on = :ID, kind = :inner)Or renaming multiple columns at a time:a = DataTable(City = [\"Amsterdam\", \"London\", \"London\", \"New York\", \"New York\"],\n              Job = [\"Lawyer\", \"Lawyer\", \"Lawyer\", \"Doctor\", \"Doctor\"],\n              Category = [1, 2, 3, 4, 5])\nb = DataTable(Location = [\"Amsterdam\", \"London\", \"London\", \"New York\", \"New York\"],\n              Work = [\"Lawyer\", \"Lawyer\", \"Lawyer\", \"Doctor\", \"Doctor\"],\n              Name = [\"a\", \"b\", \"c\", \"d\", \"e\"])\nrename!(b, [:Location => :City, :Work => :Job])\njoin(a, b, on = [:City, :Job])"
},

{
    "location": "man/split_apply_combine.html#",
    "page": "Split-apply-combine",
    "title": "Split-apply-combine",
    "category": "page",
    "text": ""
},

{
    "location": "man/split_apply_combine.html#The-Split-Apply-Combine-Strategy-1",
    "page": "Split-apply-combine",
    "title": "The Split-Apply-Combine Strategy",
    "category": "section",
    "text": "Many data analysis tasks involve splitting a data set into groups, applying some functions to each of the groups and then combining the results. A standardized framework for handling this sort of computation is described in the paper \"The Split-Apply-Combine Strategy for Data Analysis\", written by Hadley Wickham.The DataTables package supports the Split-Apply-Combine strategy through the by function, which takes in three arguments: (1) a DataTable, (2) one or more columns to split the DataTable on, and (3) a function or expression to apply to each subset of the DataTable.We show several examples of the by function applied to the iris dataset below:using DataTables\nusing CSV\niris = CSV.read(joinpath(Pkg.dir(\"DataTables\"), \"test/data/iris.csv\"), DataTable)\n\nby(iris, :Species, size)\nby(iris, :Species, dt -> mean(dropnull(dt[:PetalLength])))\nby(iris, :Species, dt -> DataTable(N = size(dt, 1)))The by function also support the do block form:by(iris, :Species) do dt\n   DataTable(m = mean(dropnull(dt[:PetalLength])), s² = var(dropnull(dt[:PetalLength])))\nendA second approach to the Split-Apply-Combine strategy is implemented in the aggregate function, which also takes three arguments: (1) a DataTable, (2) one or more columns to split the DataTable on, and (3) one or more functions that are used to compute a summary of each subset of the DataTable. Each function is applied to each column, that was not used to split the DataTable, creating new columns of the form $name_$function e.g. SepalLength_mean. Anonymous functions and expressions that do not have a name will be called λ1.We show several examples of the aggregate function applied to the iris dataset below:aggregate(iris, :Species, sum)\naggregate(iris, :Species, [sum, x->mean(dropnull(x))])If you only want to split the data set into subsets, use the groupby function:for subdt in groupby(iris, :Species)\n    println(size(subdt, 1))\nend"
},

{
    "location": "man/reshaping_and_pivoting.html#",
    "page": "Reshaping",
    "title": "Reshaping",
    "category": "page",
    "text": ""
},

{
    "location": "man/reshaping_and_pivoting.html#Reshaping-and-Pivoting-Data-1",
    "page": "Reshaping",
    "title": "Reshaping and Pivoting Data",
    "category": "section",
    "text": "Reshape data from wide to long format using the stack function:using DataTables\nusing CSV\niris = CSV.read(joinpath(Pkg.dir(\"DataTables\"), \"test/data/iris.csv\"), DataTable)\niris[:id] = 1:size(iris, 1)  # this makes it easier to unstack\nd = stack(iris, 1:4)The second optional argument to stack indicates the columns to be stacked. These are normally referred to as the measured variables. Column names can also be given:d = stack(iris, [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth])Note that all columns can be of different types. Type promotion follows the rules of vcat.The stacked DataTable that results includes all of the columns not specified to be stacked. These are repeated for each stacked column. These are normally refered to as identifier (id) columns. In addition to the id columns, two additional columns labeled :variable and :values contain the column identifier and the stacked columns.A third optional argument to stack represents the id columns that are repeated. This makes it easier to specify which variables you want included in the long format:d = stack(iris, [:SepalLength, :SepalWidth], :Species)melt is an alternative function to reshape from wide to long format. It is based on stack, but it prefers specification of the id columns as:d = melt(iris, :Species)All other columns are assumed to be measured variables (they are stacked).You can also stack an entire DataTable. The default stacks all floating-point columns:d = stack(iris)unstack converts from a long format to a wide format. The default is requires specifying which columns are an id variable, column variable names, and column values:longdt = melt(iris, [:Species, :id])\nwidedt = unstack(longdt, :id, :variable, :value)If the remaining columns are unique, you can skip the id variable and use:widedt = unstack(longdt, :variable, :value)stackdt and meltdt are two additional functions that work like stack and melt, but they provide a view into the original wide DataTable. Here is an example:d = stackdt(iris)This saves memory. To create the view, several AbstractVectors are defined::variable column – EachRepeatedVector   This repeats the variables N times where N is the number of rows of the original AbstractDataTable.:value column – StackedVector   This is provides a view of the original columns stacked together.Id columns – RepeatedVector   This repeats the original columns N times where N is the number of columns stacked.For more details on the storage representation, see:dump(stackdt(iris))None of these reshaping functions perform any aggregation. To do aggregation, use the split-apply-combine functions in combination with reshaping. Here is an example:d = stack(iris)\nx = by(d, [:variable, :Species], dt -> DataTable(vsum = mean(dropnull(dt[:value]))))\nunstack(x, :Species, :vsum)"
},

{
    "location": "man/sorting.html#",
    "page": "Sorting",
    "title": "Sorting",
    "category": "page",
    "text": ""
},

{
    "location": "man/sorting.html#Sorting-1",
    "page": "Sorting",
    "title": "Sorting",
    "category": "section",
    "text": "Sorting is a fundamental component of data analysis. Basic sorting is trivial: just calling sort! will sort all columns, in place:using DataTables\nusing CSV\niris = CSV.read(joinpath(Pkg.dir(\"DataTables\"), \"test/data/iris.csv\"), DataTable)\nsort!(iris)In Sorting DataTables, you may want to sort different columns with different options. Here are some examples showing most of the possible options:sort!(iris, rev = true)\nsort!(iris, cols = [:SepalWidth, :SepalLength])\n\nsort!(iris, cols = [order(:Species, by = uppercase),\n                    order(:SepalLength, rev = true)])Keywords used above include cols (to specify columns), rev (to sort a column or the whole DataTable in reverse), and by (to apply a function to a column/DataTable). Each keyword can either be a single value, or can be a tuple or array, with values corresponding to individual columns.As an alternative to using array or tuple values, order to specify an ordering for a particular column within a set of columnsThe following two examples show two ways to sort the iris dataset with the same result: Species will be ordered in reverse lexicographic order, and within species, rows will be sorted by increasing sepal length and width:sort!(iris, cols = (:Species, :SepalLength, :SepalWidth),\n      rev = (true, false, false))\n\nsort!(iris, cols = (order(:Species, rev = true), :SepalLength, :SepalWidth))"
},

{
    "location": "man/categorical.html#",
    "page": "Categorical Data",
    "title": "Categorical Data",
    "category": "page",
    "text": ""
},

{
    "location": "man/categorical.html#Categorical-Data-1",
    "page": "Categorical Data",
    "title": "Categorical Data",
    "category": "section",
    "text": "Often, we have to deal with factors that take on a small number of levels:v = [\"Group A\", \"Group A\", \"Group A\",\n     \"Group B\", \"Group B\", \"Group B\"]The naive encoding used in an Array or in a NullableArray represents every entry of this vector as a full string. In contrast, we can represent the data more efficiently by replacing the strings with indices into a small pool of levels. This is what the CategoricalArray type does:cv = CategoricalArray([\"Group A\", \"Group A\", \"Group A\",\n                       \"Group B\", \"Group B\", \"Group B\"])A companion type, NullableCategoricalArray, allows storing missing values in the array: is to CategoricalArray what NullableArray is to the standard Array type.In addition to representing repeated data efficiently, the CategoricalArray type allows us to determine efficiently the allowed levels of the variable at any time using the levels function (note that levels may or may not be actually used in the data):levels(cv)The levels! function also allows changing the order of appearance of the levels, which can be useful for display purposes or when working with ordered variables.By default, a CategoricalArray is able to represent 2<sup>32</sup>differents levels. You can use less memory by calling the compact function:cv = compact(cv)Often, you will have factors encoded inside a DataTable with Array or NullableArray columns instead of CategoricalArray or NullableCategoricalArray columns. You can do conversion of a single column using the categorical function:cv = categorical(v)Or you can edit the columns of a DataTable in-place using the categorical! function:dt = DataTable(A = [1, 1, 1, 2, 2, 2],\n               B = [\"X\", \"X\", \"X\", \"Y\", \"Y\", \"Y\"])\ncategorical!(dt, [:A, :B])Using categorical arrays is important for working with the GLM package. When fitting regression models, CategoricalArray and NullableCategoricalArray columns in the input are translated into 0/1 indicator columns in the ModelMatrix with one column for each of the levels of the CategoricalArray/NullableCategoricalArray. This allows one to analyze categorical data efficiently.See the CategoricalArrays package for more information regarding categorical arrays."
},

{
    "location": "man/querying_frameworks.html#",
    "page": "Querying frameworks",
    "title": "Querying frameworks",
    "category": "page",
    "text": ""
},

{
    "location": "man/querying_frameworks.html#Querying-frameworks-1",
    "page": "Querying frameworks",
    "title": "Querying frameworks",
    "category": "section",
    "text": ""
},

{
    "location": "man/querying_frameworks.html#Query.jl-1",
    "page": "Querying frameworks",
    "title": "Query.jl",
    "category": "section",
    "text": "The Query.jl package provides advanced data manipulation capabilities for DataTables (and many other data structures). This section provides a short introduction to the package, the Query.jl documentation has a more comprehensive documentation of the package.To get started, install the Query.jl package:Pkg.add(\"Query\")A query is started with the @from macro and consists of a series of query commands. Query.jl provides commands that can filter, project, join, group, flatten and group data from a DataTable. A query can return an iterator, or one can materialize the results of a query into a variety of data structures, including a new DataTable.A simple example of a query looks like this:using DataTables, Queryusing DataTables, Query\n\ndt = DataTable(name=[\"John\", \"Sally\", \"Roger\"], age=[54., 34., 79.], children=[0, 2, 4])\n\nq1 = @from i in dt begin\n     @where i.age > 40\n     @select {number_of_children=i.children, i.name}\n     @collect DataTable\nendThe query starts with the @from macro. The first argument i is the name of the range variable that will be used to refer to an individual row in later query commands. The next argument dt is the data source that one wants to query. The @where command in this query will filter the source data by applying the filter condition i.age > 40. This filters out any rows in which the age column is not larger than 40. The @select command then projects the columns of the source data onto a new column structure. The example here applies three specific modifications: 1) it only keeps a subset of the columns in the source DataTable, i.e. the age column will not be part of the transformed data; 2) it changes the order of the two columns that are selected; and 3) it renames one of the columns that is selected from children to number_of_children. The example query uses the {} syntax to achieve this. A {} in a Query.jl expression instantiates a new NamedTuple, i.e. it is a shortcut for writing @NT(number_of_children=>i.children, name=>i.name). The @collect statement determines the data structure that the query returns. In this example the results are returned as a DataTable.A query without a @collect statement returns a standard julia iterator that can be used with any normal julia language construct that can deal with iterators. The following code returns a julia iterator for the query results:q2 = @from i in dt begin\n     @where i.age > 40\n     @select {number_of_children=i.children, i.name}\nend\nnothing # hideOne can loop over the results using a standard julia for statement:total_children = 0\nfor i in q2\n    total_children += i.number_of_children\nend\n\nprintln(\"Total number of children: $(get(total_children))\")Or one can use a comprehension to extract the name of a subset of rows:y = [i.name for i in q2 if i.number_of_children > 0]The last example (extracting only the name and applying a second filter) could of course be completely expressed as a query expression:q3 = @from i in dt begin\n     @where i.age > 40 && i.children > 0\n     @select i.name\n     @collect\nendA query that ends with a @collect statement without a specific type will materialize the query results into an array. Note also the difference in the @select statement: The previous queries all used the {} syntax in the @select statement to project results into a tabular format. The last query instead just selects a single value from each row in the @select statement.These examples only scratch the surface of what one can do with Query.jl, and the interested reader is referred to the Query.jl documentation for more information."
},

{
    "location": "lib/maintypes.html#",
    "page": "Main types",
    "title": "Main types",
    "category": "page",
    "text": "CurrentModule = DataTables"
},

{
    "location": "lib/maintypes.html#DataTables.AbstractDataTable",
    "page": "Main types",
    "title": "DataTables.AbstractDataTable",
    "category": "Type",
    "text": "An abstract type for which all concrete types expose a database-like interface.\n\nCommon methods\n\nAn AbstractDataTable is a two-dimensional table with Symbols for column names. An AbstractDataTable is also similar to an Associative type in that it allows indexing by a key (the columns).\n\nThe following are normally implemented for AbstractDataTables:\n\ndescribe : summarize columns\ndump : show structure\nhcat : horizontal concatenation\nvcat : vertical concatenation\nnames : columns names\nnames! : set columns names\nrename! : rename columns names based on keyword arguments\neltypes : eltype of each column\nlength : number of columns\nsize : (nrows, ncols)\nhead : first n rows\ntail : last n rows\nconvert : convert to an array\nNullableArray : convert to a NullableArray\ncompletecases : boolean vector of complete cases (rows with no nulls)\ndropnull : remove rows with null values\ndropnull! : remove rows with null values in-place\nnonunique : indexes of duplicate rows\nunique! : remove duplicate rows\nsimilar : a DataTable with similar columns as d\n\nIndexing\n\nTable columns are accessed (getindex) by a single index that can be a symbol identifier, an integer, or a vector of each. If a single column is selected, just the column object is returned. If multiple columns are selected, some AbstractDataTable is returned.\n\nd[:colA]\nd[3]\nd[[:colA, :colB]]\nd[[1:3; 5]]\n\nRows and columns can be indexed like a Matrix with the added feature of indexing columns by name.\n\nd[1:3, :colA]\nd[3,3]\nd[3,:]\nd[3,[:colA, :colB]]\nd[:, [:colA, :colB]]\nd[[1:3; 5], :]\n\nsetindex works similarly.\n\n\n\n"
},

{
    "location": "lib/maintypes.html#DataTables.DataTable",
    "page": "Main types",
    "title": "DataTables.DataTable",
    "category": "Type",
    "text": "An AbstractDataTable that stores a set of named columns\n\nThe columns are normally AbstractVectors stored in memory, particularly a Vector, NullableVector, or CategoricalVector.\n\nConstructors\n\nDataTable(columns::Vector{Any}, names::Vector{Symbol})\nDataTable(kwargs...)\nDataTable() # an empty DataTable\nDataTable(t::Type, nrows::Integer, ncols::Integer) # an empty DataTable of arbitrary size\nDataTable(column_eltypes::Vector, names::Vector, nrows::Integer)\nDataTable(ds::Vector{Associative})\n\nArguments\n\ncolumns : a Vector{Any} with each column as contents\nnames : the column names\nkwargs : the key gives the column names, and the value is the column contents\nt : elemental type of all columns\nnrows, ncols : number of rows and columns\ncolumn_eltypes : elemental type of each column\nds : a vector of Associatives\n\nEach column in columns should be the same length.\n\nNotes\n\nMost of the default constructors convert columns to NullableArray.  The base constructor, DataTable(columns::Vector{Any}, names::Vector{Symbol}) does not convert to NullableArray.\n\nA DataTable is a lightweight object. As long as columns are not manipulated, creation of a DataTable from existing AbstractVectors is inexpensive. For example, indexing on columns is inexpensive, but indexing by rows is expensive because copies are made of each column.\n\nBecause column types can vary, a DataTable is not type stable. For performance-critical code, do not index into a DataTable inside of loops.\n\nExamples\n\ndt = DataTable()\nv = [\"x\",\"y\",\"z\"][rand(1:3, 10)]\ndt1 = DataTable(Any[collect(1:10), v, rand(10)], [:A, :B, :C])  # columns are Arrays\ndt2 = DataTable(A = 1:10, B = v, C = rand(10))           # columns are NullableArrays\ndump(dt1)\ndump(dt2)\ndescribe(dt2)\nDataTables.head(dt1)\ndt1[:A] + dt2[:C]\ndt1[1:4, 1:2]\ndt1[[:A,:C]]\ndt1[1:2, [:A,:C]]\ndt1[:, [:A,:C]]\ndt1[:, [1,3]]\ndt1[1:4, :]\ndt1[1:4, :C]\ndt1[1:4, :C] = 40. * dt1[1:4, :C]\n[dt1; dt2]  # vcat\n[dt1  dt2]  # hcat\nsize(dt1)\n\n\n\n"
},

{
    "location": "lib/maintypes.html#DataTables.SubDataTable",
    "page": "Main types",
    "title": "DataTables.SubDataTable",
    "category": "Type",
    "text": "A view of row subsets of an AbstractDataTable\n\nA SubDataTable is meant to be constructed with view.  A SubDataTable is used frequently in split/apply sorts of operations.\n\nview(d::AbstractDataTable, rows)\n\nArguments\n\nd : an AbstractDataTable\nrows : any indexing type for rows, typically an Int, AbstractVector{Int}, AbstractVector{Bool}, or a Range\n\nNotes\n\nA SubDataTable is an AbstractDataTable, so expect that most DataTable functions should work. Such methods include describe, dump, nrow, size, by, stack, and join. Indexing is just like a DataTable; copies are returned.\n\nTo subset along columns, use standard column indexing as that creates a view to the columns by default. To subset along rows and columns, use column-based indexing with view.\n\nExamples\n\ndt = DataTable(a = repeat([1, 2, 3, 4], outer=[2]),\n               b = repeat([2, 1], outer=[4]),\n               c = randn(8))\nsdt1 = view(dt, 1:6)\nsdt2 = view(dt, dt[:a] .> 1)\nsdt3 = view(dt[[1,3]], dt[:a] .> 1)  # row and column subsetting\nsdt4 = groupby(dt, :a)[1]  # indexing a GroupedDataTable returns a SubDataTable\nsdt5 = view(sdt1, 1:3)\nsdt1[:,[:a,:b]]\n\n\n\n"
},

{
    "location": "lib/maintypes.html#Main-Types-1",
    "page": "Main types",
    "title": "Main Types",
    "category": "section",
    "text": "Pages = [\"maintypes.md\"]AbstractDataTable\nDataTable\nSubDataTable"
},

{
    "location": "lib/utilities.html#",
    "page": "Utilities",
    "title": "Utilities",
    "category": "page",
    "text": "CurrentModule = DataTables"
},

{
    "location": "lib/utilities.html#DataTables.eltypes",
    "page": "Utilities",
    "title": "DataTables.eltypes",
    "category": "Function",
    "text": "Return element types of columns\n\neltypes(dt::AbstractDataTable)\n\nArguments\n\ndt : the AbstractDataTable\n\nResult\n\n::Vector{Type} : the element type of each column\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\neltypes(dt)\n\n\n\n"
},

{
    "location": "lib/utilities.html#DataTables.head",
    "page": "Utilities",
    "title": "DataTables.head",
    "category": "Function",
    "text": "Show the first or last part of an AbstractDataTable\n\nhead(dt::AbstractDataTable, r::Int = 6)\ntail(dt::AbstractDataTable, r::Int = 6)\n\nArguments\n\ndt : the AbstractDataTable\nr : the number of rows to show\n\nResult\n\n::AbstractDataTable : the first or last part of dt\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\nhead(dt)\ntail(dt)\n\n\n\n"
},

{
    "location": "lib/utilities.html#DataTables.completecases",
    "page": "Utilities",
    "title": "DataTables.completecases",
    "category": "Function",
    "text": "Indexes of complete cases (rows without null values)\n\ncompletecases(dt::AbstractDataTable)\n\nArguments\n\ndt : the AbstractDataTable\n\nResult\n\n::Vector{Bool} : indexes of complete cases\n\nSee also dropnull and dropnull!.\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\ndt[[1,4,5], :x] = Nullable()\ndt[[9,10], :y] = Nullable()\ncompletecases(dt)\n\n\n\n"
},

{
    "location": "lib/utilities.html#StatsBase.describe",
    "page": "Utilities",
    "title": "StatsBase.describe",
    "category": "Function",
    "text": "Summarize the columns of an AbstractDataTable\n\ndescribe(dt::AbstractDataTable)\ndescribe(io, dt::AbstractDataTable)\n\nArguments\n\ndt : the AbstractDataTable\nio : optional output descriptor\n\nResult\n\nnothing\n\nDetails\n\nIf the column's base type derives from Number, compute the minimum, first quantile, median, mean, third quantile, and maximum. Nulls are filtered and reported separately.\n\nFor boolean columns, report trues, falses, and nulls.\n\nFor other types, show column characteristics and number of nulls.\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\ndescribe(dt)\n\n\n\n"
},

{
    "location": "lib/utilities.html#NullableArrays.dropnull",
    "page": "Utilities",
    "title": "NullableArrays.dropnull",
    "category": "Function",
    "text": "dropnull(X::AbstractVector)\n\nReturn a vector containing only the non-null entries of X, unwrapping Nullable entries. A copy is always returned, even when X does not contain any null values.\n\n\n\nRemove rows with null values.\n\ndropnull(dt::AbstractDataTable)\n\nArguments\n\ndt : the AbstractDataTable\n\nResult\n\n::AbstractDataTable : the updated copy\n\nSee also completecases and dropnull!.\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\ndt[[1,4,5], :x] = Nullable()\ndt[[9,10], :y] = Nullable()\ndropnull(dt)\n\n\n\n"
},

{
    "location": "lib/utilities.html#NullableArrays.dropnull!",
    "page": "Utilities",
    "title": "NullableArrays.dropnull!",
    "category": "Function",
    "text": "dropnull!(X::AbstractVector)\n\nRemove null entries of X in-place and return a Vector view of the unwrapped Nullable entries. If no nulls are present, this is a no-op and X is returned.\n\n\n\ndropnull!(X::NullableVector)\n\nRemove null entries of X in-place and return a Vector view of the unwrapped Nullable entries.\n\n\n\nRemove rows with null values in-place.\n\ndropnull!(dt::AbstractDataTable)\n\nArguments\n\ndt : the AbstractDataTable\n\nResult\n\n::AbstractDataTable : the updated version\n\nSee also dropnull and completecases.\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\ndt[[1,4,5], :x] = Nullable()\ndt[[9,10], :y] = Nullable()\ndropnull!(dt)\n\n\n\n"
},

{
    "location": "lib/utilities.html#Base.dump",
    "page": "Utilities",
    "title": "Base.dump",
    "category": "Function",
    "text": "Show the structure of an AbstractDataTable, in a tree-like format\n\ndump(dt::AbstractDataTable, n::Int = 5)\ndump(io::IO, dt::AbstractDataTable, n::Int = 5)\n\nArguments\n\ndt : the AbstractDataTable\nn : the number of levels to show\nio : optional output descriptor\n\nResult\n\nnothing\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\ndump(dt)\n\n\n\n"
},

{
    "location": "lib/utilities.html#DataTables.names!",
    "page": "Utilities",
    "title": "DataTables.names!",
    "category": "Function",
    "text": "Set column names\n\nnames!(dt::AbstractDataTable, vals)\n\nArguments\n\ndt : the AbstractDataTable\nvals : column names, normally a Vector{Symbol} the same length as the number of columns in dt\nallow_duplicates : if false (the default), an error will be raised if duplicate names are found; if true, duplicate names will be suffixed with _i (i starting at 1 for the first duplicate).\n\nResult\n\n::AbstractDataTable : the updated result\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\nnames!(dt, [:a, :b, :c])\nnames!(dt, [:a, :b, :a])  # throws ArgumentError\nnames!(dt, [:a, :b, :a], allow_duplicates=true)  # renames second :a to :a_1\n\n\n\n"
},

{
    "location": "lib/utilities.html#DataTables.nonunique",
    "page": "Utilities",
    "title": "DataTables.nonunique",
    "category": "Function",
    "text": "Indexes of duplicate rows (a row that is a duplicate of a prior row)\n\nnonunique(dt::AbstractDataTable)\nnonunique(dt::AbstractDataTable, cols)\n\nArguments\n\ndt : the AbstractDataTable\ncols : a column indicator (Symbol, Int, Vector{Symbol}, etc.) specifying the column(s) to compare\n\nResult\n\n::Vector{Bool} : indicates whether the row is a duplicate of some prior row\n\nSee also unique and unique!.\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\ndt = vcat(dt, dt)\nnonunique(dt)\nnonunique(dt, 1)\n\n\n\n"
},

{
    "location": "lib/utilities.html#DataTables.rename",
    "page": "Utilities",
    "title": "DataTables.rename",
    "category": "Function",
    "text": "Rename columns\n\nrename!(dt::AbstractDataTable, from::Symbol, to::Symbol)\nrename!(dt::AbstractDataTable, d::Associative)\nrename!(f::Function, dt::AbstractDataTable)\nrename(dt::AbstractDataTable, from::Symbol, to::Symbol)\nrename(f::Function, dt::AbstractDataTable)\n\nArguments\n\ndt : the AbstractDataTable\nd : an Associative type that maps the original name to a new name\nf : a function that has the old column name (a symbol) as input and new column name (a symbol) as output\n\nResult\n\n::AbstractDataTable : the updated result\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\nrename(x -> @compat(Symbol)(uppercase(string(x))), dt)\nrename(dt, @compat(Dict(:i=>:A, :x=>:X)))\nrename(dt, :y, :Y)\nrename!(dt, @compat(Dict(:i=>:A, :x=>:X)))\n\n\n\n"
},

{
    "location": "lib/utilities.html#DataTables.rename!",
    "page": "Utilities",
    "title": "DataTables.rename!",
    "category": "Function",
    "text": "Rename columns\n\nrename!(dt::AbstractDataTable, from::Symbol, to::Symbol)\nrename!(dt::AbstractDataTable, d::Associative)\nrename!(f::Function, dt::AbstractDataTable)\nrename(dt::AbstractDataTable, from::Symbol, to::Symbol)\nrename(f::Function, dt::AbstractDataTable)\n\nArguments\n\ndt : the AbstractDataTable\nd : an Associative type that maps the original name to a new name\nf : a function that has the old column name (a symbol) as input and new column name (a symbol) as output\n\nResult\n\n::AbstractDataTable : the updated result\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\nrename(x -> @compat(Symbol)(uppercase(string(x))), dt)\nrename(dt, @compat(Dict(:i=>:A, :x=>:X)))\nrename(dt, :y, :Y)\nrename!(dt, @compat(Dict(:i=>:A, :x=>:X)))\n\n\n\n"
},

{
    "location": "lib/utilities.html#DataTables.tail",
    "page": "Utilities",
    "title": "DataTables.tail",
    "category": "Function",
    "text": "Show the first or last part of an AbstractDataTable\n\nhead(dt::AbstractDataTable, r::Int = 6)\ntail(dt::AbstractDataTable, r::Int = 6)\n\nArguments\n\ndt : the AbstractDataTable\nr : the number of rows to show\n\nResult\n\n::AbstractDataTable : the first or last part of dt\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\nhead(dt)\ntail(dt)\n\n\n\n"
},

{
    "location": "lib/utilities.html#Base.unique",
    "page": "Utilities",
    "title": "Base.unique",
    "category": "Function",
    "text": "Delete duplicate rows\n\nunique(dt::AbstractDataTable)\nunique(dt::AbstractDataTable, cols)\nunique!(dt::AbstractDataTable)\nunique!(dt::AbstractDataTable, cols)\n\nArguments\n\ndt : the AbstractDataTable\ncols :  column indicator (Symbol, Int, Vector{Symbol}, etc.)\n\nspecifying the column(s) to compare.\n\nResult\n\n::AbstractDataTable : the updated version of dt with unique rows.\n\nWhen cols is specified, the return DataTable contains complete rows, retaining in each case the first instance for which dt[cols] is unique.\n\nSee also nonunique.\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\ndt = vcat(dt, dt)\nunique(dt)   # doesn't modify dt\nunique(dt, 1)\nunique!(dt)  # modifies dt\n\n\n\nunique(A::CategoricalArray)\nunique(A::NullableCategoricalArray)\n\nReturn levels which appear in A, in the same order as levels (and not in their order of appearance). This function is significantly slower than levels since it needs to check whether levels are used or not.\n\n\n\n"
},

{
    "location": "lib/utilities.html#Base.unique!",
    "page": "Utilities",
    "title": "Base.unique!",
    "category": "Function",
    "text": "Delete duplicate rows\n\nunique(dt::AbstractDataTable)\nunique(dt::AbstractDataTable, cols)\nunique!(dt::AbstractDataTable)\nunique!(dt::AbstractDataTable, cols)\n\nArguments\n\ndt : the AbstractDataTable\ncols :  column indicator (Symbol, Int, Vector{Symbol}, etc.)\n\nspecifying the column(s) to compare.\n\nResult\n\n::AbstractDataTable : the updated version of dt with unique rows.\n\nWhen cols is specified, the return DataTable contains complete rows, retaining in each case the first instance for which dt[cols] is unique.\n\nSee also nonunique.\n\nExamples\n\ndt = DataTable(i = 1:10, x = rand(10), y = rand([\"a\", \"b\", \"c\"], 10))\ndt = vcat(dt, dt)\nunique(dt)   # doesn't modify dt\nunique(dt, 1)\nunique!(dt)  # modifies dt\n\n\n\n"
},

{
    "location": "lib/utilities.html#Utilities-1",
    "page": "Utilities",
    "title": "Utilities",
    "category": "section",
    "text": "Pages = [\"utilities.md\"]eltypes\nhead\ncompletecases\ndescribe\ndropnull\ndropnull!\ndump\nnames!\nnonunique\nrename\nrename!\ntail\nunique\nunique!"
},

{
    "location": "lib/manipulation.html#",
    "page": "Data manipulation",
    "title": "Data manipulation",
    "category": "page",
    "text": "CurrentModule = DataTables"
},

{
    "location": "lib/manipulation.html#Data-Manipulation-1",
    "page": "Data manipulation",
    "title": "Data Manipulation",
    "category": "section",
    "text": "Pages = [\"manipulation.md\"]"
},

{
    "location": "lib/manipulation.html#Base.join",
    "page": "Data manipulation",
    "title": "Base.join",
    "category": "Function",
    "text": "Join two DataTables\n\njoin(dt1::AbstractDataTable,\n     dt2::AbstractDataTable;\n     on::Union{Symbol, Vector{Symbol}} = Symbol[],\n     kind::Symbol = :inner)\n\nArguments\n\ndt1, dt2 : the two AbstractDataTables to be joined\n\nKeyword Arguments\n\non : a Symbol or Vector{Symbol}, the column(s) used as keys when joining; required argument except for kind = :cross\nkind : the type of join, options include:\n:inner : only include rows with keys that match in both dt1 and dt2, the default\n:outer : include all rows from dt1 and dt2\n:left : include all rows from dt1\n:right : include all rows from dt2\n:semi : return rows of dt1 that match with the keys in dt2\n:anti : return rows of dt1 that do not match with the keys in dt2\n:cross : a full Cartesian product of the key combinations; every row of dt1 is matched with every row of dt2\n\nFor the three join operations that may introduce missing values (:outer, :left, and :right), all columns of the returned data table will be nullable.\n\nResult\n\n::DataTable : the joined DataTable\n\nExamples\n\nname = DataTable(ID = [1, 2, 3], Name = [\"John Doe\", \"Jane Doe\", \"Joe Blogs\"])\njob = DataTable(ID = [1, 2, 4], Job = [\"Lawyer\", \"Doctor\", \"Farmer\"])\n\njoin(name, job, on = :ID)\njoin(name, job, on = :ID, kind = :outer)\njoin(name, job, on = :ID, kind = :left)\njoin(name, job, on = :ID, kind = :right)\njoin(name, job, on = :ID, kind = :semi)\njoin(name, job, on = :ID, kind = :anti)\njoin(name, job, kind = :cross)\n\n\n\n"
},

{
    "location": "lib/manipulation.html#Joins-1",
    "page": "Data manipulation",
    "title": "Joins",
    "category": "section",
    "text": "join"
},

{
    "location": "lib/manipulation.html#DataTables.melt",
    "page": "Data manipulation",
    "title": "DataTables.melt",
    "category": "Function",
    "text": "Stacks a DataTable; convert from a wide to long format; see stack.\n\n\n\n"
},

{
    "location": "lib/manipulation.html#DataTables.stack",
    "page": "Data manipulation",
    "title": "DataTables.stack",
    "category": "Function",
    "text": "Stacks a DataTable; convert from a wide to long format\n\nstack(dt::AbstractDataTable, [measure_vars], [id_vars];\n      variable_name::Symbol=:variable, value_name::Symbol=:value)\nmelt(dt::AbstractDataTable, [id_vars], [measure_vars];\n     variable_name::Symbol=:variable, value_name::Symbol=:value)\n\nArguments\n\ndt : the AbstractDataTable to be stacked\nmeasure_vars : the columns to be stacked (the measurement variables), a normal column indexing type, like a Symbol, Vector{Symbol}, Int, etc.; for melt, defaults to all variables that are not id_vars. If neither measure_vars or id_vars are given, measure_vars defaults to all floating point columns.\nid_vars : the identifier columns that are repeated during stacking, a normal column indexing type; for stack defaults to all variables that are not measure_vars\nvariable_name : the name of the new stacked column that shall hold the names of each of measure_vars\nvalue_name : the name of the new stacked column containing the values from each of measure_vars\n\nResult\n\n::DataTable : the long-format datatable with column :value holding the values of the stacked columns (measure_vars), with column :variable a Vector of Symbols with the measure_vars name, and with columns for each of the id_vars.\n\nSee also stackdt and meltdt for stacking methods that return a view into the original DataTable. See unstack for converting from long to wide format.\n\nExamples\n\nd1 = DataTable(a = repeat([1:3;], inner = [4]),\n               b = repeat([1:4;], inner = [3]),\n               c = randn(12),\n               d = randn(12),\n               e = map(string, 'a':'l'))\n\nd1s = stack(d1, [:c, :d])\nd1s2 = stack(d1, [:c, :d], [:a])\nd1m = melt(d1, [:a, :b, :e])\nd1s_name = melt(d1, [:a, :b, :e], variable_name=:somemeasure)\n\n\n\n"
},

{
    "location": "lib/manipulation.html#DataTables.unstack",
    "page": "Data manipulation",
    "title": "DataTables.unstack",
    "category": "Function",
    "text": "Unstacks a DataTable; convert from a long to wide format\n\nunstack(dt::AbstractDataTable, rowkey, colkey, value)\nunstack(dt::AbstractDataTable, colkey, value)\nunstack(dt::AbstractDataTable)\n\nArguments\n\ndt : the AbstractDataTable to be unstacked\nrowkey : the column with a unique key for each row, if not given, find a key by grouping on anything not a colkey or value\ncolkey : the column holding the column names in wide format, defaults to :variable\nvalue : the value column, defaults to :value\n\nResult\n\n::DataTable : the wide-format datatable\n\nExamples\n\nwide = DataTable(id = 1:12,\n                 a  = repeat([1:3;], inner = [4]),\n                 b  = repeat([1:4;], inner = [3]),\n                 c  = randn(12),\n                 d  = randn(12))\n\nlong = stack(wide)\nwide0 = unstack(long)\nwide1 = unstack(long, :variable, :value)\nwide2 = unstack(long, :id, :variable, :value)\n\nNote that there are some differences between the widened results above.\n\n\n\n"
},

{
    "location": "lib/manipulation.html#DataTables.stackdt",
    "page": "Data manipulation",
    "title": "DataTables.stackdt",
    "category": "Function",
    "text": "A stacked view of a DataTable (long format)\n\nLike stack and melt, but a view is returned rather than data copies.\n\nstackdt(dt::AbstractDataTable, [measure_vars], [id_vars];\n        variable_name::Symbol=:variable, value_name::Symbol=:value)\nmeltdt(dt::AbstractDataTable, [id_vars], [measure_vars];\n       variable_name::Symbol=:variable, value_name::Symbol=:value)\n\nArguments\n\ndt : the wide AbstractDataTable\nmeasure_vars : the columns to be stacked (the measurement variables), a normal column indexing type, like a Symbol, Vector{Symbol}, Int, etc.; for melt, defaults to all variables that are not id_vars\nid_vars : the identifier columns that are repeated during stacking, a normal column indexing type; for stack defaults to all variables that are not measure_vars\n\nResult\n\n::DataTable : the long-format datatable with column :value holding the values of the stacked columns (measure_vars), with column :variable a Vector of Symbols with the measure_vars name, and with columns for each of the id_vars.\n\nThe result is a view because the columns are special AbstractVectors that return indexed views into the original DataTable.\n\nExamples\n\nd1 = DataTable(a = repeat([1:3;], inner = [4]),\n               b = repeat([1:4;], inner = [3]),\n               c = randn(12),\n               d = randn(12),\n               e = map(string, 'a':'l'))\n\nd1s = stackdt(d1, [:c, :d])\nd1s2 = stackdt(d1, [:c, :d], [:a])\nd1m = meltdt(d1, [:a, :b, :e])\n\n\n\n"
},

{
    "location": "lib/manipulation.html#DataTables.meltdt",
    "page": "Data manipulation",
    "title": "DataTables.meltdt",
    "category": "Function",
    "text": "A stacked view of a DataTable (long format); see stackdt\n\n\n\n"
},

{
    "location": "lib/manipulation.html#Reshaping-1",
    "page": "Data manipulation",
    "title": "Reshaping",
    "category": "section",
    "text": "melt\nstack\nunstack\nstackdt\nmeltdt"
},

{
    "location": "NEWS.html#",
    "page": "Release Notes",
    "title": "Release Notes",
    "category": "page",
    "text": ""
},

{
    "location": "LICENSE.html#",
    "page": "License",
    "title": "License",
    "category": "page",
    "text": "DataTables.jl is licensed under the MIT License:Copyright (c) 2012-2015: Harlan Harris, EPRI (Tom Short's code), Chris DuBois, John Myles White, and other contributors.Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
},

]}
