# Helper function to load targets data
quick_load <- function(data_file) {
  data.table::fread(data_file)
}

# Creates a list with the required parameters for the data load
prep_parameters <- function(data_file = NULL, layer_loc = NULL, coor_sys = NULL) {
  
  list(
    data_file = ifelse(is.null(data_file), 'data/shape_files/washoe_parcels', data_file),
    layer_loc = ifelse(is.null(layer_loc), 'washoe_Parcels', layer_loc),
    coor_sys = coor_sys
  )
}

# Loads the shape file and removes data that is clearly unreliable
# If a partition is provided, subsets the data so that the 'col' column equals the 'subset'
load_clean_shape <- function(
  data_file, layer_loc, na_remove = NULL, partition = NULL,
  coor_sys = NULL
  ) {
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
  
  geo_shape@data$LAND_USE <- as.factor(geo_shape@data$LAND_USE)
  geo_shape@data$BEDROOMS[is.na(geo_shape@data$BEDROOMS)] <- mean(geo_shape@data$BEDROOMS, na.rm = TRUE)
  geo_shape@data$BATHS[is.na(geo_shape@data$BATHS)] <- mean(geo_shape@data$BATHS, na.rm = TRUE)
  geo_shape@data$SQFEET[is.na(geo_shape@data$SQFEET)] <- mean(geo_shape@data$SQFEET, na.rm = TRUE)
  geo_shape@data$ACREAGE[is.na(geo_shape@data$ACREAGE)] <- mean(geo_shape@data$ACREAGE, na.rm = TRUE)

  geo_shape@data$SALEDATE <- as.Date(geo_shape@data$SALEDATE, format = '%m/%d/%Y')
  
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

expand_extent <- function(in_ext, buffer = 0.0005) {
  in_ext@xmin <- sign(in_ext@xmin) * (abs(in_ext@xmin) - in_ext@xmin * buffer)
  in_ext@ymin <- sign(in_ext@ymin) * (abs(in_ext@ymin) - in_ext@ymin * buffer)
  in_ext@xmax <- sign(in_ext@xmax) * (abs(in_ext@xmax) + in_ext@xmax * buffer)
  in_ext@ymax <- sign(in_ext@ymax) * (abs(in_ext@ymax) + in_ext@ymax * buffer)
  return(in_ext)
}

prep_tif <- function(tif, ref_ext) {
  tmp <- raster(tif)
  ref_ext <- spTransform(ref_ext, CRSobj = crs(tmp))
  tmp <- crop(x = tmp, y = ref_ext)
  tmp <- extend(x = tmp, y = ref_ext)
  return(tmp)
}

create_elev_raster <- function(tif_files, ref_ext) {
  
  raster_list <- lapply(tif_files, prep_tif, ref_ext = ref_ext)
  raster_list <- raster_list[!sapply(raster_list, is.null)]
  comb_raster <- do.call(raster::merge, raster_list)
  names(comb_raster) <- 'elevation'
  
  dem_features <- terrain(
    comb_raster, opt = c('slope', 'roughness', 'aspect'),
    unit = "degrees", filename = 'data/rasters/ele_features',
    overwrite = TRUE
  )
  
  northness <- cos(dem_features[["aspect"]] * pi / 180)
  names(northness) <- 'northness'
  eastness <- sin(dem_features[["aspect"]] * pi / 180)
  names(eastness) <- 'eastness'
  
  comb_raster <- addLayer(dem_features, comb_raster)
  comb_raster <- addLayer(northness, comb_raster)
  comb_raster <- addLayer(eastness, comb_raster)
  writeRaster(x = comb_raster, filename = 'data/rasters/elevation', overwrite = TRUE)
  return(comb_raster)
}

create_noise_raster <- function(tif_files, ref_ext, raster_file, resize = TRUE, resolution = 500) {
  
  noise_raster <- lapply(tif_files, function(tif) {
    noise <- prep_tif(tif = tif, ref_ext = ref_ext)
    
    if (resize) {
      noise_extent <- extent(noise)
      new_ext <- round(noise_extent/resolution, digits = -(nchar(resolution) - 1)) * resolution
      
      num_cols <- (new_ext[2] - new_ext[1])/resolution
      num_rows <- (new_ext[4] - new_ext[3])/resolution
      raster_template <- raster(new_ext, ncol = num_cols, nrow = num_rows , crs= crs(noise))
      noise_resample <- raster::projectRaster(from = noise, to = raster_template)
      noise_resample <- raster::resample(x = noise_resample, y = raster_template)
      noise_resample@data@values[is.na(noise_resample@data@values)] <- min(noise_resample@data@values, na.rm = TRUE) * 0.85
      return(noise_resample)
    } else {
      noise@data@values[is.na(noise@data@values)] <- min(noise@data@values, na.rm = TRUE) * 0.85
      return(noise)
    }
  })
  
  
  comb_raster <- do.call(stack, noise_raster)
  writeRaster(x = comb_raster, filename = raster_file, overwrite = TRUE)
  return(comb_raster)
}


create_formula <- function(target, features) {
  formula_str <- paste0(target, ' ~ ',  paste(features, collapse = ' + '))
  as.formula(formula_str)
}

test_date_interval <- function(test_num, test_range, model_data, data_cols, form) {
  
  
  model_reults <- sdm(formula = form, data = sdm_dat, methods = 'rf')
  actual <- model_reults@models$SALEPRICE$rf[[1]]@evaluation$test.indep@observed
  predicted <- model_reults@models$SALEPRICE$rf[[1]]@evaluation$test.indep@predicted
  
  return(
    data.table(
      lat = test_data@coords[, 1],
      long = test_data@coords[, 2],
      actual_vals = actual, predicted_vals = predicted, 
      test_month = as.Date(test_range$end_date - months(test_num - 1))
    )
  )
}

build_model_data <- function(shp, rasters) {
  shp <- SpatialPointsDataFrame(coords = coordinates(shp), data = shp@data, proj4string = crs(shp))
  
  for (rast in rasters) {
    rast_values <- extract(rast, shp)
    shp@data <- cbind(shp@data, rast_values)
  }
  return(shp)
}

create_sdm_data <- function(
  model_data, end_date, test_number, train_period = 12, 
  test_period = 1, dep_var, indep_var
) {
  
  ## Create test and train sets
  train_interval <- interval(end_date - months(test_number + train_period), end_date - months(test_number))
  test_interval <- interval(end_date - months(test_number), end_date - months(test_number - test_period))
  
  ## Create formula and select data columns
  form <- create_formula(target = dep_var, features = indep_var)
  data_cols <- intersect(names(model_data@data), c(dep_var, indep_var))
  
  train_data <- model_data[model_data@data$SALEDATE %within% train_interval, ]
  test_data <- model_data[model_data@data$SALEDATE %within% test_interval, ]
  
  return(
    list(
      formula = form,
      data_cols = data_cols,
      sdm_dat = list(train_dat = train_data, test_dat = test_data),
      test_prop = test_data@data$OBJECTID
    )
  )
}

create_sdm_models <- function(dep_var, indep_vars, test_range, model_data) {
  
  ts_test_list <- lapply(1:test_range$tests, function(x) {
    var_test_list <- lapply(indep_vars, function(iv) {
      print(iv)
      sdm_data <- create_sdm_data(
        model_data = model_data, end_date = test_range$end_dt,
        test_number = x, dep_var = dep_var, indep_var = iv
      )
      
      rf_model <- randomForest(formula = sdm_data$formula, data = sdm_data$sdm_dat$train_dat, na.action = na.roughfix)
      rf_results <- predict(rf_model, sdm_data$sdm_dat$test_dat)
      
      return(
        data.table(
          test_prop = sdm_data$test_prop,
          actual_vals = sdm_data$sdm_dat$test_dat$SALEPRICE, 
          rf_predicted = rf_results,
          test_month = as.Date(test_range$end_dt - months(x - 1))
        )
      )
    })
    var_test_list <- lapply(1:length(var_test_list), function(i) {
      var_test_list[[i]][ , feature_set := sprintf('set_%s', i)] 
    })
    return(rbindlist(var_test_list))
  })
  return(ts_test_list)
}
  
  




