function probe = probe2atlasSpace(headsurf,probe,digpts,refpts)

if isempty(probe.optpos)
    return;
end

% Assign the final atlas and subj fields
atlas.head   = headsurf.mesh.vertices;
jj=1;
for ii=1:length(refpts.labels)
    k = find(strcmpi(digpts.refpts.labels, refpts.labels{ii}));
    if ~isempty(k)
        subj.p1020(jj,:)  = digpts.refpts.pos(k,:);
        subj.l1020{jj}    = digpts.refpts.labels{k};
        atlas.p1020(jj,:) = refpts.pos(ii,:);
        atlas.l1020{jj}   = refpts.labels{ii};
        jj=jj+1;
    end
end

% Bring optodes to atlas space
subj.optodes = probe.optpos;
if ~isfield(subj,'anchor')
    menu('Subject data has no anchor point(s). Defaulting to canonical registration','OK');
    method = 'canonical';
else
    method = getProbeRegMethod();
end
[probe.optpos, T] = reg_subj2atlas(method, subj, atlas);

end