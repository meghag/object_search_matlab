function compare_random_and_adaptive(dim1,dim2,res,N,horizon)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Each object is assumed to fit within a grid cell.
nrows = dim1/res;
ncols = dim2/res;

% legend_text = cell(length(algo_ids));
% for a = 1:length(algo_ids)
%     legend_text{a} = strcat('Algo ',num2str(algo_ids(a)))
% end
% 
% keyboard

all_indices = [1:nrows*ncols]';

avg_n_iterations = zeros(N-1,2);
avg_n_actions = zeros(N-1,2);
avg_time_taken = zeros(N-1,2);
avg_n_unknown = zeros(N-1,2);

for num_obj = 2:N  
    num_obj
    allStartConfigs = nchoosek(all_indices,num_obj);
    
    %num = size(allStartConfigs,1);
    num = 50;
    
    n_iterations = zeros(num,2);
    n_actions = zeros(num,2);
    time_taken = zeros(num,2);
    n_unknown = zeros(num,2);
    
    %for i = 1:size(allStartConfigs,1)
    for a = 1:2
        a
        for i = 1:num
            i;
            objLocationsIndices = [allStartConfigs(i,:)]';
            
            if (a == 1)
                %Testing object_search2 - explore EVERYTHING
                [n_iterations(i,a),n_actions(i,a),time_taken(i,a),n_unknown(i,a)] = ...
                    adaptive_horizon_search(dim1,dim2,res,objLocationsIndices,1,horizon,0);
            else
                [n_iterations(i,a),n_actions(i,a),time_taken(i,a),n_unknown(i,a)] = ...
                    random_search(dim1,dim2,res,objLocationsIndices,1,horizon,0);
            end
            
            %[~,nsteps_opt,~] = bfs(objLocationsIndices,dim1,dim2,res,1);
            %nsteps_optimal = [nsteps_optimal;nsteps_opt];
        end
    end
    avg_n_iterations(num_obj-1,:) = mean(n_iterations,1);
    avg_n_actions(num_obj-1,:) = mean(n_actions,1);
    avg_time_taken(num_obj-1,:) = mean(time_taken,1);
    avg_n_unknown(num_obj-1,:) = mean(n_unknown,1);
end

color = {[1 0 0],[0 1 0],[0 0 1],[1 0 1],[0 1 1],[0.3 0.6 0.4],...
    [1 1 0],[0.1 0.3 0.3],[0.8 0 0.5],[0.7,0.4,0],[0.1 0.3 0.8],[0 0 0]};

%num = 100;

[avg_n_iterations;avg_n_actions;avg_time_taken;avg_n_unknown]

avg_n_iterations

avg_n_actions

avg_time_taken

avg_n_unknown

plot([2:size(avg_n_actions,1)+1], avg_n_actions(:,2)./avg_n_actions(:,1),...
    'bs-','MarkerSize',10,'LineWidth',2);
xlabel('Number of objects','FontSize',14);
ylabel({'Performance ratio:','Random/Adpative Look-ahead'}, 'FontSize', 14);

% colormap spring;
% 
% plot(avg_n_iterations,'ro-');
% hold on;
% plot(avg_n_actions,
% 
% figure;
% bar([avg_n_iterations;avg_n_actions;avg_time_taken;avg_n_unknown]);
% title({'Comparing Random and Adaptive';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
%            ', Horizon = ',int2str(horizon))});

end

