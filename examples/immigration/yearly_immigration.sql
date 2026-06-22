/* Yearly Immigration from 1960 to 2020

*/
-- COPY ... TO writes to a file relative to root
COPY (
    -- Only *one* WITH ... AS is allowed here
    /* Generate ALL years */ 
    WITH all_year AS (
        -- The actual logic happens here
        SELECT generate_series AS year
        FROM generate_series(1960, 2020)
    ),
    /* Generate OBSERVED years */
    yearly_immigrations AS (
        -- The actual logic happens here
        SELECT
            CAST(YEAR(FOERSTE_INDVANDRING) AS INTEGER) AS year,
            COUNT(DISTINCT PNR) AS N
        FROM read_parquet('data-repository/BEF*.parquet') 
        WHERE IE_TYPE = 2
        GROUP BY year
    )
    --The actual logic happens here
    SELECT
        all_year.year,
        COALESCE(yearly_immigrations.N, 0) AS N
    FROM all_year -- this is 'x' in merge(x, y)
    LEFT JOIN yearly_immigrations -- this is 'y' in merge(x, y)
        ON all_year.year = yearly_immigrations.year
    ORDER BY all_year.year
) TO 'examples/immigration/yearly_immigration.csv' (HEADER, DELIMITER ',');
