;==============================================================================
;d NAME: idl_readf_call
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: wrapping for idl's readf procedure
;d CHANGELOG: 05-Jan-2017: first light 
;d I/O:
;d <- filename : string of the file to read from
;d <- output   : array to put the data in
;d <- fmt      : fortran format to interpret the data read
;d <- offset   : long integer giving the byte offset to start reading with
;d -> none     : the 'output' variable will be copied over by readf 
;d
;d USAGE: read some strings: idl_readf_call, './text.dat', str, '(A)'
;d        read but jump this header: < # here's some data \NL >
;d        (\NL stands for a newline character, aka LF, ie. offset=19+1
;d             idl_readf_call, './text.dat', str, '(A)', offset=20
;d
;d COMMENTS: (give it a blue thumb)
;d DEPENDANCIES: idl >v7.1
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
pro idl_readf_call, filename, output, fmt, offset=offset, silent=silent
;c are we passing a variable through a keyword
 if keyword_set(offset) and size(offset,/type) eq 3 then flg_ost = !true $
 else flg_ost = !false

 if keyword_set(silent) then flg_slt = !true else flg_slt = !false

 if ~flg_slt then print, ' --- idl_readf_call start --- '

 openr, unit, filename, /get_lun
 if flg_ost then point_lun, unit, offset
 readf, unit, output, format=fmt
 free_lun, unit

 if ~flg_slt then print, ' --- idl_readf_call end --- '
end
