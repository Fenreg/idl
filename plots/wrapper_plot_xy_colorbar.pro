pro wrapper_plot_xy_z_colorbar, fname, x, y, z, flg_eps, flg_png
;===============================================================================
;d PURPOSE
;d  wrapper for the plot_xy_z_colorbar script
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   11-JUN-2018: first light
;d
;d I/O :
;d  fname   -> name of output file
;d     x,y  -> 1xN arrays float, double inputs for x, y axis
;d       z  -> 1xN array float, double input for colorbar
;d flg_eps  -> set option for eps output
;d flg_png  -> set option for png conversion after eps output
;d 
;d Dependances: coyote
;===============================================================================
 eps_open, fname, flg_eps
 plot_xy_z_colorbar, fname, x,y,z
 epsclose, fname, flg_eps, flg_png
end
