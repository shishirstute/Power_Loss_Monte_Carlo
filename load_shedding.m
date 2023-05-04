function [load_shed] = load_shedding(G,sources_nodes,Active_Demand,Active_Supply)
    group={};
    %Active_Demand=[4 8 10 15 4];
    %Active_Supply = [10 0 2 0 20];

    %%grouping of source together which are in same island
    while ~isempty(sources_nodes)
      
        grp=[];
        source=sources_nodes(1);
        for each = sources_nodes
            if isreachable(G,source,each)
                grp=[grp each];
                index_to_delete=find(sources_nodes==each);
                sources_nodes(index_to_delete)=[];
            end
        end
        group{end+1}=grp;
    end

    %% finding loss in each island/group and then summing to finad total loss shed

    for i =1:length(group)
        group_sources=cell2mat(group(i));
        Nodes_reachable = dfsearch(G,group_sources(1));
        load=sum(Active_Demand(Nodes_reachable));
        generation = sum(Active_Supply(group_sources));
        if generation >= load
            loss_group(i)=0;
        else
            loss_group(i) = load-generation;
        end
    end

load_shed = sum(loss_group);

if load_shed<0.01
    load_shed=0;
end

   


function [is_reachable] = isreachable(G,source,target)
    %function determining connection between two nodes
    d = distances(G,source);
    is_reachable = ~isinf(d(target));
end

end