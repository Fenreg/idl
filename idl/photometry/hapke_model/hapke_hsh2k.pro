;==============================================================================
;d NAME: hapke_hsh2k.pro
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: compute the porosity factor according to Helfenstein's empirical
;d  expression. See Helfenstein et al., 2011
;d CHANGELOG: 2017-MAR-24 v1.0 first light
;d            2019-MAY-10 v1.1 Documentation, error propagation
;d I/O:
;d <- hsh -> double, width of SHOE 
;d -> K   -> double, porosity factor (linked to , but different from porosity)
;d
;d USAGE: IDL> print, hapke_hsh2k(8.d-2)
;d COMMENTS: none
;d DEPENDANCIES: IDL >v7.1
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
function hapke_hsh2k, h_sh, errprop=errprop
 if keyword_set(errprop) then $ 
   k=2.109d0+2.d0*0.577d0*h_sh-3.d0*0.062d0*h_sh^2 $
 else k=1.069d0+2.109d0*h_sh+0.577d0*h_sh^2-0.062d0*h_sh^3

 return, k
end
