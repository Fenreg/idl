;=============================================================================
pro OASIS_sg_concatenate, Index_OASIS, ImageName
;c code written to read OASIS surface files (s_XXXXXX.dat), OASIS geometric
;c files (g_XXXXXX.dat) and return tables of pixels containing triangles and
;c list of triangles seen and their surface contribution
;c
;--- Requisite ---
; Markwardt cmreplicate
; SPICE+DSK dasopr, dlabfs, dskz02, dski02, dskd02, reclat, dascls, kclear
;==============================================================================
dskpath = '/home/user-777/These/Tycho/SPICE/Rosetta/ShapeModels/Flyby/'
dskname = '67P-CG-SPG-SHP4-v02-flyby_ck.dsk'
Imgpath = '/home/user-777/These/Tycho/Comet/MTP013/STP043_FLYBY_CLOSE/ALIGNED_IMA/'
debug = 0
verbose = "ON"

file_s = 's_'+string(Index_OASIS, format='(I06)')+'.dat'
file_g = 'g_'+string(Index_OASIS, format='(I06)')+'.dat'

; getting Nbline_s and Nbpxls_s with unix tools
print, 'Checking '+file_s+' in progress. Might take about 10 seconds.'
spawn, 'wc -l '+file_s, Nbline_s
print, ' > -- s_ file: '+strmid(Nbline_s,0,strpos(Nbline_s,' '))+' lines to be read.'
spawn, 'cat '+file_s+' | grep -o "#triangle" | wc -l', Nbpxls_s
print, ' > -- '+Nbpxls_s+' references to facets identified.'

print, 'Reading g_ file in progress.'
data_g = rd_tfile(file_g, /auto, /convert, /nocomment) 
g_size = size(data_g, /dimension)
g_dim0 = g_size[0]-1

print, 'Loading image and filter order.'
;c loading image
ImagCube = readfits(Imgpath+ImageName+'.fits', /silent)
ImagCbSz = size(ImagCube, /dimensions)
;c hack coming up
if n_elements(ImagCbSz) eq 2 then ImagCbSz = [ImagCbSz, 1]
;c loading fiter order
ImagData = rd_tfile(Imgpath+ImageName+'.dat', /auto, /nocomment)
ImagDtSz = strlen(ImagData)
ImagDtNb = n_elements(ImagData)
;c add check on size of all elements contained in ImagData
ImagInst = strmid(ImagData, strpos(ImagData[0], 'AC')-1, 3)
ImagFltr = strmid(ImagData, ImagDtSz[0]-3, 3)

;----------------------------------------------------------
;c Setting variables
Nbline_s = long(temporary(Nbline_s))
Nbpxls_s = long(temporary(Nbpxls_s))
Fact_pxl = fltarr(5, Nbline_s-Nbpxls_s)
IFValues = fltarr(ImagCbSz[2], Nbline_s-Nbpxls_s)
ijk = long(0)
rlonglat = fltarr(6)
vrtxdata = fltarr(3,3)
nbins = 300
;c Creating structure
 Field_Names = ['TriangleNb', 'PixelIndex', 'NbTriInPxl', $
                'SurfSumInPxl', 'SurfTriInPxl', $
                'Dist_Tri_Obs', 'BestTriResol', $
                'IncAngle', 'EmiAngle', 'PhiAngle', $
                'Rad_BaryTri', 'Rad_error', $
                'Lon_BaryTri', 'Lon_error', $
                'Lat_BaryTri', 'Lat_error'];, $
 ;d               'FiltersName', 'IonFValues'],$
