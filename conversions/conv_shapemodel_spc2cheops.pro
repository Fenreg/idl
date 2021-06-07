pro conv_shapemodel_spc2cheops, filename, $
            reverse=reverse, obj_nlines=obj_nlines
;===============================================================================
;d PURPOSE:
;d  Script written to convert shape models in the SPC frame to the Cheops frame 
;d  (aka 67P/C-G_CK), seeking maximum portability.
;d
;d AUTHOR:
;d  clement<at>feller<dot>obspm<at>fr
;d
;d CHANGELOG: 
;d    27-FEB-2017: first light
;d
;d I/O:
;d  filename : string with the full path of the shape model to convert
;d  reverse  : binary option to convert from Cheops frame to SPC frame 
;d               (default=!FALSE)
;d obj_nlines: long value of the *total* numbers of lines in a obj shape model 
;d
;d NOTE: This program can only be used with .ver or with .obj models. When using 
;d  .obj, the setting of the obj_nlines option is required.
;d
;d DEPENDANCES: NONE
;===============================================================================
;c tests and settings
 if ~file_test(filename, /read) then message, 'File not found. Check its path.'
 if ~keyword_set(reverse) then begin
   cheops2spc = !FALSE 
   frame = '_cheops'
 endif else begin
   cheops2spc = !TRUE
   frame = '_spc'
 endelse

 extension = strlowcase(strmid(filename, strlen(filename)-3))
 if extension eq 'ver' then ver_flag = !TRUE else ver_flag = !FALSE
 if extension eq 'obj' then begin 
  if ~keyword_set(obj_nlines) then message, 'OBJ model: missing numbers of lines.'
  obj_flag = !TRUE 
 endif else obj_flag = !FALSE

;c defining rotation matrix from SPC to cheops
 mat = double($
     [[0.999988115010352E+00, -0.486673862742470E-02, 0.291020917157006E-03], $
      [0.486651407512085E-02, 0.999987863999109E+00, 0.767395110673006E-03], $
      [-0.294752096754503E-03, -0.765969732800629E-03, 0.999999663205728E+00]])
 tmat = transpose(mat)
 timat = transpose(invert(mat, /double))

;c defining offset vector between the two frames.
 offset = double([-0.0029655, 0.0012162, -0.0169312])

 openr, lun, filename, /get_lun

;c reading ver file
 if ver_flag then begin
;c For ver shape model, read number of vertices and facets
  nb_vertices = 0L
  nb___facets = 0L
  readf, lun, nb_vertices, nb___facets, format='(I,x,I)'
;c proper IDL quick read
  ver_table = dblarr(3L*nb_vertices)
  new_table = dblarr(3, nb_vertices)
  fct_table = strarr(2L*nb___facets)
  readf, lun, ver_table, format='(E0,x,E0,x,E0)'
  ver_table = reform(ver_table, 3, nb_vertices)
  readf, lun, fct_table, format='(A)'
  out_fmt = '(2(E15.8,x), E15.8)'
 endif

;c reading obj file
 if obj_flag then begin
   prefx = strarr(obj_nlines)
   lines = strarr(obj_nlines)
;c proper reading part, way quicker than a while loop
   readf, lun, lines, format='(A)'
;c for the purpose of identifying comments, vertices and facets ranges
   prefx = strmid(lines,0,1)
   comnt = where(prefx eq '#', complement=xedni)
   index = where(prefx[xedni] eq 'v', nb_vertices, complement=xidne, $ 
                                                     ncomplement=ncts)   
;c getting the facets range
   fct_table = strarr(ncts)
   fct_table = lines[xedni[xidne]]  
;c getting the vertices
   ver_table = dblarr(3, nb_vertices)
   new_table = dblarr(3, nb_vertices)
   vert_text = strarr(nb_vertices)
   vert_text = strtrim(strmid(lines[xedni[index]], 1), 2) 
;c selecting first column
   whitespace = strpos(vert_text[0], ' ')
   ver_table[0, *] = double(strtrim(strmid(vert_text, 0, whitespace+1), 2))
;c selecting second column
   vert_text = strtrim(strmid(vert_text, whitespace+1), 1)
   whitespace = strpos(vert_text[0], ' ')
   ver_table[1, *] = double(strtrim(strmid(vert_text, 0, whitespace+1), 2))
;c selecting third column
   vert_text = strtrim(strmid(vert_text, whitespace+1), 1)
   ver_table[2, *] = double(vert_text)
 endif

;c closing file
 free_lun, lun
 
;c perform the transformation
 bg_offset = rebin(offset, 3, nb_vertices)
 if cheops2spc then begin 
   ver_table -= bg_offset
   new_table = timat#ver_table
 endif else begin
   new_table = tmat#ver_table
   new_table += bg_offset
 endelse

;c Obj files require their vertex prefix
 if obj_flag then begin 
  prefx[xedni[index]] += ' '+string(new_table,format='(2(E15.8,x),E15.8)')
  new_table = strarr(nb_vertices)
  new_table = prefx[xedni[index]]
  out_fmt = '(A)'
 endif

;c write down the data
 new_filename = strmid(filename,0,strlen(filename)-4)+frame+'.'+extension
 openw, lun, new_filename, /get_lun
 if ver_flag then printf, lun, nb_vertices, nb___facets, format='(I,x,I)'
 printf, lun, new_table, format=out_fmt
 printf, lun, fct_table, format='(A)'
 free_lun, lun 
end
