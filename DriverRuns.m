function DriverRuns(s)

runs.teamStructs = 4;
runs.teamInits = 4;
runs.prop2ways = 0;
runs.nRefs = 1;
runs.mem = 5;
runs.s = 31;
runs.cases = 0;
runs.noise = 0;
runs.N = 100;
runs.c = 1;

t = 1;
teams = [10 10];
for t = 1:size(teams,1)
    runs.nTeams{t} = teams(t,1).*ones(1,teams(t,2));
    t = t+1;
end

for m = runs.mem
    for S =s
        for cs = 1:size(runs.cases,2)
            for t = 1:size(runs.nTeams,2)
                for p = 1:size(runs.prop2ways,2)
                    for i = runs.teamInits
                        for j = runs.teamStructs
                            for k = runs.nRefs
                                [bestFitnessAll meanFitnessAll strFname] = teamSearch('teamInit',i,'teamStructure',j,'prop2way',runs.prop2ways(p),'reformRate',k,'nTeams',[ '[' num2str(runs.nTeams{t}) ']'],'N',runs.N,'nCases',runs.cases(cs),'noise',runs.noise(cs),'curClock', ['[' num2str(runs.c) ']'] ,'memory',m,'seed',S);
                            end
                        end
                    end
                end
            end
        end
    end
end


%Plot Results
%plotResults(runs);
plot(bestFitnessAll);
xlabel('Trial Steps');
ylabel('Pr(survival)');

figure
plot(meanFitnessAll);
xlabel('Trial Steps');
ylabel('Pr(survival)');

end