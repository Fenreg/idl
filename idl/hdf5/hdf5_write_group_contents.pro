;==============================================================================
;d NAME: hdf5_write_group_contents.pro
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: write what an HDF5 group contains
;d CHANGELOG: 2019-06-09 v1.0 first light
;d I/O:
;d <- (input)
;d -> (output)
;d
;d USAGE: (example)
;d COMMENTS: (give it a blue thumb)
;d DEPENDANCIES: (compiler version, version of functions used)
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
pro hdf5_write_group_contents, h5_file_id,  $
                               name_subgroup, $
                               data, data_size

 datatype_id = h5t_idl_create(data)
 dataspace_id = h5s_create_simple(data_size)
 dataset_id = h5d_create(h5_file_id, name_subgroup, datatype_id, dataspace_id)
 h5d_write, dataset_id, data
 h5s_close, dataspace_id
 h5t_close, datatype_id

end
