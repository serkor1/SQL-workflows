## script: Yearly Immigration
## objective:
##  - Calculate the number of immigrants by
##    by year
##
##
##
##
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

## count immigrations
## by year
DT[,
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
