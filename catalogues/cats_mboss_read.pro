;==============================================================================
;d NAME: cats_read_mboss.pro
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: (short descr)
;d CHANGELOG: 2020-12-19 v1.0 first light
;d I/O:
;d <- (input)
;d -> (output)
;d
;d USAGE: (example)
;d COMMENTS: (give it a blue thumb)
;d DEPENDANCIES: (compiler version, version of functions used)
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
function cats_mboss_read
 pt_f = "/home/user777/analyses/generic_data/catalogues/eso-mboss-colors/"+$
        "mbossData.txt"

 nbfl = file_lines(pt_f)
 data = strarr(nbfl)

 openr, lun, pt_f, /get_lun
 readf, lun, data, format='(A)'
 close, lun
 free_lun, lun

;c Disregard comment lines
 cmnt = strarr(nbfl)
 cmnt[*] = strmid(data,0,1)
 lidx = where(strmatch(cmnt, '#') ne 1, lcts)
 if lcts eq 0 then message, ' > Text full of comments. No cant do.'

 tbl = {name:strarr(lcts), class:strarr(lcts),      $
        epo:lonarr(lcts), mult:lonarr(lcts),        $
        phot:fltarr(4, lcts),                       $
        clrs:fltarr(18, lcts), clrs_keys:strarr(6), $
        refs:strarr(lcts)}

;c get object name
 tbl.name[*] = strtrim(strmid(data[lidx],0, 23), 2)
;c get object type
 tbl.class[*] = strtrim(strmid(data[lidx], 24, 9), 2)
;c get number of epochs and multiplicity of observations
 tbl.epo[*]  = long(strmid(data[lidx], 33,3))
 tbl.mult[*] = long(strmid(data[lidx], 36,3))

;c get absolute magnitude and gradient 
 tmp = strarr(lcts)
 tmp = strsub( strsub( strsub( $
          strtrim(strmid(data[lidx], 39, 29),2), $
          '------', '0.0', /preserve), $
          '/',' ', /preserve), $
          '  ', ' ', /preserve)

 tbl.phot[0,*] = float(strmid(tmp, 0,6))
 tbl.phot[1,*] = float(strmid(tmp, 7,6))
 tbl.phot[2,*] = float(strmid(tmp, 13,6))
 tbl.phot[3,*] = float(strmid(tmp, 19,6))

;c get colours values, sigma and dispersion
 tbl.clrs_keys = ['B-V', 'V-R', 'R-I', 'V-J', 'J-H', 'H-K'] 
 tmp = strsub( strsub( strsub( $
          strtrim(strmid(data[lidx], 67, 21*6l),2), $
          '------', '0.000', /preserve), $
          '/',' ', /preserve), $
          '  ', ' ', /preserve)

 for ijk=0l,17l do tbl.clrs[ijk,*] = float(strmid(tmp, ijk*6,6))

;c get references
 tbl.refs[*] = strtrim(strmid(data[lidx], 193),2)

 return, tbl
end