;d                'FctSlctn', 'FctIndex']
 
 dataset = create_struct(Field_Names, lonarr(Nbline_s-Nbpxls_s),$
                        lonarr(Nbline_s-Nbpxls_s), intarr(Nbline_s-Nbpxls_s),$
                        fltarr(Nbline_s-Nbpxls_s), fltarr(Nbline_s-Nbpxls_s),$
                        fltarr(Nbline_s-Nbpxls_s), fltarr(Nbline_s-Nbpxls_s),$
                        fltarr(Nbline_s-Nbpxls_s), fltarr(Nbline_s-Nbpxls_s),$
                        fltarr(Nbline_s-Nbpxls_s), fltarr(Nbline_s-Nbpxls_s),$
                        fltarr(Nbline_s-Nbpxls_s), fltarr(Nbline_s-Nbpxls_s),$
                        fltarr(Nbline_s-Nbpxls_s), fltarr(Nbline_s-Nbpxls_s),$
                        fltarr(Nbline_s-Nbpxls_s));, ImagInst+'_'+ImagFltr, $
;d                        fltarr(3,Nbline_s-Nbpxls_s), lindgen(nbins), $
;d                        lindgen(nbins) )
;----------------------------------------------------------
print, 'Loading Shape Model.'
cspice_dasopr, dskpath+dskname, handle
cspice_dlabfs, handle, dladsc, found
if ~found then message, "DSK file not found. Exiting" else begin
  cspice_dskz02, handle, dladsc, nv, np
  if (verbose eq "ON") then begin
     print, " > --  Shape model ", dskname," opened.", format='(3A)'
     print, " > --  ", np," facets loaded.", format='(A,I0,A)'
  endif
endelse

print, 'Reading and saving s_file into table.'
openr, lun00, file_s, /Get_lun
while not EOF(lun00) do begin
  pxlx = 1.0  
  pxly = 1.0
  ntri = 1.0
  surf = 1.0
  cmnt = ''
;c reading the line with pixel informations
  readf, lun00, pxlx, pxly, ntri, surf, cmnt
  trimax = fix(ntri)-1
;c reading the line*S* with the triangles informations
  for lmn=0, trimax do begin
     ifct = 1.0
     nfct = ''
     fctr = 1.0
     readf, lun00, ifct, fctr
     if debug eq 1 then print, ifct, fctr 
     Fact_pxl[*,ijk+lmn] = [ifct, (pxlx-1)+(pxly-1)*2048., ntri, surf, fctr]
;c add correspondance with image here
;c Warning Oasis arrays starts at (1,1)
     IFValues[*, ijk+lmn] = ImagCube[pxlx-1, pxly-1, 0:(ImagCbSz[2]-1)]
  endfor
  ijk+=ntri
  print, String(13b), ijk*1.d2/double(Nbline_s-Nbpxls_s), ' %',$ 
         format='(A,X,D9.5,A,$)'
endwhile
print
free_lun, lun00

print, "Ordering s_ originated table."
;c ordering the table and saving it again in the same variable
;c alternate with temporary ?
ordr = sort(Fact_pxl[0,*])
Fact_pxl = temporary(Fact_pxl[*, ordr])
IFValues = temporary(IFValues[*, ordr])
print, "Saving and ordering s_ file done. Associating with g_ file's value"
;c finding the FctIndex of values whose successor in the array is different
;c from itself
Fact_unq = uniq(Fact_pxl[0, *])
Fact_usz = size(Fact_unq, /dimension)

;c finding match in data_g: both arrays are already sorted so let's
;c cut data_g into smaller arrays (ie bins) and looking into the appropriate
;c bin to find the match quicker. 
stp_g = (g_size[1])*1.0/nbins-1
stp_g = long(floor(temporary(stp_g)))
FctIndex = lindgen(nbins, increment=stp_g)
FctSlctn = lindgen(nbins)
FctSlctn = reform(data_g[0, FctIndex])

for opq=0,(Fact_usz[0]-1) do begin
  pltid = Fact_pxl[0, Fact_unq[opq]]
;c computing radius, longitude, latitude of triangle's vertices
  cspice_dski02, handle, dladsc, 9, long(3*(pltid-1)), 3, vrtids
  for opr=0,2 do begin
     start = long((vrtids[opr]-1)*3)
     cspice_dskd02, handle, dladsc, 19, start, 3, vtemp
     cspice_reclat, vtemp, radius, longit, latitd
