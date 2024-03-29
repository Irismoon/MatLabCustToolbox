%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
%   Math Lead & Secondary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Bioinformatics Lead:  Wayne Moore <wmoore@stanford.edu>
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%
classdef SortedStringSet < handle
    properties(SetAccess=private)
        ts;
    end
    methods
        function this=SortedStringSet(caseInsensitive, isVararginNamedValues, varargin)
            if nargin==0 || ~caseInsensitive
                this.ts=java.util.TreeSet;
            else
                this.ts=java.util.TreeSet(java.lang.String.CASE_INSENSITIVE_ORDER);
            end
            if nargin>1
                if ischar(isVararginNamedValues)
                    a=[isVararginNamedValues varargin];
                    this.addAll(a{:});
                else
                    assert(islogical(isVararginNamedValues));
                    if nargin>2
                        if isVararginNamedValues
                            this.addNames(varargin{:});
                        else
                            this.addAll(varargin{:});
                        end
                    end
                end
            end
        end
        
        function ok=contains(this, item)
            ok=this.ts.contains(java.lang.String(item));
        end
        
        function ok=add(this, item)
            ok=this.ts.add(java.lang.String(item));
        end
        
        function ok=remove(this, item)
            ok=this.ts.remove(java.lang.String(item));
        end
        
        function addAll(this, varargin)
            N=length(varargin);
            for i=1:N
                this.ts.add(java.lang.String(varargin{i}));
            end
        end
        
        function addNames(this, varargin)
            N=length(varargin);
            for i=1:2:N
                this.ts.add(java.lang.String(varargin{i}));
            end
        end
    end
    
    methods(Static)
        function this=New(p)
            s=p.Results;
            params=p.Parameters;
            ud=StringArray.Set(p.UsingDefaults, java.util.HashSet);
            argued={};
            N=length(params);
            for i=1:N
                if ~ud.contains(java.lang.String(params{i}))
                    argued{end+1}=params{i};
                end
            end
            this=SortedStringSet(true, false, argued{:});
        end
    end
end