#!/usr/bin/env bash
## script: Initialize Data
## objective:
##  Run all data-generating scripts
##  in generate_data
##
## information:
##  population_records has to be run first
##  the remaining scripts can be run in 
##  parallel
##
##
## initialize the data-repository
mkdir data-repository

## initialize the population
## records
Rscript generate_data/population_records.R

## run the remaining scripts
## in parallel
all_scripts=(generate_data/*.R)

## remove the population
## records script from the data
delete=(generate_data/population_records.R)
for all_scripts in "${delete[@]}"; do
  for i in "${!all_scripts[@]}"; do
    if [[ ${all_scripts[i]} = $all_scripts ]]; then
      unset 'all_scripts[i]'
    fi
  done
done

## execute scripts in parallel
## with & (does not wait for the previous job to finish)
for script in "${all_scripts[@]}"; do
    Rscript $script &
done

# Wait for all background jobs to finish
wait

