function compute_position_sfile, shpmdl, s_data
;d clement <dot> feller <at> obspm <dot> fr
;d 23 apr 2017 
;d
;d assuming image is 2048L*2048L
;c read sfile
; s_data = oasis_read_sfile(s_file)

;c reorder
; order = sort(s_data.facets[1,*])
; s_data.facets = s_data.facets[*,order]
; s_data.surface = s_data.surface[*,order] 

;c finding mixing angle between facets
 mixing = (s_data.surface[0,*]/s_data.surface[1,*])[*]

 ima = dblarr(2048L*2048L, 3)

 maxhisto = 2048L*2048l-1

 h = histogram(s_data.facets[1,*], min=0, max=maxhisto, reverse_indices=ri)
 index = where(h ne 0, cts, complement=xedni)

t=systime(/sec)
 for ijk=0, (cts-1L) do begin
;-----------------------"Progress bar"-----------------------------------------
;   print, String(13b),ijk+1,'/',cts, $
;                              format='(A,X,I09,A,I09,$)'
;------------------------------------------------------------------------------
   indices = ri[ri[index[ijk]]:ri[index[ijk]+1]-1]
   elements = (s_data.facets[0, indices])[*]
   pos_rec = shpmdl.vertices[*, shpmdl.facets[*, elements]]
   pos_lat = conv_coords_rec2lat(pos_rec[0,*], pos_rec[1,*], pos_rec[2,*], /deg)
   pos_lat = transpose(pos_lat)
   pos_bar = [pos_lat[0, 0:-3:3]+pos_lat[0, 1:-2:3]+pos_lat[0, 2:-1:3], $
              pos_lat[1, 0:-3:3]+pos_lat[1, 1:-2:3]+pos_lat[1, 2:-1:3], $
              pos_lat[2, 0:-3:3]+pos_lat[2, 1:-2:3]+pos_lat[2, 2:-1:3]  ]
   pos_bar /= 3.d0
   barycen = mixing[indices]##pos_bar
;   if (barycen[0] le 1.3122) or (barycen[0] gt 1.7779) then stop

   ima[index[ijk],*] = barycen[*]
 endfor 
 ima[xedni, *] = -1.d0
print, systime(/sec)-t

 return, ima
end
