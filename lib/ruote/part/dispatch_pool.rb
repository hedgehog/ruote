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


module Ruote

  #
  # The class where despatchement of workitems towards [real] participant
  # is done.
  #
  # Can be extended/replaced for better handling of Thread (why not something
  # like a thread pool or no threads at all).
  #
  class DispatchPool

    def initialize (context)

      @context = context
    end

    def dispatch (msg)

      participant = @context.plist.lookup(msg['participant_name'])

      if participant.respond_to?(:do_not_thread) && participant.do_not_thread
        do_dispatch(participant, msg)
      else
        do_threaded_dispatch(participant, msg)
      end
    end

    protected

    def do_dispatch (participant, msg)

      workitem = Ruote::Workitem.new(msg['workitem'])

      participant.consume(workitem)
    end

    def do_threaded_dispatch (participant, msg)

      Thread.new do
        begin

          do_dispatch(participant, msg)

        rescue Exception => e

          #puts '/' * 80
          #p e
          #puts '/' * 80

          @context.worker.handle_exception(
            msg,
            Ruote::Exp::FlowExpression.fetch(@context, msg['workitem']['fei']),
            e)
        end
      end
    end
  end
end

