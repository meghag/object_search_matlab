function [n_iterations,n_actions,n_unknown,time_taken] = ...
    compare_diff_horizons(dim1,dim2,res,objLocationsindices,target_id,max_horizon,algo_id,plot_flag)
% Given a start config and the algos to be compared, compare performance
% over different horizon lengths.
% Horizon varies from 1 to max_horizon. 

n_iterations = zeros(max_horizon,1);
n_actions = zeros(max_horizon,1);
time_taken = zeros(max_horizon,1);
n_unknown = zeros(max_horizon,1);

for horizon = 1:max_horizon
    horizon
    if (algo_id == 1)
        %Testing object_search2 - explore EVERYTHING
        [n_iterations(horizon),n_actions(horizon),time_taken(horizon),~] = ...
            adaptive_horizon_search(dim1, dim2, res, objLocationsindices, target_id, horizon,0);
    elseif (algo_id == 2)
        %testing object_search3 - reveal as much as possible
        [n_iterations(horizon),n_actions(horizon),time_taken(horizon),n_unknown(horizon)] = ...
            fixed_horizon_search(dim1, dim2, res, objLocationsindices, target_id, horizon,0);
    elseif (algo_id == 3)
        %testing object_search3 - reveal as much as possible
        [n_iterations(horizon),n_actions(horizon),time_taken(horizon),n_unknown(horizon)] = ...
            adaptive_horizon_search_variant1(dim1, dim2, res, objLocationsindices, target_id, horizon,0);
    elseif (algo_id == 4)
        %testing object_search3 - reveal as much as possible
        [n_iterations(horizon),n_actions(horizon),time_taken(horizon),n_unknown(horizon)] = ...
            adaptive_horizon_search_variant2(dim1, dim2, res, objLocationsindices, target_id, horizon,0);
    elseif (algo_id == 5)
        %testing object_search3 - reveal as much as possible
        [n_iterations(horizon),n_actions(horizon),time_taken(horizon),n_unknown(horizon)] = ...
            fixed_horizon_search_variant1(dim1, dim2, res, objLocationsindices, target_id, horizon,0);
    end
end

if (plot_flag == 1)
    figure;
    plot(n_iterations,'ro-','MarkerSize',10,'LineWidth',2);
    hold on;
    plot(n_actions,'bd:','MarkerSize',10,'LineWidth',2);
    plot(time_taken,'gs--','MarkerSize',10,'LineWidth',2);
    plot(n_unknown,'c^-.','MarkerSize',10,'LineWidth',2);
    xlabel('Horizon length');
    xlim([1,max_horizon]);
    
    legend('Total iterations', 'Total actions','Total time taken','Unobserved Cells','Location','SouthEast');
    title({'Performance vs Horizon length',strcat('Algo',num2str(algo_id))});
    hold off
end

end

