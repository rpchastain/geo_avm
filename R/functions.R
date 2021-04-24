# Helper function to load targets data
quick_load <- function(data_file) {
  data.table::fread(file.path('data', data_file))
}

# Creates a list with the required parameters for the data load
prep_parameters <- function(data_file = NULL, layer_loc = NULL, na_remove = NULL, coor_sys = NULL) {
  
  if (is.null(na_remove)) {
    na_remove <- quick_load(data_file = 'na_remove.csv')$feature
  }
  
  list(
    data_file = ifelse(is.null(data_file), 'data/shape_files/', data_file),
    layer_loc = ifelse(is.null(layer_loc), 'washoe_Parcels', layer_loc),
    na_remove = na_remove,
    coor_sys = coor_sys
  )
}

# Loads the shape file and removes data that is clearly unreliable
# If a partition is provided, subsets the data so that the 'col' column equals the 'subset'
load_clean_shape <- function(data_file, layer_loc, na_remove = NULL, partition = NULL, coor_sys = NULL) {
  geo_shape <- rgdal::readOGR(dsn = data_file, layer = layer_loc, verbose = FALSE)
  
  if (!is.null(na_remove)) {
    for (feature in na_remove) {
      geo_shape <- geo_shape[!is.na(geo_shape@data[[feature]]), ]
    }
  }
  
  if (!is.null(partition)) {
    geo_shape <- geo_shape[geo_shape@data[[partition$col]] == partition$subset, ]
  }
  
  if (!is.null(coor_sys)) {
    coor_crs <- CRS(coor_sys)
    geo_shape <- spTransform(geo_shape, coor_sys)
  }
  
  return(geo_shape)
}


build_raster_brick <- function(shp, rast, layers) {
  raster_list <- mapply(
    rasterize,
    field = layers$feature, background = layers$bckgnd,
    MoreArgs = list(x = shp, y = rast)
  )
  
  return(brick(x = raster_list))
}