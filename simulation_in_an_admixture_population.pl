#!/usr/bin/perl -w
use strict;
use Data::Dumper;

print STDERR "     ######################################################################\n";
print STDERR "     #                                                                    #\n";
print STDERR "     #                        Society, version 1.0                        #\n";
print STDERR "     #                                                                    #\n";
print STDERR "     #       Copyright (C) 2018 Libing Shen <steveshen79\@gmail.com>      #\n";
print STDERR "     #                                                                    #\n";
print STDERR "     #    This program simulates different individuals using different    #\n";
print STDERR "     #         strategies (mentalities) to compete within a group         #\n";
print STDERR "     #           under the framework of the prisoner's dilemma.           #\n";
print STDERR "     #                                                                    #\n";
print STDERR "     ######################################################################\n\n";

my %num;

$num{always_cooperate} = 5;
$num{always_defect} = 5;
$num{always_trembling} = 5;
$num{tit_for_tat} = 5;
$num{generous_TFT} = 5;
$num{TFT_with_trembling_hand} = 5;
$num{shame_driven_hiding} = 5;
$num{shame_driven_denying} = 5;
$num{guilt_driven_amending} = 5;
$num{Pavlov} = 5;

my $population_size;

foreach my $num (values %num){
    
    $population_size += $num;
}

my $error_rate = 0.4;

my $benefit = 1;
my $cost = 0.25;

my $probability_of_forgiveness = ($benefit-$cost)/$benefit;

print STDERR "The population size for this simulation is: $population_size \n";
print STDERR "The error rate for this simulation is: $error_rate \n";
print STDERR "The benefit of donation game is: $benefit \n";
print STDERR "The cost of donation game is: $cost \n";

my $simulation_iteration = 100;
my $num_of_round_for_each_player = 200;

my %game_average_fitness = ( # The number of individuals for each strategy.
    "always_cooperate" => 0,
    "always_defect" => 0,  
    "always_trembling" => 0,
    "tit_for_tat" => 0,
    "generous_TFT" => 0,
    "TFT_with_trembling_hand" => 0,
    "shame_driven_hiding" => 0,
    "shame_driven_denying" => 0,
    "guilt_driven_amending" => 0,
    "Pavlov" => 0,
);

