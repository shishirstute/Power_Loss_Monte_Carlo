function [Fail_Scenario, Representative_Loss, Selected_Loss_Vector] = Scenario_Selection_Setup(Damage_Power, Damage_Line)

    %% scenario selection
    Fail_Scenario = {}; %contains selected scenario
    Representative_Loss = []; %contains loss associated with selected scenario
    Selected_Loss_Vector =[];  % contains loss that is used to select scenario
    Damage_Power1 = num2cell(Damage_Power);

    %1st data contains minimum, then medium then maximum then mean after
    %returning
    %fail scenario for minimum
    Selected_Loss = min(Damage_Power);
   
    [fail_scenario_return, loss_final_return] = scenario_selection(Damage_Power1,... 
       Selected_Loss, Damage_Line);
    
    Fail_Scenario=vertcat(Fail_Scenario,fail_scenario_return); %adding returned scenarios
    Representative_Loss = vertcat(Representative_Loss,loss_final_return); % adding loss
    Selected_Loss_Vector = vertcat(Selected_Loss_Vector,Selected_Loss);
    
    %fail_scenario for median
    Selected_Loss = median(Damage_Power);
    
    [fail_scenario_return, loss_final_return] = scenario_selection(Damage_Power1,...  
       Selected_Loss, Damage_Line);
    
    Fail_Scenario=vertcat(Fail_Scenario,fail_scenario_return); %adding returned scenarios
    Representative_Loss = vertcat(Representative_Loss,loss_final_return);
    Selected_Loss_Vector = vertcat(Selected_Loss_Vector,Selected_Loss);
    
    
    %fail scenario for max
    Selected_Loss = max(Damage_Power);
    
    [fail_scenario_return, loss_final_return] = scenario_selection(Damage_Power1,...  %scenario_selection2 for non zerro type selection
       Selected_Loss, Damage_Line);
    
    Fail_Scenario=vertcat(Fail_Scenario,fail_scenario_return); %adding returned scenarios
    Representative_Loss = vertcat(Representative_Loss,loss_final_return);
    Selected_Loss_Vector = vertcat(Selected_Loss_Vector,Selected_Loss);

    %fail scenario for mean
    Selected_Loss = mean(Damage_Power);
    [fail_scenario_return, loss_final_return] = scenario_selection(Damage_Power1,...  %scenario_selection2 for non zerro type selection
       Selected_Loss, Damage_Line);
    
    Fail_Scenario=vertcat(Fail_Scenario,fail_scenario_return); %adding returned scenarios
    Representative_Loss = vertcat(Representative_Loss,loss_final_return);
    Selected_Loss_Vector = vertcat(Selected_Loss_Vector,Selected_Loss);
end

    
    
  