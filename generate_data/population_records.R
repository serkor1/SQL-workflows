## script: Population Records
## objective:
##  - Replicate the BEF data-set from
##    Statistics Denmark
##
## information:
##  - The script assumes
##    a constant number of individuals
##    across record years
##
population_size <- 1e3 ## change for higher population

## initialize data for each
## population member at year zero
population_records <- data.table::data.table(
    data.table::CJ(
        AAR = 2000:2020,
        PNR = 1:population_size
    )
)

## population characteristics
## by PNR

population_records[,
    `:=`(
        ## Ancestry:
        ##  1: Danish
        ##  2: Immigrant
        ##  3: Descendant of Immigrant
        ##  9: Unkown
        IE_TYPE = sample(
            c(1:3, 9),
            size = .N,
            replace = TRUE,
            prob = c(
                0.75,
                0.10,
                0.10,
                0.05
            )
        ),
        ## Sex:
        ##  1: Male
        ##  2: Female
        ##  9: Unknown
        KOEN = sample(
            c(1:2, 9),
            size = .N,
            replace = TRUE,
            prob = c(
                0.495,
                0.495,
                0.01
            )
        )
    ),
    by = .(
        PNR
    )
]

## FOED_DAG / Birthdates
## non-uniformly
birth_dates <- seq(as.Date("1920-01-01"), as.Date("2020-12-31"), by = "day")
n_birth_dates <- length(birth_dates)
birth_date_prob <- diff(c(0, sort(stats::runif(n_birth_dates - 1L)), 1))

population_records[,
    `:=`(
        FOED_DAG = data.table::as.IDate(
            sample(
                x = birth_dates,
                size = .N,
                replace = TRUE,
                prob = birth_date_prob
            )
        )
    ),
    by = .(
        PNR
    )
]

## Immigration Dates
## if the individual is danish
## the data
##
##
## immigrant count
immigrants <- unique(
    population_records[IE_TYPE == 2]$PNR
)

## extract early and
## late cohorts
early_cohort <- sample(
    immigrants,
    size = floor(0.7 * length(immigrants))
)

late_cohort <- immigrants[
    !(early_cohort %in% immigrants)
]

population_records[
    PNR %in% early_cohort,
    FOERSTE_INDVANDRING := sample(
        seq(as.Date("1960-01-01"), as.Date("1980-12-31"), by = "day"),
        size = .N,
        replace = TRUE
    ),
    by = .(
        PNR
    )
]

population_records[
    PNR %in% late_cohort,
    FOERSTE_INDVANDRING := sample(
        seq(as.Date("1999-01-01"), as.Date("2025-12-31"), by = "day"),
        size = .N,
        replace = TRUE
    ),
    by = .(
        PNR
    )
]

population_records[
    IE_TYPE %in% c(1, 3),
    FOERSTE_INDVANDRING := FOED_DAG,
]

## exclude individuals
## from the data conditionally
##
## An individual can only be present
## in the data if the record is post
## birth year (FOED_YEAR)
population_records <- population_records[
    AAR >= data.table::year(FOED_DAG)
]

population_records <- population_records[
    AAR >= data.table::year(FOERSTE_INDVANDRING) | is.na(FOERSTE_INDVANDRING)
]

## write data as parquet files
## by year
lapply(
    X = split(
        population_records,
        by = "AAR"
    ),
    FUN = function(x) {
        arrow::write_parquet(
            x = x,
            sink = paste0(
                "data-repository/BEF",
                unique(x$AAR),
                ".parquet"
            )
        )
    }
)
