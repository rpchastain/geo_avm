geo_avm_pres
========================================================
author: 
date: 
autosize: true

First Slide
========================================================



For more details on authoring R presentations please visit <https://support.rstudio.com/hc/en-us/articles/200486468>.

- Bullet 1
- Bullet 2
- Bullet 3

Slide With Code
========================================================


```r
summary(test_shp_set_4@data )
```

```
    OBJECTID           APN              REGION              PIN           
 Min.   : 22464   Min.   : 1231630   Length:1829        Length:1829       
 1st Qu.:115040   1st Qu.:14063102   Class :character   Class :character  
 Median :120897   Median :14326305   Mode  :character   Mode  :character  
 Mean   :108419   Mean   :12857492                                        
 3rd Qu.:128997   3rd Qu.:16108917                                        
 Max.   :146926   Max.   :24007401                                        
                                                                          
    RECMAP              BOOK               PAGE              BLOCK          
 Length:1829        Length:1829        Length:1829        Length:1829       
 Class :character   Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character   Mode  :character  
                                                                            
                                                                            
                                                                            
                                                                            
    PARCEL            SUBNAME            TOWNSHIP            RANGE          
 Length:1829        Length:1829        Length:1829        Length:1829       
 Class :character   Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character   Mode  :character  
                                                                            
                                                                            
                                                                            
                                                                            
   SECTION_             FLOOR          MAPLINK               FLR        
 Length:1829        Min.   : 1.000   Length:1829        Min.   : 1.000  
 Class :character   1st Qu.: 1.000   Class :character   1st Qu.: 1.000  
 Mode  :character   Median : 1.000   Mode  :character   Median : 1.000  
                    Mean   : 1.128                      Mean   : 1.128  
                    3rd Qu.: 1.000                      3rd Qu.: 1.000  
                    Max.   :23.000                      Max.   :23.000  
                                                                        
  STREETNUM          STREETDIR            STREET              CITY          
 Length:1829        Length:1829        Length:1829        Length:1829       
 Class :character   Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character   Mode  :character  
                                                                            
                                                                            
                                                                            
                                                                            
   SITUSZIP          FIRSTNAME           LASTNAME           MAILING1        
 Length:1829        Length:1829        Length:1829        Length:1829       
 Class :character   Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character   Mode  :character  
                                                                            
                                                                            
                                                                            
                                                                            
   MAILING2           MAILCITY          MAILSTATE           MAILZIP         
 Length:1829        Length:1829        Length:1829        Length:1829       
 Class :character   Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character   Mode  :character  
                                                                            
                                                                            
                                                                            
                                                                            
    LAND_USE       WATER              SEWER              ACREAGE        
 200    :1346   Length:1829        Length:1829        Min.   : 0.00002  
 210    : 326   Class :character   Class :character   1st Qu.: 0.09024  
 110    :  51   Mode  :character   Mode  :character   Median : 0.14720  
 410    :  29                                         Mean   : 0.28561  
 140    :  14                                         3rd Qu.: 0.19148  
 400    :  11                                         Max.   :75.55000  
 (Other):  52                                                           
   TAXDIST             BEDROOMS           BATHS            YEARBLT    
 Length:1829        Min.   :  0.000   Min.   :  0.000   Min.   :   0  
 Class :character   1st Qu.:  2.000   1st Qu.:  2.000   1st Qu.:1997  
 Mode  :character   Median :  3.000   Median :  2.500   Median :2006  
                    Mean   :  3.252   Mean   :  2.589   Mean   :1906  
                    3rd Qu.:  4.000   3rd Qu.:  3.000   3rd Qu.:2019  
                    Max.   :496.000   Max.   :498.000   Max.   :2020  
                                                                      
    LANDASS           BUILDASS          TOTALASS           LANDAPR       
 Min.   :      0   Min.   :      0   Min.   :       0   Min.   :      0  
 1st Qu.:  20759   1st Qu.:  38987   1st Qu.:   62444   1st Qu.:  59310  
 Median :  28525   Median :  75956   Median :  105354   Median :  81500  
 Mean   :  38342   Mean   :  92135   Mean   :  130476   Mean   : 109548  
 3rd Qu.:  34349   3rd Qu.: 107679   3rd Qu.:  145893   3rd Qu.:  98140  
 Max.   :2469600   Max.   :9582878   Max.   :11509278   Max.   :7056000  
                                                                         
   BUILDAPR           TOTALAPR           DEPRECIATI        SALEDATE         
 Length:1829        Length:1829        Min.   : 0.000   Min.   :2020-01-02  
 Class :character   Class :character   1st Qu.: 1.501   1st Qu.:2020-04-03  
 Mode  :character   Mode  :character   Median :19.500   Median :2020-07-22  
                                       Mean   :22.677   Mean   :2020-07-10  
                                       3rd Qu.:33.000   3rd Qu.:2020-10-06  
                                       Max.   :87.500   Max.   :2020-12-31  
                                                                            
   SALEPRICE         OCCUPANCY           PROPCODE           TAXYEAR         
 Min.   :     500   Length:1829        Length:1829        Length:1829       
 1st Qu.:  365000   Class :character   Class :character   Class :character  
 Median :  478000   Mode  :character   Mode  :character   Mode  :character  
 Mean   :  716385                                                           
 3rd Qu.:  637691                                                           
 Max.   :92500000                                                           
                                                                            
   STORIES           TOWNHOUSE             SQFEET           UNITS        
 Length:1829        Length:1829        Min.   :     0   Min.   :  0.000  
 Class :character   Class :character   1st Qu.:  1405   1st Qu.:  1.000  
 Mode  :character   Mode  :character   Median :  1958   Median :  1.000  
                                       Mean   :  2955   Mean   :  1.174  
                                       3rd Qu.:  2607   3rd Qu.:  1.000  
                                       Max.   :335490   Max.   :344.000  
                                                                         
  AVCONSYEAR         BUILDINGTY            NBHD            SPECPROPCO       
 Length:1829        Length:1829        Length:1829        Length:1829       
 Class :character   Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character   Mode  :character  
                                                                            
                                                                            
                                                                            
                                                                            
      QC              LAND_BASE          NBC              Fireplaces    
 Length:1829        Min.   :     0   Length:1829        Min.   :0.0000  
 Class :character   1st Qu.: 59000   Class :character   1st Qu.:0.0000  
 Mode  :character   Median : 81500   Mode  :character   Median :1.0000  
                    Mean   : 79632                      Mean   :0.6052  
                    3rd Qu.:105900                      3rd Qu.:1.0000  
                    Max.   :157300                      Max.   :8.0000  
                                                                        
    Agency            AG_ABBR           FullAddres         ZoningWith       
 Length:1829        Length:1829        Length:1829        Length:1829       
 Class :character   Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character   Mode  :character  
                                                                            
                                                                            
                                                                            
                                                                            
   HeatType          SecHeatTyp           Zoning           Zoning_GIS       
 Length:1829        Length:1829        Length:1829        Length:1829       
 Class :character   Class :character   Class :character   Class :character  
 Mode  :character   Mode  :character   Mode  :character   Mode  :character  
                                                                            
                                                                            
                                                                            
                                                                            
    STRAP            actual_vals        rf_predicted        test_month        
 Length:1829        Min.   :     500   Min.   :   85151   Min.   :2020-02-01  
 Class :character   1st Qu.:  365000   1st Qu.:  369871   1st Qu.:2020-05-01  
 Mode  :character   Median :  478000   Median :  475632   Median :2020-08-01  
                    Mean   :  716385   Mean   :  788120   Mean   :2020-07-24  
                    3rd Qu.:  637691   3rd Qu.:  629116   3rd Qu.:2020-11-01  
                    Max.   :92500000   Max.   :38060277   Max.   :2021-01-01  
                                                                              
 feature_set            error          
 Length:1829        Min.   :-21524507  
 Class :character   1st Qu.:   -23803  
 Mode  :character   Median :     7273  
                    Mean   :   -71736  
                    3rd Qu.:    35609  
                    Max.   : 54439723  
                                       
```

Slide With Plot
========================================================



```
Error in path.expand(path) : invalid 'path' argument
```