;c saving radius in km, longitude and latitude in degrees
     vrtxdata[opr,*] = [radius, longit*!RADEG, latitd*!RADEG]
     radius = 0.0
     longit = 0.0
     latitd = 0.0
  endfor

;c saving median position and its std deviation
  rlonglat = [median(vrtxdata[*,0]), stddev(vrtxdata[*,0]), $
              median(vrtxdata[*,1]), stddev(vrtxdata[*,1]), $
              median(vrtxdata[*,2]), stddev(vrtxdata[*,2])]

;c NB there should be only *ONE* match found in data_g
;c comparing the pltid with the FctSlctn segment
  near = min(abs(FctSlctn[*]-pltid), indx)
;c here's where the magic takes place: looking for matches between the facets
;c   selection and the pltid variables and extracting the corresponding
;c   geometric information from the g_ file.
  if (indx eq 0) then $
          codex = where(data_g[0, FctIndex[0]:FctIndex[1]] eq pltid, cnt)

  if ((indx ge 1) and (indx lt (nbins-1))) then begin
     if ((FctSlctn[indx]-pltid) lt 0) then $
        codex = where(data_g[0,FctIndex[indx-1]:FctIndex[indx]] eq pltid, cnt) 
     if ((FctSlctn[indx]-pltid) gt 0) then $
        codex = where(data_g[0,FctIndex[indx]:FctIndex[indx+1]] eq pltid, cnt)
  endif

  if (indx eq (nbins-1)) then $
          codex = where(data_g[0,FctIndex[indx-1]:*] eq pltid, cnt)

;c when a match is found, append the informations of the g_ file and the positions
  if cnt ne 0 then begin
     if (indx eq 0) then rank = FctIndex[0]+codex[0]
     if (indx ge 1) then rank = FctIndex[indx-1]+codex[0]

     if opq eq 0 then begin
;c copying from line 0 to line Fact_unq[0] the contents of all the rows of
;c Fact_pxl and concatenating the rows of matching data_g line.
        dataset.TriangleNb[0:Fact_unq[0]] = Fact_pxl[0,0:Fact_unq[0]]
        dataset.PixelIndex[0:Fact_unq[0]] = Fact_pxl[1,0:Fact_unq[0]]
        dataset.NbTriInPxl[0:Fact_unq[0]] = Fact_pxl[2,0:Fact_unq[0]]
        dataset.SurfSumInPxl[0:Fact_unq[0]] = Fact_pxl[3,0:Fact_unq[0]]
        dataset.SurfTriInPxl[0:Fact_unq[0]] = Fact_pxl[4,0:Fact_unq[0]]
        dataset.Dist_Tri_Obs[0:Fact_unq[0]] = data_g[1,rank]
        dataset.BestTriResol[0:Fact_unq[0]] = data_g[2,rank]
        dataset.IncAngle[0:Fact_unq[0]] = data_g[5,rank]
        dataset.EmiAngle[0:Fact_unq[0]] = data_g[6,rank]
        dataset.PhiAngle[0:Fact_unq[0]] = data_g[7,rank]
        dataset.Rad_BaryTri[0:Fact_unq[0]] = rlonglat[0] 
        dataset.Lon_BaryTri[0:Fact_unq[0]] = rlonglat[2]
        dataset.Lat_BaryTri[0:Fact_unq[0]] = rlonglat[4]
        dataset.Rad_error[0:Fact_unq[0]] = rlonglat[1]
        dataset.Lon_error[0:Fact_unq[0]] = rlonglat[3]
        dataset.Lat_error[0:Fact_unq[0]] = rlonglat[5]
;d        dataset.IonFValues[*,0:Fact_unq[0]] = IFValues[*,0:Fact_unq[0]]
     endif else begin