for (my $j = 0; $j < $simulation_iteration; $j++){ #use $j instead of $i here.
    
    my @player;
    
    my $player_ref =\@player;
    
    ($player_ref, $num{always_cooperate}, $num{always_defect}, $num{always_trembling}, $num{tit_for_tat}, $num{TFT_with_trembling_hand}, $num{shame_driven_hiding}, $num{shame_driven_denying}, $num{guilt_driven_amending}, $num{Pavlov}, $num{generous_TFT}) = puppet_maker ($player_ref, $num{always_cooperate}, $num{always_defect}, $num{always_trembling}, $num{tit_for_tat}, $num{TFT_with_trembling_hand}, $num{shame_driven_hiding}, $num{shame_driven_denying}, $num{guilt_driven_amending}, $num{Pavlov}, $num{generous_TFT});
    #print Dumper (@player);
    
    foreach my $player (@player){
        
        my @opponent; #It is a mirror array of @player.
        
        my $opponent_ref =\@opponent;
        
        ($opponent_ref, $num{always_cooperate}, $num{always_defect}, $num{always_trembling}, $num{tit_for_tat}, $num{TFT_with_trembling_hand}, $num{shame_driven_hiding}, $num{shame_driven_denying}, $num{guilt_driven_amending}, $num{Pavlov}, $num{generous_TFT}) = puppet_maker ($opponent_ref, $num{always_cooperate}, $num{always_defect}, $num{always_trembling}, $num{tit_for_tat}, $num{TFT_with_trembling_hand}, $num{shame_driven_hiding}, $num{shame_driven_denying}, $num{guilt_driven_amending}, $num{Pavlov}, $num{generous_TFT});
        
        my $cannot_play_with_oneself;
        
        for (my $i = 0; $i< scalar(@opponent); $i++){
            
            if ($player->{name} eq $opponent[$i]->{name}){
                
                $cannot_play_with_oneself = $i;
            }
        }
        
        splice (@opponent, $cannot_play_with_oneself, 1); #Remove player from opponent pool.
        
        my @player_error;
        my @opponent_error;
        
        my $player_error_ref = \@player_error;
        my $opponent_error_ref = \@opponent_error;
        
        ($player_error_ref, $opponent_error_ref, $num_of_round_for_each_player, $error_rate) = error_round_generator ($player_error_ref, $opponent_error_ref, $num_of_round_for_each_player, $error_rate); #Generate errors for TFT_with_trembling_hand and self_conscious.
        
        for (my $round = $num_of_round_for_each_player; $round > 0; $round--){
            
            my @backup_opponent = @opponent; #If opponent's hiding fails, use backup opponent.
            
            for (my $i = 0; $i < scalar(@opponent); $i++){
                
                if ($opponent[$i]->{character} eq "shame_driven_hiding"){
                    
                    foreach my $name (@{$opponent[$i]->{self_conscious}}){ 
                        
                        if ($name eq $player->{name}){
                            
                            splice (@opponent, $i, 1); #shame_driven_hiding opponent chooses to hide.
                        }
                    }
                }
            }
            
            my $num_of_opponent = scalar (@opponent);
            
            if ($num_of_opponent != 0){
                
                @opponent = @opponent;
                
            } else{
                
                @opponent = @backup_opponent;
            }
            
            my $opponent;
            
            my $player_moral_decision;
            my $opponent_moral_decision;
            
            if ($player->{character} eq "shame_driven_hiding"){
                
                ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision) = shame_driven_hiding_moral_decision ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision);
                
            } elsif ($player->{character} eq "shame_driven_denying"){
                
                ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision) = shame_driven_denying_moral_decision ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision);
                
            } elsif ($player->{character} eq "guilt_driven_amending"){
                
                ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision) = guilt_driven_amending_moral_decision ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision);
                
            } else{
                
                my $potential_opponent = $opponent[rand @opponent];
                
                if ($potential_opponent->{character} eq "shame_driven_hiding" || $potential_opponent->{character} eq "shame_driven_denying"){
                    
                    foreach my $name (@{$potential_opponent->{self_conscious}}){ #Shame_prone opponent uses an antagonistic strategy.
                        
                        if ($name eq $player->{name}){
                            
                            $opponent_moral_decision = 0;
                        }
                    }
                    
                    $opponent = $potential_opponent;
                 
                } elsif ($potential_opponent->{character} eq "guilt_driven_amending"){
                    
                    foreach my $name (@{$potential_opponent->{self_conscious}}){ #guilt_driven_amending opponent uses a conciliatory strategy.
                        
                        if ($name eq $player->{name}){
                            
                            $opponent_moral_decision = 1;
                        }
                    }
                    
                    $opponent = $potential_opponent;
                    
                } else{
                    
                    $opponent = $potential_opponent;
                }
            }
            
            my $choice_one; #game_choice_for_player.
            my $choice_two; #game_choice_for_opponent.
            
            my $player_cooperate_name = 0;
            my $player_defect_name = 0;
            
            my $opponent_cooperate_name = 0;
            my $opponent_defect_name = 0;
            
            my $player_error = 0;
            my $opponent_error = 0;
            
            foreach my $error (@player_error){
                
                if ($error == $round){
                    
                    $player_error++;
                }
            }
            
            foreach my $error (@opponent_error){
                
                if ($error == $round){
                    
                    $opponent_error++;
                }
            }
            
            ($player, $opponent->{name}, $choice_one, $player_cooperate_name, $player_defect_name, $player_error, $player_moral_decision, $probability_of_forgiveness) = different_strategy ($player, $opponent->{name}, $choice_one, $player_cooperate_name, $player_defect_name, $player_error, $player_moral_decision, $probability_of_forgiveness);
            ($opponent, $player->{name}, $choice_two, $opponent_cooperate_name, $opponent_defect_name, $opponent_error, $opponent_moral_decision, $probability_of_forgiveness) = different_strategy ($opponent, $player->{name}, $choice_two, $opponent_cooperate_name, $opponent_defect_name, $opponent_error, $opponent_moral_decision, $probability_of_forgiveness);
            
            ($choice_one, $choice_two, $player->{fitness}, $opponent->{fitness}, $player->{round}, $opponent->{round}) = game_payoff ($choice_one, $choice_two, $player->{fitness}, $opponent->{fitness}, $player->{round}, $opponent->{round});
            
            ($player, $opponent->{name}, $choice_one, $choice_two, $player_cooperate_name, $player_defect_name, $player_moral_decision) = after_game_memory ($player, $opponent->{name}, $choice_one, $choice_two, $player_cooperate_name, $player_defect_name, $player_moral_decision);
            ($opponent, $player->{name}, $choice_two, $choice_one, $opponent_cooperate_name, $opponent_defect_name, $opponent_moral_decision) = after_game_memory ($opponent, $player->{name}, $choice_two, $choice_one, $opponent_cooperate_name, $opponent_defect_name, $opponent_moral_decision);
            
            #print Dumper ($player);
        }
        
        #print Dumper ($player);
    }
    
    my $num_of_always_cooperate = 0;
    my $num_of_always_defect = 0;
    my $num_of_always_trembling = 0;
    my $num_of_tit_for_tat = 0;
    my $num_of_generous_TFT = 0;
    my $num_of_TFT_with_trembling_hand = 0;
    my $num_of_shame_driven_hiding = 0;
    my $num_of_shame_driven_denying = 0;
    my $num_of_guilt_driven_amending = 0;
    my $num_of_Pavlov = 0;
    
    my $average_fitness_of_always_cooperate = 0;
    my $average_fitness_of_always_defect = 0;
    my $average_fitness_of_always_trembling = 0;
    my $average_fitness_of_tit_for_tat = 0;
    my $average_fitness_of_generous_TFT = 0;
    my $average_fitness_of_TFT_with_trembling_hand = 0;
    my $average_fitness_of_shame_driven_hiding = 0;
    my $average_fitness_of_shame_driven_denying = 0;
    my $average_fitness_of_guilt_driven_amending = 0;
    my $average_fitness_of_Pavlov = 0;
    
    foreach my $player (@player){
        
        if ($player->{character} eq "always_cooperate" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_always_cooperate++;
            $average_fitness_of_always_cooperate += $player->{fitness};
        }
        
        if ($player->{character} eq "always_defect" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_always_defect++;
            $average_fitness_of_always_defect += $player->{fitness};
        }
        
        if ($player->{character} eq "always_trembling" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_always_trembling++;
            $average_fitness_of_always_trembling += $player->{fitness};
        }
        
        if ($player->{character} eq "tit_for_tat" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_tit_for_tat++;
            $average_fitness_of_tit_for_tat += $player->{fitness};
        }
        
        if ($player->{character} eq "TFT_with_trembling_hand" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_TFT_with_trembling_hand++;
            $average_fitness_of_TFT_with_trembling_hand += $player->{fitness};
        }
        
        if ($player->{character} eq "shame_driven_hiding" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_shame_driven_hiding++;
            $average_fitness_of_shame_driven_hiding += $player->{fitness};
        }
        
        if ($player->{character} eq "shame_driven_denying" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_shame_driven_denying++;
            $average_fitness_of_shame_driven_denying += $player->{fitness};
        }
        
        if ($player->{character} eq "guilt_driven_amending" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_guilt_driven_amending++;
            $average_fitness_of_guilt_driven_amending += $player->{fitness};
        }
        
        if ($player->{character} eq "Pavlov" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_Pavlov++;
            $average_fitness_of_Pavlov += $player->{fitness};
        }
        
        if ($player->{character} eq "generous_TFT" && $player->{round} == $num_of_round_for_each_player){
            
            $num_of_generous_TFT++;
            $average_fitness_of_generous_TFT += $player->{fitness};
        }
    }

    if ($num_of_always_cooperate != 0){
        
        $average_fitness_of_always_cooperate = $average_fitness_of_always_cooperate/$num_of_always_cooperate;
    }
    
    if ($num_of_always_defect != 0){
        
        $average_fitness_of_always_defect = $average_fitness_of_always_defect/$num_of_always_defect;
    }
    
    if ($num_of_always_trembling != 0){
        
        $average_fitness_of_always_trembling = $average_fitness_of_always_trembling/$num_of_always_trembling;
    }
    
    if ($num_of_tit_for_tat != 0){
        
        $average_fitness_of_tit_for_tat = $average_fitness_of_tit_for_tat/$num_of_tit_for_tat;
    }
    
    if ($num_of_TFT_with_trembling_hand != 0){
        
        $average_fitness_of_TFT_with_trembling_hand = $average_fitness_of_TFT_with_trembling_hand/$num_of_TFT_with_trembling_hand;
    }
    
    if ($num_of_shame_driven_hiding != 0){
        
        $average_fitness_of_shame_driven_hiding = $average_fitness_of_shame_driven_hiding/$num_of_shame_driven_hiding;
    }
    
    if ($num_of_shame_driven_denying != 0){
        
        $average_fitness_of_shame_driven_denying = $average_fitness_of_shame_driven_denying/$num_of_shame_driven_denying;
    }
    
    if ($num_of_guilt_driven_amending != 0){
        
        $average_fitness_of_guilt_driven_amending = $average_fitness_of_guilt_driven_amending/$num_of_guilt_driven_amending;
    }

    if ($num_of_Pavlov != 0){
        
        $average_fitness_of_Pavlov = $average_fitness_of_Pavlov/$num_of_Pavlov;
    }
    
    if ($num_of_generous_TFT != 0){
        
        $average_fitness_of_generous_TFT = $average_fitness_of_generous_TFT/$num_of_generous_TFT;
    }

    $game_average_fitness{always_cooperate} += $average_fitness_of_always_cooperate;
    $game_average_fitness{always_defect} += $average_fitness_of_always_defect;
    $game_average_fitness{always_trembling} += $average_fitness_of_always_trembling;
    $game_average_fitness{tit_for_tat} += $average_fitness_of_tit_for_tat;
    $game_average_fitness{TFT_with_trembling_hand} += $average_fitness_of_TFT_with_trembling_hand;
    $game_average_fitness{shame_driven_hiding} += $average_fitness_of_shame_driven_hiding;
    $game_average_fitness{shame_driven_denying} += $average_fitness_of_shame_driven_denying;
    $game_average_fitness{guilt_driven_amending} += $average_fitness_of_guilt_driven_amending;
    $game_average_fitness{Pavlov} += $average_fitness_of_Pavlov;
    $game_average_fitness{generous_TFT} += $average_fitness_of_generous_TFT;
}

