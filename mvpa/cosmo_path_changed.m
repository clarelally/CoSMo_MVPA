function path_changed=cosmo_path_changed(set_stack_counter_)
% helper function to detect changes in the matlab path
%
% path_changed=cosmo_path_changed(set_stack_counter_)
%
% Inputs:
%   set_stack_counter_     Optional argument that changes the internal
%                          state of this function. Can be on of:
%                          'on':     enables checking for changes
%                          'off':    disables checking for changes
%                          'push':   disables checking for changes
%                          'pop':    when called after 'push', resets the x
%                                    for changes before the last 'push'
%                          'update': force check for changes in the path
%                          'not_here': like 'push', but returns a function
%                                      handle that does a pop
%
% Output:
%   path_changed           Boolean (true or false) indicating whether the
%                          path has changed since the last call. If the
%                          input is 'not_here' a function handle is
%                          returned that does a pop
%
% Notes:
%   - the rationale for this function is that it takes time to check for
%     changes in the matlab path. Code can be optimized in functions where
%     the path will not change.
%   - in a function where the path will not change, one can add a line
%        on_cleanup_=onCleanup(cosmo_path_changed('not_here'));
%     which will do a 'push' immediately and ensures a 'pop' is done when
%     leaving the function
%     
% NNO Aug 2014

    persistent cached_path_    % path from last call
    persistent stack_counter_  % #push minus #pop
    persistent func_me_        % handle to this function
    
    if isempty(stack_counter_)
        stack_counter_=1;
    end
    
    force_update=false;
    
    if nargin>=1
        allowed_states={'on','off','push','pop','update','not_here'};
        if ~cosmo_match({set_stack_counter_},allowed_states)
            error('Illegal argument value: must be one of: %s.',...
                        cosmo_strjoin(allowed_states,', '));
        end
        
        switch set_stack_counter_
            case 'push'
                stack_counter_=stack_counter_+1;
            case 'pop'
                if stack_counter_<=0
                    error('More pops and pushes');
                end
                stack_counter_=stack_counter_-1;
            case 'off'
                stack_counter_=0;
            case 'on'
                stack_counter_=1;
            case 'update'
                force_update=true;
            case 'not_here'
                stack_counter_=stack_counter_+1;
                
                if isempty(func_me_)
                    func_me_=str2func(mfilename());
                end
                
                path_changed=@()func_me_('pop');
                return
        end
    end
    
    if stack_counter_==0 && ~force_update
        path_changed=false;
        return
    end
    
    p=path();
    n=numel(p);
    path_changed=n~=numel(cached_path_)||~strncmp(p,cached_path_,n);

    if path_changed
        cached_path_=p;
    end


    
    
    

