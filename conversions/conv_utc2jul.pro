function conv_utc2jul, utc_string
;===============================================================================
;d PURPOSE:
;d  wrapper for the plot_if_norm_std script
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   03-Feb-2017: first light
;d
;d I/O :
;d     x     -> x axis data (eg wavelength) (array)
;d     y     -> y axis data (eg if data)    (array)
;d normwave  -> index of wavelength wrt to which normalise y data to
;d imaconfig -> structure containing details for plots
;d   fname   -> name of file to write the plots in 
;d 
;d Dependances: None
;===============================================================================

 nb_string = n_elements(utc_string)
 result = dblarr(nb_string)

 for ijk=0L, (nb_string-1L) do begin
   timestamptovalues, utc_string[ijk], YEAR=year, MONTH=month, $
             DAY=day, HOUR=hour, MINUTE=minute, SECOND=second, $
             OFFSET=offset
   result[ijk] = julday(month, day, year, hour, minute, second)
 endfor

 return, result
end
