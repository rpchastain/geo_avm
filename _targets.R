# Set variables and environment conditions
## Load targets package
library(targets)

## Source functions so they are available to use with the targets plan
source("R/functions.R")

## Suppress notifications from tidy verse because they're a little annoying
options(tidyverse.quiet = TRUE)

## Define vector to load required packages:
## data.table and tidy packages for data munging and cleaning, 
## rgdal, sp, sf, raster, and rgeos for loading/processing geographic data
packages_vec <- c(
  "data.table", "tidyverse", "tidytable",
  "rgdal", "raster", "rgeos",
  "sp", "sf"
)

## Tell target to load the packages defined above
tar_option_set(packages = packages_vec)

tar_option_set(debug = "parcel_data")

# Define the target plan to run
list(
  # Define parameters for the shape file
  tar_target(name = shp_params, command = prep_parameters(coor_sys = "+init=epsg:4326")),
  # Load the shape file
  tar_target(
    name = parcel_shp,
    command = load_clean_shape(
      data_file = shp_params$data_file, layer_loc = shp_params$layer_loc,
      na_remove = shp_params$na_remove, partition = list(col = 'REGION', subset = 'GOLDN'),
      coor_sys = shp_params$coor_sys
    )
  ),
  # Create the raster file based on the parcel polygons
  tar_target(name = parcel_raster, command = raster(parcel_shp, nrow = 500, ncol = 1000)),
  # Load the layer parameters that will be used to build the raster brick
  tar_target(name = raster_layers, command = quick_load(data_file = 'raster_layers.csv')),
  # Build the parcel raster brick
  tar_target(
    name = parcel_brick,
    command = build_raster_brick(
      shp = parcel_shp, layers = raster_layers,
      rast = parcel_raster)
  )
)
