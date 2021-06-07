function plot_cfg_xy_ima_colorbar, $
              eps=eps
;d minimal description
;d  27-JAN-2018 v1.0 first light
;d  
;d set up structure for configuring plots (based on a034'*' scripts)

 if keyword_set(eps) then flg_eps = !true else flg_eps = !false
 struc = {DisplayTitle:  '', $
          Displayarray: [700, 800] , $
          ima_position: [0.1,0.1, 0.8, 0.8], $
          GnlThickness:  1.0, $
          Chara___Size:  1.0, $
          Chara__Thick:  1.0, $
          symbol__size:  1.0, $
          layout_xmrgn: [7.0, 2.2], $
          layout_ymrgn: [4.8, 7.0], $
          layout__xgap:  2.5, $
          layout__ygap:  2.5, $
          ima_valrange: [0.0, 1.0], $
          ima__stretch:    1, $
          Xaxis__title:   '', $
          Xaxis__range: [0.0, 1.0], $
          Xaxis__style:    1,       $
          Xtick_format: '(F5.2)',   $
          Xaxis_nticks:    4,       $
          Xaxis__minor:    5,       $
          xaxis_logplt: !false,     $
          Yaxis__title:   '',       $
          Yaxis__range: [0.0, 1.0], $
          Yaxis__style:    1,       $
          Ytick_format:  '(F5.2)',  $
          Yaxis_nticks:    4,       $
          yaxis__minor:    5,       $
          yaxis_logplt: !false,     $
          Tick__length:   0., $
          Al__Position: [0.1,0.88,0.9,0.95],   $
          CbTbl____pos: [0.1,0.88,0.9,0.94],   $
          CbTbl__Title:  'Colorbar title (%)', $
          CbTbl__Table:   33, $
          CbTblPalette: bytarr(256,3), $
          CbTbl_bottom:    0, $
          CbTbl___clip:  [0, 255], $
          ColorReverse: !false,    $
          cbtbl_xticks:    5, $
          CbTbl_format:  '(F6.3)', $
          CbTbl_vrange: [0.0, 1.0]*100. $
          }
;===========================================
 if flg_eps then begin
   struc.Chara___Size = 1.0
   struc.Chara__Thick = 1.0
   struc.layout_xmrgn = [7.0, 2.2]
   struc.layout_ymrgn = [4.0, 7.5]
   struc.layout__xgap = 3.0
   struc.layout__ygap = 3.0
 endif
;===========================================

 return, struc
end