$game_average_fitness{always_cooperate}= $game_average_fitness{always_cooperate}/$simulation_iteration;
$game_average_fitness{always_defect}= $game_average_fitness{always_defect}/$simulation_iteration;
$game_average_fitness{always_trembling}= $game_average_fitness{always_trembling}/$simulation_iteration;
$game_average_fitness{tit_for_tat} = $game_average_fitness{tit_for_tat}/$simulation_iteration;
$game_average_fitness{TFT_with_trembling_hand} = $game_average_fitness{TFT_with_trembling_hand}/$simulation_iteration;
$game_average_fitness{shame_driven_hiding} = $game_average_fitness{shame_driven_hiding}/$simulation_iteration;
$game_average_fitness{shame_driven_denying} = $game_average_fitness{shame_driven_denying}/$simulation_iteration;
$game_average_fitness{guilt_driven_amending} = $game_average_fitness{guilt_driven_amending}/$simulation_iteration;
$game_average_fitness{Pavlov} = $game_average_fitness{Pavlov}/$simulation_iteration;
$game_average_fitness{generous_TFT} = $game_average_fitness{generous_TFT}/$simulation_iteration;

my $output_file = "simulation_result.txt";

my $OUTPUT_FILE_HANDLE;

open ($OUTPUT_FILE_HANDLE, ">$output_file") || die $!;