;c copying from line Fact_unq[opq-1]+1 to line Fact_unq[opq] the contents of
;c all the rows of Fact_pxl and concatenating the rows of matching data_g line.
        dataset.TriangleNb[Fact_unq[opq-1]+1:Fact_unq[opq]] = $
                                   Fact_pxl[0,Fact_unq[opq-1]+1:Fact_unq[opq]]
        dataset.PixelIndex[Fact_unq[opq-1]+1:Fact_unq[opq]] = $
                                   Fact_pxl[1,Fact_unq[opq-1]+1:Fact_unq[opq]]
        dataset.NbTriInPxl[Fact_unq[opq-1]+1:Fact_unq[opq]] = $
                                   Fact_pxl[2,Fact_unq[opq-1]+1:Fact_unq[opq]]
        dataset.SurfSumInPxl[Fact_unq[opq-1]+1:Fact_unq[opq]] = $
                                   Fact_pxl[3,Fact_unq[opq-1]+1:Fact_unq[opq]]
        dataset.SurfTriInPxl[Fact_unq[opq-1]+1:Fact_unq[opq]] = $
                                   Fact_pxl[4,Fact_unq[opq-1]+1:Fact_unq[opq]]
        dataset.Dist_Tri_Obs[Fact_unq[opq-1]+1:Fact_unq[opq]] = data_g[1,rank]
        dataset.BestTriResol[Fact_unq[opq-1]+1:Fact_unq[opq]] = data_g[2,rank]
        dataset.IncAngle[Fact_unq[opq-1]+1:Fact_unq[opq]] = data_g[5,rank]
        dataset.EmiAngle[Fact_unq[opq-1]+1:Fact_unq[opq]] = data_g[6,rank]
        dataset.PhiAngle[Fact_unq[opq-1]+1:Fact_unq[opq]] = data_g[7,rank]
        dataset.Rad_BaryTri[Fact_unq[opq-1]+1:Fact_unq[opq]] = rlonglat[0]
        dataset.Lon_BaryTri[Fact_unq[opq-1]+1:Fact_unq[opq]] = rlonglat[2]
        dataset.Lat_BaryTri[Fact_unq[opq-1]+1:Fact_unq[opq]] = rlonglat[4]
        dataset.Rad_error[Fact_unq[opq-1]+1:Fact_unq[opq]] = rlonglat[1]
        dataset.Lon_error[Fact_unq[opq-1]+1:Fact_unq[opq]] = rlonglat[3]
        dataset.Lat_error[Fact_unq[opq-1]+1:Fact_unq[opq]] = rlonglat[5]
;d        dataset.IonFValues[*,Fact_unq[opq-1]+1:Fact_unq[opq]] = $
;d                                   IFValues[*,Fact_unq[opq-1]+1:Fact_unq[opq]]
     endelse
;  dataset.FctSlctn = FctSlctn 
;  dataset.FctIndex = FctIndex
  endif
;c progression
  print, String(13b), (opq+1.d0)*1.d2/double(Fact_usz[0]), ' %',$
         format='(A,X,D9.5,A,$)'
endfor
print
;----------------------------------------------------------
;c closing spice
cspice_dascls, handle
cspice_kclear
print, 'Concatening achieved. Saving table...'
FileName = ImageName 
nrecords = (Nbline_s-Nbpxls_s)

FileNameID = h5f_create(FileName+'.h5')

loc_id = FileNameID
dset_name = 'test'
table_title = 'Facets Infos'
chunk_size = nrecords / 2
compress = 1

wmb_h5tb_make_table, table_title, $
                     loc_id, $
                     dset_name, $
                     nrecords, $
                     dataset, $
                     chunk_size, $
                     compress, $
                     databuffer = dataset
;c close the file
h5f_close, FileNameID 

;c alternative to IDL save file
;d DescSave = 'Variables contenues:Table_SG, vecteur FctSlctn, FctIndex, ImagInst'$
;d            +', ImagFltr.'
;d save, dataset, $
;d       filename=FileName+'.sav', description=DescSave

end
;==============================================================================
