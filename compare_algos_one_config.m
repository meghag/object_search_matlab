function compare_algos_one_config(dim1,dim2,res,N,max_horizon,algo_ids)
%This function takes all algos and for given dimensions and number of
%objects, compares their average performance across all possible configs
%and for different horizons. 

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

temp = unique(randi(dim1*dim2,25,1));
objLocationsIndices = temp(1:N)

% 
% filename = strcat('configs',int2str(dim1),'by',int2str(dim2),'objects',...
%     int2str(N),'horizon',int2str(horizon),'algoid',int2str(algo_id),'.mat')
% save(filename,'allStartConfigs');


% n_iterations = zeros(100,length(algo_ids));
% n_actions = zeros(100,length(algo_ids));
% time_taken = zeros(100,length(algo_ids));
% n_unknown = zeros(100,length(algo_ids));

avg_n_iterations = zeros(max_horizon,length(algo_ids));
avg_n_actions = zeros(max_horizon,length(algo_ids));
avg_time_taken = zeros(max_horizon,length(algo_ids));
avg_n_unknown = zeros(max_horizon,length(algo_ids));

%num = size(allStartConfigs,1);
num = 1;

for horizon = 2:max_horizon
    horizon
    for a = 1:length(algo_ids)
        a
        for i = 1:num
            i;
            %objLocationsIndices = [allStartConfigs(i,:)]';
            %objLocationsIndices = [allStartConfigs(100,:)]';
            
            if (algo_ids(a) == 2)
                %Testing object_search2 - explore EVERYTHING
                tic
                [n_iterations,n_actions,time_taken,n_unknown] = ...
                    object_search2(dim1,dim2,res,objLocationsIndices,1,horizon,0);
                toc
            elseif (algo_ids(a) == 3)
                %testing object_search3 - reveal as much as possible
                tic
                 [n_iterations,n_actions,time_taken,n_unknown] = ...
                    object_search3(dim1,dim2,res,objLocationsIndices,1,horizon,0);
                toc
            elseif (algo_ids(a) == 4)
                %testing object_search3 - reveal as much as possible
                 [n_iterations,n_actions,time_taken,n_unknown] = ...
                    object_search4(dim1,dim2,res,objLocationsIndices,1,horizon,0);
            elseif (algo_ids(a) == 5)
                %testing object_search3 - reveal as much as possible
                 [n_iterations,n_actions,time_taken,n_unknown] = ...
                    object_search5(dim1,dim2,res,objLocationsIndices,1,horizon,0);
            elseif (algo_ids(a) == 6)
                %testing object_search3 - reveal as much as possible
                 [n_iterations,n_actions,time_taken,n_unknown] = ...
                    object_search6(dim1,dim2,res,objLocationsIndices,1,horizon,0);
            end
            
            avg_n_iterations(horizon,a) = avg_n_iterations(horizon,a) + n_iterations;
            avg_n_actions(horizon,a) = avg_n_actions(horizon,a) + n_actions;
            avg_time_taken(horizon,a) = avg_time_taken(horizon,a) + time_taken;
            avg_n_unknown(horizon,a) = avg_n_unknown(horizon,a) + n_unknown;
            
            %[~,nsteps_opt,~] = bfs(objLocationsIndices,dim1,dim2,res,1);
            %nsteps_optimal = [nsteps_optimal;nsteps_opt];
        end
        avg_n_iterations(horizon,a) = avg_n_iterations(horizon,a)/num;
        avg_n_actions(horizon,a) = avg_n_actions(horizon,a)/num;
        avg_time_taken(horizon,a) = avg_time_taken(horizon,a)/num;
        avg_n_unknown(horizon,a) = avg_n_unknown(horizon,a)/num;
    end
end

color = {[1 0 0],[0 1 0],[0 0 1],[1 0 1],[0 1 1],[0.3 0.6 0.4],...
    [1 1 0],[0.1 0.3 0.3],[0.8 0 0.5],[0.7,0.4,0],[0.1 0.3 0.8],[0 0 0]};

%num = 100;

colormap spring;

figure;
bar(avg_n_iterations);
title({'Average Number of Iterations';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N))});

figure;
bar(avg_n_actions);
title({'Average Number of Actions';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N))});

figure;
bar(avg_n_unknown);
title({'Average Number of Unknown Cells';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N))});

figure;
bar(avg_time_taken);
title({'Average Time Taken';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N))});
   
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

