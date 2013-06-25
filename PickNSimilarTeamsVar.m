function [teams teamPart ]= PickNSimilarTeamsVar( population, minFlag, o)
% most similar/dissimilar guys in the same team
% find the team of most similar guys, take them out of the
% population and do it again till all teams are formed.
indLabNew = [];
teamPart = [];
if o.nTeams(1)==1
    for i = 1:size(population,1)
        teams{i} = population(i,:);
        teamPart = [teamPart; i];
    end
else
    Num = 1:o.nPop;
    if minFlag == 1 % similar guys
        for t = 1:o.nTeam
            D = squareform(pdist(population,'hamming'));
            FIX = eye(size(population,1));
            D = D-FIX; % make all the elements on the diagonal of D to be -1
            [sortV, sortD] = sort(D,2); % sort each row of the D
            meanIndDistance  = mean(sortV(:,2:o.nTeams(t)-1),2); % Fixed sortD to sortV didn't run to see changes
            [~, sortMean] = sort(meanIndDistance);
            teams{t} = population([sortMean(1) sortD(sortMean(1),2:o.nTeams(t))],:);
            teamPart([Num(sortMean(1)) Num(sortD(sortMean(1),2:o.nTeams(t)))]) = t;
            Num ([sortMean(1) sortD(sortMean(1),2:o.nTeams(t) )]) = [];
            population([sortMean(1) sortD(sortMean(1),2:o.nTeams(t) )],:) = [];
        end
    else
      % dissimilar guys
    end
end
end

