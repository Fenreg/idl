function compute_combinations, vec, s_v, $
         index=index
;===============================================================================
;d AUTHOR: clement <dot> feller <at> obspm <dot> fr
;d
;d PURPOSE: Building all possible combinations given different sets of values.
;d
;d CHANGELOG:
;d   23-NOV-2017 v1.0 First light
;d   05-FEB-2017 v1.1 Implementing saveguarding of the result index table 
;d   06-MAR-2018 v1.2 Adding catch-up in case of passed single array in vec
;d   30-APR-2019 v1.3 removing negative array indices
;d
;d I/O:
;d    vec  -> 1D-array concatenating the differents sets of values.
;d    s_v  -> 1D-array detailling the number of elements per set.
;d  result -> array with all possible combinations given the different sets of 
;d               values.
;d   index -> array with the same dimension as result giving the replication 
;d               map.
;d
;d DEPENDANCIES: NONE
;d
;d REMARKS: NONE
;d  
;d EXAMPLE: 
;d IDL> u = [1,2,3]
;d IDL> v = [3.5,4.5]
;d IDL> w = [!pi/3., !pi/2, 2*!pi/3, !pi]
;d IDL> vec = [u,v,w] & s_v = [n_elements(u), n_elements(v), n_elements(w)]
;d IDL> print, compute_combinations(vec,s_v)
;d /* first set of combinations */
;d    1.00000|||   3.50000||    1.04720|
;d    1.00000|||   3.50000||    1.57080|
;d    1.00000|||   3.50000||    2.09440|
;d    1.00000|||   3.50000||    3.14159|
;d    1.00000|||   4.50000||    1.04720
;d    1.00000|||   4.50000||    1.57080
;d    1.00000|||   4.50000||    2.09440
;d    1.00000|||   4.50000||    3.14159
;d /* second set of combinations */
;d    2.00000|||   3.50000      1.04720
;d    2.00000|||   3.50000      1.57080
;d    2.00000|||   3.50000      2.09440
;d    2.00000|||   3.50000      3.14159
;d    2.00000|||   4.50000      1.04720
;d    2.00000|||   4.50000      1.57080
;d    2.00000|||   4.50000      2.09440
;d    2.00000|||   4.50000      3.14159
;d /* third and last set of combinations */
;d    3.00000|||   3.50000      1.04720
;d    3.00000|||   3.50000      1.57080
;d    3.00000|||   3.50000      2.09440
;d    3.00000|||   3.50000      3.14159
;d    3.00000|||   4.50000      1.04720
;d    3.00000|||   4.50000      1.57080
;d    3.00000|||   4.50000      2.09440
;d    3.00000|||   4.50000      3.14159
;d |   -> sequence of 4 elements repeated 3*2 times
;d ||  -> sequence of 2 elements duplicated 4 times and repeated 3 times
;d ||| -> sequence of 3 elements duplicated 2*4 times
;===============================================================================
 if arg_present(index) then flg_ind = !true else flg_ind = !false
 v_type = size(vec, /type)
;c Ketch-up in case of passed-on single-value-array in vec
;c s_v *either* equal to 1l (value) or greater than 1l
 idx = where(s_v eq 1l, complement=xdi, ncomplement=stc, cts)
 s_c = (cts gt 0l) ? s_v[xdi] : s_v

 ctsm1 = cts-1L
 prd__s = product(s_c)
 vncols = n_elements(s_v)
 cncols = n_elements(s_c)
;c Sparing a few cycles and allocating memory for result
 result = make_array(vncols, prd__s, type=v_type)
 if flg_ind then tbl = make_array(vncols, prd__s, type=3)

;c Selecting the operable sub array from vec
 nbv = total(s_c)
 idv = [0, total(s_v, /cumulative)]
 idc = [0, total(s_c, /cumulative)]
 cev = make_array(nbv, type=v_type)
 for ijk=0L,(stc-1l) do $
   cev[idc[ijk]:idc[ijk+1L]-1L] = vec[idv[xdi[ijk]]:idv[xdi[ijk]+1L]-1L]

;c Dealing with the first column
 rplct = reform(rebin(indgen(s_c[0]),prd__s), prd__s)
 result[xdi[0],*] = (cev[0:s_c[0]-1L])[rplct]
 if flg_ind then tbl[xdi[0],*] = rplct

;c Dealing with the last column
 rplct = reform(rebin(indgen(s_c[cncols-1]), reverse(s_c)), prd__s)
 result[xdi[stc-1],*] = (cev[total(s_c[0:cncols-2]):total(s_c[0:*])-1L])[rplct]
 if flg_ind then tbl[xdi[stc-1],*] = rplct

;c Dealing with all columns in between
 if flg_ind then begin 
  for ijk=(cncols-2L),1L,-1L do begin
    nb1 = product(s_c[ijk+1L:*])*s_c[ijk]
    nb2 = product(s_c[0:ijk-1L])
    rplct=reform(rebin(reform(rebin(indgen(s_c[ijk]),nb1),nb1),nb1,nb2),nb1*nb2)
    result[xdi[ijk],*] = (cev[total(s_c[0:ijk-1L]):total(s_c[0:ijk])-1L])[rplct]
    tbl[xdi[ijk],*] = rplct 
  endfor
 endif else begin 
  for ijk=(cncols-2L),1L,-1L do begin
    nb1 = product(s_c[ijk+1L:*])*s_c[ijk]
    nb2 = product(s_c[0:ijk-1L])
    rplct=reform(rebin(reform(rebin(indgen(s_c[ijk]),nb1),nb1),nb1,nb2),nb1*nb2)
    result[xdi[ijk],*] = (cev[total(s_c[0:ijk-1L]):total(s_c[0:ijk])-1L])[rplct]
  endfor
 endelse

;c Latching back on eventual subvectors of vec associated with a single-value
;c  ie going through vec and selecting the appropriate values
 if cts gt 0 then begin 
   result[idx[0],*] = vec[total(s_v[0:idx[0]-1])]
   for ijk=1L,(cts-2L) do result[idx[ijk],*] = vec[total(s_v[0:idx[ijk-1L]])]
   result[idx[ctsm1],*] = vec[total(s_v[0:idx[ctsm1]-1L])]
 endif

 if flg_ind then index = tbl
 return, result
end
