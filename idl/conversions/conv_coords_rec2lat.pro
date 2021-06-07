function conv_coords_rec2lat, x, y, z, $
                error = error, $
                dx = dx, dy = dy, dz = dz, $
                deg = deg,$
                verbose = verbose
;===============================================================================
;d Program written by cfeller (clement.feller at obspm dot fr)
;d Changelog: 
;d    2016-JUL-08 v1.0 first light
;d    2017-NOV-27 v1.1 correction equation and clarification
;d
;d Transforms a set of rectangulars coordinates to spherical ones.
;d If error option is set, and the drad, dlon and dlat values set, the errors 
;d on the transformation are computed. If the verbose option is set, the print 
;d out is verbose
;d Assumptions: Unless the deg option is set, we assume the angles are in 
;d              radians. Furthermore, we use the angles notation in which the 
;d              latitude corresponds to the elevation above/below the xOy 
;d              plane.
;d
;d producing 3XN array
;==============================================================================
ErrorMessage0 = 'Formal use of coords_rec2lat function:'+'\n'
ErrorMessage1 = ' sph = coords_rec2lat(x, y, z)'
ErrorMessage2 = ' sph = coords_rec2lat(x, y, z, /error, dx=x_error, dy=y_error, dz=z_error)'

;c Check the correct number of input is being given
 if n_params() lt 3 then message, ErrorMessage0+ErrorMessage1

;c Check all errors are given if the errors need to be computed.
 if keyword_set(error) then begin
    if (keyword_set(dx) and keyword_set(dy) and keyword_set(dz)) then $
       message, ErrorMessage0+ErrorMessage2
 endif


 if keyword_set(deg) then flg_ang = 180.d0/!dpi else  flg_ang = 1.d0

;c Making sure we're dealing with 1D-array 
 x = x[*]
 y = y[*]
 z = z[*]

;c Allocating Memory
 x_size = size(x, /dimensions)
 rad = dblarr(x_size)
 lat = dblarr(x_size)
 lon = dblarr(x_size)

;c Compute transformation
;c compute radius
 bsq = x^2+y^2
 rad = sqrt(bsq+z^2)
;c lon(gitude) and lat(itude) 
 lon = flg_ang*atan(y, x)
 lat = flg_ang*atan(z, sqrt(bsq))

;c Creating result variable
 result = transpose([[rad], [lon], [lat]])

;c In case computing the errors are necessary
 if keyword_set(error) then begin
  xoy = sqrt(bsq)
 ;c Allocating more memory
  drad = dblarr(x_size)
  dlon = dblarr(x_size)
  dlat = dblarr(x_size)
 
  drad = x*dx/r+y*dy/r+z*dz/r
  dlon = flg_ang*(x*dy-y*dx)/bsq
  dlat = flg_ang*(bsq*dz-x*z*dx-y*z*dy)/(rad*rad*xoy)
 
;c modifying result variable
 result = [ [result], tranpose([[drad, dlon, dlat]]) ]
 endif

return, result
end
