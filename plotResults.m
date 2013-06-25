function   plotResults(runs)

strW = ['Results' num2str(runs.c)];
strR = num2str(runs.c);
mkdir(strW);

color = {'r','k','r','k'};
symb = {'--','--','-','-'};
fs = 28;

fct = 1;
ct = 1;

for t = 1:size(runs.nTeams,2)
    for cs = 1:size(runs.cases,2)
        clear P;
        for p = 1:size(runs.prop2ways,2)
            ctK = 1;
            NRefs = [];
            for k = 1:size(runs.nRefs,2)
                M = [];
                for i = runs.teamInits
                    for j = runs.teamStructs;
                        for s =1:runs.s
                            try
                                str = ['/SM' num2str(runs.nRefs(k)) '_I' num2str(i) '_T' num2str(j)  '_P' num2str(runs.prop2ways(p)*10) '_N' num2str(runs.N) '_nTeams' num2str(size(runs.nTeams{t},2)) '_nIndPerTeam' num2str(runs.nTeams{t}(1))   '_cases' num2str(runs.cases(cs))  'Mem' num2str(runs.mem) '_S'   num2str(s)];
                                ind = strfind(str,' ');
                                str(ind) = '_';
                                load([strR str]);
                                
                                tempM(s,:) = meanFitnessAll;
                            catch err
                                str
                                ct = ct+1
                            end
                        end
                        M((i-1)*2+j,:) = mean(tempM,1);
                    end
                end
                NRefs(:,:,ctK) =M;
                ctK = ctK+1;
            end
            P{p} = NRefs;
        end
        Cases{cs} = P;
    end
end

save([strW '/Data' num2str(t)],'Cases');


% Plot the results for CH over generations
for cs = 1:size(Cases,2)
    P = Cases{cs};
    for p = 1:size(P,2)
        NRefs = P{p};
        NRefs = NRefs([1 4 7 10],:,:);
        figure;
        for i = 1:4
            hold on
            h = plot(NRefs(i,:,1),[symb{i} color{i}],'LineWidth',5,'MarkerSize',16);
            set(gca,'FontSize',fs, 'FontWeight','bold');
            %set(get(h,'Parent'), 'XScale', 'log','xtick',runs.nRefs,'xtickLabel',{'1','4','6',' ','10','20','50','Inf'},'xlim',[0 100]);
        end
        %plot(NRefs(:,:,1)','LineWidth',2);
        xlabel('Trials');
        ylabel('Pr(survival)');
        title(['Cases: ' num2str(runs.cases(cs)) 'p: ' num2str(runs.prop2ways(p)*10)]);
    end
end

% Plot the results for the number of Reformations
for cs = 1:size(Cases,2)
    P = Cases{cs};
    for p = 1:size(P,2)
        NRefs = P{p};
        NRefs = NRefs([1 4 7 10],:,:);
        figure;
        for nr = 1:size(NRefs,3)
            NR(:,nr) = mean(NRefs(:,:,nr),2);
        end
        for i = 1:4
            hold on
            h = plot(runs.nRefs,NR(i,:),[symb{i} color{i}],'LineWidth',5,'MarkerSize',16);
            set(gca,'FontSize',fs, 'FontWeight','bold');
            set(get(h,'Parent'), 'XScale', 'log','xtick',runs.nRefs,'xtickLabel',{'1','4','6',' ','10','20','50','Inf'},'xlim',[0 100]);
        end
        legend('RR','RH','CR','CH');
        xlabel('Frequency of Reformation');
        ylabel('Pr(survival)');
        title(['Cases: ' num2str(runs.cases(cs)) 'p: ' num2str(runs.prop2ways(p)*10)]);
        saveas(gcf,[strW '/' num2str(fct) '.jpg' ]);
        saveas(gcf,[strW '/' num2str(fct) '.fig' ]);
    end
end

end

