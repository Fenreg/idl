;==============================================================================
;d NAME: minim_hhs_cfg_build_hpk_model.pro
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: (short descr)
;d CHANGELOG: 2019-07-18 v1.0 first light
;d            2019-08-22 v1.1 committing model to file
;d            2019-09-03 v1.2 adding message to deal with wrong cfg flags
;d I/O:
;d <- hpk_hhs_cfg: structure containing the configuration for the HHS model
;d -> file minim_model_call.pro
;d
;d USAGE: obvious
;d COMMENTS: none 
;d DEPENDANCIES: idl >v7.0 and minim_model_call_hhs_optim.orp (backup)
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
pro minim_hhs_cfg_build_hpk_model, hpk_hhs_cfg

;c coherent-backscaterring
 case hpk_hhs_cfg.flg_bcb of
   0: bcb = ''
   1: bcb = 'hpk_optim_cboe_shk(parms[5], parms[6])*'
   2: bcb = 'hpk_optim_shoe(parms[5], parms[6])*' ; yes shoe
   else: message, ' > Error hpk_cfg: wrong flag bcb.'
 endcase

;c shadow-hiding
 case hpk_hhs_cfg.flg_bsh of 
   0: bsh = ''
   1: bsh = 'hpk_optim_shoe_erf(parms[3], parms[4])*'
   2: bsh = 'hpk_optim_shoe(parms[3], parms[4])*'
   else: message, ' > Error hpk_cfg: wrong flag bsh.'
 endcase

;c single particle phase function
 case hpk_hhs_cfg.flg_hgf of
   0: hgf = 'hpk_optim_hg_1(parms[1])+'
   1: hgf = 'hpk_optim_hg_2(parms[1], parms[2])+'
   2: hgf = 'hpk_optim_hg_2(parms[1], parms[2])+'
   3: hgf = 'hpk_optim_hg_2(parms[1], parms[2])+'
   else: message, ' > Error hpk_cfg: wrong flag HG function.'
 endcase

;c multiple scattering
 case hpk_hhs_cfg.flg_msc of 
   0: msc = 'hpk_optim_imsa(parms[0], r_0, parms[8])'
 ;c we're not computing Legendre polynomials right now
   1: begin 
        msc = 'hpk_optim_imsa(parms[0], r_0, parms[8])' 
        print, 'Optimized Legendre polynomials not implemented right now'
      end
   else: message, ' > Error hpk_cfg: wrong flag Mscat.'
  endcase

;c roughness function
 case hpk_hhs_cfg.flg_rgh of 
   0: rgh = 'disk*'
   1: rgh = 'hpk_optim_disk_rgh_fct(parms[7])*'
   else: message, ' > Error hpk_cfg: wrong flag roughness function.'
 endcase

;c finally assembling the model 
 l_0 =' return, 0.25d0*!idpi*parms[0]*parms[8]*'+rgh+'$'
 l_1 ='         ('+bsh+hgf+'$'
 l_2 ='          '+bcb+msc+')'

;c looking for hapke base of minim_model_call 
 basefile = 'minim_model_call_hhs_optim.orp'
 r = file_search(strsplit(!path, path_sep(/search_path),/extract)+'/'+basefile)
 if r eq '' then message, ' > Error: file '+basefile+' not found.'

;c copying that file and checking it is copied (ie dir is writeable)
 path = strmid(r, 0, strpos(r, '/', /reverse_search)+1l)
 pthf = path+'minim_model_call.pro'
;c a previous model file exists ? delete it
 flge = file_search(pthf)
 print, ' > minim_hhs_cfg_build_hpk_model: replacing previous version of '+ $
        'minim_model_call.'

 if flge ne '' then file_delete, pthf
;c copy in the new file
 file_copy, r, pthf
 r = file_search(pthf)
 if r eq '' then message, ' > minim_hhs_cfg_build_hpk_model: Error - file '+ $
                          basefile+' not properly copied.'

;c now assuming file is writeable, inserting the optimized return value
 nb_ln = file_lines(r)

 openw, lun, r, /get_lun, /append
 printf, lun, l_0, string(10b), l_1,string(10b), $
              l_2, string(10b), string(10b), 'end', $
              format='(8A)'

 free_lun, lun

end
