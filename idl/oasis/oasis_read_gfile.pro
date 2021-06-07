function oasis_read_gfile, filename
;===============================================================================
;d PURPOSE:
;d  Script written to read from g files created by Oasis (a list of columns)
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   04-Jan-2016: first light
;d
;d I/O :
;d  filename -> string of the file to read from 
;d
;d Dependances: none
;==============================================================================
;c format of g_file is known and set: 1 column of long, 7 columns of floats
 print, ' --- oasis_read_gfile start --- '
 tmp = "/tmp/idl_oasis_gfile.dat"
 cmd = "awk '!/#/{print $0 > "+'"'+tmp+'"'+" }' "+filename
 spawn, cmd, exit_status=flag
 if flag then message, 'oasis_read_gfile error - Awk call failed.'
 nb_lines = bash_wc_lines(tmp)
 g_data = fltarr(8L*nb_lines)

;c quickest IDL way to read data
 openr, lun, tmp, /get_lun
 readf, lun, g_data, format='(7(F0,x),F0)'
 free_lun, lun

 print, ' --- oasis_read_gfile end --- '
 return, reform(g_data, 8, nb_lines)
end