print $OUTPUT_FILE_HANDLE "strategy"."\t"."num of individuals"."\t"."average fitness payoff"."\n";
print $OUTPUT_FILE_HANDLE "always_cooperate"."\t".$num{always_cooperate}."\t".$game_average_fitness{always_cooperate}."\n";
print $OUTPUT_FILE_HANDLE "always_defect"."\t".$num{always_defect}."\t".$game_average_fitness{always_defect}."\n";
print $OUTPUT_FILE_HANDLE "always_trembling"."\t".$num{always_trembling}."\t".$game_average_fitness{always_trembling}."\n";
print $OUTPUT_FILE_HANDLE "tit_for_tat"."\t".$num{tit_for_tat}."\t".$game_average_fitness{tit_for_tat}."\n";
print $OUTPUT_FILE_HANDLE "generous_TFT"."\t".$num{generous_TFT}."\t".$game_average_fitness{generous_TFT}."\n";
print $OUTPUT_FILE_HANDLE "TFT_with_trembling_hand"."\t".$num{TFT_with_trembling_hand}."\t".$game_average_fitness{TFT_with_trembling_hand}."\n";
print $OUTPUT_FILE_HANDLE "shame_driven_hiding"."\t".$num{shame_driven_hiding}."\t".$game_average_fitness{shame_driven_hiding}."\n";
print $OUTPUT_FILE_HANDLE "shame_driven_denying"."\t".$num{shame_driven_denying}."\t".$game_average_fitness{shame_driven_denying}."\n";
print $OUTPUT_FILE_HANDLE "guilt_driven_amending"."\t".$num{guilt_driven_amending}."\t".$game_average_fitness{guilt_driven_amending}."\n";
print $OUTPUT_FILE_HANDLE "Pavlov"."\t".$num{Pavlov}."\t".$game_average_fitness{Pavlov}."\n";

close $OUTPUT_FILE_HANDLE;

exit;

sub puppet_maker {
    
    my ($puppet, $always_co_num, $always_de_num, $always_tr_num, $TFT_num, $TFT_with_tr_num, $shame_pro_h_num, $shame_pro_d_num, $guilt_pro_num, $Pavlov_num, $generous_TFT_num) = @_;
    
    my $population_size = $always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num + $shame_pro_d_num + $guilt_pro_num + $Pavlov_num + $generous_TFT_num;
    
    for (my $i = 0; $i < $population_size; $i++){
        
        my $fitness = 0;
        my $round = 0;
        
        my $character = "always_cooperate"; # By default, all players are not selfish.
        
        my @cooperate;
        my @defect;
        my @self_conscious;
        
        my $cooperate = \@cooperate;
        my $defect = \@defect;
        my $self_conscious = \@self_conscious;
        
        my %array_element = (
            "name" => "$i",
            "fitness" => $fitness,
            "character" => "$character",
            "cooperate" => $cooperate,
            "defect" => $defect,
            "self_conscious" => $self_conscious,
            "round" => $round,
        );
        
        my $hash_ref = \%array_element;
        
        push (@{$puppet}, $hash_ref);
    }
    
    for (my $i = 0; $i < $always_co_num; $i++){
        
        ${$puppet}[$i]->{character} = "always_cooperate";
    }
    
    for (my $i = $always_co_num; $i < ($always_co_num + $always_de_num); $i++){
        
        ${$puppet}[$i]->{character} = "always_defect";
    }
    
    for (my $i = ($always_co_num + $always_de_num); $i < ($always_co_num + $always_de_num + $always_tr_num); $i++){
        
        ${$puppet}[$i]->{character} = "always_trembling";
    }
    
    for (my $i = ($always_co_num + $always_de_num + $always_tr_num); $i < ($always_co_num + $always_de_num + $always_tr_num + $TFT_num); $i++){
     
        ${$puppet}[$i]->{character} = "tit_for_tat";
    }
    
    for (my $i = ($always_co_num + $always_de_num + $always_tr_num + $TFT_num); $i < ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num); $i++){
     
        ${$puppet}[$i]->{character} = "TFT_with_trembling_hand";
    }
    
    for (my $i = ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num); $i < ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num); $i++){
        
        ${$puppet}[$i]->{character} = "shame_driven_hiding";
    }
    
    for (my $i = ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num); $i < ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num + $shame_pro_d_num); $i++){
        
        ${$puppet}[$i]->{character} = "shame_driven_denying";
    }
    
    for (my $i = ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num + $shame_pro_d_num); $i < ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num + $shame_pro_d_num + $guilt_pro_num); $i++){
        
        ${$puppet}[$i]->{character} = "guilt_driven_amending";
    }
    
    for (my $i = ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num + $shame_pro_d_num + $guilt_pro_num); $i < ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num + $shame_pro_d_num + $guilt_pro_num + $Pavlov_num); $i++){
        
        ${$puppet}[$i]->{character} = "Pavlov";
    }
    
    for (my $i = ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num + $shame_pro_d_num + $guilt_pro_num + $Pavlov_num); $i < ($always_co_num + $always_de_num + $always_tr_num + $TFT_num + $TFT_with_tr_num + $shame_pro_h_num + $shame_pro_d_num + $guilt_pro_num + $Pavlov_num + $generous_TFT_num); $i++){
        
        ${$puppet}[$i]->{character} = "generous_TFT";
    }
    
    
    return ($puppet, $always_co_num, $always_de_num, $always_tr_num, $TFT_num, $TFT_with_tr_num, $shame_pro_h_num, $shame_pro_d_num, $guilt_pro_num, $Pavlov_num, $generous_TFT_num);
}

