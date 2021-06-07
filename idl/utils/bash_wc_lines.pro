function bash_wc_lines, str
;===============================================================================
;d PURPOSE:
;d  Script written to obtain the amount of lines of single/multiple *text* files
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   06-Jan-2016: first light
;d
;d I/O :
;d str -> string or string array of the files in question
;d 
;d Dependances: bash wc and awk
;===============================================================================
 nstr = n_elements(str)

;c check existence and readibility of files
 for ijk=0,nstr-1 do begin
   error = 'bash_wc_lines error - Check path and properties of '+str[ijk]
   if ~file_test(str[ijk], /read) then message, error
 endfor
 
;c execute word count call
 files = ''
 for ijk=0, nstr-1 do files += str[ijk]+' '
 cmd = "wc -l "+files+"| awk -F' ' '{print $1}'"
 spawn, cmd, nb_lines, exit_status=flag
 if flag then message, 'bash_wc_lines - wc/awk call failed.'

;c finish call and remove and total word count lines
return, long(nb_lines[0:nstr-1])
end
