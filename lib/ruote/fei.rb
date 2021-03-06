#--
# Copyright (c) 2005-2010, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

require 'ruote/version'
require 'ruote/util/misc'
require 'ruote/util/hashdot'


module Ruote

  # A shortcut for
  #
  #   Ruote::FlowExpressionId.to_storage_id(fei)
  #
  def self.to_storage_id (fei)

    Ruote::FlowExpressionId.to_storage_id(fei)
  end

  #
  # The FlowExpressionId (fei for short) is an process expression identifier.
  # Each expression when instantiated gets a unique fei.
  #
  # Feis are also used in workitems, where the fei is the fei of the
  # [participant] expression that emitted the workitem.
  #
  # Feis can thus indicate the position of a workitem in a process tree.
  #
  # Feis contain four pieces of information :
  #
  # * wfid : workflow instance id, the identifier for the process instance
  # * sub_wfid : the identifier for the sub process within the main instance
  # * expid : the expression id, where in the process tree
  # * engine_id : only relevant in multi engine scenarii (defaults to 'engine')
  #
  class FlowExpressionId

    CHILD_SEP = '_'

    attr_reader :h

    def initialize (h)

      @h = h
      class << h; include Ruote::HashDot; end
    end

    def expid
      @h['expid']
    end

    def wfid
      @h['wfid']
    end

    def sub_wfid
      @h['sub_wfid']
    end

    def to_storage_id
      "#{@h['expid']}!#{@h['sub_wfid']}!#{@h['wfid']}"
    end

    def self.to_storage_id (hfei)
      "#{hfei['expid']}!#{hfei['sub_wfid']}!#{hfei['wfid']}"
    end

    def self.from_id (s, engine_id='engine')

      ss = s.split('!')

      FlowExpressionId.new(
        'engine_id' => engine_id,
        'expid' => ss[-3], 'sub_wfid' => ss[-2], 'wfid' => ss[-1])
    end

    # Returns the last number in the expid. For instance, if the expid is
    # '0_5_7', the child_id will be '7'.
    #
    def child_id
      h.expid.split(CHILD_SEP).last.to_i
    end

    def hash
      to_storage_id.hash
    end

    def == (other)

      return false unless other.is_a?(Ruote::FlowExpressionId)

      (hash == other.hash)
    end

    alias eql? ==

    # Returns true if the h is a representation of a FlowExpressionId instance.
    #
    def self.is_a_fei? (h)

      h.respond_to?(:keys) &&
      (h.keys - [ 'sub_wfid' ]).sort == %w[ engine_id expid wfid ]
    end

    # Returns child_id... For an expid of '0_1_4', this will be 4.
    #
    def self.child_id (h)
      h['expid'].split(CHILD_SEP).last.to_i
    end

    def to_h
      @h
    end

    def self.direct_child? (parent_fei, other_fei)

      %w[ sub_wfid wfid engine_id ].each do |k|
        return false if parent_fei[k] != other_fei[k]
      end

      pei = other_fei['expid'].split(CHILD_SEP)[0..-2].join('_')

      (pei == parent_fei['expid'])
    end
  end
end

