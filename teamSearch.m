function [bestFitnessAll meanFitnessAll strFname]  = teamSearch(varargin)

genFound = -1; % Init to never found, update when find
if nargin ~=1
    % Initialize parameters for team search
    o = initSearch(varargin, -1);
else
    o = varargin{1};
end

teamPart = [];
% Generate initial population
switch(o.teamInit)
    case 1 % Random population
        % Generate random nTeam x nIndPerTeam individuals with N genes
        population = double(rand(o.rsm,o.nPop, o.N)>0.5);
    case 2 % Hamming distance withing indv in population less then maxH proportion of N
        maxHamDist = round(o.N*o.maxH/2); % 0.3<maxH < 0.6 median = 0.25, 0.6< maxH < 1 median = 0.33
        coreIndv = rand(o.rsm,1, o.N)>0.5;
        population = zeros(o.nPop,o.N);
        
        for i = 1:o.nPop
            r = randperm(o.rsm,o.N);
            nBitsToFlip = randi(o.rsm,maxHamDist,1,1);
            %nBitsToFlip = randi(o.rsm,o.N,1,1);  % This gives a median of exactly 0.5
            temp = coreIndv;
            temp(r(1:nBitsToFlip)) = ~ temp(r(1:nBitsToFlip));
            population(i,:) = temp;
        end
    case 3 % Hamming distance within indv in each team less then maxH proportion of N
        maxHamDist = round(o.N*o.maxH/2); % 2*0.2 = 40%
        population = zeros(o.nPop,o.N);
        
        for i = 1:o.nTeam
            coreIndv = rand(o.rsm,1, o.N)>0.5;
            for j = 1:o.nTeams(i)
                r = randperm(o.rsm,o.N);
                nBitsToFlip = randi(o.rsm,maxHamDist,1,1);
                temp = coreIndv;
                temp(r(1:nBitsToFlip)) = ~ temp(r(1:nBitsToFlip));
                population((i-1)*o.nTeams(i)+j,:) = temp;
            end
        end
    case 4 % SNAKE
        d = 0.125;
        maxHamDist = round(o.N*d);
        coreIndv = rand(o.rsm,1, o.N)>0.5;
        population = zeros(o.nPop,o.N);
        for i = 1:o.sN
            if i~=1
                rInt = randi(o.rsm,o.sInds,1,1);
                coreIndv = population((i-2)*o.sInds + rInt,:);
            end
            population((i-1)*o.sInds+1,:) = coreIndv;
            for j = 2:o.sInds
                r = randperm(o.rsm,o.N);
                nBitsToFlip = maxHamDist; %min(o.N,randi(maxHamDist,1,1));
                temp = coreIndv;
                temp(r(1:nBitsToFlip)) = ~ temp(r(1:nBitsToFlip));
                population((i-1)*o.sInd+j,:) = temp;
            end
        end
        population = population(1:o.nPop,:);
    case 5 % Real Data for initial population with real teams
        population = [];
        for tn = 1:7
            load(['RealTeams/Team' num2str(tn)]);
            teams{tn} = team;
            population = [population; team];
            teamPart = [];
            for zz = 1:o.nTeam
                teamPart = [teamPart ones(1,o.nTeams(zz)).*zz];
            end
        end
    case 6 % Real Data for initial population with constructed teams
        load realPopulation;
        %         population = [];
        %         for tn = 1:7
        %             load(['RealTeams/Team' num2str(tn)]);
        %             %teams{tn} = team;
        %             population = [population; team];
        %         end
end

% Initialize the best individuals vector
bestFitnessAll = zeros(o.generations,1);
meanFitnessAll= zeros(o.generations,1);
ClusteringAndPath = zeros(o.generations,4);

tabu = zeros(size(population));
NN = 1:size(population,1);

o.tempTeamStruct = o.teamStructure;

