pro eps_open, outputname, flg_eps
;d minimal description
;d  27-JAN-2018 v1.0 first light
;d  cutting down few lines in other codes

 if flg_eps then cgPS_Open, outputname+'.eps', /quiet, $
                            _REF_EXTRA={DECOMPOSED:!true}

end