sub error_round_generator {
    
    my ($player_error, $opponent_error, $num_of_round_for_each_player, $error_rate) = @_;
    
    my @round_num;

    for (my $i = $num_of_round_for_each_player; $i > 0; $i--){
        
        push (@round_num, $i);
    }
    
    my @round_num_for_player = @round_num;
    my @round_num_for_opponent = @round_num;
    
    for (my $i = 0; $i < ($error_rate*$num_of_round_for_each_player); $i++){ #This is error generator.
        
        my $error_for_player = $round_num_for_player[rand@round_num_for_player];
        my $error_for_opponent = $round_num_for_opponent[rand@round_num_for_opponent];
        
        push (@{$player_error}, $error_for_player);
        push (@{$opponent_error}, $error_for_opponent);
        
        for (my $j = 0; $j < scalar(@round_num_for_player); $j++){
            
            if ($error_for_player == $round_num_for_player[$j]){
                
                splice (@round_num_for_player, $j, 1);
            }
        }
        
        for (my $k = 0; $k < scalar(@round_num_for_opponent); $k++){
            
            if ($error_for_opponent == $round_num_for_opponent[$k]){
                
                splice (@round_num_for_opponent, $k, 1);
            }
        }
    }
    
    return ($player_error, $opponent_error, $num_of_round_for_each_player, $error_rate);
}

sub shame_driven_hiding_moral_decision {
    
    my ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision) = @_;
    
    my @opponent = @{$opponent_ref};
    
    #print Dumper (@opponent); die;
    
    foreach my $name (@{$player->{self_conscious}}){
        
        for (my $i = 0; $i < scalar(@opponent); $i++){
            
            if ($name eq $opponent[$i]->{name}){
                
                splice (@opponent, $i, 1); #shame_driven_hiding player chooses to hide.
            }
        }
    }
    
    my $num_of_opponent = scalar (@opponent);
    
    if ($num_of_opponent != 0){
        
        my $potential_opponent = $opponent[rand @opponent];
        
        if ($potential_opponent->{character} eq "shame_driven_hiding" || $potential_opponent->{character} eq "shame_driven_denying"){
            
            foreach my $name (@{$potential_opponent->{self_conscious}}){ #Shame_prone opponent uses an antagonistic strategy.
                
                if ($name eq $player->{name}){
                    
                    $opponent_moral_decision = 0;
                }
            }
            
            $opponent = $potential_opponent;
            
        } elsif ($potential_opponent->{character} eq "guilt_driven_amending"){
            
            foreach my $name (@{$potential_opponent->{self_conscious}}){ #guilt_driven_amending opponent uses a conciliatory strategy.
                
                if ($name eq $player->{name}){ 
                    
                    $opponent_moral_decision = 1;
                }
            }
            
            $opponent = $potential_opponent;
            
        } else{
            
            $opponent = $potential_opponent;
        }
        
    } else{
        
        my @new_opponent = @{$opponent_ref};
        
        $opponent = $new_opponent[rand @new_opponent];
        
        $player_moral_decision = 0; #shame_driven_hiding player runs out of opponents and begins to use an antagonistic (denying) strategy.
    }
    
    return ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision);
}

sub shame_driven_denying_moral_decision {
    
    my ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision) = @_;
    
    my @opponent = @{$opponent_ref};
    
    $opponent = $opponent[rand @opponent];
    
    if ($opponent->{character} eq "shame_driven_hiding" || $opponent->{character} eq "shame_driven_denying"){
        
        foreach my $name (@{$opponent->{self_conscious}}){ #Shame_prone opponent uses an antagonistic strategy.
            
            if ($name eq $player->{name}){
                
                $opponent_moral_decision = 0;
            }
        }
        
    } elsif ($opponent->{character} eq "guilt_driven_amending"){
        
        foreach my $name (@{$opponent->{self_conscious}}){ #guilt_driven_amending opponent uses a conciliatory strategy.
            
            if ($name eq $player->{name}){ 
                
                $opponent_moral_decision = 1;
            }
        }
    }
    
    foreach my $name (@{$player->{self_conscious}}){
        
        if ($name eq $opponent->{name}){
            
            $player_moral_decision = 0; #shame_driven_denying player uses an antagonistic strategy.
        }
    }
    
    return ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision);
}

