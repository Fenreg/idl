;==============================================================================
;d NAME: hpk_hhs_optim
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: optimised script to evaluate the Hapke-Helfenstein-Shkuratov 
;d          function. 
;d CHANGELOG: >2017<      v1.0 First light
;d            2019-APR-30 v1.1 * Adding documentation header
;d                             * Changing output from RADF to bidirectionnal
;d                              reflectance. The user must know adapt inputs 
;d                              and outputs
;d                             * Introducing forward_function for compilation 
;d                               purposes.
;d                             * Renaming the roughness function
;d                             * Rewriting conditionals tests in hpk_hhs_optim
;d            2019-MAY-05 v1.2 * Adding hpk_optim_hg_2 and hpk_optim_shoe_erf
;d            2019-AUG-16 v1.3 * renaming disk option and disk*roughness call
;d
;d I/O:
;d <- HHS function's parameters (wssa, gscat, Bs0, hs0, Bcb, Hcb, thetabar, 
;d    Kporo) (1x9 double array)
;d -> 1xN double array containing evaluation of the HHS function in 
;d       *bidirectionnal reflectance*
;d
;d USAGE: (example)
;d COMMENTS: none
;d DEPENDANCIES: >idl 7.1, hpk_hhs_optim_loader
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
;forward_function hpk_optim_hg_1, $
;                 hpk_optim_hg_2, $
;                 hpk_optim_shoe, $
;                 hpk_optim_shoe_erf, $
;                 hpk_optim_imsa, $
;                 hpk_optim_cboe_shk, $
;                 hpk_optim_dsk_rgh_fct, $
;                 hpk_hhs_optim
;
;function hpk_optim_hg_1, gscat
; common _hpk_var_phase, g, cos_g, tan_g, tang2
;  gscat2 = gscat*gscat
;  denom = exp(-1.5d0*alog(1.d0+2.d0*gscat*cos_g+gscat2))
; return, (1.d0-gscat2)*denom
;end
;
;function hpk_optim_hg_2, gscat, c
; common _hpk_var_phase, g, cos_g, tan_g, tang2
;  gscat2 = gscat*gscat
;  exp_factor = 2.d0*gscat*cos_g
;  backscat = exp(-1.5d0*alog(1.d0+gscat2-exp_factor))
;  forwscat = exp(-1.5d0*alog(1.d0+gscat2+exp_factor))
; return, 0.5d0*(1.d0-gscat2)*((1.d0+c)*backscat+(1.d0-c)*forwscat)
;end
;
;function hpk_optim_shoe, b_sh0, h_sh
; common _hpk_var_phase, g, cos_g, tan_g, tang2
; return, 1.d0+b_sh0/(1.d0+tang2/h_sh)
;end
;
;function hpk_optim_shoe_erf, b_sh0, h_sh
; common _hpk_var_phase, g, cos_g, tan_g, tang2
;  y1 = sqrt(h_sh/tang2)
;  y4 = 2.d0*y1
; return, 1.d0-b_sh0+b_sh0*(sqrt(!dpi)*(erf(y4)-erf(y1))*((y4*exp(y1))<!mc.xmax)+$
;                     exp(-3*y1)) 
;end
;
;function hpk_optim_imsa, w_ssa, r0, kporo
; common _hpk_var_angle, cosi, cose
;  mu0k = cosi/kporo
;  wi = w_ssa*mu0k
;  H1 = 1.d0/(1.d0-wi*(r0+(0.5d0-mu0k*r0)*alog(1.d0+1.d0/mu0k)))
; 
;  mu_k = cose/kporo
;  we = w_ssa*mu_k
;  H2 = 1.d0/(1.d0-we*(r0+(0.5d0-mu_k*r0)*alog(1.d0+1.d0/mu_k)))
; return, H1*H2-1.d0
;end
;
;function hpk_optim_cboe_shk, b_cb0, h_cb
; common _hpk_var_phase, g, cos_g, tan_g, tang2
; common _hpk_var_angle, cosi, cose
;  b = 3.d0*b_cb0/(8.d0*!dpi)
;  ah = g/h_cb
;  mu_mu0 = cosi+cose
; 
;  numer = b*mu_mu0*(2.d0*cosi*cose/mu_mu0+(1.d0-exp(-ah/0.75d0))/ah)
;  denom = (1.d0+ah*cose)*(1.d0+ah*cosi)
; return, 1.d0+numer/denom
;end
;
;function hpk_optim_disk_rgh_fct, theta
;;c roughness function defined in hapke 1984
;;c returns ratio of the reflectance masked by mutual shadows
;;c Reminder g, i, e, p and theta should be in radians by now computing parts 
;;c that remains identical in eqs.
;;c equations taken from Hapke 1984, Shkuratov 2012, Domingue 2014 and 
;;c Sofie Spjuth's dissertation
;
; common _hpk_var_roughness, phi_p, cos_p, sn2p2, cos_i, sin_i, tan_i, $
;                            cos_e, tan_e, f, f2, msk_e_ge_i, msk_e_lt_i
;;c if theta is null then return 1xLommel seeliger else return 
;;c "modified disk law" times "roughness function"
; if theta eq 0. then return, cos_i/(cos_e+cos_i) else begin
;   tan_t = tan(theta)
;
;   ti_tt = tan_i*tan_t
;   si_tt = sin_i*tan_t
;   te_tt = tan_e*tan_t
;
;   Ei = 1.d0/ti_tt
;   Ee = 1.d0/te_tt
;   E1_i = exp(-2.d0*Ei/!dpi)
;   E1bi = 2.d0-E1_i
;   E2_i = exp(-Ei*Ei/!dpi)
;   E1_e = exp(-2.d0*Ee/!dpi)
;   E1be = 2.d0-E1_e
;   E2_e = exp(-Ee*Ee/!dpi)
;
;;c defining different eta than hapke -> eta(x) = eta_hpk(x)/(chi_theta*cos(x))
;   eta_i = 1.d0+ti_tt*E2_i/E1bi
;   eta_e = 1.d0+te_tt*E2_e/E1be
;
;;c Case e greater or equal to i
;;c -> Hapke 1993   equations: 12.46 -> 12.51
;;c -> Sofie Spujth equations: 2.36->2.38 + 2.42->2.45
;   D = E1be-phi_p*E1_i
;   X = sn2p2*E2_i
;   A = cos_e/(cos_i*D+si_tt*(cos_p*E2_e+X))
;   B = 1.d0/(D+te_tt*(E2_e-X))
;   C = D*eta_e*(f+f2*eta_i)
;   dxs_e_ge_i = msk_e_ge_i*1.d0/((A+B)*C)
;;c Case e smaller than i
;;c -> Hapke 1993   equations: 
;;c -> Sofie Spujth equations: 
;   D = E1bi-phi_p*E1_e
;   X = sn2p2*E2_e
;   A = cos_e/(cos_i*D+si_tt*(E2_i-X))
;   B = 1.d0/(D+te_tt*(cos_p*E2_i+X))
;   C = D*eta_i*(f+f2*eta_e)
;   dxs_e_lt_i = msk_e_lt_i*1.d0/((A+B)*C)
;
;   return, [dxs_e_ge_i+dxs_e_lt_i]
; endelse
;end

function hpk_hhs_optim, parms, $
                        mpfit=mpfit, disk_S=disk_S, _EXTRA=ex

 mpfit_lock = (keyword_set(mpfit) and keyword_set(disk_S)) ? !true : !false

 tmp = sqrt(1.d0-parms[0])
 r_0 = (1.d0-tmp)/(1.d0+tmp)
 sppf = hpk_optim_hg_1(parms[1])
; sppf = hpk_optim_hg_2(parms[1], parms[2])
 Mscat= hpk_optim_imsa(parms[0], r_0, parms[8])

 DskS = mpfit_lock ? disk_S : hpk_optim_disk_rgh_fct(parms[7])
 B_sh = (parms[3] ne 0.d0) ? hpk_optim_shoe(parms[3], parms[4]):1.d0
 B_cb = (parms[5] ne 0.d0) ? hpk_optim_cboe_shk(parms[5], parms[6]):1.d0 

 return, 0.25d0*!idpi*parms[8]*parms[0]*DskS*(B_sh*sppf+B_cb*Mscat)
end
