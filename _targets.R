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
  "sp", "sf", "lubridate",
  "sdm", "parallel", "randomForest"
)

## Tell target to load the packages defined above
tar_option_set(packages = packages_vec)

tar_option_set(debug = "parcel_data")

# Define the target plan to run
list(
  # Define parameters for the shape file
  tar_target(name = shp_params, command = prep_parameters(coor_sys = "+init=epsg:4326")),
  # Load the shape file
  tar_target(na_data_file, 'data/na_remove.csv', format = 'file'),
  tar_target(na_remove_cols, command = quick_load(data_file = na_data_file)),
  tar_target(
    name = parcel_shp,
    command = load_clean_shape(
      data_file = shp_params$data_file, layer_loc = shp_params$layer_loc,
      na_remove = na_remove_cols$feature, partition = list(col = 'CITY', subset = 'RENO'),
      coor_sys = shp_params$coor_sys
    )
  ),
  # Get the raster extent
  tar_target(shp_buffer_extent, command = expand_extent(in_ext = extent(parcel_shp))),
  tar_target(ref_extent, command = SpatialPoints(shp_buffer_extent, proj4string = crs(parcel_shp))),
  # Create geographic rasters
  tar_target(ele_tif_files, 'data/shape_files/tif_rasters', format = 'file'),
  tar_target(
    name = elev_raster,
    command = create_elev_raster(
      tif_files = list.files(ele_tif_files, full.names = TRUE), 
      ref_ext = ref_extent
    )
  ),
  tar_target(noise_tif_files, 'data/raw_rasters', format = 'file'),
  tar_target(
    name = noise_raster_large,
    command = create_noise_raster(
      tif_files = list.files(noise_tif_files, full.names = TRUE), 
      ref_ext = ref_extent, raster_file = 'data/rasters/noise_large'
    )
  ),
  ## Define SDM features and target variables
  tar_target(name = dep_vars, command = c('SALEPRICE')),
  tar_target(
    name = indep_vars,
    command = list(
      physical = c('BEDROOMS', 'BATHS', 'SQFEET', 'ACREAGE'),
      physical_ele = c('BEDROOMS', 'BATHS', 'SQFEET', 'ACREAGE', 'elevation'),
      physical_ele_enh = c(
        'BEDROOMS', 'BATHS', 'SQFEET', 'ACREAGE', 'elevation', 
        'slope', 'roughness', 'aspect', 'eastness', 'northness'
      ),
      physical_ele_enh_noise = c(
        'BEDROOMS', 'BATHS', 'SQFEET', 'ACREAGE', 'elevation', 
        'slope', 'roughness', 'aspect', 'eastness', 'northness',
        'aviation_noise', 'road_noise'
      ),
      ele_enh_noise = c(
        'elevation', 'aviation_noise', 'road_noise',
        'slope', 'roughness', 'aspect', 'eastness', 'northness'
      ),
      ele_enh = c('elevation', 'slope', 'roughness', 'aspect', 'eastness', 'northness')
    )
  ),
  tar_target(
    model_data,
    command = build_model_data(
      shp = parcel_shp,
      rasters = list(noise_raster_large, elev_raster)
    )
  ),
  # Build SDM models
  tar_target(
    model_results,
    command = create_sdm_models(
      dep_var = dep_vars, indep_vars = indep_vars, 
      test_range = list(end_dt = as.Date('2021-01-01'), tests = 12),
      model_data = model_data
    )
  )
)