sub guilt_driven_amending_moral_decision {
    
    my ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision) = @_;
    
    my @opponent = @{$opponent_ref};
    
    $opponent = $opponent[rand @opponent];
    
    foreach my $name (@{$player->{self_conscious}}){
        
        if ($name eq  $opponent->{name}){
            
            $player_moral_decision = 1; #guilt_driven_amending player uses a conciliatory strategy.
        }
    }
    
    if ($opponent->{character} eq "shame_driven_hiding" || $opponent->{character} eq "shame_driven_denying"){
        
        foreach my $name (@{$opponent->{self_conscious}}){ #Shame_prone opponent uses an antagonistic strategy.
            
            if ($name eq $player->{name}){ 
                
                $opponent_moral_decision = 0;
            }
        }
        
    } elsif ($opponent->{character} eq "guilt_driven_amending"){
        
        foreach my $name (@{$opponent->{self_conscious}}){ #guilt_driven_amending opponent uses a conciliatory strategy.
            
            if ($name eq $player->{name}){ 
                
                $opponent_moral_decision = 1;
            }
        }   
    }
    
    return ($player, $opponent_ref, $opponent, $player_moral_decision, $opponent_moral_decision);
}

sub cooperate_choice {
    
    my ($choice) = @_;
    
    $choice = 1; #1 means cooperation and 0 means defection.
    
    return $choice;
}

sub defect_choice {
    
    my ($choice) = @_;
    
    $choice = 0; #1 means cooperation and 0 means defection.
    
    return $choice;
}

sub random_choice_generator { #This is for always_trembling.
    
    my ($choice) = @_;
    
    my $random_num = int(rand(10));
    
    $choice = $random_num%2;
    
    return $choice;
}

sub different_strategy {
    
    my ($this_player, $its_opponent_name, $its_choice, $this_player_cooperate_name, $this_player_defect_name, $error, $moral_decision, $prob_of_forgiveness) = @_;

    foreach my $name (@{$this_player->{cooperate}}){
        
        if ($name eq $its_opponent_name){
            
            $this_player_cooperate_name++;
        }
    }
    
    foreach my $name (@{$this_player->{defect}}){
        
        if ($name eq $its_opponent_name){
            
            $this_player_defect_name++;
        }
    }
    
    if ($this_player->{character} eq "always_cooperate"){
        
        $its_choice = cooperate_choice($its_choice);
        
    } elsif ($this_player->{character} eq "always_defect"){
        
        $its_choice = defect_choice($its_choice);
        
    } elsif ($this_player->{character} eq "always_trembling"){
        
        $its_choice = random_choice_generator($its_choice);
        
    } elsif ($this_player->{character} eq "TFT_with_trembling_hand" || $this_player->{character} eq "shame_driven_hiding" || $this_player->{character} eq "shame_driven_denying" || $this_player->{character} eq "guilt_driven_amending"){
        
        if (!defined $moral_decision){
            
            if ($error == 0){
                
                if ($this_player_cooperate_name == 0 && $this_player_defect_name == 0){
                    
                    $its_choice = cooperate_choice($its_choice);
                    
                } elsif ($this_player_cooperate_name == 1){
                    
                    $its_choice = cooperate_choice($its_choice);
                    
                } elsif ($this_player_defect_name == 1){
                    
                    $its_choice = defect_choice($its_choice);
                }
                
            } elsif ($error == 1){
                
                $its_choice = defect_choice($its_choice);
            }
            
        } elsif ($moral_decision == 1){
            
            $its_choice = cooperate_choice($its_choice);
            
            my $player_redemption;
            
            for (my $i = 0; $i< scalar(@{$this_player->{self_conscious}}); $i++){
                
                if ($its_opponent_name eq $this_player->{self_conscious}[$i]){
                    
                    $player_redemption = $i;
                }
            }
            
            splice (@{$this_player->{self_conscious}}, $player_redemption, 1);
            
        } elsif ($moral_decision == 0){
            
            $its_choice = defect_choice($its_choice); #No redemption.
        }
        
    } elsif ($this_player->{character} eq "tit_for_tat"){
        
        if ($this_player_cooperate_name == 0 && $this_player_defect_name == 0){
            
            $its_choice = cooperate_choice($its_choice);
            
        } elsif ($this_player_cooperate_name == 1){
            
            $its_choice = cooperate_choice($its_choice);
         
        } elsif ($this_player_defect_name == 1){
            
            $its_choice = defect_choice($its_choice);
        }
        
    } elsif ($this_player->{character} eq "Pavlov"){ #Pavlov player uses a win-stay, lose-switch strategy.
        
        my $Pavlov_cooperate = scalar(@{$this_player->{cooperate}});
        my $Pavlov_defect = scalar(@{$this_player->{defect}});
        
        if ($error == 0){
            
            if ($Pavlov_cooperate == 0 && $Pavlov_defect == 0){
                
                $its_choice = cooperate_choice($its_choice); #Pavlov starts with a cooperation choice.
                
            } elsif ($Pavlov_cooperate == 1 && $Pavlov_defect == 0){
                
                $its_choice = cooperate_choice($its_choice);
                
            } elsif ($Pavlov_cooperate == 0 && $Pavlov_defect == 1){
                
                $its_choice = defect_choice($its_choice);
            }
            
        } elsif ($error == 1){ #If there is an error, Pavlov will reverse its original choice.
            
            if ($Pavlov_cooperate == 0 && $Pavlov_defect == 0){
                
                $its_choice = defect_choice($its_choice); 
                
            } elsif ($Pavlov_cooperate == 1 && $Pavlov_defect == 0){
                
                $its_choice = defect_choice($its_choice);
                
            } elsif ($Pavlov_cooperate == 0 && $Pavlov_defect == 1){
                
                $its_choice = cooperate_choice($its_choice);
            }
        }
        
    } elsif ($this_player->{character} eq "generous_TFT"){
        
        if ($this_player_cooperate_name == 0 && $this_player_defect_name == 0){
            
            $its_choice = cooperate_choice($its_choice);
            
        } elsif ($this_player_cooperate_name == 1){
            
            $its_choice = cooperate_choice($its_choice);
         
        } elsif ($this_player_defect_name == 1){
            
            my $random_num = int(rand(4)); # Generous tit-for-tat player forgives at a certian probability.
            
            if ($prob_of_forgiveness == 0.25){
                
                if ($random_num > 0){
                    
                    $its_choice = defect_choice($its_choice);
                    
                }else{
                    
                    $its_choice = cooperate_choice($its_choice);
                }
                
            } elsif ($prob_of_forgiveness == 0.5){
                
                my $choice = $random_num%2;
                
                if ($choice == 0){
                    
                    $its_choice = defect_choice($its_choice);
                    
                }else{
                    
                    $its_choice = cooperate_choice($its_choice);
                }
                
            } elsif ($prob_of_forgiveness == 0.75){
                
                if ($random_num == 0){
                    
                    $its_choice = defect_choice($its_choice);
                    
                }else{
                    
                    $its_choice = cooperate_choice($its_choice);
                }
            }
        }
    }
    
    return ($this_player, $its_opponent_name, $its_choice, $this_player_cooperate_name, $this_player_defect_name, $error, $moral_decision, $prob_of_forgiveness);
}

