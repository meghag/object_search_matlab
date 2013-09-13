function compare_algos(dim1,dim2,res,N,horizon,algo_ids)
% Given the grid size, num of objects, horizon, and the algos to be compared, it
% compares performance for all possible start configs or for the first
% 'num' start configs for just that value of horizon.

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

allStartConfigs = nchoosek(all_indices,N);
% 
% filename = strcat('configs',int2str(dim1),'by',int2str(dim2),'objects',...
%     int2str(N),'horizon',int2str(horizon),'algoid',int2str(algo_id),'.mat')
% save(filename,'allStartConfigs');


n_iterations = zeros(100,length(algo_ids));
n_actions = zeros(100,length(algo_ids));
time_taken = zeros(100,length(algo_ids));
n_unknown = zeros(100,length(algo_ids));

num = size(allStartConfigs,1);

%for i = 1:size(allStartConfigs,1)
for a = 1:length(algo_ids)   
    a
    for i = 1:num
        i;
        objLocationsIndices = [allStartConfigs(i,:)]';
        
        if (algo_ids(a) == 1)
            %Testing object_search2 - explore EVERYTHING
            [n_iterations(i,a),n_actions(i,a),time_taken(i,a),n_unknown(i,a)] = ...
                adaptive_horizon_search(dim1,dim2,res,objLocationsIndices,1,horizon,0);
        elseif (algo_ids(a) == 2)
            %testing object_search3 - reveal as much as possible
            [n_iterations(i,a),n_actions(i,a),time_taken(i,a),n_unknown(i,a)] = ...
                fixed_horizon_search(dim1,dim2,res,objLocationsIndices,1,horizon,0);
        elseif (algo_ids(a) == 3)
            %testing object_search3 - reveal as much as possible
            [n_iterations(i,a),n_actions(i,a),time_taken(i,a),n_unknown(i,a)] = ...
                adaptive_horizon_search_variant1(dim1,dim2,res,objLocationsIndices,1,horizon,0);
        elseif (algo_ids(a) == 4)
            %testing object_search3 - reveal as much as possible
            [n_iterations(i,a),n_actions(i,a),time_taken(i,a),n_unknown(i,a)] = ...
                adaptive_horizon_search_variant2(dim1,dim2,res,objLocationsIndices,1,horizon,0);
        elseif (algo_ids(a) == 5)
            %testing object_search3 - reveal as much as possible
            [n_iterations(i,a),n_actions(i,a),time_taken(i,a),n_unknown(i,a)] = ...
                fixed_horizon_search_variant1(dim1,dim2,res,objLocationsIndices,1,horizon,0);
        end
        
        %[~,nsteps_opt,~] = bfs(objLocationsIndices,dim1,dim2,res,1);
        %nsteps_optimal = [nsteps_optimal;nsteps_opt];
    end
end

color = {[1 0 0],[0 1 0],[0 0 1],[1 0 1],[0 1 1],[0.3 0.6 0.4],...
    [1 1 0],[0.1 0.3 0.3],[0.8 0 0.5],[0.7,0.4,0],[0.1 0.3 0.8],[0 0 0]};

%num = 100;

colormap spring;

figure;
bar(n_iterations(1:num,:));
title({'Number of Iterations';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
           ', Horizon = ',int2str(horizon))});

figure;
bar(n_actions(1:num,:));
title({'Number of Actions';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
             ', Horizon = ',int2str(horizon))});

figure;
bar(n_unknown(1:num,:));
title({'Number of Unknown Cells';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
             ', Horizon = ',int2str(horizon))});

figure;
bar(time_taken(1:num,:));
title({'Time Taken';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
       ', Horizon = ',int2str(horizon))});
   
% figure;
% for a = 1:length(algo_ids) 
%     subplot(length(algo_ids),1,a), plot(n_iterations(:,a),'-s','MarkerFaceColor',color{a});
%     legend(strcat('Algo',num2str(algo_ids(a))));
%     %hold on;
%     if (a == 1)
%         title({'Number of Iterations';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
%             ', Horizon = ',int2str(horizon))})
%     end
% end
% %legend('1','2','3','4','5');
% %hold off;
% 
% figure;
% for a = 1:length(algo_ids) 
%     subplot(length(algo_ids),1,a), plot(n_actions(:,a),'-^','MarkerFaceColor',color{a});
%     %plot(n_actions(:,a),'-o','MarkerFaceColor',color{a});
%     legend(strcat('Algo',num2str(algo_ids(a))));
%     %hold on;
%     if (a == 1)
%         title({'Number of Actions';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
%             ', Horizon = ',int2str(horizon))})
%     end
% end
% 
% figure;
% for a = 1:length(algo_ids) 
%     %plot(n_unknown(:,a),'-d','MarkerFaceColor',color{a});
%     subplot(length(algo_ids),1,a), plot(n_unknown(:,a),'-d','MarkerFaceColor',color{a});
%     %plot(n_actions(:,a),'-o','MarkerFaceColor',color{a});
%     legend(strcat('Algo',num2str(algo_ids(a))));
%     %hold on;
%     if (a == 1)
%         title({'Number of Unknown Cells';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
%             ', Horizon = ',int2str(horizon))})
%     end
% end
% 
% figure;
% for a = 1:length(algo_ids) 
%     %plot(time_taken(:,a),'-x','MarkerFaceColor',color{a});
%     subplot(length(algo_ids),1,a), plot(time_taken(:,a),'-o','MarkerFaceColor',color{a});
%     %plot(n_actions(:,a),'-o','MarkerFaceColor',color{a});
%     legend(strcat('Algo',num2str(algo_ids(a))));
%     %hold on;
%     if (a == 1)
%         title({'Time Taken';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
%             ', Horizon = ',int2str(horizon))})
%     end
% end


% plot(n_actions,'bo--');
% plot(n_unknown,'gx-.');
% plot(time_taken,'cd:');
% 
% %ylim(0,10);
% title(strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
%     ', Horizon = ',int2str(horizon),', Algo Id = ',int2str(algo_id)))
% legend('No. of iterations','No. of actions','No. of unobserved','Time taken', 'Location','best');
% hold off

%avg_gap = [avg_gap;mean(nsteps_sampling-nsteps_optimal)];
%largest_gap = [largest_gap; max(nsteps_sampling-nsteps_optimal)];
%end


end

