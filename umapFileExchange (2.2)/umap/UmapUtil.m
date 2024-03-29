%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
%   Math Lead & Secondary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Bioinformatics Lead:  Wayne Moore <wmoore@stanford.edu>
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%
classdef UmapUtil < handle
    properties(Constant)
        PATH='run_umap/examples';
        DFLT_TRANSFORM_Q_SZ=1.35;
        CATEGORICAL='categorical';
        SYNTHESIZE_MAX_RATIO=[10 20];
        COMPRESS_MAX_RATIO=[1 1];
    end

    methods(Static)
        function fldr=LocalSamplesFolder
            fldr=fullfile(File.Home, 'Documents', UmapUtil.PATH);
            File.mkDir(fldr);
        end
        
        function SeeHtml(results, htmlFile, how, tick, ttl, h3)
            if nargin<6
                h3='';
                if nargin<5
                    ttl='';
                    if nargin<4
                        tick='';
                        if nargin<3
                            how=1;
                        end
                    end
                end
            end
            if ~isempty(tick)
                tick2=String.MinutesSeconds(toc(tick));
                disp(tick2);
            else
                tick2='';
            end
            
            UmapUtil.SeeTableHtml(results.htmlHead1, results.htmlHead2, ...
                results.htmlHead3, results.htmlBody, how, htmlFile, ...
                ['<h1>UST results: ' ttl '</h1>'], ...
                ['<h2>Runtime: ' tick2 '</h2>'], ...
                ['<h3>' h3 '</h3>'] );
        end
        
        function SeeTableHtml(th1, th2, th3, tr, how, htmlFile, h1, h2, h3)
            if isempty(th1)
                return;
            end
            if nargin<9
                h3='';
                if nargin<8
                    h2='';
                    if nargin<7
                        h1='';
                        if nargin<6
                            if nargin<5
                                how=1;
                            end
                        end
                    end
                end
            end
            html=['<html>' h1 h2 h3 '<table border="1"><thead>' ...
                '<tr>' th1 '</tr>' '<tr>' th2 '</tr>' '<tr>' th3 ...
                '</tr></thead>' tr...
                '</table><hr>Created on ' char(datetime) '</html>'];
            if ~isempty(htmlFile)
                File.mkDir(fileparts(htmlFile));
                File.SaveTextFile(htmlFile, html);
            end
            if how==-1
                msg(html, 0, 'east++', 'Match rResults', 'genieSearch.png')
            elseif how==1
                if ~isempty(htmlFile)
                    Html.BrowseFile(htmlFile)
                else
                    Html.BrowseString(html);
                end
            end
        end
        function [x,y,z]=Labels(inputDims, outputDims, ax)
            dimInfo=sprintf('  %dD\\rightarrow%dD', ...
                inputDims, outputDims);
            x=['UMAP-X' dimInfo];
            y=['UMAP-Y' dimInfo];
            if outputDims>2
                z=['UMAP-Z' dimInfo];
            end
            if nargin>2
                xlabel(ax, x);
                ylabel(ax, y);
                if outputDims>2
                    zlabel(ax, z);
                end                
            end
        end
        
        function [args, argued]=GetArgs(varargin)
            p=UmapUtil.DefineArgs;
            [args, argued, unmatchedArgs]=Args.NewKeepUnmatched(p, varargin{:});
            if ~isempty(unmatchedArgs)
                s=args.handle_unmatched_args;
                fn=fieldnames(unmatchedArgs);
                N=length(fn);
                if strcmpi(s, 'ask')
                    if N>4
                        fn=[fn(1:4)' 'etc.'];
                    end
                    if ~askYesOrNo(Html.WrapHr(sprintf(['run_umap will '...
                            'ignore <br>%d urecognized arg(s)...<br>(%s)'...
                            '<br><br><b>Continue?</b>'], N, ...
                            Html.WrapSmallTags(fn))))
                        error('%d arg(s) unrecognized by run_umap', N);
                    end
                elseif strcmpi(s, 'halt')
                    error('%d arg(s) unrecognized by run_umap: %s', N, ...
                        StringArray.toString(fn));
                end
            end
            args=KnnFind.ExtractDistArgs(args, argued);
        end
        
        function args=CheckArgs(args, argued)
            args.buildLabelMap=false;
            if ischar(args.class_descriptions)
                args.class_descriptions={args.class_descriptions,...
                    'data points'};
            elseif iscell(args.class_descriptions)
                if length(args.class_descriptions)==1
                    args.class_descriptions=[args.class_descriptions, 'data points'];
                end
            end
            if islogical(args.verbose)
                if args.verbose
                    args.verbose = 'graphic';
                else
                    args.verbose = 'none';
                end
            end
            if ischar(args.cluster_detail)
                args.cluster_detail={args.cluster_detail};
            end
            if args.false_positive_negative_plot
                if isempty(find(args.match_scenarios==4, 1))
                    warning('Adding match_scenarios 4 because false_positive_negative_plot==TRUE');
                    if isequal(args.match_scenarios, 0)
                        args.match_scenarios=4;
                    else
                        args.match_scenarios(end+1)=4;
                    end
                end
            end

            args.match_scenarios=unique(args.match_scenarios);
            ms=args.match_scenarios;
            if any(ms==0) && any(ms>0)
                ms(ms==0)=[];
                args.match_scenarios=ms;
            end
            ustMatches=ms==1 | ms==2;
            args.matchingUst=any(ustMatches);
            if isempty(args.template_file)
                if args.qf_dissimilarity
                    warning('qf_dissimarity=true is ONLY for supervised template reductions');
                    args.qf_dissimilarity=false;
                end
                if args.matchingUst
                    warning('match_scenarios==1 or 2 needs supervised template_file');
                    ms(ustMatches)=[];
                    args.match_scenarios=ms;
                    args.matchingUst=false;
                end
            end
            
            if ~args.qf_dissimilarity
                if args.matchingUst
                    args.qf_dissimilarity=true;
                end
            else
                if isequal(ms, 0) && ~isempty(args.template_file)
                    ms=2;
                    args.match_scenarios=ms;
                    args.matchingUst=true;
                end
            end
            args.matchingUmap=any(ms==3 | ms==4);
            if ~isequal(args.label_column, 0) 
                if ~isempty(args.template_file)
                    if ~args.matchingUst && ~args.matchingUmap
                        warning('label_column has no effect without match_scenarios=1 2 3 or 4)');
                    end
                else
                    if isempty(args.label_file)
                        warning(['label_column without label_file '...
                            'to match/supervise, will use default names/colors'])
                        args.buildLabelMap=true;
                    end
                end
            else
                if ~isempty(args.label_file)
                    warning(['label_file has no effect without a label_column '...
                        'to match/supervise'])
                    disp('A map of colors and names for labels will be built');
                    args.buildLabelMap=true;
                end
                testLabelMatches=ms==1 | ms==3 | ms==4;
                if any(testLabelMatches)
                    warning('Assume label_column==end for match_scenarios 1 3 or 4 ');
                    args.label_column='end';
                    if isempty(args.label_file)
                         if ischar(args.csv_file_or_data)
                             [p,fn]=fileparts(args.csv_file_or_data);
                             lblFile=fullfile(p, [fn '.properties']);
                             if isempty(p) % ~/Documents/run_umap/examples
                                 args.label_file=lblFile;
                                 warning('Assume label_file is %s', lblFile);
                             else
                                 if exist(lblFile, 'file')
                                     args.label_file=lblFile;
                                     warning('Assume label_file is %s', lblFile);
                                 end
                             end
                         end
                    end
                end
            end
            if isempty(ms)
                if args.qf_dissimilarity
                    ms=2;
                    args.match_scenarios=2;
                end
            end
            args.matchingUmap=any(ms==3 | ms==4);
            args.ustMatches=ms==1 | ms==2;
            args.matchingUst=any(args.ustMatches);
            args.matchingTestLabels=any(ms==1 | ms==3 | ms==4);            
            if ~strcmpi('MEX', args.method)
                if argued.contains('sgd_tasks')
                    warning(['''method'' is ''%s'', thus '...
                        '''sgd_tasks''==%d is ignored'], args.method, args.sgd_tasks);
                end
            end
        end
        
        function SetArgsTemplateCanOverride(umap, args, argued, parameter_names)
            warningCnt=0;
            warnings='';
            setArgs=true;
            if argued.contains('template_file')
                forbidTemplateArg('n_components');
                forbidTemplateArg('parameter_names', 'dimNames');
                if ~args.override_template_args
                    forbidTemplateArg('n_neighbors');
                    forbidTemplateArg('min_dist');
                    forbidTemplateArg('metric');
                    forbidTemplateArg('dist_args');
                    forbidTemplateArg('NSMethod');
                    forbidTemplateArg('IncludeTies');
                    forbidTemplateArg('BucketSize');
                    setArgs=false;
                end
                if warningCnt>0
                    warning(...
                        ['%d arguments are overridden in template '...
                        '"%s"\n%s'], warningCnt, args.template_file, ...
                        warnings);
                end
            else
                umap.n_components=args.n_components;
                umap.dimNames=parameter_names;
            end
            if setArgs
                umap.metric=args.metric;
                umap.n_neighbors=args.n_neighbors;
                umap.min_dist=args.min_dist;
                umap.set_op_mix_ratio=args.set_op_mix_ratio;
                umap.target_weight=args.target_weight;
                umap.dist_args=args.dist_args;
                umap.IncludeTies=args.IncludeTies;
                umap.BucketSize=args.BucketSize;
                umap.NSMethod=args.NSMethod;
            end
            function forbidTemplateArg(arg, alias)
                if argued.contains(arg)
                    arguedValue=String.toString(args.(arg));
                    if nargin>1
                        templateValue=String.toString(umap.(alias));
                    else
                        templateValue=String.toString(umap.(arg));
                    end
                    if ~isequal(arguedValue,templateValue)
                        warnings=sprintf('%s''%s''=%s is overriden by: %s\n', ...
                            warnings, arg, arguedValue, templateValue);
                        warningCnt=warningCnt+1;
                    else
                        if nargin<2
                            warnings=sprintf('%s''%s''=%s is already set\n', ...
                                warnings, arg, arguedValue);
                            warningCnt=warningCnt+1;
                        end
                    end
                end
            end
        end
        
        function [args, changed]=NewArgDefault(args, argued, arg, dflt)
            if ~argued.contains(lower(arg))
                args.(arg)=dflt;
                changed=true;
            else
                changed=false;
            end 
        end
        
        function p=DefineArgs
            p = inputParser;
            defaultMetric = 'euclidean';
            expectedMetric = {'precomputed', 'euclidean', 'l2', 'manhattan', 'l1',...
                'taxicab', 'cityblock', 'seuclidean', 'standardised_euclidean',...
                'chebychev', 'linfinity', 'linfty', 'linf', 'minkowski',...
                'mahalanobis', 'cosine', 'correlation', 'hamming', 'jaccard',...
                'spearman'};
            defaultVerbose= 'graphic';
            expectedVerbose = {'graphic','text','none'};
            defaultMethod='MEX';
            expectedMethod={'Java', 'C', 'C vectorized', 'MATLAB', 'MATLAB vectorized',...
                'MATLAB experimental', 'MATLAB experimental 2', 'C++', 'MEX'};
            addOptional(p,'csv_file_or_data',[],@(x) ischar(x) || isnumeric(x));
            addParameter(p,'save_template_file',[], @ischar);
            addParameter(p,'ask_to_save_template', false, @islogical);
            addParameter(p,'randomize', true, @islogical);
            addParameter(p,'sgd_tasks', 0, @(x)isnumeric(x) && x>0 && x<=80);
            addParameter(p,'template_file',[], @(x) ischar(x) || isa(x, 'UMAP'));
            addParameter(p,'n_neighbors', 15, @(x) isnumeric(x) && x>2 && x<200);
            addParameter(p,'min_dist', .3, @(x) isnumeric(x) && x>.05 && x<.8);
            addParameter(p,'set_op_mix_ratio', 1, @(x) isnumeric(x) && x>=0 && x<=1);
            addParameter(p,'metric',defaultMetric,@(x)validateCallback(x)...
                || any(validatestring(x,expectedMetric)));
            addParameter(p,'n_epochs',[], @(x) isnumeric(x) && x>4);
            addParameter(p,'target_weight', .5, @(x) isnumeric(x) && x>=0 && x<=1);
            addParameter(p,'verbose',defaultVerbose,...
                @(x)islogical(x) || any(validatestring(x,expectedVerbose)));
            addParameter(p,'method',defaultMethod,...
                @(x) any(validatestring(x,expectedMethod)));
            addParameter(p, 'parameter_names', {}, @validateParameterNames);
            addParameter(p, 'progress_callback', [], @validateCallback);
            addParameter(p,'label_column',0,...
                @(x) strcmpi(x, 'end') || (isnumeric(x) && x>0));
            addParameter(p,'label_file',[], @ischar);
            addParameter(p,'n_components', 2, @(x) isnumeric(x) && x>=2 && x<101);
            addParameter(p,'frequencyDensity3D', true, @islogical);
            addParameter(p,'match_supervisors', 3, @(x)validateMatchType(x));
            addParameter(p,'match_3D_limit', 20000, @(x)isnumeric(x)&&x>=0);
            addParameter(p,'qf_dissimilarity', false, @(x) islogical(x) ...
                || (isnumeric(x)&&x==0||x==1));
            addParameter(p,'match_scenarios', 0, @validateMatchScenario);
            addParameter(p,'qf_tree', false, @islogical);
            addParameter(p,'match_table_fig', true, @islogical);
            addParameter(p,'match_histogram_fig', true, @islogical);
            addParameter(p,'joined_transform', false, @islogical);
            addParameter(p,'python', false, @islogical);
            addParameter(p,'see_training', false, @islogical);
            addParameter(p,'cluster_detail', 'most high', @validateClusterDetail);
            expectedMethod={'dbm', 'dbscan'};
            addParameter(p, 'cluster_method_2D', 'dbm', ...
                @(x)any(validatestring(x,expectedMethod)));
            addParameter(p,'minpts', 5, @(x) isnumeric(x) && x>=3 && x<1501);
            addParameter(p,'epsilon', .6, @(x) isnumeric(x) && x>.1 && x<100);
            expectedClusterOutput={'graphic', 'numeric', 'none', 'ignore', 'text'};
            addParameter(p, 'cluster_output', 'none', ...
                @(x)any(validatestring(x,expectedClusterOutput)));
            addParameter(p,'dbscan_distance', 'euclidean', ...
                @(x) any(validatestring(x,expectedMetric)));
            addParameter(p,'contour_percent', 10, ...
                @(x) isnumeric(x) && x>=0 && x<=25); 
            addParameter(p,'ust_test_cases', 1, ...
                @(x) isnumeric(x) && all(x>=0 & x<=25)); 
            addParameter(p,'ust_test_components', 2, ...
                @(x) isnumeric(x) && all(x>=2 & x<=4)); 
            
            addParameter(p,'context', struct(), @isstruct); 
            addParameter(p,'description', '', @ischar); 
            addParameter(p,'result_folder', '', @ischar); 
            addParameter(p,'match_file', '', @ischar); 
            addParameter(p,'ust_test_shift', .10, @(x)isnumeric(x) ...
                && x>=0 && x<.7);
            addParameter(p,'cascade_x', 0, @(x)isnumeric(x) && x>=0 && x<700);
            addParameter(p,'ust_test_freq_mean', .25, @(x)isnumeric(x) ...
                && x>=0 && x<=1);
            addParameter(p,'ust_test_perturbation', 0.05, @(x)isnumeric(x) ...
                && x>=0 && x <=1);
            addParameter(p,'ust_test_both_thirds', false, @islogical);
            addParameter(p,'ust_test_basic_reduction', false, @islogical);
            addParameter(p,'false_positive_negative_plot', false, @islogical);
            addParameter(p,'match_html', 0, @(x)isnumeric(x) && x>-2 && x<2);
            addParameter(p, 'parent_context', '', @ischar);
            addParameter(p, 'parent_popUp', '', @(x) isa(x, 'PopUp'));
            addParameter(p,'color_file','colorsByName.properties',@(x) ischar(x));
            addParameter(p,'color_defaults', false, @islogical);
            addParameter(p,'test_set',[],@(x) ischar(x));
            addParameter(p,'training_set',[],@(x) ischar(x));
            addParameter(p,'sample_set',[],@(x) ischar(x));
            addParameter(p, 'ust_test_synthesize', ...
                0, @(x)x==0 || (x>.01 && x<5));
            addParameter(p, 'synthesize', [], ...
                @(x)validateResize(x, false));
            addParameter(p,'compress',[],@(x)validateResize(x, true));
            addParameter(p,'dist_args', [], @(x)isnumeric(x));
            addParameter(p,'nn_descent_min_rows', 40000, @(x)isnumeric(x) && (x==0 || x>5000));
            addParameter(p,'nn_descent_min_cols', 11, @(x)isnumeric(x) && x>6);
            addParameter(p,'nn_descent_max_neighbors', 45, @(x)isnumeric(x) && x>3);
            addParameter(p,'nn_descent_transform_queue_size', ...
                [], @(x)isnumeric(x)  && x>=1 && x<=4);
            addParameter(p,'nn_descent_tasks', 0, @(x)isnumeric(x) && x>0 && x<=80);
            addParameter(p,'override_template_args', false, @islogical);
            addParameter(p,'K', 15, @(x) isnumeric(x));
            addParameter(p,'Cov', [], @(x)isnumeric(x));
            addParameter(p,'P', [], @(x)isnumeric(x));
            addParameter(p,'Scale', [], @(x)isnumeric(x));
            addParameter(p, 'Distance',[],@(x)validateCallback(x)...
                || any(validatestring(x,expectedMetric)));
            expectedNSMethod= {'kdtree', 'exhaustive', 'nn_descent'};
            addParameter(p,'NSMethod', [], ...
                @(x) any(validatestring(x,expectedNSMethod)));
            addParameter(p,'IncludeTies', false, @(x)islogical(x));
            addParameter(p,'BucketSize', [], @(x)isnumeric(x));
            expectedInit={UMAP.INIT_SPECTRAL, UMAP.INIT_RANDOM};
            addParameter(p,'init',UMAP.INIT_SPECTRAL, ...
                @(x)isnumeric(x) || any(validatestring(x,expectedInit)));
            addParameter(p,'marker_size', 2, @(x)isnumeric(x) && x>1 && x<=30);
            addParameter(p,'marker', '.', @(x)any(validatestring(x, Gui.MARKERS)));
            addParameter(p,'eigen_limit', ...
                UMAP.EIGEN_LIMIT, ...
                @(x)isnumeric(x) && x>=4096 && x<=8*4096);
            addParameter(p,'probability_bin_limit', ...
                UMAP.PROBABILITY_BIN_LIMIT, ...
                @(x)isnumeric(x) && x>=12*4096 && x<=320*4096);
            defaultSupervisedMetric=UmapUtil.CATEGORICAL;
            addParameter(p,'supervised_metric', ...
                defaultSupervisedMetric, @(x)validateCallback(x)...
                || any(validatestring(x,expectedMetric)));
            addParameter(p,'supervised_dist_args', ...
                [], @(x)isnumeric(x));
            addParameter(p, 'handle_unmatched_args', 'ask', ...
                @(x)any(validatestring(x, {'ask', 'halt', 'allow'})));
            addParameter(p, 'class_descriptions', {'cell type', 'cells'}, ...
                @(x) ischar(x) || iscell(x) );
            addParameter(p, 'roi_scales',[], @validateRoiScales);
            addParameter(p, 'roi_table', 3, @validateRoiTable);
            
            function validateRoiTable(x)
                ok=true;
                if isnumeric(x) && x>=0 && x<=3
                    return;
                end
                error(['roi_table: 0 no table, 1 for ROIs, '...
                    '2 for match table, 3 for both']);
            end
            
            function ok=validateRoiScales(x)
                ok=true;
                if isnumeric(x) && size(x,2)==3
                    return;
                end
                error('roi_scales is matrix of [idx min max]');
            end
            
            function ok=validateResize(x, compressOnly)
                ok=false;
                requirement=['specifies ratio/count for data set size'...
                    '\nand optionally for minimum class size if '...
                    'labels provided.'];
                if ~isnumeric(x) || length(x)>2 || any(x<=0)
                    warning('Synthesize %s.', requirement);
                    return;
                end
                if isempty(x) 
                    ok=true;
                    return;
                end
                N=length(x);
                if compressOnly
                    maxs=UmapUtil.COMPRESS_MAX_RATIO;
                else
                    maxs=UmapUtil.SYNTHESIZE_MAX_RATIO;
                end
                s={'1st', '2nd'};
                for i=1:N
                    if floor(x(i))~=x(i)
                        if x(i)>=maxs(i)
                            error(...
                                'Synthesize %s ratio  %s is greater than %d',...
                                s{i}, String.encodeRounded(x(i)), maxs(i));
                        end
                    else
                        if i==1
                            if x(i)<100
                                if x(i)==1
                                    warning('Interpreting 1 as NO compression');
                                else
                                    warning('%d seems small for synthesizing', x(i))
                                end
                            end
                        else
                            if x(i)<10
                                warning('%d seems small for synthesizing', x(i))
                            end
                        end
                    end
                end
                ok=true;
            end
            
            function ok=validateMatchType(x)
                if isnumeric(x) 
                    ok=all(x>=1) && all(x<=4);
                else
                    ok=false;
                end
            end
            
            function ok=validateMatchScenario(x)
                if isnumeric(x) 
                    ok=all(x>=0) && all(x<=4);
                else
                    ok=islogical(x(1));
                end
            end
            
            function ok=validateCallback(x)
                ok=isequal('function_handle', class(x));
            end
            
            function ok=validateParameterNames(x)
                ok=false;
                if iscell(x)
                    N=length(x);
                    if N>0
                        for i=1:N
                            if ~ischar(x{i})
                                ok=false;
                                return;
                            end
                        end
                        ok=true;
                    end
                end
            end
            
            function ok=validateClusterDetail(x)
                ok=false;
                if ischar(x) && ~isempty(x)
                    idx=StringArray.IndexOf(Density.DETAILS, lower(x));
                    ok=idx>0;
                    if ~ok
                        disp(['Unrecognized clustger detail "' x '"']);
                    end
                elseif iscell(x)
                    ok=true;
                    N=length(x);
                    for i=1:N
                        v=x{i};
                        idx=StringArray.IndexOf(Density.DETAILS, lower(v));
                        if idx<1
                            disp(['Unrecognized clustger detail "' v '"']);
                            ok=false;
                            break;
                        end
                    end
                end
            end
        end 
        
        function [clusterIds, numClusters, density]=Cluster(data,...
                clusterDetail, pu, clusterMethodIf2D, minopts, ...
                epsilon, dbscanDistance)
            if nargin<7
                dbscanDistance='euclidean';
                if nargin<6
                    epsilon=.6;
                    if nargin<5
                        minopts=5;
                        if nargin<5
                            clusterMethodIf2D='dbm';
                            if nargin<3
                                pu=[];
                                if nargin<2
                                    clusterDetail='most high';
                                end
                            end
                        end
                    end
                end
            end
            [mins, maxs]=Supervisors.GetMinsMaxs(data);
            [numClusters, clusterIds, density]=Density.FindClusters(data, ...
                clusterDetail, clusterMethodIf2D, pu, ...
                epsilon, minopts, dbscanDistance, ...
                mins, maxs);

        end
        
        function [qft, tNames]=Match(args, unreducedData, tLbls, tLblMap,...
                sLbls, clusterDetail, matchStrategy, visible, pu, file, ...
                btns, btnLbls)
            if nargin<12
                btnLbls=[];
                if nargin<11
                    btns=[];
                    if nargin<10
                        file=[];
                        if nargin<9
                            pu=[];
                            if nargin<8
                                visible=true;
                                if nargin<7
                                    matchStrategy=1;
                                end
                            end
                        end
                    end
                end
            end
            reductionType=args.reductionType;
            u=unique(sLbls);
            u(u == 0) = [];
            nU=length(u);
            sNames=cell(1, nU);
            for i=1:nU
                sNames{i}=['Cluster ' num2str(u(i))];
            end
            [tNames, clrs]=UmapUtil.GetNamesClrs(tLbls, tLblMap); 
            if isempty(file) || ~exist(file, 'file')
                qf=run_HiD_match(unreducedData, tLbls,...
                    unreducedData, sLbls, 'trainingNames', tNames, ...
                    'matchStrategy', matchStrategy, 'log10', true, ...
                    'testNames', sNames, 'pu', pu);
            else
                qf=QfTable.Load(file);
            end
            qft=QfTable(qf, clrs, [], get(0, 'currentFig'), visible, args);
            qft.fncSelect=@(qf, isTeacher, qfIdx)select(qf, isTeacher, qfIdx);
            if ~qft.doHistQF(visible)
                qft=[];
                return;
            end
            if matchStrategy==2
                qft.doHistF(visible);
            end
            if ~isempty(file) && ~exist(file, 'file')
                qft.save(qf, file);
            end
            qft.addSuffixToFigs(clusterDetail);
            qft.contextDescription=clusterDetail;
            if matchStrategy==2
                scenario=4;
            else
                scenario=3;
            end
            context=args.context;
            context.matchType=1;
            context.matchScenario=scenario;
            context.matchStrategy=matchStrategy;
            context.reductionType=reductionType;
            context.clusterDetail=clusterDetail;
            qft.context=context;
            roiTable=[];
            
            function select(qf, isTeacher, qfIdx)
                [name, lbl, tLbl, sLbl]=QfHiDM.GetIds2(qf, isTeacher, qfIdx);
                fprintf('teacher=%d, tId=%d, name="%s"\n',...
                    isTeacher, tLbl, name);
                if ~isempty(qft.btns)
                    lblIdx=find(qft.btnLbls==tLbl, 1);
                    if isempty(lblIdx)
                        lblIdx=find(qft.btnLbls==sLbl, 1);
                    end
                    if ~isempty(lblIdx)
                        qft.btns.get( lblIdx-1).doClick
                    end
                end
                if ~isempty(args.parameter_names) && args.roi_table>=2
                    if isTeacher
                        d=unreducedData(tLbls==lbl,:);
                    else
                        d=unreducedData(sLbls==lbl,:);
                    end
                    try
                        needToMake=isempty(roiTable) ...
                            || ~ishandle(roiTable.table.table.fig);
                    catch
                        needToMake=true;
                    end
                    if needToMake
                        roiTable=Kld.Table(d, ...
                            args.parameter_names, ...
                            args.roi_scales, qft.fig, name);
                        Gui.Locate(roiTable.table.table.fig, ...
                            qft.fig, 'south++');
                    else
                        roiTable.refresh(d, name);
                    end                    
                end
            end
        end
        
        function SaveFiles(results, file, showFalsePosNeg)
            File.SaveTextFile(File.SwitchExtension(file, '.csv'), ...
                [results.csvHead results.csvBody]);
            if ~isempty(results.falsePosNegBody)
                fpnFile=File.SwitchExtension(file, '.txt');
                File.SaveTextFile(fpnFile, ...
                    [results.falsePosNegHead results.falsePosNegBody]);
                if nargin>2 && showFalsePosNeg
                    FalsePositiveNegative.Plot([0 1], fpnFile);
                end
            end
        end
        
        function matchedLabels=GetMatches(data, qf, tNames, labelMap, density, ...
                clusterIds, numClusters)
            [~, sCnt, supr1stIdx4Clue, clusterMatch]=qf.getMatches;
            D=size(data,2);
            cluMdns=zeros(numClusters, D);
            clusterLabels=cell(1,numClusters);
            clusterNames=cell(1,numClusters);
            clusterColors=cell(1,numClusters);
            newSubsets=0;
            matchedLabels=zeros(size(data, 1), 1);
            for i=1:numClusters
                l=clusterIds==i;
                if sCnt(i)==0
                    newSubsets=newSubsets+1;
                    clusterLabel=0-i;
                    clusterNames{i}=['New subset #' num2str(newSubsets) ];
                    clr=num2str(Supervisors.NewColor(newSubsets));
                else
                    clusterLabel=clusterMatch(i);
                    clusterNames{i}=tNames{supr1stIdx4Clue(i)};
                    clr=labelMap.get([num2str(clusterLabel) '.color']);
                end
                clusterColors{i}=clr;
                clusterLabels{i}=clusterLabel;
                matchedLabels(l)=clusterLabel;
                cluMdns(i,:)=median(data(l,:));
            end
            density.setLabels(matchedLabels, clusterNames, ...
                clusterColors, cluMdns, clusterLabels);
        end
            
        function DrawClusterBorders(ax, density, clr)
            wasHeld=ishold(ax);
            if ~wasHeld
                hold(ax, 'on');
            end
            N_=length(density.clusterColors);
            for i=1:N_
                if nargin<3
                    clr=(str2double(density.clusterColors{i})/256)*.85;
                end
                gridEdge(density, true, i, clr, ax, .8, '.', '-', .5);
                if Supervisors.VERBOSE
                    str2double(density.clusterColors{i})
                    disp(['clr = ' num2str(clr)]);
                    disp('ok');
                end
            end
            if ~wasHeld
                hold(ax, 'off');
            end
        end
        
        function [names, clrs]=GetNamesClrs(lbls, lblMap)
            ids=unique(lbls);
            ids(ids <= 0) = [];
            N_=length(ids);
            names=cell(1,N_);
            clrs=zeros(N_,3);
            for i=1:N_
                id=ids(i);      
                key=num2str(id);
                names{i}=lblMap.get(java.lang.String(key));
                if isempty(names{i})
                    names{i}=key;
                end
                clr_=lblMap.get([key '.color']);
                if isempty(clr_)
                    clrs(i,:)=[.95 .9 .99];
                else
                    clrs(i,:)=str2num(clr_)/256; %#ok<ST2NM>
                end         
            end
        end
        
       function sc=GetMatchScenarioText(scenario, reductionType)
            if scenario==1
                sc='training/test';
            elseif scenario==2
                sc='training/ust';
            else
                if scenario==3
                    sc=[reductionType '/test'];
                else
                    sc=[reductionType '/test*'];
                end
            end
        end
        
        function mt=GetMatchTypeText(matchType, reductionType, reducedD, unreducedD)
            if isequal(reductionType, UMAP.REDUCTION_SUPERVISED_TEMPLATE)
                if matchType==0
                    mt='cluMd';
                elseif matchType==1
                    mt='cluQf';
                elseif matchType==2
                    mt='cluNn';
                elseif matchType==3
                    mt=['nn ' num2str(reducedD) 'D'];
                else
                    mt=['nn ' num2str(unreducedD) 'D'];
                end
            else
                mt='cluQf ';
            end
        end

        function mt=GetMatchTypeLongText(matchType, reductionType, reducedD, unreducedD)
            if isequal(reductionType, UMAP.REDUCTION_SUPERVISED_TEMPLATE)
                if isempty(reducedD)
                    lowD='low D space';
                else
                    lowD=[num2str(reducedD) 'D space'];
                end
                if matchType==0
                    mt='Cluster median';
                elseif matchType==1
                    mt='Cluster dis-<br>similarity';
                elseif matchType==2
                    mt=['Cluster nearest neighbor<br>in ' lowD];
                elseif matchType==3
                    mt=['Nearest neigbor <br>in ' lowD];
                else
                    mt=['Nearest neigbor<br>in ' num2str(unreducedD) 'D space'];
                end
            else
                mt='Basic reduction<br>Cluster dissimilarity';
            end
        end

        function s=GetReductionLongText(rt)
            switch(rt)
                case UMAP.REDUCTION_BASIC
                    s='basic';
                case UMAP.REDUCTION_SUPERVISED
                    s='supervised';
                case UMAP.REDUCTION_TEMPLATE
                    s='basic template';
                otherwise
                    s='supervised template';
            end
            s=[s ' (' rt ')'];
        end
        
        function cnt=CountMatchOps(args, nSplits)
            if nargin<2
                nSplits=2;%splitting sample into test set + TWO test sets
            end
            nMatchScenarios=length(args.match_scenarios);
            if any(args.match_scenarios==1)
                cnt=nSplits;%2 parts of each test
                nUstScenarios=nMatchScenarios-1;
            else
                cnt=0;
                nUstScenarios=nMatchScenarios;
            end
            nMatchTypes=length(args.match_supervisors);
            cnt=cnt+(nUstScenarios*nSplits*nMatchTypes);
            if ischar(args.cluster_detail)
                nDtls=1;
            else
                nDtls=length(args.cluster_detail);
            end
            if nDtls>1
                if any(args.match_supervisors==1)
                    cnt=cnt+(nUstScenarios*nSplits*(nDtls-1));
                end
                if any(args.match_supervisors==2)
                    cnt=cnt+(nUstScenarios*nSplits*(nDtls-1));
                end
            end
        end
        
        function [result, existence, missingFiles]=...
                RelocateExamples(files, tryDownload, ignore)
            if nargin<3
                ignore={};
                if nargin<2
                    tryDownload=true;
                end
            end
            testExistence=nargout>1;
            existence=[];
            missingFiles={};
            argType='cell';
            if isstruct(files)
                argType='struct';
                args=files;
                files={};
                if ischar(args.csv_file_or_data)
                    files{end+1}=args.csv_file_or_data;
                end
                if ~isempty(args.label_file)
                    files{end+1}=args.label_file;
                end
                if ~isempty(args.template_file)
                    files{end+1}=args.template_file;
                end
                if ~isempty(args.color_file)
                    files{end+1}=args.color_file;
                end
            elseif ischar(files)
                argType='char';
                files={files};
            end
            missingExamples=java.util.HashMap;
            N=length(files);
            fileUrls={};
            localFiles={};
            lsf=UmapUtil.LocalSamplesFolder;
            for i=1:N
                file=files{i};
                if ~exist(file, 'file')
                    if ~ispc
                        if file(1)=='~'
                            file=[File.Home file(2:end)];
                        end
                    end
                end
                if ~exist(file, 'file')
                    [fldr, fn, ext]=fileparts(file);
                    if isempty(fldr) || isequal(lsf, fldr)
                        fldr=lsf;
                        File.mkDir(fldr);
                        file2=fullfile(fldr, [fn ext]);
                        missingExamples.put(java.lang.String(file), java.lang.String(file2));
                        
                        if ~exist(file2, 'file') && tryDownload
                            fileUrls{end+1}=...
                                WebDownload.ResolveUrl([fn ext]);
                            localFiles{end+1}=file2;
                        end
                    end
                end
            end
            downloadFailures=[];
            if ~isempty(fileUrls)
                nMissing=length(fileUrls);
                [cancelledByUser, bad]=WebDownload.Get(...
                    fileUrls, localFiles, false);
                if cancelledByUser
                elseif bad==0
                    msg(Html.WrapHr([ String.Pluralize2('file', ...
                        nMissing) ' downloaded to<br><b>' ...
                        BasicMap.Global.smallStart ...
                        UmapUtil.LocalSamplesFolder...
                        BasicMap.Global.smallEnd '</b>']), 8, ...
                        'south east+');
                else
                    
                    if bad==nMissing
                        downloadFailures=[String.Pluralize2('file', ...
                            nMissing) ' NOT downloaded'];
                    else
                        downloadFailures=[ num2str(bad) ' of '...
                            String.Pluralize2('file', ...
                            nMissing) ' NOT downloaded'];
                    end
                end
            end
            if isequal(argType, 'struct')
                if ischar(args.csv_file_or_data)
                    args.csv_file_or_data=grab(args.csv_file_or_data);
                end
                args.label_file=grab(args.label_file);
                args.template_file=grab(args.template_file);
                args.color_file=grab(args.color_file);
            else
                for i=1:N
                    files{i}=grab(files{i});
                end
            end
            if isequal(argType, 'cell')
                result=files;
            elseif isequal(argType, 'struct')
                result=args;
            else %argType == char
                result=files{1};
            end
            if any(~existence) && ~isempty(missingFiles)
                if ~isempty(ignore)
                    [~, canIgnore]=StringArray.EndsWith(missingFiles, ignore);
                else
                    canIgnore=false;
                end
                if ~canIgnore
                    app=BasicMap.Global;
                    html=Html.Wrap([app.h2Start 'Missing files' ...
                        app.h2End downloadFailures app.smallStart ...
                        Html.ToList(missingFiles, 'ol') app.smallEnd '<hr>']);
                    msgWarning(html, 11, 'south', 'Missing files...');
                else
                    existence(:)=2;
                end
            end
            
            function out=grab(in)
                out=in;
                if ~isempty(in)
                    key=java.lang.String(in);
                    if missingExamples.containsKey(key)
                        if tryDownload
                            out=char(missingExamples.get(key));
                        else
                            out='';
                        end
                    else
                        if in(1)=='~'
                            out=[File.Home in(2:end)];
                        end
                    end
                end
                if testExistence
                    existence(end+1)=exist(out, 'file');
                    if ~existence(end)
                        missingFiles{end+1}=out;
                    end
                end
            end
        end
        
        function [results, ok]=ExtendResultsHtmlHead(extras, results)
            ok=false;
            if ~isempty(extras.matchHtmlHead1)
                if isfield(results, 'htmlHead1')
                    results.htmlHead1=[results.htmlHead1 extras.matchHtmlHead1];
                    results.htmlHead2=[results.htmlHead2 extras.matchHtmlHead2];
                    results.htmlHead3=[results.htmlHead3 extras.matchHtmlHead3];
                    ok=true;
                end
            end
        end
        
        function results=SetResultsHtmlRow(results)
            if isfield(results, 'htmlBody')
                results.htmlBody=[results.htmlBody '<tr>' results.row '</tr>'];
                results.row='';
            end
        end
        
        function [results, ok]=CollectResults(extras, results)
            if ~isempty(extras.matchHtmlHead1)
                ok=true;
                if ~isfield(results, 'csvBody')
                    results.htmlHead1=extras.matchHtmlHead1;
                    results.htmlHead2=extras.matchHtmlHead2;
                    results.htmlHead3=extras.matchHtmlHead3;
                    results.htmlBody='';
                    results.row=extras.matchHtmlBody;
                    results.csvHead=extras.matchCsvHead;
                    results.csvBody=extras.matchCsvBody;
                    results.falsePosNegHead=extras.falsePosNegHead;
                    results.falsePosNegBody=extras.falsePosNegBody;
                else
                    results.row=[results.row extras.matchHtmlBody];
                    results.csvBody=[results.csvBody extras.matchCsvBody];
                    results.falsePosNegBody=[results.falsePosNegBody ...
                        extras.falsePosNegBody];
                end
            else
                ok=false;
            end
        end
        
        function [args, argued]=Initialize(varargin)
            initJava;
            pth=fileparts(mfilename('fullpath'));
            pPth=fileparts(pth);
            utilPath=fullfile(pPth, 'util');
            addpath(utilPath);
            FileBasics.AddNonConflictingPaths({pth, utilPath});
            if nargin>0
                if length(varargin)==1 && isstruct(varargin{1}) ...
                        && isfield(varargin{1}, 'n_components')
                    args=varargin{1};
                    argued=[];
                else
                    [args, argued]=UmapUtil.GetArgs(varargin{:});
                end
            else
                [args, argued]=UmapUtil.GetArgs(varargin{:});
            end
        end
        
        function [nLoDs, nRunUmaps, dataSetsTxt, dataSetTxt]...
                =InitProgress(args, pu, nDataSets, nSplits, hiR, hiD)
            if nargin<4
                nSplits=2;
                if nargin<3
                    nDataSets=1;
                end
            end
            nLoDs=length(args.ust_test_components);
            nUstMatchOps=UmapUtil.CountMatchOps(args, nSplits);
            nOps=nDataSets*nUstMatchOps;
            nSetsBySplits=nDataSets*nSplits;
            if args.ust_test_basic_reduction
                if nLoDs>1
                    loDTxt=[num2str(nLoDs) ' loDs X ('];
                    endTxt=')';
                else
                    loDTxt='';
                    endTxt='';
                end
                args2.cluster_detail=args.cluster_detail;
                sc=args.match_scenarios(args.match_scenarios>2);
                if isempty(sc)
                    sc=4;
                end
                args2.match_scenarios=sc;
                args2.match_supervisors=1;
                nUbMatchOps=UmapUtil.CountMatchOps(args2, nSplits);
                nOps=nOps+(nDataSets*nUbMatchOps);
                nRunUmaps=nSetsBySplits*2;
                dataSetsTxt=[loDTxt num2str(nSetsBySplits) ' ust X ' ...
                    num2str(nUstMatchOps/nSplits) ' matches + ' ...
                    num2str(nSetsBySplits) ' ub X '...
                    num2str(nUbMatchOps/nSplits) ' matches' endTxt];
                
            else
                if nLoDs>1
                    loDTxt=[num2str(nLoDs) ' loDs X '];
                else
                    loDTxt='';
                end
                dataSetsTxt=[loDTxt, num2str(nSetsBySplits) ' ust X '...
                    num2str(nUstMatchOps/nSplits) ' matches'];
                nRunUmaps=nSetsBySplits;
            end
            if nargin>=6
                dataSetTxt=[String.encodeInteger(hiR)...
                    'x' num2str(hiD) 'D' ];
                pu.setText(['Starting ' dataSetsTxt ' on ' dataSetTxt]);
                pu.dlg.setTitle(['UstTest: ' dataSetsTxt]);
            end
            pu.initProgress((nRunUmaps+nOps)*nLoDs);
        end
        
        function GoogleDrive(btn, stop, examplesOnly)
            if nargin<3
                examplesOnly=false;
                if nargin<2
                    stop=false;
                    if nargin<1
                        btn=[];
                    end
                end
            end
            fldr=UmapUtil.LocalSamplesFolder;
            url='https://drive.google.com/drive/folders/1VXj6J0D-Z8qE6rkPIx35FIkcOhNWjnrq?usp=sharing';
            web(url, '-browser');
            MatBasics.RunLater(@(h,e)advise(btn), 3);
            function advise(btn)
                h2=Html.H2('Downloading from our Google Drive');
                font1='"<font color="#006699">';
                font2='"<font color="blue">';
                fontEnd='</font>"';
                html=['<b>To use our examples....</b><ol>'...
                    '<li>Download all files from folder ' ...
                    font1 'examples' fontEnd '"' ...
                    '<li>Move files to<br>' font2 fldr fontEnd ...
                    '</ol>'];
                if ~examplesOnly
                    html=['<ul><li>' html ...
                        '<li><b>To get complete UMAP submission</b><ol>'...
                        '<li>Download ' ...
                        font1 'umapDistribution.zip' fontEnd '".'...
                        '<li>Remove the incomplete submission you '...
                        'downloaded from File Exchange'...
                        '</ol>',...
                        '<li><b>To ONLY get faster mex &amp; m code</b><ol>'...
                        '<li>If using a MAC download <ul><li>' font1 ...
                        'mexStochasticGradientDescent'...
                        '.mexmaci64' fontEnd ...
                        '<li>' font1 ...
                        'nn_descent'...
                        '.mexmaci64' fontEnd '</ul>'...
                        '<li>If using MS Windows download <ul><li>' ...
                        font1 'mexStochasticGradientDescent'...
                        '.mexw64' fontEnd ...
                        '<li>' font1 ...
                        'nn_descent'...
                        '.mexw64' fontEnd '</ul>'...
                        '<li>Download' font1 'lobpcg.m' fontEnd...
                        '<li>Move the mex & m file to your folder<br>'...
                        font2 fileparts(mfilename('fullpath')) fontEnd...
                        '</ol>'];
                end
                html=[html '</ul><br>THANK YOU!'];
                ttl='Advice on downloading';
                if  stop 
                    if ~isempty(btn)
                        jw=Gui.WindowAncestor(btn);
                    else
                        jw=[];
                    end
                    msgTxt=Html.Wrap([h2 html '<hr>']);
                    msgModalOnTop(msgTxt, 'south east++', ...
                        jw, 'facs.gif', ttl);
                else
                    jd=msg(Html.Wrap([h2 html '<hr>']), 0, 'south++', ttl);
                    jd.setAlwaysOnTop(true);
                end
            end
        end
        
        function OfferFullDistribution(stop)
            if nargin<1
                stop=false;
            end
            rel=@(x)['<b><font color="blue">' x '</font></b> UMAP'];
            full=rel('full');
            basic=rel('basic');
            if stop
                br='<br>';
            else
                br=' ';
            end
             preamble=['Our ' basic ' lacks our advanced accelerants'...
                    ' because' br '<b>MathWorks File Exchange</b> disallows'...
                    ' mex binary files and<br>3rd party plugins '...
                    'that lack a full BSD open source license.'...
                    '<hr><br><b>HOWEVER....there ARE solutions '...
                    'to speed things up!!!</b>'];
               
            if stop
                choices={'Download all our UMAP accelerants directly',...
                    'Build our mex binaries from our open source',...
                    ['<html>Download our ' full ...
                    ' (umapDistribution.zip)</html>'],...
                    ['<html>Access our ' full ' &amp; examples '...
                    'on GoogleDrive</html>']};
                [choice, cancelled]=Gui.Ask(Html.Wrap(preamble), choices, ...
                    'umapFullDistribution', ...
                    'MathWorks File Exchange restrictions!', 1);
                if cancelled
                    return;
                end
                if choice==1
                    UmapUtil.DownloadAdditions(false, 'accelerants');
                elseif choice==2
                    build;
                elseif choice==3
                    UmapUtil.DownloadAdditions(true, 'full');
                elseif choice==4
                    UmapUtil.GoogleDrive([], true)
                end
            else
                b1=Gui.NewBtn('Download accelerants', ...
                    @(h,e)UmapUtil.DownloadAdditions(false, 'accelerants', h), ...
                    'Download the missing mex files and lobpcg.m', 'downArrow.png');
                b2=Gui.NewBtn('Build mex binaries', @(h,e)build(h), ...
                    'Do mex build (mex -setup cpp must FIRST be run)', 'wrench.png');
                b3=Gui.NewBtn('Download umapDistribution.zip', ...
                    @(h,e)UmapUtil.DownloadAdditions(true, 'full', h), ...
                    'Download all of our UMAP distribution!', 'world_16.png');
                b4=Gui.NewBtn(['<html>Access ' full ...
                    ' &amp; examples</html>'], ...
                    @(h,e)UmapUtil.GoogleDrive(h, stop), ...
                    ['Download mex files, lobpcg.m full distribution '...
                    'PLUS samples', 'downArrow.png']);
                sw=Gui.Panel;
                sw.add(b1);
                sw.add(b2);
                sw.add(b3);
                sw.add(b4);
                bp=Gui.BorderPanel;
                bp.add(sw, 'South');
                bp.add(javax.swing.JLabel(Html.Wrap([preamble  '<ul>'...
                    '<li>Download all our UMAP accelerants directly'...
                    ' (mex binaries and lobpcg.m)'...
                    '<li>Build the mex binaries with our scripts '...
                    'umap/InstallMexAndExe.m &amp; umap/KnnFind.Build'...
                    '<li>Download our ' full 'distribution contained in'...
                    ' umapDistribution.zip<li>Access our ' full ...
                    ' and all of examples on our GoogleDrive<hr>'])), 'Center');
                msg(bp, 0, 'north east++', 'MathWorks File Exchange restrictions!', ...
                    'warning.png');
            end
            
            
            function build(h)
                if nargin>0
                    wnd=Gui.WindowAncestor(h);
                end
                app=BasicMap.Global;
                msg(Html.Wrap(['Build results are reported in MatLab ''Command window'''...
                    '<br><br>' app.smallStart '<b><font color="red">'...
                    'NOTE:&nbsp;&nbsp;</font>You must have done the MEX setup '...
                    'first to attach a C++ <br>compiler to MatLab... '...
                    'CLang++ is the compiler we prefer for speed.</b>' ...
                    '<br><br>To do the setup type "<font color="blue">'...
                    'mex -setup cpp</font>" in MatLab''s '...
                    'command window.' app.smallEnd '<hr>']));
                if nargin>0
                    wnd.dispose;
                end
                UmapUtil.DownloadAdditions(false, 'lobpcg');
                InstallMexAndExe
                KnnFind.Build
            end      
            
        end
        
        function counts = discreteCount(x, labels)
            if isempty(labels)
                counts = [];
                return;
            end
            if ~any(isinf(labels))
                labels(end+1) = inf;
            end
            counts = histcounts(x, labels);
        end
        
        function ok=DownloadAdditions(ask, which, h)
            ok=false;
            if nargin<3
                h=[];
                if nargin<2
                    which='accelerants';
                    if nargin<1
                        ask=true;
                    end
                end
            end
            exeNN=UmapUtil.LocateMex;
            if isequal(which, 'lobpcg')
                lob='lobpcg.m';
                [from, to, cancelled]=gather(fileparts(mfilename('fullpath')), ...
                    lob);
            elseif isequal(which, 'nn_descent')
                [from, to,cancelled]=gather(...
                    fileparts(mfilename('fullpath')), exeNN);
            elseif isequal(which, 'accelerants')
                exeSGD=UmapUtil.LocateMex('sgd');
                lob='lobpcg.m';
                if ~isempty(h)
                    wnd=Gui.WindowAncestor(h);
                    wnd.dispose;
                end
                [from, to, cancelled]=gather(...
                    fileparts(mfilename('fullpath')), ...
                    exeSGD, exeNN, lob);
            else
                [from, to, cancelled]=gather(...
                    fullfile(File.Home, 'Downloads'), ...
                    'umapDistribution.zip');
                if isempty(from) && ~cancelled
                    instructUnzip
                end
            end
            if isempty(from)
                ok=~cancelled;
                return;
            end
            [cancelled, bad]=WebDownload.Get(from, to, false, true);
            if ~cancelled && ~bad && ~isequal(which, 'lobpcg')
                ok=true;
                if ~isequal(which, 'nn_descent') && ~isequal(which, 'accelerants')
                    instructUnzip;
                else
                    msg(Html.WrapHr('<b>The accelerants are downloaded!</b>'),...
                        5, 'north+', '', 'genieSearch.png');
                end
            end
            
            function instructUnzip
                msg(Html.WrapHr(['<html>umapDistribution.zip has been '...
                    'downloaded to<br><b>' fullfile(File.Home, 'Downloads') ...
                    '</b><hr><br><b>Note</b>: you <b>must replace</b> the '...
                    'current basic umap by<br>unzipping this zip file over'...
                    ' top of this installation...']), 0, 'south++');
            end
            
            function [from, to, cancelled]=gather(toFolder, varargin)
                cancelled=false;
                from={};
                to={};
                N=length(varargin);
                have=false(1,N);
                haveAlready={};
                doNotHave={};
                for i=1:N
                    if exist(fullfile(toFolder, varargin{i}), 'file')
                        haveAlready{end+1}=varargin{i};
                        have(i)=true;
                    else
                        doNotHave{end+1}=varargin{i};
                    end
                end
                if ~ask
                    overwrite=false;
                elseif ~isempty(haveAlready)
                    if isempty(doNotHave)
                        [overwrite, cancelled]=askYesOrNo(Html.Wrap([...
                            'Overwrite the following...?<hr>'...
                            Html.ToList(haveAlready, 'ul') ...
                            ' in the folder <br>' ...
                            Html.WrapBoldSmall(toFolder) '??<hr>' ]));
                        if cancelled
                            return;
                        end
                    else
                        labels={['Only download the ' String.Pluralize2(...
                            'missing item', length(doNotHave))...
                            '...'], ['Download EVERYTHING '...
                            'including the ' String.Pluralize2(...
                            'pre-exisitng item', length(haveAlready)) ]};
                        [choice, cancelled]=Gui.Ask(Html.Wrap([...
                            'These files pre-exist...'...
                            Html.ToList(haveAlready, 'ul') ...
                            ' in the folder <br>' ...
                            Html.WrapBoldSmall(toFolder) ...
                            '<hr>HENCE I will ...' ]), ...
                            labels);
                        if cancelled
                            return;
                        end
                        overwrite=choice==2;
                    end
                else
                    overwrite=true;
                end
                if ~overwrite && all(have)
                    if isequal(which, 'accelerants')
                        msg('You were already fully up to date!');
                    end
                end
                for i=1:N
                    if overwrite || ~have(i)
                        from{end+1}=...
                            WebDownload.ResolveUrl(varargin{i}, 'run_umap');
                        to{end+1}=fullfile(toFolder, varargin{i});
                    end
                end
            end
        end
        
        function [file, fullFile, umapFolder]=LocateMex(which)
            if nargin==0 || ~strcmpi(which, 'sgd')
                file=['nn_descent.' mexext];
            else
                file=['mexStochasticGradientDescent.' mexext];
            end
            if nargout>1
                umapFolder=fileparts(mfilename('fullpath'));
                fullFile=fullfile(umapFolder, file);
            end
        end

        function UstNew3(csv, n_neighbors, metric, dist_args)
            if nargin<4
                dist_args=[];
                if nargin<3
                    metric='euclidean';
                    if nargin<2 
                        n_neighbors=15;
                        if nargin<1 || isempty(csv)
                            csv=29;
                        end
                    end
               
                end
            end
            if isnumeric(csv) && csv==29
                csv='s3_samusikImported_29D';
            end            
            run_umap([csv '.csv'], 'label_column', 'end', 'label_file', ...
                [csv '.properties'], 'n_components', 3, ...
                'save_template_file', ['ust_' csv '.mat'], ...
                'n_neighbors', n_neighbors,...
                'color_defaults', true, ...
                'metric', metric, 'dist_args', dist_args);
        end
            
        %run_umap('s2_samusikImported_29D.csv', 'template_file', 'ust_s1_samusikImported_29D_15nn_3D.mat', 'label_column', 'end', 'label_file', 's2_samusikImported_29D.properties', 'match_scenarios', [1 2 4],  'match_histogram_fig', false, 'see_training', true, 'false_positive_negative_plot', true, 'match_supervisors', [3 1 4], 'verbose', verbose);
        function UstRun(csv, tmplt, false_positive_negative_plot, ...
            match_supervisors, match_scenarios, match_histogram_fig)
            if nargin<6
                match_histogram_fig=false;
                if nargin<5
                    match_scenarios=4;
                    if nargin<4
                        match_supervisors=3;
                        if nargin<3
                            false_positive_negative_plot=true;
                            if nargin<2 
                                tmplt=[];
                                if nargin<1
                                    csv=29;
                                end
                            end
                        end
                    end
                end
            end
            if isempty(tmplt)
                tmplt='s3_samusikImported_29D';
            end
            if isnumeric(csv) && csv==29
                csv='s2_samusikImported_29D';
            end
            run_umap([csv '.csv'], 'label_column', 'end', 'label_file', ...
                [csv '.properties'], 'match_scenarios', match_scenarios,...
                'template_file', ['ust_' tmplt '.mat'], ...
                'match_supervisors', match_supervisors,...
                'false_positive_negative_plot', false_positive_negative_plot, ...
                'match_histogram_fig', match_histogram_fig,...
                'color_file', '',...
                'see_training', true);
        end
        
        function fl=GetFile(fileName)
            if nargin<1
                fileName='cytofExample.csv';
            end
            fl=fullfile(File.Home, 'Documents', 'run_umap', 'examples', fileName);
            if ~exist(fl, 'file')
                url=WebDownload.ResolveUrl(fileName);
                WebDownload.Get({url}, {fl}, false, false, 'south');
            end
        end

        function [data, labels]=Compress(data, labels, dataSetFactor, classFactor)
            if nargin<4
                classFactor=0;
            end
            R=size(data, 1);
            if dataSetFactor==1
                return;
            end
            if floor(dataSetFactor)~=dataSetFactor
                sz=floor(dataSetFactor*R);
            else
                sz=dataSetFactor;
            end
            if sz>=R
                warning('%s factor produces %d and data set has %d rows',...
                    String.encodeRounded(dataSetFactor,2), sz, sz);
                return;
            end
            r=randperm(R);
            r=r(1:sz);
            if ~isempty(labels)
                if classFactor>0
                    uOriginal=unique(labels)';
                    cntsOriginal=MatBasics.HistCounts(labels, uOriginal);
                    smallestSubset=min(cntsOriginal);
                    isRatio=floor(classFactor)~=classFactor;
                    if isRatio
                        minimum=classFactor*smallestSubset;
                    else
                        minimum=classFactor;
                        if any(minimum>cntsOriginal)
                            warning(...
                                ['BEFORE compression %d is > '...
                                'than %d subset(s):'...
                                '  labels=[%s]. Counts=[%s]'], ...
                                minimum, sum(minimum>cntsOriginal), ...
                                MatBasics.toString(...
                                uOriginal(minimum>cntsOriginal)), ...
                                MatBasics.toString(...
                                cntsOriginal(minimum>cntsOriginal))...
                                );
                        end
                    end
                    temp=labels(r);
                    uCompressed=unique(temp)';
                    cntsCompressed=MatBasics.HistCounts(temp, uCompressed);
                    missing=uOriginal(~ismember(uOriginal, uCompressed));
                    tooSmallR=uCompressed(minimum>cntsCompressed);
                    needToIncrease=[missing tooSmallR];
                    nTooSmallLabels=length(needToIncrease);
                    if nTooSmallLabels>0
                        r=r(~ismember(temp, needToIncrease));
                        for i=1:nTooSmallLabels
                            label=needToIncrease(i);
                            idxs=find(labels==label)';
                            nIdxs=length(idxs);
                            if nIdxs<=minimum
                                r=[r idxs];
                            else
                                r2=randperm(nIdxs);
                                r=[r idxs(r2(1:minimum))];
                            end
                        end
                    end
                    data=data(r,:);
                    labels=labels(r);
                    if nTooSmallLabels>0
                        cntsCompressedScaledUp=MatBasics.HistCounts(labels, uCompressed);
                        originalTooSmall=uOriginal(minimum>cntsOriginal);
                        newTooSmall=~ismember(needToIncrease, originalTooSmall);
                        if any(newTooSmall)
                            % make nice report for warning
                            newTooSmallLabels=needToIncrease(newTooSmall);
                            N2=length(newTooSmallLabels);
                            s='';
                            for j=1:N2
                                label=newTooSmallLabels(j);
                                cnt1=cntsOriginal(find(uOriginal==label,1));
                                idx2=find(uCompressed==label,1);
                                if idx2==0
                                    cnt2=0;
                                else
                                    cnt2=cntsCompressed(idx2);
                                end
                                s=[s sprintf('[%d %d %d] ', label, cnt1, cnt2)];
                            end
                            warning('labels=[%s]. Counts=[%s]', ...
                                MatBasics.toString(uCompressed), ...
                                MatBasics.toString(cntsCompressedScaledUp));
                            warning(...
                                ['AFTER compression %d subsets '...
                                'were scaled up to %d),'...
                                '  [label before compressed]:  %s'], ...
                                N2, minimum, s); 
                        end
                    end
                else
                    data=data(r,:);
                    labels=labels(r);
                end
            else
                data=data(r,:);
            end
        end
        
        function [synData, synLabels]=Synthesize(...
                data, labels, classFactor, dataSetFactor, verbose)
            if nargin<5
                verbose=false;
            end
            N=size(labels, 1);
            if dataSetFactor<UmapUtil.SYNTHESIZE_MAX_RATIO(1) ...
                    && floor(dataSetFactor)~=dataSetFactor
                dataSetFactor=dataSetFactor*N;
            end
            if classFactor==0
                [synData, synLabels]=generate_synthetic_set(data, labels,...
                    'size', dataSetFactor);
            else
                [tp, cntsOriginal, cntsResized]=...
                    UmapUtil.GetSyntheticClassProps(...
                    labels, classFactor, dataSetFactor);
                [synData, synLabels]=generate_synthetic_set(data, labels,...
                    'size', dataSetFactor, 'targetProps', tp);
                
                cntsSyn=MatBasics.HistCounts(synLabels);
                if verbose
                    num2str([cntsOriginal;cntsResized;cntsSyn])
                end
            end
        end
        
        function [tp, cntsOriginal, cntsResized]=GetSyntheticClassProps(...
                labels, minimum, sz)
            N=length(labels);
            u=unique(labels)';
            nIds=length(u);
            tp=ones(1,nIds);
            cntsOriginal=MatBasics.HistCounts(labels, u);
            if minimum<UmapUtil.SYNTHESIZE_MAX_RATIO(2)...
                    && floor(minimum)~=minimum
                minimum=minimum*min(cntsOriginal);
            end
            cntsResized=floor(cntsOriginal*(sz/N));
            l=cntsResized<minimum;
            if any(l)
                boost=minimum./cntsResized(l);
                tp(l)=boost;
                cntsResized=ceil(tp.*cntsResized);
            end
            tp=cntsResized/sum(cntsResized);
        end
        
        function s=EncodeCompressOrSynthesize(arg, compressing)
            s='';
            if ~isempty(arg) && arg(1)~=1
                if compressing
                    abbrev='cmp';
                else
                    abbrev='syn';
                end
                if floor(arg(1))==arg(1)
                    s=['_' abbrev num2str(arg(1))];
                else
                    s=['_' abbrev num2str(floor(100*arg(1))) '%' ];
                end
                if length(arg)==2
                    if floor(arg(2))==arg(2)
                        s=[s ',' num2str(arg(2))];
                    else
                        s=[s ',' num2str(floor(100*arg(2))) '%'];
                    end
                end
            end
        end
        
        function [name, ustTemplateName]=...
                SampleNameFromArgs(args, forTrainingSet)    
            %args required fields
            %   test_set        # for prefix in set s1_*, s2_* etc
            %   training_set    same as above but for training_set
            %   gate            omip69_35D, samusik_29D etc
            %   compress        compression args
            %   synthesize      synthesize args
            %   run_umap        args for run_umap use metric, Distance,
            %                   n_neighbors and K in name
            %   
            
            strDist='';
            strD='';
            if forTrainingSet                
                strCompress=UmapUtil.EncodeCompressOrSynthesize(...
                    args.compress, true);
                strSynthesize=UmapUtil.EncodeCompressOrSynthesize(...
                    args.synthesize, false);
                prefix='ust_';
                if ~isempty(args.run_umap)
                    D=Args.Get('n_components', args.run_umap{:});
                    if ~isempty(D)
                        strD=['_' num2str(D) 'D'];
                    end
                    nn=Args.Get('n_neighbors', args.run_umap{:});
                    if isempty(nn)
                        nn=Args.Get('K', args.run_umap{:});
                    end
                    metric=Args.Get('Distance', args.run_umap{:});
                    P=Args.Get('P', args.run_umap{:});
                    if ~isempty(nn)
                        strDist=['_' num2str(nn) 'nn'];
                    end
                    if ~isempty(metric)
                        if ~strcmpi('euclidean', metric)
                            strDist=[strDist '_' metric];
                            if ~isempty(P)
                                strDist=[strDist '_' num2str(P) 'P'];
                            end
                        end
                    end
                end
                
                name=['s' num2str(args.training_set) '_' args.gate];
                ustTemplateName=[prefix name strCompress strSynthesize ...
                    strDist strD];
            else
                name=['s' num2str(args.test_set) '_' args.gate];
                ustTemplateName=[];
            end
        end
    end
    
    
end