sub game_payoff {
    
    my ($choice_1, $choice_2, $player_fitness, $opponent_fitness, $player_round, $opponent_round) = @_;
    
    if ($choice_1 == 1 && $choice_2 == 1){
        
        $player_fitness = $player_fitness + ($benefit - $cost);
        $opponent_fitness = $opponent_fitness + ($benefit - $cost);
        
    } elsif ($choice_1 == 1 && $choice_2 == 0){
        
        $player_fitness = $player_fitness - $cost;
        $opponent_fitness = $opponent_fitness + $benefit;
        
    } elsif ($choice_1 == 0 && $choice_2 == 1){
        
        $player_fitness = $player_fitness + $benefit;
        $opponent_fitness = $opponent_fitness - $cost;
        
    } else{
        
        $player_fitness = $player_fitness;
        $opponent_fitness = $opponent_fitness;
    }
    
    $player_round++;
    $opponent_round++;
    
    return ($choice_1, $choice_2, $player_fitness, $opponent_fitness, $player_round, $opponent_round);
}

sub after_game_memory {
    
    my ($this_player, $its_opponent_name, $its_choice, $its_opponent_choice, $this_player_cooperate_name, $this_player_defect_name, $this_player_moral_decision) = @_;
    
    if ($this_player->{character} eq "tit_for_tat" || $this_player->{character} eq "TFT_with_trembling_hand" || $this_player->{character} eq "shame_driven_hiding" || $this_player->{character} eq "shame_driven_denying" || $this_player->{character} eq "guilt_driven_amending" || $this_player->{character} eq "generous_TFT"){
        
        if (!defined $this_player_moral_decision){
            
            if ($its_choice == 1 && $its_opponent_choice == 1 && $this_player_cooperate_name == 0){
                
                push (@{$this_player->{cooperate}}, $its_opponent_name);
                
            } elsif ($its_choice == 1 && $its_opponent_choice == 0 && $this_player_defect_name == 0){
                
                push (@{$this_player->{defect}}, $its_opponent_name);
                
                my $no_longer_cooperate;
                
                for (my $i = 0; $i< scalar(@{$this_player->{cooperate}}); $i++){
                    
                    if ($its_opponent_name eq ${$this_player->{cooperate}}[$i]){
                        
                        $no_longer_cooperate = $i;
                    }
                }
                
                if (defined $no_longer_cooperate){
                    
                    splice (@{$this_player->{cooperate}}, $no_longer_cooperate, 1); #Error happened, so need to remove its opponent's name from its cooperation memory.
                    
                }
                
            } elsif ($its_choice == 0 && $its_opponent_choice == 1 && $this_player_defect_name == 1){
                
                my $forget;
                
                for (my $i = 0; $i< scalar(@{$this_player->{defect}}); $i++){
                    
                    if ($its_opponent_name eq ${$this_player->{defect}}[$i]){
                        
                        $forget = $i;
                    }
                }
                
                splice (@{$this_player->{defect}}, $forget, 1); #This player forgets and forgives.
                
            } elsif ($this_player->{character} eq "shame_driven_hiding" && $its_choice == 0 && $its_opponent_choice == 1 && $this_player_defect_name == 0){
                
                push (@{$this_player->{self_conscious}}, $its_opponent_name);
                
                my $no_longer_cooperate;
                
                for (my $i = 0; $i< scalar(@{$this_player->{cooperate}}); $i++){
                    
                    if ($its_opponent_name eq ${$this_player->{cooperate}}[$i]){
                        
                        $no_longer_cooperate = $i;
                    }
                }
                
                if (defined $no_longer_cooperate){
                    
                    splice (@{$this_player->{cooperate}}, $no_longer_cooperate, 1); #Error happened. So need to remove its opponent name from its cooperation memory.
                    
                }
                
            } elsif ($this_player->{character} eq "shame_driven_denying" && $its_choice == 0 && $its_opponent_choice == 1 && $this_player_defect_name == 0){
                
                push (@{$this_player->{self_conscious}}, $its_opponent_name);
                
                my $no_longer_cooperate;
                
                for (my $i = 0; $i< scalar(@{$this_player->{cooperate}}); $i++){
                    
                    if ($its_opponent_name eq ${$this_player->{cooperate}}[$i]){
                        
                        $no_longer_cooperate = $i;
                    }
                }
                
                if (defined $no_longer_cooperate){
                    
                    splice (@{$this_player->{cooperate}}, $no_longer_cooperate, 1); #Error happened. So need to remove its opponent name from its cooperation memory.
                    
                }
                
            } elsif ($this_player->{character} eq "guilt_driven_amending" && $its_choice == 0 && $its_opponent_choice == 1 && $this_player_defect_name == 0){
                
                push (@{$this_player->{self_conscious}}, $its_opponent_name);
                
                my $no_longer_cooperate;
                
                for (my $i = 0; $i< scalar(@{$this_player->{cooperate}}); $i++){
                    
                    if ($its_opponent_name eq ${$this_player->{cooperate}}[$i]){
                        
                        $no_longer_cooperate = $i;
                    }
                }
                
                if (defined $no_longer_cooperate){
                    
                    splice (@{$this_player->{cooperate}}, $no_longer_cooperate, 1); #Error happened. So need to remove its opponent name from its cooperation memory.
                }
            }
        }
        
    } elsif ($this_player->{character} eq "Pavlov"){
        
        my $Pavlov_cooperate = scalar (@{$this_player->{cooperate}});
        my $Pavlov_defect = scalar (@{$this_player->{defect}});
        
        if ($its_choice == 1 && $its_opponent_choice == 1){ #Pavlov player wins and stays cooperating.
            
            if ($Pavlov_cooperate == 0 && $Pavlov_defect == 0){
                
                push (@{$this_player->{cooperate}}, "cooperate");
                
            } elsif ($Pavlov_cooperate == 0 && $Pavlov_defect == 1){
                
                splice (@{$this_player->{defect}}, 0, 1);
                push (@{$this_player->{cooperate}}, "cooperate");
            }
            
        } elsif ($its_choice == 0 && $its_opponent_choice == 1){ #Pavlov player wins and stays defecting.
            
            if ($Pavlov_cooperate == 0 && $Pavlov_defect == 0){
                
                push (@{$this_player->{defect}}, "defect");
                
            } elsif ($Pavlov_cooperate == 1 && $Pavlov_defect == 0){
                
                splice (@{$this_player->{cooperate}}, 0, 1);
                push (@{$this_player->{defect}}, "defect");
            }
            
        } elsif ($its_choice == 1 && $its_opponent_choice == 0){ #Pavlov player loses and changes to defect.
            
            if ($Pavlov_cooperate == 0 && $Pavlov_defect == 0){
                
                push (@{$this_player->{defect}}, "defect");
                
            } elsif ($Pavlov_cooperate == 1 && $Pavlov_defect == 0){
                
                splice (@{$this_player->{cooperate}}, 0, 1);
                push (@{$this_player->{defect}}, "defect");   
            }
            
        } elsif ($its_choice == 0 && $its_opponent_choice == 0){ #Pavlov player loses and changes to cooperate.
            
            if ($Pavlov_cooperate == 0 && $Pavlov_defect == 0){
                
                push (@{$this_player->{cooperate}}, "cooperate");
                
            } elsif ($Pavlov_cooperate == 0 && $Pavlov_defect == 1){
                
                splice (@{$this_player->{defect}}, 0, 1);
                push (@{$this_player->{cooperate}}, "cooperate");
            }
        }
    }
    
    return ($this_player, $its_opponent_name, $its_choice, $its_opponent_choice, $this_player_cooperate_name, $this_player_defect_name, $this_player_moral_decision);
}