for g = 1:o.generations
    if rem(g,o.reformRate) ~= 0 && g~=1
        o.tempTeamStruct = 6;
    end
    
    % construct/reconstruct the teams
    switch(o.tempTeamStruct)
        case 1 % random teams
            [teams teamPart] = RandomTeams( population, o );
            %TP(g,:) = teamPart;
        case 2 % Do Round Robin Similar indvs together
            teams = RoundRobinVar( population, 1, o ); %KMeans
        case 3 % Do Round Robin Dissimilar indvs together
            teams = RoundRobinVarKMeans( population, 0, o );
        case 4 % most similar guys in the same team
            % find the team of most similar guys, take them out of the
            % population and do it again till all teams are formed.
            [teams teamPart ] = PickNSimilarTeamsVar( population, 1, o );
            %TP(g,:) = teamPart;
        case 5 % most dissimilar guys in the same team
            % find the team of most similar guys, take them out of the
            % population and do it again till all teams are formed.
            [teams teamPart tabu indLab] = PickNSimilarTeamsVar( population, 0,tabus, indLab, o );
            %TP(g,:) = teamPart;
        case 6 % never alter the teams
            %if ~exist('teams') % Real population with no teams
            %    [teams teamPart tabu] = PickNSimilarTeamsVar( population, 1, teamPart,tabus, o );
            %end
            %TP(g,:) = teamPart;
        case 7 % teams stay the same with occasional swap of individuals between teams
            if ~exist('teams') % Real population with no teams
                teamPart = [];
                [teams teamPart tabu] = PickNSimilarTeamsVar( population, 1, teamPart, tabus,o );
                %TP(g,:) = teamPart;
            else
                [teams teamPart] = swapIndv(teams,teamPart, o);
            end
            
    end
    
    
    o.tempTeamStruct = o.teamStructure;
    tempAdj = zeros(o.nPop);
    
    for z = 1:o.nTeam
        Num = 1:o.nPop;
        teammates = Num(teamPart == z);
        tempAdj(teammates,teammates) = 1;
    end
    Adj(:,:,g) = tempAdj- eye(o.nPop);
    
    
    fitness= feval(o.fitnessFnc, o.model, population);
    
    bestFitnessAll(g) = max(fitness);
    meanFitnessAll(g) = mean(fitness);
    
    if o.networkChars == 1
        W = squareform(pdist(population,'hamming'));
        [C P nF PWeighted] = smallWorld(W, o);
        ClusteringAndPath(g,:) = [C P nF PWeighted];
    end
    
    % Check if found the best result if flag knownResult ==1
    if o.knownBestFitness == 1
        if min(fitness(:)) == o.trueBestFitness && genFound== -1
            genFound = g;
        end
    end
    
    % Smart Crossover among teams
    popAll{g} = population;
    tabu(tabu>0) = tabu(tabu>0)-1;
    for k = 1:o.nTeam
        teamk = population(NN(teamPart == k),:);
        fitnessk = fitness(NN(teamPart == k));
        tabuk = tabu(NN(teamPart == k),:);
        [ newTeam, newTabu ] = crossover(o, teamk, fitnessk, tabuk, k); %crossoverNoInfo
        population(NN(teamPart == k),:) = newTeam;
        tabu(NN(teamPart == k),:) = newTabu;
    end
    
    if o.networkChars == 1
        % Check the population clustering
        [s minavgDBetween, avgDWithin, AB] = mySilhouette(population,teamMembership,'hamming');
        MB(g) = mean(AB);
        MW(g) = mean(avgDWithin);
        S(g) = mean(s);
    end
end

teamStructureLabels = {'Random','RRSimilar','RRDissimilar','NSimilar','NDissimilar','Same Teams','Swap'};
teamInitLabels = {'Random','PopMax','TeamMax','Snake','RealTRP','RealP'};
str = ['M' num2str(o.reformRate) '_I' num2str(o.teamInit) '_T' num2str(o.teamStructure)  '_P' num2str(o.prop2way*10) '_N' num2str(o.N) '_nTeams' num2str(o.nTeam) '_nIndPerTeam' num2str(o.nPop/o.nTeam)  '_cases' num2str(o.nCases) 'Mem' num2str(o.memory )  '_S'   num2str(o.seed)]; %  '_' num2str(o.nTeams)
ind = strfind(str,' ');
str(ind) = '_';

strFname = num2str(o.curClock);
fn = mkdir(strFname);

save([strFname '/S' str], 'bestFitnessAll', 'meanFitnessAll','popAll','Adj');

end