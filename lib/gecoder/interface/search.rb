module Gecode
  class Model
    # Finds the first solution to the modelled problem and updates the variables
    # to that solution. Returns the model if a solution was found, nil 
    # otherwise.
    def solve!
      space = dfs_engine.next
      return nil if space.nil?
      self.active_space = space
      return self
    end
    
    # Returns to the original state, before any search was made (but propagation 
    # might have been performed). Returns the reset model.
    def reset!
      self.active_space = base_space
      return self
    end
    
    # Yields the first solution (if any) to the block. If no solution is found
    # then the block is not used. Returns the result of the block (nil in case
    # the block wasn't run). 
    def solution(&block)
      solution = self.solve!
      res = yield solution unless solution.nil?
      self.reset!
      return res
    end
    
    # Yields each solution that the model has.
    def each_solution(&block)
      dfs = dfs_engine
      next_solution = nil
      while not (next_solution = dfs.next).nil?
        self.active_space = next_solution
        yield self
      end
      self.reset!
    end
    
    # Finds the optimal solution. Optimality is defined by the provided block
    # which is given one parameter, a solution to the problem. The block should
    # constrain the solution so that that only "better" solutions can be new 
    # solutions. For instance if one wants to optimize a variable named price
    # (accessible from the model) to be as low as possible then one should write
    # the following.
    #
    #   model.optimize! do |model, best_so_far|
    #     model.price.must < best_so_far.price.val
    #   end
    #
    # Returns nil if there is no solution.
    def optimize!(&block)
      # Execute constraints.
      perform_queued_gecode_interactions

      # Set the method used for constrain calls by the BAB-search.
      Model.constrain_proc = lambda do |home_space, best_space|
        self.active_space = best_space
        @variable_creation_space = home_space
        yield(self, self)
        self.active_space = home_space
        @variable_creation_space = nil
        
        perform_queued_gecode_interactions
      end

      # Perform the search.
      options = Gecode::Raw::Search::Options.new
      options.c_d = Gecode::Raw::Search::Config::MINIMAL_DISTANCE
      options.a_d = Gecode::Raw::Search::Config::ADAPTIVE_DISTANCE
      options.stop = nil
      result = Gecode::Raw::bab(selected_space, options)
      
      # Reset the method used constrain calls and return the result.
      Model.constrain_proc = nil
      return nil if result.nil?
      
      # Switch to the result.
      self.active_space = result
      return self
    end
    
    # Finds the solution that maximizes a given integer variable. The name of 
    # the method that accesses the variable from the model should be given. To 
    # for instance maximize a variable named "profit", that's accessible through 
    # the model, one would use the following.
    #
    #   model.maximize! :profit
    #
    # Returns nil if there is no solution.
    def maximize!(var)
      variable = self.method(var).call
      unless variable.kind_of? Gecode::FreeIntVar
        raise ArgumentError.new("Expected integer variable, got #{variable.class}.")
      end
      
      optimize! do |model, best_so_far|
        model.method(var).call.must > best_so_far.method(var).call.value
      end
    end
    
    # Finds the solution that minimizes a given integer variable. The name of 
    # the method that accesses the variable from the model should be given. To 
    # for instance minimize a variable named "cost", that's accessible through 
    # the model, one would use the following.
    #
    #   model.minimize! :cost
    #
    # Returns nil if there is no solution.
    def minimize!(var)
      variable = self.method(var).call
      unless variable.kind_of? Gecode::FreeIntVar
        raise ArgumentError.new("Expected integer variable, got #{variable.class}.")
      end
      
      optimize! do |model, best_so_far|
        model.method(var).call.must < best_so_far.method(var).call.value
      end
    end
    
    class <<self 
      # Sets the proc that should be used to handle constrain requests.
      def constrain_proc=(proc) #:nodoc:
        @constrain_proc = proc
      end
    
      # Called by spaces when they want to constrain as part of BAB-search.
      def constrain(home, best) #:nodoc:
        if @constrain_proc.nil?
          raise NotImplementedError, 'Constrain method not implemented.' 
        else
          @constrain_proc.call(home, best)
        end
      end
    end
    
    private
    
    # Creates a depth first search engine for search, executing any 
    # unexecuted constraints first.
    def dfs_engine
      # Execute constraints.
      perform_queued_gecode_interactions
      
      # Construct the engine.
      Gecode::Raw::DFS.new(selected_space, 
        Gecode::Raw::Search::Config::MINIMAL_DISTANCE,
        Gecode::Raw::Search::Config::ADAPTIVE_DISTANCE, 
        nil)
    end
  end
end
