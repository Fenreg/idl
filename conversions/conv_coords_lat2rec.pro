function conv_coords_lat2rec, radius, longitude, latitude, $
                deg = deg,$
                error = error, $
                drad = drad, dlon = dlon, dlat = dlat, $
                verbose = verbose
;===============================================================================
;d Program written by cfeller (clement.feller at obspm dot fr)
;d Changelog: v01 8 july 2016
;d
;d Transforms a set of spherical coordinates to rectangulars ones.
;d If error option is set, and the drad, dlon and dlat values set, the errors 
;d on the transformation are computed. If the verbose option is set, the print 
;d out is verbose
;d Assumptions: Unless the deg option is set, we assume the angles are in 
;d              radians. Furthermore, we use the angles notation in which the 
;d              latitude corresponds to the elevation above/below the xOy 
;d              plane.
;d
;==============================================================================
ErrorMessage0 = 'Formal use of coords_lat2rec function:'+'\n'
ErrorMessage1 = ' rec = coords_lat2rec(radius, longitude, latitude)'
ErrorMessage2 = ' rec = coords_lat2rec(radius, longitude, latitude, /error, drad=radius_error, dlon=longitude_error, dlat=latitude_error)'

;c Check the correct number of input is being given
 if n_params() lt 3 then message, ErrorMessage0+ErrorMessage1

;c Check all errors are given if the errors need to be computed.
 if keyword_set(error) then begin
    if (keyword_set(drad) and keyword_set(dlon) and keyword_set(dlat)) then $
       message, ErrorMessage0+ErrorMessage2
 endif

;c Allocating Memory
 rad_size = size(radius, /dimensions)
 x = fltarr(rad_size)
 y = fltarr(rad_size)
 z = fltarr(rad_size)

;c Enforce computation in radians
 if keyword_set(deg) then begin
    lon_rad = longitude/!RADEG
    lat_rad = latitude/!RADEG
 endif

;c Compute transformation and minimise number of computations
 coslat = cos(lat_rad)
 coslon = cos(lon_rad)
 sinlat = sin(lat_rad)
 sinlon = sin(lon_rad)
 rad_coslat = radius*coslat
 rad_sinlat = radius*sinlat
 
 x = rad_coslat*coslon
 y = rad_coslat*sinlon
 z = rad_sinlat
 
;c Creating result variable
 result = [x,y,z]

;c In case computing the errors are necessary
 if keyword_set(error) then begin
 ;c Allocating more memory
 dx = fltarr(rad_size)
 dy = fltarr(rad_size)
 dz = fltarr(rad_size)

 rad_sinlat_dlat = rad_sinlat*dlat
 rad_coslat_dlon = rad_coslat*dlon

 dx = x*drad/radius - sinlon*rad_coslat_dlon - coslon*rad_sinlat_dlat
 dy = y*drad/radius - coslon*rad_coslat_dlon - sinlon*rad_sinlat_dlat
 dz = sinlat*drad + rad_coslat_dlon
;c modifying result variable
 result = [ [result], [[dx,dy,dz]] ]
 endif

return, result
end
