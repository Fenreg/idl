function dot_product, v1, v2
;d short descriptor
;d author
;d changelog 01-APR-2018
;d I/O assuming 1x3 vectors
;d dependances none
;d purpose compute the 3D dot product of two vectors
  v1 = v1[*]
  v2 = v2[*]
  return, [[v1[1]*v2[2]-v1[2]*v2[1]], $
           [v1[2]*v2[0]-v1[0]*v2[2]], $ 
           [v1[0]*v2[1]-v1[1]*v2[0]]]
end
