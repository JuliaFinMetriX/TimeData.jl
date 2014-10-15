using Base.Test

@test istrue(true)
@test istrue(false) == false
@test istrue(NA) == false

@test isfalse(false)
@test isfalse(true) == false
@test isfalse(NA) == false

@test isna(true) == false
@test isna(false) == false
@test isna(NA) == true
