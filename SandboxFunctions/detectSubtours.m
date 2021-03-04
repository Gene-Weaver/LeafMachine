function subTours = detectSubtours(x,idxs)
% Returns a cell array of subtours. The first subtour is the first row of x, etc.

r = find(x); % indices of the trips that exist in the solution
substuff = idxs(r,:); % the collection of node pairs in the solution
unvisitedSubToursSubTours = ones(length(r),1); % keep track of places not yet visitedSubTours
curr = 1; % subtour we are evaluating
startour = find(unvisitedSubToursSubTours,1); % first unvisitedSubToursSubTours trip
    while ~isempty(startour)
        home = substuff(startour,1); % starting point of subtour
        nextpt = substuff(startour,2); % next point of tour
        visitedSubTours = nextpt; unvisitedSubToursSubTours(startour) = 0; % update unvisitedSubToursSubTours points
        while nextpt ~= home
            % Find the other trips that starts at nextpt
            [srow,scol] = find(substuff == nextpt);
            % Find just the new trip
            trow = srow(srow ~= startour);
            scol = 3-scol(trow == srow); % turn 1 into 2 and 2 into 1
            startour = trow; % the new place on the subtour
            nextpt = substuff(startour,scol); % the point not where we came from
            visitedSubTours = [visitedSubTours,nextpt]; % update nodes on the subtour
            unvisitedSubToursSubTours(startour) = 0; % update unvisitedSubToursSubTours
        end
        subTours{curr} = visitedSubTours; % store in cell array
        curr = curr + 1; % next subtour
        startour = find(unvisitedSubToursSubTours,1); % first unvisitedSubToursSubTours trip
    end
end