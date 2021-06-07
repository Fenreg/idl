function conv_coords_spc2cheops, x,y,z, $
                reverse=reverse
;===============================================================================
;d PURPOSE:
;d  Script written to convert coordinate mappings from the SPC frame to the 
;d Cheops frame (aka 67P/C-G_CK), seeking maximum portability.
;d
;d AUTHOR:
;d  clement<at>feller<dot>obspm<at>fr
;d
;d CHANGELOG: 
;d    08-JUN-2018: first light
;d
;d I/O:
;d  x,y,z    : 1xN float,double arrays standing for the cartesian coordinates
;d  reverse  : binary option to convert from Cheops frame to SPC frame 
;d               (default=!false)
;d obj_nlines: long value of the *total* numbers of lines in a obj shape model 
;d
;d NOTE: This program can only be used with .ver or with .obj models. When using 
;d  .obj, the setting of the obj_nlines option is required.
;d
;d DEPENDANCES: NONE
;===============================================================================
;c tests and settings
;c assuming nx=ny=nz and x,y,z are 1xN arrays
 nx = n_elements(x)

 if ~keyword_set(reverse) then begin
   cheops2spc = !false
   frame = ' > Converting from cheops to spc frame...'
 endif else begin
   cheops2spc = !true
   frame = ' > Converting from spc to cheops frame...'
 endelse

;c defining rotation matrix from SPC to cheops
 mat = double($
     [[0.999988115010352E+00, -0.486673862742470E-02, 0.291020917157006E-03], $
      [0.486651407512085E-02, 0.999987863999109E+00, 0.767395110673006E-03], $
      [-0.294752096754503E-03, -0.765969732800629E-03, 0.999999663205728E+00]])
 tmat = transpose(mat)
 timat = transpose(invert(mat, /double))

;c defining offset vector between the two frames.
 offset = double([-0.0029655, 0.0012162, -0.0169312])

;c Gathering coordinates in a 3xN array the Cartesian Coordinates Table
 CCoordsTbl = [x,y,z]
 new__table = dblarr(3, nx)

;c perform the transformation
 bg_offset = rebin(offset, 3, nx)
 if cheops2spc then begin
   CCoordsTbl -= bg_offset
   new__table = timat#CCoordsTbl
 endif else begin
   new__table = tmat#CCoordsTbl
   new__table += bg_offset
 endelse

return, new__table
end
