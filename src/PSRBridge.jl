module PSRBridge

using Dates
using NamingConventions
import PSRClassesInterface as PSRI
using Random
using Serialization

const PSRDatabaseSQLite = PSRI.PSRDatabaseSQLite
const DatabaseSQLite = PSRI.PSRDatabaseSQLite.DatabaseSQLite

export
    AbstractInputs,
    AbstractCollection,
    AbstractData,
    StaticData,
    TimeSeriesData,
    MapData,
    Cache,
    initialize!,
    update!,
    finalize!,
    @collection

include("abstract.jl")
include("data/static.jl")
include("data/time_series.jl")
include("data/map.jl")
include("collection.jl")
include("inputs.jl")
include("cache.jl")
include("build.jl")

function __init__()
    return nothing
end

end
