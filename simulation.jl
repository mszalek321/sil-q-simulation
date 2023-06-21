include("./silq_simulation_functions.jl")
 
function simulation(n_outcomes)
    outcomes = ones(n_outcomes)
    Threads.@threads for i in 1:length(outcomes)
        outcome = one_fight(constitution=4,
        melee=10,
        evasion=10,
        dict_weapon=battle_axe_one_hand,
        strength=3,
        concentration=false,
        perception_concentration=0,
        finess=false,
        power=false,
        subtlety=false,
        smite=false,
        balanced=false,
        function_my_armour=my_armour,
        function_enemy=function_orc_skirmisher,
        nocrits=false,
        debug=0)
        outcomes[i] = outcome
    end
    return outcomes
end
 
outcomes = simulation(10000)
print(sum(outcomes)/length(outcomes))