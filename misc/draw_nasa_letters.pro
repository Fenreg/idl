pro draw_nasa_letters, png=png
;d Author: clement<.>feller<@>obspm<.>fr
;d Changelog: 24-Feb-2018 v1.0 first light
;d Purpose: Display the letters 'a', 'n', 's' in blue, add a little computer 
;d    and eventually save it to file in the present working directory
;d *REAL* purpose: None whatsover besides using some legacy Hershey vector 
;d    fonts that are not repertoried by the IDL manual.
;d
;d Dependancies: none
;d
;d Use: compile and run with or without the png option
;d
;d Example: IDL> .run draw_nasa_letters, /png
;d
;d NB: The Herschey vector font #19 DOES NOT exist in IDL. 
;d    Why? TA-DA-DA-DAAAAN! No one knows.

 if keyword_set(png) then flg_png = !true else flg_png = !false

 loadct, 0
 a = '!10'+string("101B)+'!X'
 n = '!10'+string("116B)+'!X'
 s = '!10'+string("123B)+'!X'
 computer = '!10'+string("164B)+'!X'

 m = make_array(400,250, /float, value=1)
 window, xsize=400, ysize=250
 tv, m
 xyouts, 0.15, 0.45, n, charsize=4.4, color=93
 xyouts, 0.35, 0.45, a, charsize=4.4, color=93
 xyouts, 0.55, 0.45, s, charsize=4.4, color=93
 xyouts, 0.75, 0.45, a, charsize=4.4, color=93
 xyouts, 0.80, 0.10, computer, charsize=4.4, color=83, alignment=0.5

 if flg_png then begin & write_png, 'Nasa_letters.png', tvrd(/true) & $
  print, ' > File "Nasa_letters.png" created in the present folder.' & endif

end
