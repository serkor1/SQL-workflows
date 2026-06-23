## script: Yearly Immigration
## objective:
##  - Calculate the number of immigrants by
##    by year
##
##
##
## 1) load all population records
##    from data-repository
DT <- data.table::rbindlist(
    {
        ## extract files
        all_files <- list.files(
            "data-repository/",
            pattern = "BEF",
            full.names = TRUE
        )

        lapply(
            all_files,
            function(x) {
                data.table::as.data.table(
                    arrow::read_parquet(
                        x
                    )
                )[
                    IE_TYPE == 2
                ]
            }
        )
    }
)

## calculate immigration
## year
DT[,
    `:=`(
        immigration_year = data.table::year(
            FOERSTE_INDVANDRING
        )
    ),
]

## aggregate by immigration
## year (observed)
yearly_immigration <- DT[,
    .(
        immigrations = data.table::uniqueN(
            PNR
        )
    ),
    by = .(
        immigration_year
    )
][
    order(immigration_year)
]

## expand with with missing
## years
yearly_immigration <- {
    ## construct yearly
    ## data
    x <- data.table::data.table(
        year = 1960:2020
    )

    ## merge data
    x <- yearly_immigration[
        x,
        on = .(
            immigration_year = year
        )
    ]

    ## fill missing years with
    ## zero (missing years are set to zero)
    x[,
        immigrations := data.table::fcoalesce(
            immigrations,
            0L
        ),
    ]

    ## rename columns to year
    ## to reflect the observed years
    data.table::setnames(
        x,
        old = "immigration_year",
        new = "year"
    )

    x[]
}
