# The Formula, ModelFrame and ModelMatrix Types

In regression analysis, we often want to describe the relationship between a response variable and one or more input variables in terms of main effects and interactions. To facilitate the specification of a regression model in terms of the columns of a `DataTable`, the DataTables package provides a `Formula` type, which is created by the `~` binary operator in Julia:

```julia
fm = Z ~ X + Y
```

A `Formula` object can be used to transform a `DataTable` into a `ModelFrame` object:

```julia
dt = DataTable(X = randn(10), Y = randn(10), Z = randn(10))
mf = ModelFrame(Z ~ X + Y, dt)
```

A `ModelFrame` object is just a simple wrapper around a `DataTable`. For modeling purposes, one generally wants to construct a `ModelMatrix`, which constructs a `Matrix{Float64}` that can be used directly to fit a statistical model:

```julia
mm = ModelMatrix(ModelFrame(Z ~ X + Y, dt))
```

Note that `mm` contains an additional column consisting entirely of `1.0` values. This is used to fit an intercept term in a regression model.

In addition to specifying main effects, it is possible to specify interactions using the `&` operator inside a `Formula`:

```julia
mm = ModelMatrix(ModelFrame(Z ~ X + Y + X&Y, dt))
```

If you would like to specify both main effects and an interaction term at once, use the `*` operator inside a \`Formula\`:

```julia
mm = ModelMatrix(ModelFrame(Z ~ X*Y, dt))
```

You can control how categorical variables (e.g., `CategoricalArray` columns) are converted to `ModelMatrix` columns by specifying _contrasts_ when you construct a `ModelFrame`:

```julia
mm = ModelMatrix(ModelFrame(Z ~ X*Y, dt, contrasts = Dict(:X => HelmertCoding())))
```

Contrasts can also be modified in an existing `ModelFrame`:

```julia
mf = ModelFrame(Z ~ X*Y, dt)
contrasts!(mf, X = HelmertCoding())
```

The construction of model matrices makes it easy to formulate complex statistical models. These are used to good effect by the [GLM Package.](https://github.com/JuliaStats/GLM.jl)
