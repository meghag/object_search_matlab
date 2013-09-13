function adaptive_horizon_search_pomdpv0(dim1,dim2,res,objLocationsindices,plot_flag)
% ADAPTIVE_HORIZON
% Goal: reveal state of ALL voxels even if horizon length has to be increased.
% Let us see how different horizon lengths affect no. of actions and time
% taken to explore everything.

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

fid = fopen('obj_search_pomdp.txt','w');


% Each object is assumed to fit within a grid cell.
nrows = dim1/res;
ncols = dim2/res;
%N = length(objLocationsindices);

[objLocations(:,1),objLocations(:,2)] = ind2sub([nrows,ncols],objLocationsindices);

cellCentres = zeros(dim1/res,dim2/res,2);

%Calculating centres of grid cells
for i = 1:dim1/res
    for j = 1:dim2/res
        cellCentres(i,j,1) = (j-1)*res + res/2;
        cellCentres(i,j,2) = (i-1)*res + res/2;
    end
end

true_init_config = [(1:size(objLocations,1))',objLocations];
n_cells = nrows*ncols;
n_states = 5^n_cells;

fprintf(fid, 'discount: 0.95\n');
fprintf(fid, 'values: reward\n');
fprintf(fid, 'actions: %d\n', 4*n_cells);
fprintf(fid, 'observations: %d\n', 3^n_cells);
fprintf(fid, 'states: %d\n\n', n_states);

% visible - Vx3 matrix of visible objects at current time
% unknown - Ux3 matrix of objects that have never been seen and so, their locations are unknown.
% known - Kx3 matrix of objects that have been seen at least once and hence, their locations are exactly known.
% free - a vector of indices taht are known to be free
[visible,known] = find_visible2(true_init_config,[]);
prev_occupied = [];
occupied = union(sub2ind([nrows,ncols],known(:,2),known(:,3)), prev_occupied);
free = find_free(occupied,nrows,ncols,[]);

state = 4*ones(n_cells,1);

visible_indices = sub2ind([nrows, ncols], visible(:,2), visible(:,3));
%keyboard
state(visible_indices) = 3*ones(length(visible_indices),1);
state(free) = 1*ones(length(free),1);

if (plot_flag == 1)
    % Plotting the true intial configuration
    plot_config2(true_init_config,visible,known,occupied,free,dim1,dim2,res,'true start config',1);
end

state
current_state_idx = state2stateidx(state);

%belief_prior = zeros(n_states,1);
%belief_prior(current_state_idx) = 1.0;

fprintf(fid, 'start: %d\n', current_state_idx);
%for i = 1:length(belief_prior)
%    fprintf(fid, '%1.2f ', belief_prior(i));
%end

for i = 1:n_states
    state = stateidx2state(i, n_cells);
    %find_visible(state);
    actions = find_actions(state, nrows, ncols);
    for a = 1:size(actions,1)
        this_action = actions(a,:);
        action_idx = (this_action(1)-1)*4 + this_action(2);
        
        %Find all possible end states
        end_state_idx = state2stateidx(this_action(3)');
        
        %Write in POMDP file
        fprintf(fid, 'T: %d\t: %d\t: %d\t %1.2f\n', action_idx, i-1, end_state_idx, 1/size(actions,1));
    end
end
fclose(fid);

end

function actions = find_actions(state, nrows, ncols)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

occupied_indices = find(state > 1 & state ~= 4);
[occupied(:,1),occupied(:,2)] = ind2sub([nrows,ncols],occupied_indices);
occupied_or_unknown_indices = find(state > 1);
[occupied_or_unknown(:,1),occupied_or_unknown(:,2)] = ind2sub([nrows,ncols],occupied_or_unknown_indices);
visible_indices = find(state == 3);
[visible(:,1),visible(:,2)] = ind2sub([nrows,ncols],visible_indices);

actions = [];

for obj = 1:size(visible,1)
    objRow = visible(obj,1);
    objCol = visible(obj,2);
    visible_idx = sub2ind([nrows,ncols],objRow, objCol);
    %Find valid moves
    if (objRow >= 1 && objRow ~= nrows && ...
            numel(setdiff([objRow+1,objCol], occupied_or_unknown,'rows')) ~= 0)
        %Can move back (away from camera)
        destination_idx = sub2ind([nrows, ncols], objRow+1, objCol);
        end_state = state;
        end_state(visible_idx) = 1;
        same_col_obj = occupied(occupied(:,2) == objCol, :);
        if (isempty(find(same_col_obj(:,1) < objRow+1, 1)))
            end_state(destination_idx) = 3;
        else 
            end_state(destination_idx) = 2;
        end
            
        %this_action = [start_cell, dirn (N,S,E,W = 0,1,2,3), end state]
        this_action = [visible_idx, 0, end_state'];
        actions = [actions;this_action];
    end
    
    if (objRow <= nrows && objRow ~= 1 && ...
            numel(setdiff([objRow-1,objCol], occupied_or_unknown,'rows')) ~= 0)
        %Can move forward (closer to camera)    
        destination_idx = sub2ind([nrows, ncols], objRow-1, objCol);
        end_state = state;
        end_state(visible_idx) = 0;
        same_col_obj = occupied(occupied(:,2) == objCol, :);
        if (isempty(find(same_col_obj(:,1) < objRow-1, 1)))
            end_state(destination_idx) = 3;
        else 
            end_state(destination_idx) = 2;
        end
       
        this_action = [sub2ind([nrows,ncols],objRow, objCol), 1, end_state'];
        actions = [actions;this_action];
    end  
   
    if (objCol ~= ncols && objCol >= 1 && ...
            numel(setdiff([objRow,objCol+1], occupied_or_unknown,'rows')) ~= 0)
        %Can move right
        destination_idx = sub2ind([nrows, ncols], objRow, objCol+1);
        end_state = state;
        end_state(visible_idx) = 1;
        same_col_obj = occupied(occupied(:,2) == objCol+1, :);
        if (isempty(find(same_col_obj(:,1) < objRow, 1)))
            end_state(destination_idx) = 3;
        else 
            end_state(destination_idx) = 2;
        end
        
        this_action = [sub2ind([nrows,ncols],objRow, objCol), 2, end_state'];
        actions = [actions;this_action];
    end
    
    if (objCol <= ncols && objCol ~= 1 && ...
            numel(setdiff([objRow,objCol-1], occupied_or_unknown,'rows')) ~= 0)
        %Can move left
        destination_idx = sub2ind([nrows, ncols], objRow, objCol-1);
        end_state = state;
        end_state(visible_idx) = 1;
        same_col_obj = occupied(occupied(:,2) == objCol-1, :);
        if (isempty(find(same_col_obj(:,1) < objRow, 1)))
            end_state(destination_idx) = 3;
        else 
            end_state(destination_idx) = 2;
        end
        
        this_action = [sub2ind([nrows,ncols],objRow, objCol), 3, end_state'];
        actions = [actions;this_action];
    end
end
end

function idx = state2stateidx(state)
idx = 1;
for i = 1:length(state)
    idx = idx + state(i)*(5^(i-1));
end
end

function state = stateidx2state(state_idx, n_cells)
    quotient = state_idx-1;
    state = zeros(n_cells,1);
    curr = 1;
    state_idx;
    while (quotient > 0)
        remainder = rem(quotient,5);
        quotient = idivide(quotient,int32(5));
        state(curr) = remainder;
        curr = curr+1;
    end
end

% true_config = true_init_config;
% target_found = 0;
% iteration = 0;
% n_actions_taken = 0;
% unknown_state = 0;
% 
% tic
% %If the goal is to know identity and location of each object
% %while (nrows*ncols - (size(known,1) + length(free)) > 0)
% 
% %If the goal is only to know state of each voxel - free or occupied
% while (nrows*ncols - (length(occupied) + length(free)) > 0)
% %for itr = 1:1
%     %current_config = true_config;
%     if (numel(find(visible(:,1) == target_id,1)) ~= 0)
%         %Target is visible
%         target_found = 1;
%         
%         %If the goal is just to find target
%         %break;
%     end
%     
%     iteration = iteration + 1;
%     
%     % Plan
%     %Goal: To observe every voxel even if it means increasing horizon
%     temp_horizon = horizon-1;
%     info_gain = 0;
%     while (info_gain < 1)        
%          temp_horizon = temp_horizon+1;
%          [info_gain,action_sequence] = plan2(visible,known,occupied,free,dim1,dim2,res,temp_horizon,0);
%          if (isempty(action_sequence))
%              disp('No more moves possible.');
%              time_taken = toc;
%              return;
%          end
%     end
%     temp_horizon;
%     info_gain;    
%     
%     %Take chosen action
%     %for act = 1:1
%     for act = 1:size(action_sequence,1)
%         action = action_sequence(act,:);
%        % known_before_action = known;
%         
%         [~,new_true_config,moved,visible,known,occupied,free,~,no_new_findings] = ...
%             take_action2(true_config,action,true_config,visible,known,occupied,free,nrows,ncols);
%         n_actions_taken = n_actions_taken+1;
%                 
%         true_config = new_true_config;
%         if (plot_flag == 1)
%             plot_title = strcat('Iteration ',int2str(iteration),': Config after action ',int2str(act), ', Horizon =', int2str(temp_horizon));
%             plot_config2(true_config,visible,known,occupied,free,dim1,dim2,res,plot_title,target_id);
%         end
%         %keyboard;
%         
%         if (moved == 0)
%             %Replan.
%             break;
%         end
%         
%         %Did you see what you expected to?
%         
%         %If the goal is only to know state of each voxel - free or occupied
%         if (no_new_findings == 0)
%             %Something new was seen that we didn't expected to see.
%             %Replan for the same horizon.
%             %no_new_findings
%             break;
%         end
% %       Else everything is as expected. Continue executing actions.        
%     end
% end
% time_taken = toc;
