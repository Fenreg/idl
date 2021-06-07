pro DisplayImageTvBox, Image, $
                       NbCube, CubeCenter, CubeSide, $
                       title=title
;------------------------------------------------------------------------------
;c I - Image: 2D-Array
;c I - NbCube: Integer
;c I - CubeCenter: array of 2D-Array
;c I - CubeSide: Integer
;c
;c Purpose:
;c
;c Remarks:
;c
;------------------------------------------------------------------------------
;c Create define layout and titles
;c IM_position = [0.015, 0.015, 0.985, 0.985]
 IM_position = [0.075, 0.005, 0.945, 0.860]
 CB_position = [0.065, 0.903, 0.955, 0.953]

 ImaTitle = 'Normal albedo map at 12:40:34'
 CB_Title = 'I/F (%)'
 X__Title = 'Pixel column'
 Y__Title = 'Pixel row'

 ImageSz = size(Image, /dimension)
 X__Range = [0, 2047]
 Y__Range = [0, 2047]

;c Details of Titles font
 Thickness = 2 
 CharaSize = 1.4
 CharThick = 2

 Stretch_type = 1
 minValue = 0.050
 maxValue = 0.075
 NbLevels = 8

;c create Coyote display
 cgDisplay, 650, 650, title = ImaTitle, wid=1

;c Load color Table
 bottom = 0
 cgLoadCT, 0,$
;c          /Reverse,$
;c          NColors=NbLevels, Bottom=0, CLIP=[0,256],$
          bottom = bottom, CLIP = [Bottom,255],$
          rgb_table=palette

;c Adding Black color to color table at index 0 and retrieving the new color table 
 TVLCT, cgColor('black', /Triple), 0
 TVLCT, r, g, b, /Get
 palette = [ [r], [g], [b] ]

;c clipping values outside the range
 index = where((Image lt minValue) and (Image gt maxValue))
 Image[index] = minValue/2.

;c Display Image with settings
 cgImage, Image, position = IM_Position,$
  stretch = Stretch_type, MinValue = minValue, MaxValue = maxValue,$
;  NColors=NbLevels,$
  Palette=palette,$
  /Axes,$
  AXKEYWORDS={Xstyle:4, Ystyle:4},$
  Charsize = CharaSize,$
  XTitle = X__Title, YTitle = Y__Title,$
  XRange = X__Range, YRange = Y__Range;, /Keep_aspect

 if keyword_set(title) then begin
   cgtext, 0.515, 0.030, ImaTitle, /normal,$
          Alignment=0.5,$
          Charsize = CharaSize, charthick = CharThick
 endif

 for ijk=0,(NbCube-1) do begin
  BoxSz = CubeSide/2.
  XMin = CubeCenter[0,ijk]-BoxSz
  XMax = CubeCenter[0,ijk]+BoxSz
  YMin = CubeCenter[1,ijk]-BoxSz
  YMax = CubeCenter[1,ijk]+BoxSz
  
  if (XMin lt 0) then begin
     Diff = Xmin
     Xmin = 0
     Xmax-= Diff
  endif
  if (YMin lt 0) then begin
     Diff = YMin
     YMin = 0
     YMax-= Diff
  endif
  if (XMax gt 2047) then begin
     Diff = XMax-2047
     XMax = 2047
     XMin+= Diff
  endif
  if (YMax gt 2047) then begin
     Diff = YMax-2047
     YMax = 2047
     YMin+= Diff
  endif
;c Normalising and modyfing Position with respect to IM_Position
   XFactor = IM_Position[2]-IM_Position[0]
   YFactor = IM_Position[3]-IM_Position[1]
   XMin = temporary(Xmin/ImageSz[0])*XFactor+IM_Position[0]
   XMax = temporary(Xmax/ImageSz[0])*XFactor+IM_Position[0]
   YMin = temporary(YMin/ImageSz[1])*YFactor+IM_Position[1]
   YMax = temporary(Ymax/ImageSz[1])*YFactor+IM_Position[1]
   Square = [[XMin,YMin],[XMin, YMax], [XMax, YMax], [XMax,YMin], [XMin, YMin]]

;c Plotting Square
  cgPlots, Square, /norm,$
           Psym=-3, symsize=3,$
           color='yellow', thick=4

;c Plotting Number 
  cgText, XMin, YMin, string(ijk+1, format='(I1)'), /norm,$
          color='Yellow',$
          Alignment=1,$
          Charsize = 4, charthick = CharThick
          
 endfor

;c Add color bar
 cgColorbar, position = CB_position, $
;  ncolors = NbLevels,$
  palette=palette,$
  Range = [minValue, maxValue]*100.,$
  Charsize= CharaSize, textthick=2, $
;  division = NbLevels, bottom=0, /Discrete, $
  Title = CB_Title, TLocation = 'top',$
  format='(F4.1)'




end
;==============================================================================
pro Plot_CgImage_TvBox, Image,$
                           NbCube, CubeCenter, CubeSide,$
                           eps=eps, png=png
;------------------------------------------------------------------------------
;c Provide image and get it on display and eventually hardcopy it in eps or png
;c format. 
;------------------------------------------------------------------------------
 Output = 'Image_ColorBar'

 if ~keyword_set(eps) then begin
   DisplayImageTvBox, Image, NbCube, CubeCenter, CubeSide 
 endif else begin
   cgPS_Open, Output+'.ps'
   DisplayImageTvBox, Image, NbCube, CubeCenter, CubeSide
   cgPS_Close
   
  if keyword_set(png) then $
     cgPS2Raster, Output+'.ps', /PNG, density=600
   
 endelse
end
