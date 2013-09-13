function [ output_args ] = pomdp2by2(rows, cols, Nmax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

num_cells = rows*cols;
num_states = 0;
for i = 1:Nmax
    num_states = num_states + nchoosek(num_cells,i);
end
S = 1:num_states;

num_actions = 4*num_cells - 2*(nrows+ncols);
A = 1:num_actions;

num_obs = 0;
for i = 1:Nmax
    num_obs = num_obs + nchoosek(ncols, i)*nrows;
end
O = 1:num_obs;

T = zeros(num_states,num_actions,num_states);
T(1,1,2) = 1.0;
T(1,2,3) = 1.0;
T(5,2,8) = 1.0;
T(6,1,8) = 1.0;
T(6,5,7) = 1.0;
T(7,1,9) = 1.0;
T(7,2,10) = 1.0;
T(7,7,6) = 1.0;
T(7,8,5) = 1.0;
T(2,3,1) = 1.0;
T(2,4,4) = 1.0;
T(8,3,6) = 1.0;
T(8,4,10) = 1.0;
T(8,5,9) = 1.0;
T(8,6,5) = 1.0;
T(3,5,4)= 1.0;
T(3,6,1) = 1.0;
T(4,7,3) = 1.0;
T(4,8,2) = 1.0;
T(9,3,7) = 1.0;
T(9,7,8) = 1.0;
T(10,6,7) = 1.0;

Z = zeros(num_states,num_obs);
Z(1,1) = 1.0;
Z(2,2) = 1.0;
Z(3,3) = 1.0;
Z(4,4) = 1.0;
Z(5,1) = 1.0;
Z(6,5) = 1.0;
Z(7,6) = 1.0;
Z(8,7) = 1.0;
Z(9,8) = 1.0;
Z(10,3) = 1.0;
     
% All rewards are +1 (This will not try to minimize steps)

% B represents current belief. It is a |S| dim vector
B = (1/num_states)*ones(num_states,1);

V = zeros(num_states,1);

for b = 1:num_states
    for a = 1:num_actions
        for obs = 1:num_obs
            

end

