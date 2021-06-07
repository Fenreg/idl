;==============================================================================
;d NAME: cats_read_peixinho.pro
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: (short descr)
;d CHANGELOG: 2020-12-19 v1.0 first light
;d I/O:
;d <- nothing
;d -> returns table from Peixinho+2015 as structure 
;d
;d USAGE: (example)
;d COMMENTS: (give it a blue thumb)
;d DEPENDANCIES: idl71, read_csv
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
function cats_peixinho_read
 pt_f = "/home/user777/analyses/generic_data/catalogues/peixinho_2015/"+$
        "peixinho_2015_table5.dat"

 nbfl = file_lines(pt_f)
 data = strarr(nbfl)

 openr, lun, pt_f, /get_lun
 readf, lun, data, format='(A)'
 close, lun
 free_lun, lun

;c first table line is header/comment
 data = data[1:*]
 nbfl-=1l

;c allocating memory for table
 tbl = {name:strarr(nbfl), class:strarr(nbfl),    $
        phot:fltarr(4, nbfl),                     $
        clrs:fltarr(12, nbfl),                    $
        orbt:fltarr(10, nbfl), refs:strarr(nbfl), $
        clrs_keys:strarr(6)}

 tbl.clrs_keys = ['B-V', 'V-R', 'R-I', 'V-I', 'B-I', 'B-R']

;get some strings
 s_ini = 0l
 for ijk = 0l,1l do begin 
   s_end = strpos(data[0], '|')
   tbl.(ijk)[*] = strtrim(strmid(data, s_ini, s_end),2)
   data = strmid(data, s_end+1)
 endfor

;get some numbers
 ;c photometry
 for ijk = 0l,3l do begin 
   s_end = strpos(data[0], '|')
   tbl.(2)[ijk,*] = float(strmid(data, s_ini, s_end))
   data = strmid(data, s_end+1)
 endfor
 ;c colours
 for ijk = 0l,11l do begin 
   s_end = strpos(data[0], '|')
   tbl.(3)[ijk,*] = float(strmid(data, s_ini, s_end))
   data = strmid(data, s_end+1)
 endfor
 ;c orbital properties
 for ijk = 0l,9l do begin 
   s_end = strpos(data[0], '|')
   tbl.(4)[ijk,*] = float(strmid(data, s_ini, s_end))
   data = strmid(data, s_end+1)
 endfor
 ;c get the references
 tbl.(5)[*] = strtrim(strmid(data, s_ini, s_end),2)

 return, tbl
end
