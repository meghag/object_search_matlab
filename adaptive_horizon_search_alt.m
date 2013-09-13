%function [iteration,n_actions_taken,time_taken,unknown_state, horizon_distribution] = adaptive_horizon_search_alt(dim1,dim2,res,objLocationsindices,knownLocationsIndices,target_id,horizon,plot_flag)
function log_cell_array = adaptive_horizon_search_alt(dim1,dim2,res,objLocationsindices,knownLocationsIndices,target_id,horizon,plot_flag)
% ADAPTIVE_HORIZON
% Goal: reveal state of ALL voxels even if horizon length has to be increased.
% Let us see how different horizon lengths affect no. of actions and time
% taken to explore everything.
% It is the adaptive horizon search but more adapted to real world because:
%      1. it gets a list of known objects in the beginning. These could be
% taller objects in the back that are seen by the camera.
%      2. it moves objects only to free space, not hidden. 

% INPUT:
% dim1 - along Y
% dim2 - along X
% res - grid resolution
% objLocationIndices - indices of true object locations
% horizon - no. of steps to look ahead while planning

% OUTPUT:
% iteration - no. of iterations taken to reveal as much as possible.
% n_actions - no. of actions *executed* (not planned) to reveal as much as
% possible. executed <= planned.
% time_taken - time taken to run the algo.
% unknown_state - no. of voxels whose state could not be revealed (always
% zero in this case).

%***************************************************************************%


% Each object is assumed to fit within a grid cell.
nrows = dim1/res;
ncols = dim2/res;
%N = length(objLocationsindices);
cellCentres = zeros(dim1/res,dim2/res,2);

%Calculating centres of grid cells
for i = 1:dim1/res
    for j = 1:dim2/res
        cellCentres(i,j,1) = (j-1)*res + res/2;
        cellCentres(i,j,2) = (i-1)*res + res/2;
    end
end

[objLocations(:,1),objLocations(:,2)] = ind2sub([nrows,ncols],objLocationsindices);
true_init_config = [(1:size(objLocations,1))',objLocations];
known = [];

if (~isempty(knownLocationsIndices))
    [knownLocations(:,1),knownLocations(:,2)] = ind2sub([nrows,ncols],knownLocationsIndices);
    for i = 1:length(knownLocationsIndices)
        known_idx = find(objLocationsindices == knownLocationsIndices(i));
        known = [known; [known_idx, objLocations(known_idx,:)]];
    end
end

% visible - Vx3 matrix of visible objects at current time
% unknown - Ux3 matrix of objects that have never been seen and so, their locations are unknown.
% known - Kx3 matrix of objects that have been seen at least once and hence, their locations are exactly known.
%[visible,known] = find_visible2(true_init_config,[]);
[visible,known] = find_visible2(true_init_config,known);

prev_occupied = [];
occupied = union(sub2ind([nrows,ncols],known(:,2),known(:,3)), prev_occupied);
free = find_free(occupied,nrows,ncols,[]);

if (plot_flag == 1)
    % Plotting the true intial configuration
    plot_config2_qual(true_init_config,visible,known,occupied,free,dim1,dim2,res,'true start config',target_id);
end

true_config = true_init_config;
target_found = 0;
iteration = 0;
n_actions_taken = 0;
unknown_state = 0;
horizon_distribution = zeros(4,1);
iteration_details = [];

tstart_search = tic;
%If the goal is to know identity and location of each object
%while (nrows*ncols - (size(known,1) + length(free)) > 0)

%If the goal is only to know state of each voxel - free or occupied
while (nrows*ncols - (length(occupied) + length(free)) > 0)
%for itr = 1:1
    %current_config = true_config;
    if (numel(find(visible(:,1) == target_id,1)) ~= 0)
        %Target is visible
        target_found = 1;
        
        %If the goal is just to find target
        %disp('Target found.');
        %break;
    end
    
    iteration = iteration + 1;
    
    % Plan
    %Goal: To observe every voxel even if it means increasing horizon
    temp_horizon = horizon-1;
    info_gain = 0;
    tstart_planning = tic;
    while (info_gain < 1 && temp_horizon < horizon+3)
        temp_horizon = temp_horizon+1;
        if (temp_horizon > 2)
            temp_horizon;
        end
        [info_gain,action_sequence] = plan2_alt(visible,known,occupied,free,dim1,dim2,res,temp_horizon,0);
        if (isempty(action_sequence))
            disp('No more moves possible.');
            time_taken = toc(tstart_search);
            iteration_details = [iteration_details, [temp_horizon; 0; toc(tstart_planning)]];
            n_actions_taken = 1000;
            unknown_state = nrows*ncols - (length(occupied) + length(free));
            log_cell_array = {iteration,n_actions_taken,time_taken,unknown_state, horizon_distribution, iteration_details};
            return;
        end
    end
    if (temp_horizon == horizon+3)
        disp('No more moves possible.');
        time_taken = toc(tstart_search);
        iteration_details = [iteration_details, [temp_horizon; 0; toc(tstart_planning)]];
        n_actions_taken = 1000;
        unknown_state = nrows*ncols - (length(occupied) + length(free));
        log_cell_array = {iteration,n_actions_taken,time_taken,unknown_state, horizon_distribution, iteration_details};
        return;
    end
    
    horizon_distribution(temp_horizon) = horizon_distribution(temp_horizon)+1;
    planning_time_taken = toc(tstart_planning);
    
    temp_horizon;
    info_gain;
    
    %Take chosen action
    %for act = 1:1
    for act = 1:size(action_sequence,1)
        action = action_sequence(act,:);
       % known_before_action = known;
        
        [~,new_true_config,moved,visible,known,occupied,free,~,no_new_findings] = ...
            take_action2_alt(true_config,action,true_config,visible,known,occupied,free,nrows,ncols);
        n_actions_taken = n_actions_taken+1;
                
        true_config = new_true_config;
        if (plot_flag == 1)
            plot_title = strcat('Iteration ',int2str(iteration),': Config after action ',int2str(act), ', Horizon =', int2str(temp_horizon));
            plot_config2_qual(true_config,visible,known,occupied,free,dim1,dim2,res,plot_title,target_id);
        end
        %keyboard;
        
        if (nrows*ncols - (length(occupied) + length(free)) == 0)
            time_taken = toc(tstart_search);
            iteration_details = [iteration_details, [temp_horizon; act; planning_time_taken]];
            unknown_state = 0;
            log_cell_array = {iteration,n_actions_taken,time_taken,unknown_state, horizon_distribution, iteration_details};
            return;
        end
        
        if (moved == 0)
            %Replan.
            break;
        end
        
        %Did you see what you expected to?
        
        %If the goal is only to know state of each voxel - free or occupied
        if (no_new_findings == 0)
            %Something new was seen that we didn't expected to see.
            %Replan for the same horizon.
            %no_new_findings
            iteration_details = [iteration_details, [temp_horizon; act; planning_time_taken]];
            break;
        elseif (act == size(action_sequence,1))
            iteration_details = [iteration_details, [temp_horizon; act; planning_time_taken]];
        end
%       Else everything is as expected. Continue executing actions.        
    end
    
end
iteration_details
time_taken = toc(tstart_search);

end
