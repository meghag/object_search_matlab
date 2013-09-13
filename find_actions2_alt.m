function actions = find_actions2_alt(visible,occupied_indices,free_indices,dim1,dim2,res)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

nrows = dim1/res;
ncols = dim2/res;
actions = [];

if (length(occupied_indices) > 0)
    [occupied(:,1),occupied(:,2)] = ind2sub([nrows,ncols],occupied_indices);
end
if (length(free_indices) > 0)
    [free(:,1),free(:,2)] = ind2sub([nrows,ncols],free_indices);
else
    return;
end

%actions = zeros(size(visible,1)*size(free,1), 5);

%count = 1;
for obj = 1:size(visible,1)
    objId = visible(obj,1);
    objRow = visible(obj,2);
    objCol = visible(obj,3);
    %Find valid moves    
    for dest = 1:size(free,1)
        blocked = 0;
       freeCol = free(dest,2);
       same_col_idx = find(occupied(:,2) == freeCol);
       for i = 1:length(same_col_idx)
           occupiedRow = occupied(same_col_idx(i),1);
           occupiedCol = occupied(same_col_idx(i),2);
           if (occupiedRow < free(dest,1))
               if (occupiedRow == objRow && occupiedCol == objCol)
                   continue;
               else
                   blocked = 1;
                   break;
               end
           end
       end
       if (blocked == 0)
           actions = [actions; [objId, objRow, objCol, free(dest,1), free(dest,2)]];
           %count = count+1;
       end
    end
end

% for obj = 1:size(visible,1)
%     objId = visible(obj,1);
%     objRow = visible(obj,2);
%     objCol = visible(obj,3);
%     %Find valid moves    
%     if (objRow <= nrows && objRow ~= 1 && ...
%             numel(setdiff([objRow-1,objCol], occupied,'rows')) ~= 0 && ...
%             numel(find(free(:,1) == objId)) ~= 0)
%         %Can move forward (closer to camera)
%         actions = [actions;[objId,-1,0,objRow,objCol]];
%     end
%     
%     if (objRow >= 1 && objRow ~= nrows && ...
%             numel(setdiff([objRow+1,objCol], occupied,'rows')) ~= 0 && ...
%             numel(find(free(:,1) == objId)) ~= 0)
%         %Can move back (away from camera)
%         actions = [actions;[objId,1,0,objRow,objCol]];
%     end
%     
%     if (objCol <= ncols && objCol ~= 1 && ...
%             numel(setdiff([objRow,objCol-1], occupied,'rows')) ~= 0 && ...
%             numel(find(free(:,1) == objId)) ~= 0)
%         %Can move left
%         actions = [actions;[objId,0,-1,objRow,objCol]];
%     end
%     
%     if (objCol ~= ncols && objCol >= 1 && ...
%             numel(setdiff([objRow,objCol+1], occupied,'rows')) ~= 0 && ...
%             numel(find(free(:,1) == objId)) ~= 0)
%         %Can move right
%         actions = [actions;[objId,0,1,objRow,objCol]];
%     end
% end
