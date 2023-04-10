function rand_dx(x)
    rn = rand()
    breaks = [1/x: 01/x: 1;]
    for (index, break_) in enumerate(breaks)
        if rn < break_
            return index
        end
    end
end
 
function rand_ydx(y, x)
    return_list = ones(Int64(y))
    for (index, element) in enumerate(return_list)
        damage_roll = rand_dx(x)
        return_list[index] = damage_roll
    end
    sum_rolls = sum(return_list)
    return sum(return_list)
end
 
function rand_smite(y, x)
    return_list = ones(Int64(y))
    for (index, element) in enumerate(return_list)
        return_list[index] = x
    end
    return sum(return_list)
end
 
function sum_roll(to_hit, to_avoid)
    roll_hit=rand_dx(20)
    roll_avoid=rand_dx(20)
    sum_roll = (roll_hit+to_hit) - (roll_avoid+to_avoid)
    return sum_roll
end
 
function one_hit(to_hit, to_avoid, weight, balanced)
    
    sumroll = sum_roll(to_hit, to_avoid)
    
    if sumroll<0 && balanced==false
        bonus_dice=-1
    elseif sumroll<0 && balanced==true
        sumroll = sum_roll(to_hit, to_avoid)
        if sumroll<=0
            bonus_dice=-1
        else
            bonus_dice = floor(sumroll/(7+weight))
        end
    else
        bonus_dice = floor(sumroll/(7+weight))
    end
    return bonus_dice
end
 
function one_round(to_hit, to_avoid, weight, dice, damage, armour, smite, balanced, sharpness = 0)
    bonus_dice = one_hit(to_hit, to_avoid, weight, balanced)
 
    if bonus_dice >= 0 && smite == false
        total_damage = rand_ydx((dice+bonus_dice), damage)
    elseif bonus_dice >=0 && smite == true
        total_damage = rand_smite((dice+bonus_dice), damage)
    else
        total_damage = 0
    end
    total_damage = max(total_damage, 0)
    total_damage = total_damage-(armour*(1-sharpness))
    total_damage = max(total_damage, 0)
    return total_damage, bonus_dice
end

function calculate_hp(constitution)
    hp = floor(20*(1.2)^constitution)
    return hp
end

function function_belegwath(field)
    if field == "health"
        return rand_ydx(36,4)
    elseif field == "to_avoid"
        return 17
    elseif field == "armour"
        return rand_ydx(4, 4)
    elseif field == "attack"
        if rand()<0.5
            to_hit_enemy = 22
            enemy_dice = 3
            enemy_damage_total = 14
        else
            to_hit_enemy = 18
            enemy_dice = 3
            enemy_damage_total = 8
        end
        return to_hit_enemy, enemy_dice, enemy_damage_total
    elseif field == "name"
        return "Belegwath, Balrog of Shadow"
    end
end

function my_armour(field)
    if field == "armour"
        return rand_ydx(1,7)+rand_ydx(1,3)+rand_ydx(1,2)+1
    elseif field == "to_avoid"
        return (-1+2-2)
    end
end

function great_sword(field)
    if field=="to_avoid"
        return 1
    elseif field=="to_hit"
        return -1
    elseif field=="weapon_weigh"
        return 6
    elseif field=="weapon_dice"
        return 3
    elseif field=="weapon_damage"
        return 5
    end
end
    
 
function one_fight(;constitution,
                   strength,
                   dexterity,
                   grace,
                   melee,
                   evasion,
                   function_weapon,
                   concentration,
                   perception_concentration,
                   finess,
                   power,
                   subtlety,
                   smite,
                   balanced,
                   function_my_armour,
                   function_enemy,
                   debug=0)
    
    my_name = "Antar"

    to_hit_mine=melee+function_weapon("to_hit")
    to_avoid_mine=evasion+function_weapon("to_avoid")+function_my_armour("to_avoid")

    health_mine = calculate_hp(constitution)
    max_hp = health_mine
    base_strength=strength
    base_grace=grace

    weapon_dice=function_weapon("weapon_dice")
    weapon_weight=function_weapon("weapon_weigh")
    weapon_damage=function_weapon("weapon_damage")
    
    if finess==true
        weapon_weight=weapon_weight-2
    end
    if (finess==true && subtlety==true)
        weapon_weight=weapon_weight-2
    end

    if power==true
        weapon_weight=weapon_weight+1
        strength=strength+1
    end

    health_enemy = function_enemy("health")
    to_avoid_enemy = function_enemy("to_avoid")
    enemy_name = function_enemy("name")
    
    round = 0
    

    while true
        max_concentration = floor(perception_concentration/2)
        if concentration==true
            concentration_bonus=min(round, max_concentration)
        else
            concentration_bonus=0
        end

        armour_mine = function_my_armour("armour")
        armour_enemy = function_enemy("armour")

        weapon_damage_total = min(strength, weapon_weight)+weapon_damage
        
        (my_hit, bonus_dice) = one_round(to_hit_mine+concentration_bonus,
                           to_avoid_enemy,
                           weapon_weight,
                           weapon_dice,
                           weapon_damage_total,
                           armour_enemy,
                           smite,
                           balanced)
 
        
        crit_exclamations = "!"^Int64(max(bonus_dice, 0))
        
        health_enemy = health_enemy-my_hit
        print("$my_name hit $enemy_name for $my_hit damage$crit_exclamations  left $health_enemy  enemy HP\n"^debug)
        if health_enemy<=0
            print("$my_name wins!\n"^debug)
            return 1
        end      
 
        if smite==true
            num_turn=2
        else
            num_turn=1
        end

        for _ in 1:num_turn
            to_hit_enemy, enemy_dice, enemy_damage_total = function_enemy("attack")
            
            (enemy_hit, bonus_dice) = one_round(to_hit_enemy,
                                  to_avoid_mine,
                                  0,
                                  enemy_dice,
                                  enemy_damage_total,
                                  armour_mine,
                                  false,
                                  false)

            crit_exclamations = "!"^Int64(max(bonus_dice, 0))

            
            health_mine = health_mine-enemy_hit
            print("$enemy_name hit $my_name for $enemy_hit damage$crit_exclamations left $health_mine  enemy HP\n"^debug)

            
            if health_mine<=0
                print("$enemy_name wins!\n"^debug)
                return 0
            end
        end
        round=round+1
    end
end
 