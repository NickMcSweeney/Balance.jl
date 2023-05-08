using Test
using Dates

@testset "test structs" begin
    import Balance.WorkItem
    
    work_item = WorkItem("Fake Company", Dates.today(), 8, "Some Work")
    @test work_item isa WorkItem
end