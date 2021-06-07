;==============================================================================
;d NAME: curve_running_box
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: computing a simple running box on a time series
;d CHANGELOG: 2019-07-25 v1.0 first light
;d            2019-10-21 v1.1 adding forward, backward 
;d I/O:
;d <- x: 1xN float/double array (the data to average)
;d <- r: single int/lon value (the radius with which to average)
;d -> meanv: 1xN float/double array (the gathered data)
;d
;d USAGE: (example)
;d COMMENTS: (give it a blue thumb)
;d DEPENDANCIES: idl > v7.1, none 
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
function curve_running_box, x, r, $
  forward=forward, backward=backward,$
  sum=sum

 if keyword_set(forward) then flg_fwd = !true else flg_fwd = !false
 if keyword_set(backward) then flg_bwd = !true else flg_bwd = !false

;c operations to perform (default is mean)
 if keyword_set(sum) then flg_sum = !true else flg_sum = !false
 

 dt_sz = n_elements(x)
 gthrd = dblarr(dt_sz)
 v_lt = lonarr(dt_sz)
 v_rt = lonarr(dt_sz)

 v_lt = (-lindgen(dt_sz)>(-r+1))
 v_rt = reverse(-v_lt)

 if flg_fwd then v_lt[*] = 0l
 if flg_bwd then v_rt[*] = 0l

 nvls = 1-v_lt+v_rt

 for ijk=0l,dt_sz-1l do gthrd[ijk] = total(x[ijk+v_lt[ijk]:ijk+v_rt[ijk]])

 if flg_sum then return, gthrd[*]

 return, gthrd[*]/nvls[*]
end

