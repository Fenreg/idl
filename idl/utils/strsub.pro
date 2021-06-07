function strsub, strg, expr, argt, preserve=preserve
;==============================================================================
;d PURPOSE:
;d Script written for quick and dirty substraction of substrings in IDL
;d
;d AUTHOR;
;d clement.feller <at> obspm.fr 
;d
;d CHANGELOG:
;d 2016-Jul-18: first light
;d 2016-Dec-21: rewritten to use strplit and strjoin IDL functions, now allows
;d               for multiple substitutions
;d 2020-Jan-14: adding preserve_null option on strsplit to encompass patterns
;d              at beginning/end of string
;d I/O:
;d strg -> string in which to perform substitutions 
;d expr -> substring to remove
;d argt -> substring to add instead
;d 
;d DEPENDANCES: None
;==============================================================================

 if n_elements(preserve) ne 0 or arg_present(preserve) then $
   flg_preserve = !true else flg_preserve = !false
; print, flg_preserve
 nstrings = n_elements(strg)
 if nstrings eq 1 then begin
  return, strjoin(strsplit(strg, expr, /extract, /regex, $
                  preserve_null=flg_preserve), argt)
 endif else begin
  temp = strarr(nstrings)
  for ijk=0,(nstrings-1) do begin
    temp[ijk] = $
        strjoin(strsplit(strg[ijk], expr, /extract, /regex, $
                preserve_null=flg_preserve), argt)
  endfor
  return, temp
 endelse
end
