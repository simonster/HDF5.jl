load("src/hdf5.jl")
import HDF5.*
#import HDF5

# Create a new file
fn = "/tmp/testA.h5"
fid = h5open(fn, "w+")
# Write scalars
fid["Float64"] = 3.2
fid["Int16"] = int16(4)
# Create arrays of different types
A = randn(3,5)
write(fid, "Afloat64", float64(A))
write(fid, "Vfloat64", float64(randn(10)))
write(fid, "Afloat32", float32(A))
## The following worked, but seemed to affect ability to close files.
# HDF5Attributes(fid["Afloat32"])["hi"] = 3
##
# Group
g = g_create(fid, "mygroup")
# Test dataset with compression
R = randi(20, 200, 400);
g["CompressedA", "chunk", (20,20), "compress", 9] = R
g["Int64"] = 23
close(g)
Ai = randi(20, 2, 4)
write(fid, "Aint8", int8(Ai))
fid["Aint16"] = int16(Ai)
write(fid, "Aint32", int32(Ai))
# Test strings
salut = "Hi there"
write(fid, "salut", salut)
# Empty arrays
empty = Array(Uint32, 0)
write(fid, "empty", empty)
# Attributes
dset = fid["salut"]
label = "This is a string"
dset["typeinfo"] = label
close(dset)
close(fid)


# Read the file back in
fidr = h5open(fn)
fidr | dump
fidr["Aint8"]
fidr["Aint8"][:,:]
fidr["mygroup"]
fidr["mygroup"]["CompressedA"][1:2,1:2]
for (k,v) in fidr
    println("$(k): value len: $(length(v))")
end
keys(fidr)
values(fidr) | dump
has(fidr, "Aint8") 
fidr["Float64"]  # do we want this to return the actual value rather than a reference?
sum(fidr["Vfloat64"])

close(fidr)
