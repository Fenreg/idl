function linexp_model, pha, par
;d Short descriptor
;d Author clement <dot> feller <at> obspm <dot>fr
;d Changelog 22-APR-2018 v1.0 first light written as self-standing script
;d I/O: pha: phase angle (in radians)
;d      par: function parameters
;d
;d Dependances: none
 return, par[0]*exp(par[1]*pha)+par[2]*pha+par[3]
end
