load("src/hdf5.jl")
import HDF5.*
#import HDF5

type TestType
    vec::Vector{Float64}
    i::Int
end

function read(x::HDF5Group, ::Type{TestType})
    vec = read(x, "Vfloat64")
    i = read(x, "Int64")
    TestType(vec, i)
end
function write{F<:HDF5File}(parent::Union(F, HDF5Group{F}), name::ByteString, val::TestType)
    g = g_create(parent, name)
    g["Vfloat64"] = val.vec
    g["Int64"] = val.i
    a_write(g, "julia_type", "TestType")
    close(g)
end

type TestType2
    vec::Vector{Float64}
    i::Int
end

function read(x::HDF5Dataset, ::Type{TestType2})
    vec = x[:]
    i = read(x, "Int64")
    TestType2(vec, i)
end
function write{F<:HDF5File}(parent::Union(F, HDF5Group{F}), name::ByteString, val::TestType2)
    parent[name] = val.vec
    d = d_open(parent, name) 
    a_write(d, "Int64", val.i)
    a_write(d, "julia_type", "TestType2")
    close(d)
end


# Create a new file
fn = "/tmp/testJT.h5"
fid = h5open(fn, "w+")
write(fid, "group1", TestType([1:10]*pi, 999))
write(fid, "ds", TestType2([1:10]/pi, -999))
## # Group
## g = g_create(fid, "group1")
## g["Vfloat64"] = randn(10)
## g["Int64"] = 23
## a = a_write(g, "julia_type", "TestType")
## close(g)
# For default Group read
g = g_create(fid, "group2")
g["Vfloat64"] = randn(10)
g["Int64"] = 2
close(g)
close(fid)

# Read the file back in
fidr = h5open(fn)
fidr | dump
res1 = read(fidr["group1"])
dump(res1)
res2 = fidr["ds"]
dump(res2)
res3 = read(fidr["group2"])
dump(res3)
close(fidr)
