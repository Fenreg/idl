function strc_unravel, structure
;===============================================================================
;d PURPOSE:
;d Script written to if structure contains a simple tags or if one of them is a
;d  structure.
;d
;d AUTHOR:
;d clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   08-Feb-2017: first light
;d
;d I/O:
;d structure -> can be a two-level structure tops
;d        => returns an array whose cell value is 1 for 
;d
;d DEPENDANCES: None
;===============================================================================

 ntags = n_tags(structure)
 stype = 0L
 depth = lonarr(ntags)
 
 for ijk=0,(ntags-1) do begin
  stype = size(structure.(ijk), /type)
  case 1 of
    (stype ge 2 and stype le 7): depth[ijk] = 1
    stype eq 8: begin
                  temp = n_tags(structure.(ijk))
                  for lmn=0,(temp-1) do $
                     if (size(structure.(ijk).(lmn), /type) eq 8) then begin
                       depth[ijk] = -1
                       break
                     endif else depth[ijk] = temp

                end
    else: message,' > Problem with structure type and size. Read documentation.'
  endcase
 endfor
 
 return, depth
end
