function oasis_build_duplicate, data, minvalue, maxvalue
;===============================================================================
;d PURPOSE:
;d  Script written to find the proper replication vector for the data vector.
;d  Written with the concatenation of the oasis' g_file and s_file data in mind
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   09-Jan-2016: first light
;d
;d I/O :
;d data -> integer array containing duplicates
;d minvalue -> minimum value contained in data
;d maxvalue -> maximum value contained in data
;d       => array containing how much duplicates each unique value in data has
;d           
;d References; JD Smith's tuto: www.idlcoyote.com/tips/histogram_tutorial.html
;d Dependances: None
;===============================================================================
;c Building frequence table for the data array
 frequenz = histogram(data, binsize=1, min=minvalue, max=maxvalue)

;c As binsize=1, if data is not contiguous, we need to remove the empty values
 frequenz = frequenz[where(frequenz ne 0)]

;c Creating the adequate multiplication vector
 histogrm = histogram(total(frequenz, /cumulative)-1, /binsize, min=0, $
                      reverse_indices=ri)

;c Returning the duplication vector
 return, ri[0:n_elements(histogrm)-1]-ri[0]
end
