function add_thermal_plant!(db::DatabaseSQLite; kwargs...)
    PSRI.create_element!(db, "ThermalPlant"; kwargs...)
    return nothing
end

function add_hydro_plant!(db::DatabaseSQLite; kwargs...)
    PSRI.create_element!(db, "HydroPlant"; kwargs...)
    return nothing
end

function build_thermal_plant_label(i::Integer)
    return "Thermal Plant $i"
end

function build_hydro_plant_label(i::Integer)
    return "Hydro Plant $i"
end

function build_bool(date_time::DateTime)
    return Dates.month(date_time) % 2 == 0
end

function build_bool(i::Integer)
    return i % 2 == 0
end

function build_float(i::Integer)
    return Float64(i)
end

function build_float(date_time::DateTime)
    return Float64(Dates.month(date_time))
end

function build_int(i::Integer)
    return i
end

function build_int(date_time::DateTime)
    return Dates.month(date_time)
end

function build_thermal_plant_file()
    return "thermal_plant_file"
end

function build_hydro_plant_file()
    return "hydro_plant_file"
end

function build_database(path::AbstractString)
    println("Building database")

    if isfile(path)
        rm(path; force = true)
    end

    path_schema = joinpath(@__DIR__, "schema.sql")

    db = PSRDatabaseSQLite.create_empty_db_from_schema(
        path,
        path_schema;
        force = true,
    )

    PSRDatabaseSQLite.create_element!(
        db,
        "Configuration";
        label = "Test case",
    )

    for i in 1:THERMAL_PLANT_SIZE
        add_thermal_plant!(
            db;
            label = build_thermal_plant_label(i),
            static_vector_float = build_float(i),
            static_vector_int = build_int(i),
            static_vector_bool = build_bool(i) ? 1 : 0,
            parameters = DataFrame(;
                date_time = DATE_TIMES,
                time_series_float = [build_float(date_time) for date_time in DATE_TIMES],
                time_series_int = [build_int(date_time) for date_time in DATE_TIMES],
                time_series_bool = [build_bool(date_time) ? 1 : 0 for date_time in DATE_TIMES],
            ),
        )
    end

    PSRI.link_series_to_file(
        db,
        "ThermalPlant";
        time_series_file = build_thermal_plant_file(),
    )

    for i in 1:HYDRO_PLANT_SIZE
        add_hydro_plant!(db;
            label = build_hydro_plant_label(i),
            static_vector_float = build_float(i),
            static_vector_int = build_int(i),
            static_vector_bool = build_bool(i) ? 1 : 0,
            parameters = DataFrame(;
                date_time = DATE_TIMES,
                time_series_float = [build_float(date_time) for date_time in DATE_TIMES],
                time_series_int = [build_int(date_time) for date_time in DATE_TIMES],
                time_series_bool = [build_bool(date_time) ? 1 : 0 for date_time in DATE_TIMES],
            ),
        )
    end

    PSRI.link_series_to_file(
        db,
        "HydroPlant";
        time_series_file = build_hydro_plant_file(),
    )

    PSRDatabaseSQLite.close!(db)

    return nothing
end
