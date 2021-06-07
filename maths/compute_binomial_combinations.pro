;==============================================================================
;d short descriptor
;d Author clement <dot> feller <at> obspm <dot>fr
;d Changelog 30-MAR-2018 v1.0 written as self-standing script
;d           2019-MAY-14: adding inclusive and exclusive options
;d I/O nb_values: integer value indicating the number of values from 
;d                which to draw the possible combinations
;d     output, 2xnb_values array containing the sets of unique combinations
;d
;d Dependances: none
;d Notes: Script adapted from a deleted post on the google forum idl-pvwave.
;d  The basic idea of the script is to generate a strictly upper triangular 
;d  matrix and to select its values which gives the set of unique combinations.
;d USAGE: (example)
;d COMMENTS: (give it a blue thumb)
;d DEPENDANCIES: (compiler version, version of functions used)
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
function compute_binomial_combinations, nb_values, incl=incl
 if nb_values lt 2 then message, " > Argument should be greater or equal to 2."
 if keyword_set(incl) then flg_inc = !true else flg_inc = !false

 case nb_values of 
 2: return, [0,1]
 else: begin
    matrixunity = intarr(nb_values, nb_values)+1
    vectorindgn = indgen(nb_values)
    vectorunity = replicate(1, nb_values)
    matrix_hori = vectorindgn # vectorunity
    matrix_vert = vectorindgn ## vectorunity

    if flg_inc then vals_upper_triangular = $
                    where(matrixunity*(matrix_hori ge matrix_vert) ne 0) $
    else vals_upper_triangular = $
         where(matrixunity*(matrix_hori gt matrix_vert) ne 0)

    combinations_set_A = (matrix_vert)[vals_upper_triangular]
    combinations_set_B = (vals_upper_triangular mod nb_values)
    
    return, transpose([[combinations_set_A], [combinations_set_B]])
       end
 endcase
end
