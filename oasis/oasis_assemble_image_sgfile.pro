function oasis_assemble_image_sgfile, imagename, sfile, gfile
;===============================================================================
;d PURPOSE:
;d  Script written to assemble osiris image and oasis s and g tables
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   09-Jan-2017: first light
;d
;d I/O :
;d image -> string of the image to read from (img format)
;d sfile -> string of the sfile to read from
;d gfile -> string of the gfile to read from
;d       => structure containing all of the following informations
;d           facets, pixel index, surface, geometrical information, details
;d 
;d References; JD Smith's tuto: www.idlcoyote.com/tips/histogram_tutorial.html
;d Dependances: None
;===============================================================================
print, ' --- oasis_assemble_image_sgfile start --- '
;c reading all data
 g_data = oasis_read_gfile(gfile)
 s_data = oasis_read_sfile(sfile)
 p_read, imagename, h, image, 'IMAGE'
 p_read, imagename, h, error, 'SIGMA_MAP_IMAGE'
 print, ' > oasis_assemble_image_sgfile - reading data done.'

;c finding common information between s_file and g_file
 g_facets = (long(g_data[0,*]))[*]
 s_facets = s_data.facets[0, *]
 s__index = s_data.facets[1, *]
 s_uniq_f = s_facets[uniq(s_facets[*])]
 common_f = [g_facets, s_uniq_f]

;c building an histogram of all (facet) index values appearing in g and s files
 h = histogram(common_f, binsize=1, min=g_facets[0], max=g_facets[-1])
;c a one liner with h eq 1 or h ne 0 and h ne 2 doesn't give the proper indices.
 h = h[where(h ne 0)]
 index_rm = where(h ne 2)
 index_cp = where(histogram(index_rm, min=0, max=n_elements(g_facets)-1) eq 0)
 
;c Replicating the g_data according to the number of s_data duplicates
 multiply = oasis_build_duplicate(s_facets[*], s_uniq_f[0], s_uniq_f[-1])
 nb_multi = n_elements(multiply)
 
;c getting the data and multiplying it.
 ng_data = g_data[1:-1, index_cp]
 duplica = ng_data[*, multiply]

;c Preparing and getting the image data, variation as previous lines
 image = reform(image, 2048L*2048L)
 error = reform(error,  2048L*2048L)

;c getting the "image indices" duplicates
 nimage = image[s_data.facets[1,*]]
 nerror = error[s_data.facets[1,*]]
stop
;c Merging the g, s and image informations (at last!)
return, { facets:s_data.facets, sgdata:[duplica, s_data.surface, nimage, nerror], $
          header:h }

end 
