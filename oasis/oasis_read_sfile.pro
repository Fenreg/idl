function oasis_read_sfile, filename, imagesize=imagesize
;===============================================================================
;d PURPOSE:
;d  Script written to read from s files created by Oasis, an intricate data mix 
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   05-Jan-2016: first light
;d   15-Jan-2016: Saving the total surface value, using histogram power instead
;d                of a "for" loop
;d
;d I/O :
;d filename -> string of the file to read from 
;d imagesize -> the breadth and length of the image 
;d output -> structure with the reordered s file data 
;d 
;d Dependances: bash: awk, wc
;===============================================================================
 if ~keyword_set(imagesize) then modulo = 2048L else modulo = long(imagesize)

 tmp1 = '/tmp/idl_oasis_sfile1.dat'
 tmpX = '/tmp/idl_oasis_sfile1b.dat'
 tmp2 = '/tmp/idl_oasis_sfile2.dat'

 print, ' --- oasis_read_sfile start ---' 
;c Cuz awk cuts a 200MB file in 2.7s, grep in 2m44s and IDL is still running 
 cmd = "awk '{ /#/ ? m=1 : m=0 ; if ( m == 1 ) { print $0 > "+'"' + tmp1 + '"'+$
       " } else { print $0 > "+'"' + tmp2 + '"' + " } }' "+filename
 spawn, cmd, exit_status=flag
 if flag then message, 'oasis_read_sfile error - Awk call 1 failed.'

;c Easying the coming file reading for IDL
 cmd = "awk -F' #' '{print $1}' "+tmp1+" > "+tmpX
 spawn, cmd, exit_status=flag
 if flag then message, 'oasis_read_sfile error - Awk call 2 failed.'
 spawn, "mv "+tmpX+" "+tmp1

;c finding size of tables of create
 nb_lines = bash_wc_lines([tmp1, tmp2])
 print, ' > oasis_read_sfile - stream processing done.'

;c optimised IDL/fortran file reading 
 nbl_file1 = 4L*nb_lines[0]
 lines = fltarr(nbl_file1) 
 idl_readf_call, tmp1, lines, '(F0, x, F0, x, F0, x, F0)'
 
 f_surf = fltarr(2L*nb_lines[1])
 idl_readf_call, tmp2, f_surf, '(F0,x,F0)'
 
;c cutting the tmp1 file's line down
 nbl_gener = lindgen(nbl_file1)
 ind_replica = nbl_gener[2:nbl_file1-1:4]
 ind_surface = nbl_gener[3:nbl_file1-1:4]
 h = histogram([nbl_gener, ind_replica, ind_surface], binsize=1, $ 
                                         min=0, max=nbl_gener[-1])
 index_pxl = nbl_gener[where(h lt 2)]
 pxl = long(lines[index_pxl])
 duplication_vec = long(lines[ind_replica])
 sur = lines[ind_surface]
;c freeing memory
 delvar, lines  
 print, ' > oasis_read_sfile - reading files done.'

;c Reordering the array to have a facet-type of order
 facets = lonarr(2L, nb_lines[1])
 srfpxl = fltarr(2L, nb_lines[1])
 index = (pxl[0:2L*nb_lines[0]-1:2]-1)+(pxl[1:2L*nb_lines[0]-1:2]-1)*modulo 
 h = histogram(total(duplication_vec, /cumulative)-1, /binsize, min=0, $
                                                     reverse_indices=ri)
 duplication_ind = ri[0:n_elements(h)-1]-ri[0]
 facets = transpose([[f_surf[0:2L*nb_lines[1]-1:2]], [index[duplication_ind]]])
 srfpxl = transpose([[f_surf[1:2L*nb_lines[1]-1:2]], [sur[duplication_ind]]])
 print, ' > oasis_read_sfile - reordering done.'

;c reordering to ease the comparison of s and g files
 index = sort(facets[0, *])
 spawn, "rm "+tmp1+" "+tmp2
 print, ' --- oasis_read_sfile end --- '
 return,{facets:long(facets[*, index]), surface:srfpxl[*, index]}
end
