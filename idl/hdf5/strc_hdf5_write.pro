function strc_hdf5_write, f_id, struct_part, struct_part_name
;===============================================================================
;d PURPOSE:
;d  Script to write the part of a structure into a hdf5 file
;d
;d AUTHOR: 
;d   clement.feller<at>obspm.fr
;d
;d CHANGELOG:
;d   09-Jan-2016: first light
;d
;d I/O :
;d  f_id        -> id of the hdf5 file to write in
;d  struct_part -> the part of the structure to write
;d
;d Dependances: HDF 5 IDL library 
;===============================================================================
 data__type = H5T_IDL_CREATE(struct_part)
 data_space = H5S_CREATE_SIMPLE(size(struct_part, /dimension))
 dataset_id = H5D_CREATE(f_id, struct_part_name, data__type, data_space)
 H5D_WRITE, dataset_id, struct_part

return, 0
end
