pro epsclose, outputname, flg_eps, png=png, pdf=pdf
;d minimal description
;d  27-JAN-2018 v1.0 first light
;d  cutting down few lines in other codes

 if keyword_set(portrait) then flg_prt = !true else flg_prt = !false
 if keyword_set(png) then flg_png = !true else flg_png = !false
 if keyword_set(pdf) then flg_pdf = !true else flg_pdf = !false

 if (flg_png or flg_pdf) then flg_dlt = !true else flg_dlt = !false
 if flg_eps then cgps_close, delete_ps=flg_dlt, density=600, $
                             png=flg_png, pdf=flg_pdf

end
