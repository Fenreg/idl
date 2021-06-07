;==============================================================================
;d NAME: rng_coyote.pro
;d AUTHOR: Clément Feller (cxlfeller--at--gmx<dot>com)
;d PURPOSE: Generate random numbers using Coyote's method, with uniform
;d           distribution between 0 and 1.
;d CHANGELOG: 2021-01-25 v1.0 first light
;d I/O:
;d <- n_pts: (long) integer: number of values to generate
;d <- n_dim: (long) integer: number of dimensions to generate array
;d -> rng  : n_dim*n_pts float array of number
;d
;d USAGE: (example)
;d COMMENTS: (give it a blue thumb)
;d DEPENDANCIES: vIDL>7.1, coyote library
;d NOTES: None
;d COPYRIGHT: CC-BY-NC-ND
;==============================================================================
function rng_coyote, n_pts, n_dim

 if ~keyword_set(n_pts) then message, ' > Error: no number of points provided.'
 if ~keyword_set(n_dim) then n_dim = 1

 DefSysV, '!RNG', Obj_New('RandomNumberGenerator')
 rng = !RNG -> GetRandomNumbers(n_dim, n_pts)

 return, rng
end
