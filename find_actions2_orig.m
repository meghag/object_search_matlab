function actions = find_actions2(visible,occupied_indices,dim1,dim2,res)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

nrows = dim1/res;
ncols = dim2/res;

[occupied(:,1),occupied(:,2)] = ind2sub([nrows,ncols],occupied_indices);

actions = [];

for obj = 1:size(visible,1)
    objId = visible(obj,1);
    objRow = visible(obj,2);
    objCol = visible(obj,3);
    %Find valid moves    
    if (objRow <= nrows && objRow ~= 1 && ...
            numel(setdiff([objRow-1,objCol], occupied,'rows')) ~= 0)
        %Can move forward
        actions = [actions;[objId,-1,0]];
    end
    
    if (objRow >= 1 && objRow ~= nrows && ...
            numel(setdiff([objRow+1,objCol], occupied,'rows')) ~= 0)
        %Can move back
        actions = [actions;[objId,1,0]];
    end
    
    if (objCol <= ncols && objCol ~= 1 && ...
            numel(setdiff([objRow,objCol-1], occupied,'rows')) ~= 0)
        %Can move left
        actions = [actions;[objId,0,-1]];
    end
    
    if (objCol ~= ncols && objCol >= 1 && ...
            numel(setdiff([objRow,objCol+1], occupied,'rows')) ~= 0)
        %Can move right
        actions = [actions;[objId,0,1]];
    end
end

