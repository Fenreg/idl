pro wrapper_plot_cgimage_colorbar, fname, image, imaconfig, eps=eps, png=png
;===============================================================================
;d PURPOSE:
;d  wrapper for the plot_cgimage_colorbar script
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   21-Feb-2017: first light
;d   13-May-2017: modifying eps trigger
;d   16-Aug-2017: removing the cgps2raster "/portrait" option
;d
;d I/O :
;d image  -> the image to plot (float array)
;d imageconfig -> structure with the details for the plotting of the image
;d 
;d Dependances: None
;===============================================================================
 if keyword_set(eps) then flg_eps = eps else flg_eps = !false
 if keyword_set(png) then flg_png = png else flg_png = !false

 eps_open, fname, flg_eps
 cgdisplay, imaconfig.displayarray[0], imaconfig.displayarray[1], $
            title=imaconfig.displaytitle

 cgloadct, imaconfig.CbTbl__Table, bottom=imaconfig.CbTbl_bottom, $
           rgb_table=imaconfig.CbTblPalette, reverse=imaconfig.ColorReverse

 plot_cgimage_colorbar, image, imaconfig

 epsclose, fname, flg_eps, png=flg_png
end
