# Copyright (c) 2005-2007 Diego Pettenò <flameeyes@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Rust

  # This class represents a generic element for Rust, that responds to
  # the three generic methods: Element.declaration, Element.definition
  # and Element.initialization that form a Ruby extension generated by
  # Rust.
  # An element can also have children element, which methods are
  # called as a pyramid.
  class Element
    def initialize
      @children = []
      @expansions = []

      @declaration_template = "#error Element #{self.inspect} missing declaration template"
      @definition_template = "#error Element #{self.inspect} missing definition template"
      @initializatio_template = "#error Element #{self.inspect} missing initialization template"
    end

    def add_expansion(key, value = key)
      throw "missing @expansions array -- did you call Element.initialize?" unless @expansions
      @expansions << [key, value]
    end

    def expand(str)
      @expansions.each do |key, expression|
        begin
          str.gsub!("!#{key}!", eval(expression).to_s)
        rescue
          $stderr.puts "Exception during substitution of '#{key}' into '#{expression}' for #{self.inspect}"
          raise
        end
      end

      return str
    end

    def declaration
      ret = @declaration_template +
        @children.collect { |child| child.declaration }.join("\n")

      expand(ret)
    end

    def definition
      ret = @definition_template +
        @children.collect { |child| child.definition }.join("\n")

      expand(ret)
    end

    def initialization
      ret = @initialization_template +
        @children.collect { |child| child.initialization }.join("\n")

      expand(ret)
    end
  end

end
