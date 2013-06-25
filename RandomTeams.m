function [teams teamPart ] = RandomTeams( population, o )

  teamPart = [];
if o.nTeams(1)==1
    for i = 1:size(population,1)
        teams{i} = population(i,:);
        teamPart = [teamPart; i];
    end
else
    r = randperm(o.rsm,size(population,1));
    for t = 1:o.nTeam
        if t == 1
            teams{t} = population(r(1:sum(o.nTeams(t))),:); 
            teamPart(r(1:sum(o.nTeams(t))))=t;
        else
            teams{t} = population(r(sum(o.nTeams(1:t-1))+1:sum(o.nTeams(1:t))),:);          
            teamPart(r(sum(o.nTeams(1:t-1))+1:sum(o.nTeams(1:t)))) = t;
        end
    end
end
end

