#############
## Timenum ##
#############

import Base.convert
## to Timedata: conversion upwards - always works
function convert(::Type{Timedata}, tn::Timenum)
    return Timedata(tn.vals, tn.idx)
end

## to Timematr: conversion downwards - fails for NAs
function convert(::Type{Timematr}, tn::Timenum, rmNA = false)
    if rmNA
        tm = narm(tn)
        tm = Timematr(tm.vals, tm.idx)
    else
        tm = Timematr(tn.vals, tn.idx)
    end
    return tm
end

##############
## Timematr ##
##############
    
## to Timedata: conversion upwards - always works
function convert(::Type{Timedata}, tm::Timematr)
    Timedata(tm.vals, tm.idx)
end

## to Timenum: conversion upwards - always works
function convert(::Type{Timenum}, tm::Timematr)
    Timenum(tm.vals, tm.idx)
end


##############
## Timedata ##
##############

## to Timenum: conversion downwards - fails for non-numeric values
function convert(::Type{Timenum}, td::Timedata)
    Timenum(td.vals, td.idx)
end

## to Timematr: conversion downwards - fails for NAs
function convert(::Type{Timematr}, td::Timedata)
    Timematr(td.vals, td.idx)
end

