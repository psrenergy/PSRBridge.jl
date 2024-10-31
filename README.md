# PSRBridge.jl

[![CI](https://github.com/psrenergy/PSRBridge.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/psrenergy/PSRBridge.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/psrenergy/PSRBridge.jl/graph/badge.svg?token=7tA9ajgsLf)](https://codecov.io/gh/psrenergy/PSRBridge.jl)

## Introduction

## Getting Started

### Installation

```julia
julia> ] add PSRBridge
```

### Usage

```julia
using PSRBridge

import PSRClassesInterface as PSRI

const PSRDatabaseSQLite = PSRI.PSRDatabaseSQLite
const DatabaseSQLite = PSRI.PSRDatabaseSQLite.DatabaseSQLite
```

### Collection Definition

```julia
@collection @kwdef mutable struct HydroPlant <: AbstractCollection
    id::String = "HydroPlant"
    label::StaticVectorData{String} = "label"

    static_vector_int::StaticVectorData{Int} = "static_vector_int"
    time_series_float::TimeSeriesVectorData{Float64} = "time_series_float"
    time_series_file::TimeSeriesFileData = "time_series_file"
end

@collection @kwdef mutable struct ThermalPlant <: AbstractCollection
    id::String = "ThermalPlant"
    label::StaticVectorData{String} = "label"

    static_vector_bool::StaticVectorData{Bool} = "static_vector_bool"
    time_series_float::TimeSeriesVectorData{Float64} = "time_series_float"
    time_series_file::TimeSeriesFileData = "time_series_file"

    adjusted_vector_float::AdjustedVectorData{Float64} = AdjustedVectorData{Float64}()
end
```

### Collections Definition

```julia
@kwdef mutable struct Collections <: AbstractCollections
    hydro_plant::HydroPlant = HydroPlant()
    thermal_plant::ThermalPlant = ThermalPlant()
end
```

### Inputs Definition

```julia
@kwdef mutable struct Inputs <: AbstractInputs
    db::DatabaseSQLite
    collections::Collections = Collections()
end
```

### Initialization

```julia
path = joinpath(@__DIR__, "db.sqlite")

db = PSRI.load_study(PSRI.PSRDatabaseSQLiteInterface(), path, read_only = true)

inputs = Inputs(; db = db)
cache = Cache(verbose = false)

initialize!(inputs)
```

### Collection Id

```julia
@show thermal_plant_id(inputs)
@show hydro_plant_id(inputs)
```

### Collection Size

```julia
@show number_of_hydro_plant(inputs)
@show number_of_thermal_plant(inputs)
```

### Collection Indices

```julia
@show indices_of_hydro_plant(inputs)
@show indices_of_thermal_plant(inputs)
```

### Collection Label

```julia
@show hydro_plant_label(inputs)
@show thermal_plant_label(inputs)
```

### Time Series File

```julia
@show hydro_plant_time_series_file(inputs)
@show thermal_plant_time_series_file(inputs)
```

### Label and Static Vector

```julia
for i in indices_of_hydro_plant(inputs)
    @show hydro_plant_static_vector_int(inputs, i)
end

for i in indices_of_thermal_plant(inputs)
    @show thermal_plant_static_vector_bool(inputs, i)
end
```

### Time Series

```julia
for date_time in [DateTime(year, month, 1) for month in 1:12 for year in 2000:2005]
    key = Dates.format(date_time, "yyyymmdd")
    update!(inputs, cache, key; date_time = date_time)

    for i in indices_of_hydro_plant(inputs)
        @show hydro_plant_time_series_float(inputs, i)
    end

    for i in indices_of_thermal_plant(inputs)
        @show thermal_plant_time_series_float(inputs, i)
    end
end
```

### Finalization

```julia
finalize!(inputs)
finalize!(cache)

PSRDatabaseSQLite.close!(db)
```