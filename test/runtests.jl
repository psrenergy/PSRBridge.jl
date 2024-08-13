using PSRBridge

using Dates
using PSRClassesInterface
using Random
using Serialization
using Test
using TimerOutputs

const PSRI = PSRClassesInterface
const PSRDatabaseSQLite = PSRI.PSRDatabaseSQLite

# @kwdef mutable struct BidBasedInputs <: AbstractInputs
#     # db::PSRDatabaseSQLite.DatabaseSQLite
#     # args::Args
#     thermal_plant::ThermalPlant = ThermalPlant()
# end

# function load!(hydro_plant::HydroPlant, inputs)
#     hydro_plant.label = PSRI.get_parms(inputs.db, "HydroPlant", "label")
#     thermal_plant.max_ramp_up = PSRI.get_parms(inputs.db, "ThermalPlant", "max_ramp_up")

#     load_time_series_in_db!(hydro_plant, inputs.db, initial_date_time(inputs))

#     hydro_plant.inflow_file = PSRDatabaseSQLite.read_time_series_file(inputs.db, "HydroPlant", "inflow")

#     return nothing
# end

# function load!(data::ThermalPlant; stage::Integer)

#     return nothing
# end

# function initialize!(data::ThermalPlant)
#     size = length(data.d1)

#     data.label = [randstring(10) for _ in 1:size]
#     data.existing = rand(Bool, size)
#     data.max_startups = rand(Int, size)
#     data.max_generation = rand(Float64, size)

#     return nothing
# end

# function load!(data::ThermalPlant; stage::Integer)
#     size = length(data.d1)

#     data.label = [randstring(10) for _ in 1:size]
#     data.existing = rand(Bool, size)
#     data.max_startups = rand(Int, size)
#     data.max_generation = rand(Float64, size)

#     return nothing
# end

# thermal_plant_label(collection::ThermalPlant, i::Integer) = collection.label[i]

# function load!(hydro_plant::HydroPlant, inputs)
#     hydro_plant.label = PSRI.get_parms(inputs.db, "HydroPlant", "label")

#     load_time_series_in_db!(hydro_plant, inputs.db, initial_date_time(inputs))

#     hydro_plant.inflow_file = PSRDatabaseSQLite.read_time_series_file(inputs.db, "HydroPlant", "inflow")

#     return nothing
# end

# function load_time_series_in_db!(hydro_plant::HydroPlant, db::DatabaseSQLite, stage_date_time::DateTime)
#     hydro_plant.existing = PSRDatabaseSQLite.read_time_series_row(db, "HydroPlant", "existing"; date_time = stage_date_time)

#     return nothing
# end

# hydro_plant_min_generation(inputs, idx::Int) = inputs.collections.hydro_plant.min_generation[idx]

# function add_hydro_plant!(db::DatabaseSQLite; kwargs...)
#     PSRI.create_element!(db, "HydroPlant"; kwargs...)
#     return nothing
# end

# function update_hydro_plant!(db::DatabaseSQLite, label::String; kwargs...)
#     for (attribute, value) in kwargs
#         PSRI.set_parm!(db, "HydroPlant", string(attribute), label, value)
#     end
#     return nothing
# end

@build_collection @kwdef mutable struct ThermalPlant <: AbstractCollection
    id::String = "ThermalPlant"
    label::StaticData{String} = "label"
    has_commitment::StaticData{Bool} = "has_commitment"
    max_startups::StaticData{Int} = "max_startups"
    shutdown_cost::StaticData{Float64} = "shutdown_cost"

    existing::TimeSeriesData{Bool} = "existing"
    min_generation::TimeSeriesData{Float64} = "min_generation"
    max_generation::TimeSeriesData{Float64} = "max_generation"
    om_cost::TimeSeriesData{Float64} = "om_cost"
    startup_cost::TimeSeriesData{Float64} = "startup_cost"
end

@kwdef mutable struct Inputs <: AbstractInputs
    thermal_plant::ThermalPlant = ThermalPlant()
end

function test_all()
    iterations = 100
    path = raw"C:\Development\BidBasedDispatch\slow\study.bid_based_dispatch"

    db = PSRI.load_study(PSRI.PSRDatabaseSQLiteInterface(), path, read_only = true)

    inputs = Inputs()
    cache = Cache()

    @timeit "initialize!" initialize!(inputs, db)

    @show thermal_plant_label(inputs, 1)

    @timeit "not cached" begin
        for _ in 1:iterations
            for month in 1:12
                @timeit "update!" update!(inputs, db, date_time = DateTime(2025, month, 1))
            end
        end
    end

    @timeit "cached" begin
        for _ in 1:iterations
            for month in 1:12
                @timeit "update!" update!(inputs, db, cache, date_time = DateTime(2025, month, 1))
            end
        end
    end

    @timeit "finalize!" begin 
        finalize!(inputs)
        finalize!(cache)
    end

    PSRDatabaseSQLite.close!(db)

    return nothing
end

reset_timer!()
test_all()
print_timer()
