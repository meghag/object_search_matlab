function [n_iterations,n_actions,n_unknown,time_taken] = ...
    compare_horizon_distribution_alt(dim1,dim2,res,max_N,target_id,max_horizon,plot_flag)
% Given a start config and the algos to be compared, compare performance
% over different horizon lengths.
% Horizon varies from 1 to max_horizon. 

avg_n_iterations = zeros(max_horizon,1);
avg_n_actions = zeros(max_horizon,1);
avg_time_taken = zeros(max_horizon,1);
avg_n_unknown = zeros(max_horizon,1);
avg_horizon_distribution = zeros(max_horizon,1);

all_indices = [1:dim1*dim2]';


%num = min(500, nchoosek(dim1*dim2,N))
num = 10;
horizon = 1;

%allStartConfigs(20,:)

color = {[1 0 0],[0 1 0],[0 0 1],[0.3 0.6 0.4],[1 0 1],[0 1 1],...
    [1 1 0],[0.1 0.3 0.3],[0.8 0 0.5],[0.7,0.4,0],[0.1 0.3 0.8],[0 0 0]};

figure;

for N = 4:max_N
    N
    allStartConfigs = nchoosek(all_indices,N);
    num_explored = zeros(max_horizon,1);
    n_actions_vec = zeros(num,1);
    n_known_vec = zeros(num,1);
    
    for i = 1:num
        i
        objLocationsIndices = [allStartConfigs(i,:)]';
        %explore EVERYTHING with adaptive horizon when needed
        [n_iterations,n_actions,time_taken,n_unknown, horizon_distribution] = ...
            adaptive_horizon_search_alt(dim1, dim2, res, objLocationsIndices, [], target_id, horizon, 0);
        
        %[n_iterations,n_actions,time_taken,n_unknown, ~] = ...
         %   fixed_horizon_search_alt(dim1, dim2, res, objLocationsIndices, [], target_id, horizon,0);
        
        if (n_actions < 1000) 
            num_explored(horizon,1) = num_explored(horizon,1)+1;
        else
            continue;
        end
        n_known_vec(i) = dim1*dim2 - n_unknown;
        n_actions_vec(i) = n_actions;
        
        avg_n_iterations(horizon,1) = avg_n_iterations(horizon,1) + n_iterations;
        avg_n_actions(horizon,1) = avg_n_actions(horizon,1) + n_actions;
        avg_time_taken(horizon,1) = avg_time_taken(horizon,1) + time_taken;
        avg_n_unknown(horizon,1) = avg_n_unknown(horizon,1) + n_unknown;
    end
    plot(n_actions_vec,'o','MarkerSize',10,'LineWidth',2,'MarkerEdgeColor',color{horizon});
    hold on;
    plot(n_known_vec,'x','MarkerSize',10,'LineWidth',2,'MarkerEdgeColor',color{horizon});
    
    avg_n_iterations(horizon,1) = avg_n_iterations(horizon,1)/num_explored(horizon,1)
    avg_n_actions(horizon,1) = avg_n_actions(horizon,1)/num_explored(horizon,1)
    avg_time_taken(horizon,1) = avg_time_taken(horizon,1)/num_explored(horizon,1)
    avg_n_unknown(horizon,1) = avg_n_unknown(horizon,1)/num_explored(horizon,1)
end
hold off;

if (plot_flag == 1)
    figure;
    plot(avg_n_iterations,'ro-','MarkerSize',10,'LineWidth',2);
    hold on;
    plot(avg_n_actions,'bd--','MarkerSize',10,'LineWidth',2);
    plot(avg_n_unknown,'c^-.','MarkerSize',10,'LineWidth',2);
    xlabel('Horizon length');
    xlim([1,max_horizon]);
    
    %legend('Total iterations', 'Total actions','Total time taken','Unobserved Cells','Location','SouthEast');
    legend('Total iterations', 'Total actions', 'Average unknown', 'Location','NorthWest');
    title('Performance vs Horizon length');
    hold off
    
    figure;
    plot(avg_time_taken,'ks--','MarkerSize',10,'LineWidth',2);
    xlabel('Horizon length');
    ylabel('Exploration time');
    xlim([1,max_horizon]);
    title('Exploration time vs Horizon length');
    
    
end

end

