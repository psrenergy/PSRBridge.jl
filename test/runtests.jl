using PSRBridge

using Dates
import PSRClassesInterface as PSRI
using Random
using Serialization
using Test
using TimerOutputs

const PSRDatabaseSQLite = PSRI.PSRDatabaseSQLite

@collection @kwdef mutable struct ThermalPlant <: AbstractCollection
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

@collection @kwdef mutable struct HydroPlant <: AbstractCollection
    id::String = "HydroPlant"
    label::StaticData{String} = "label"
    initial_volume::StaticData{Float64} = "initial_volume"
    has_commitment::StaticData{Bool} = "has_commitment"
    non_controllable_spillage::StaticData{Bool} = "non_controllable_spillage"

    existing::TimeSeriesData{Float64} = "existing"
    production_factor::TimeSeriesData{Float64} = "production_factor"
    min_generation::TimeSeriesData{Float64} = "min_generation"
    max_generation::TimeSeriesData{Float64} = "max_generation"
    min_turbining::TimeSeriesData{Float64} = "min_turbining"
    max_turbining::TimeSeriesData{Float64} = "max_turbining"
    min_volume::TimeSeriesData{Float64} = "min_volume"
    max_volume::TimeSeriesData{Float64} = "max_volume"
    min_outflow::TimeSeriesData{Float64} = "min_outflow"
    om_cost::TimeSeriesData{Float64} = "om_cost"

    bus_index::MapData = ("Bus", "id")
    agent_index::MapData = ("Agent", "id")
    gauging_station_index::MapData = ("GaugingStation", "id")
    turbine_to_index::MapData = ("HydroPlant", "turbine_to")
    spill_to_index::MapData = ("HydroPlant", "spill_to")
end

@kwdef mutable struct Collections <: AbstractCollections
    hydro_plant::HydroPlant = HydroPlant()
    thermal_plant::ThermalPlant = ThermalPlant()
end

@kwdef mutable struct Inputs <: AbstractInputs
    db::DatabaseSQLite
    collections::Collections = Collections()
end

function test_all()
    iterations = 10
    path = raw"C:\Development\BidBasedDispatch\slow\study.bid_based_dispatch"

    db = PSRI.load_study(PSRI.PSRDatabaseSQLiteInterface(), path, read_only = true)

    inputs = Inputs(; db = db)
    cache = Cache()

    @timeit "initialize!" initialize!(inputs)

    @show thermal_plant_label(inputs, 1)

    @timeit "not cached" begin
        for _ in 1:iterations
            for month in 1:12
                @timeit "update!" update!(inputs, date_time = DateTime(2025, month, 1))
            end
        end
    end

    @timeit "cached" begin
        for _ in 1:iterations
            for month in 1:12
                @timeit "update!" update!(inputs, cache, date_time = DateTime(2025, month, 1))
            end
        end
    end

    file_size = PSRBridge.file_size(cache)
    files = length(PSRBridge.files(cache))
    println("Cache size: $files files with $file_size bytes")

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
