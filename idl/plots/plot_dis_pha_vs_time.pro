pro Graph_DisPhaVsTime, JulianTime, Distance, Phase, ErrDis, ErrPha, date

 cgDisplay, 650, 650
 Disp = cgLayout([1,1], OXMargin=[7.8,5.0], OYMargin=[5.8,3.8])

;c X axis
 dummy = Label_date(Date_Format=['%H:%I:%S'])
 XRange = [JulianTime[0]-0.0022, JulianTime[-1]+0.0022]
;c Y axes
 DisMax = max(Distance, min=DisMin)
; DisRng = [DisMin*0.98, DisMax*1.02]
 DisRng = [28, 30]
 PhaRng = [0, max(Phase)*1.10]

 thicknes = 3
 chars1ze = 1.5
 charthik = 2
 psymsize = 1.3
 ErrThick = 2
 ticklgth = 1.0
 
 Color_01 = 'red5'
 Color_02 = 'blu7'
 MonthArr = ['Jan','Feb','Mar','Apr','May','Jun',$
             'Jul','Aug','Sep','Oct','Nov','Dec']

 Cal_Date = strcompress(string(date[0])+'-'+MonthArr[date[1]-1]+'-'$
                        +string(date[2]), /remove_all)
 Cal_Date = '2016-Apr-09'
 X0_Title = 'Time on '+Cal_Date
 Y1_Title = 'Median S/C Distance to Nucleus Surface (km)'
 Y2_Title = 'Median Phase angle (degrees)'

 Al_Names = ['Distance','Phase angle']
;c Plotting Distance curve
;c NB 15 min in julian time is equal to 0.0104
 cgPlot, JulianTime, Distance,$
  Err_Ylow = ErrDis[*,0], Err_YHigh = ErrDis[*,1],$
  Xrange = XRange, xstyle = 1, xtickformat = 'Label_Date',$
  xticks=4, xminor=6, $
  Yrange = DisRng, ystyle = 9,$
  color = Color_01, Err_Color = Color_01,$
  xtitle = X0_Title, ytitle = Y1_Title,$
  Err_thick=ErrThick, Thick=thicknes, charsize=chars1ze, charthick=charthik, $
  psym = 16, symsize = psymsize,$
  position = Disp

;c Adding new Y axis, suppress former Y second ticks
 cgAxis, Yaxis=1, Yrange=PhaRng, ytitle= Y2_Title,$
         charsize=chars1ze, charthick = charthik, ystyle=1,$
         /Save

;c Adding Phase Angle Curve
 cgOplot, JulianTime, Phase,$
   Err_YLow = ErrPha[*,0], Err_YHigh = ErrPha[*,1],$
   color = Color_02, Err_Color = Color_02,$
   Err_thick = ErrThick, thick = thicknes,$
   charsize = chars1ze, charthick = charthik,$
   psym = 15, symsize = psymsize

 Al_Legend, Al_Names, color= [Color_01, Color_02],$
           psym=[16,15],$
           /top,/center, /vertical, $
           charsize = chars1ze, charthick = charthik, thick = thicknes,$
           background = 'white' 
end
;------------------------------------------------------------------------------
pro Plot_Dis_Pha_vs_Time, Time, Distance, Phase, ErrDis, ErrPha,$
                         eps=eps, png=png
;c Provide three inputs and provide either window graphics, or eps, or eps+png
;c (I) Time     : Time at which images are taken. FMT = YYYY-MM-DDTHH:MM:SSZ
;c (I) Distance : At given time, distance to nucleus (km)
;c (I) Phase    : At given time, phase angle between sun comet & observer (deg)
;c  All inputs are supposed to be a one-column array
 if (size(ErrDis))[0] eq 1 then ErrDis = [[ErrDis], [ErrDis]]
 if (size(ErrPha))[0] eq 1 then ErrPha = [[ErrPha], [ErrPha]]

 Var1 = Time
 Var2 = Distance
 Var3 = Phase
 Var4 = ErrDis
 Var5 = ErrPha

 Var1Sz = n_elements(Var1)
 Var6 = dblarr(Var1Sz)
;c FileName standard
 Output = 'Graph_Dis_Pha_vs_Time'

;c Convertir UTC time en Julian dates
 for ijk=0,(Var1Sz-1) do begin
 TimeStampToValues, Time[ijk], YEAR=year, MONTH=month, DAY=day, HOUR=hour,$
                    MINUTE=minute, SECOND=second
 Var6[ijk] = JulDay(month, day, year, hour, minute, second)
 endfor
 Var7 = [year, month, day]

;c Display part
 if ~keyword_set(eps) then begin
  Graph_DisPhaVsTime, Var6, Var2, Var3, Var4, Var5, Var7
 endif else begin
  cgPS_Open, Output+'.ps',$
            CHARSIZE=1.5, DEFAULT_THICKNESS=1
  Graph_DisPhaVsTime, Var6, Var2, Var3, Var4, Var5, Var7
  cgPS_Close
 
  if keyword_set(png) then $
     cgPS2Raster, Output+'.ps', /PNG, /portrait, density=450
 endelse

end
