function mdp2by1(rows, cols, Nmax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%rows = 2
% cols = 1

num_cells = rows*cols;
num_states = 3^num_cells;

num_actions = 4*num_cells;
%A = 1:num_actions;

% First digit in tuple is for cell closer to cam
% S = {00,01,10,11,12}
% A = {1N,1S,1E,1W,2N,2S,2E,2W}

T = zeros(num_states,num_actions,num_states);
T(2,6,3) = 1.0;
T(3,1,2) = 1.0;
T(5,1,2) = 0.5;
T(5,1,4) = 0.5;



for i = 1:num_states
    col = i/nrows + 1;
    row = rem(i,nrows);
    if row == 0
        row = 1;
    end
    
    if row < nrows
        % Can move north
        north_action_index = (i-1)*4 + 1;
        T(i,north_action_index,i+1) = 1.0;
    end
   
    if row > 1
        % Can move south
        south_action_index = (i-1)*4 + 2;
        T(i, south_action_index, i-1) = 1.0;
    end
    
    if col > 1
        % Can move east
        east_action_index = (i-1)*4 + 3;
        T(i,east_action_index,i+nrows) = 1.0;
    end
    
    if col < ncols
        %Can move west
        west_action_index = 4*i;
        T(i,west_action_index,i-nrows) = 1.0;
    end
    
    
    
end

Z = zeros(num_states,num-ons);
for i = 1:num_states
    
        

end

