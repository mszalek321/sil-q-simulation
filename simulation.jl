include("./silq_simulation_functions.jl")

outcomes = ones(100000)
 
function simulation(outcomes)
    Threads.@threads for i in 1:length(outcomes)
        outcome = one_fight(constitution=5,
        melee=22-3+4,
        evasion=23-3+4,
        function_weapon=great_sword,
        strength=3,
        concentration=false,
        perception_concentration=9,
        finess=false,
        power=false,
        subtlety=false,
        smite=true,
        balanced=true,
        function_my_armour=my_armour,
        function_enemy=function_belegwath,
        debug=0)
        outcomes[i] = outcome
    end
    return outcomes
end
 
@time outcomes = simulation(outcomes)
print(sum(outcomes)/length(outcomes))