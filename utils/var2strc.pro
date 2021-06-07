function typelist, int
 idl_type = ['UNDEFINED', 'BYTE', 'INT', 'LONG', 'FLOAT', 'DOUBLE', 'COMPLEX', 'STRING', $
        'STRUCT', 'DCOMPLEX', 'POINTER', 'OBJREF', 'UINT', 'ULONG', 'LONG64', 'ULONG64']
return, idl_type[int]
end

function var2strc, variable

 vsize = size(variable)
 vtype = typelist(vsize[-2])
 vnelm = visze[-1] 
 vndim = vsize[0]
 dsize = vsize[1:vsize[0]-2]
 
return, {value:variable, type:vtype, ndim:vndim, nelem: vnelm, sdim:dsize}
end
