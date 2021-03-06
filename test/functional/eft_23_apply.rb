
#
# testing ruote
#
# Thu Aug 20 13:21:54 JST 2009
#

require File.join(File.dirname(__FILE__), 'base')


class EftApplyTest < Test::Unit::TestCase
  include FunctionalBase

  def test_empty_apply

    pdef = Ruote.process_definition :name => 'test' do
      sequence do
        echo 'in'
        apply
        echo 'out.'
      end
    end

    #noisy

    assert_trace(pdef, %w[ in out. ])
  end

  def test_apply_tree

    pdef = Ruote.process_definition :name => 'test' do
      apply :tree => [ 'echo', { 'nada' => nil }, [] ]
    end

    #noisy

    assert_trace(pdef, 'nada')
  end

  def test_apply_default_tree_variable

    pdef = Ruote.process_definition :name => 'test' do
      sequence do
        set :var => 'tree', :val => [ 'echo', { 'nada' => nil }, [] ]
        apply
      end
    end

    #noisy

    assert_trace(pdef, 'nada')
  end

  def test_apply_tree_variable

    pdef = Ruote.process_definition :name => 'test' do
      sequence do
        set :var => 't', :val => [ 'echo', { 'nada' => nil }, [] ]
        apply :tree_var => 't'
      end
    end

    #noisy

    assert_trace(pdef, 'nada')
  end

  def test_apply_tree_field

    pdef = Ruote.process_definition :name => 'test' do
      sequence do
        set :field => 't', :val => [ 'echo', { 'nada' => nil }, [] ]
        #apply :tree_field => 't'
        apply :tree_f => 't'
      end
    end

    #noisy

    assert_trace(pdef, 'nada')
  end

  def test_apply_attributes_as_variables

    pdef = Ruote.process_definition :name => 'test' do
      apply :tree => [ 'echo', { 'a:${v:a}' => nil }, [] ], :a => 'surf'
    end

    #noisy

    assert_trace(pdef, 'a:surf')
  end

  def test_apply_default_with_attributes_as_variables

    pdef = Ruote.process_definition :name => 'test' do
      sequence do
        set :var => 'tree', :val => [ 'echo', { 'a:${v:a}' => nil }, [] ], :escape => true
        apply
        apply :a => 'surf'
      end
    end

    #noisy

    assert_trace(pdef, %w[ a: a:surf ])
  end

  def test_apply_within_subprocess

    pdef = Ruote.process_definition 'test' do
      sub0 do
        echo 'nada'
      end
      define 'sub0' do
        sequence do
          apply
          apply
          apply
        end
      end
    end

    #noisy

    assert_trace(pdef, %w[ nada ] * 3)
  end

  def test_apply_within_subprocess_2

    pdef = Ruote.process_definition 'test' do
      subprocess :ref => 'sub0' do
        echo 'nada'
      end
      define 'sub0' do
        apply
      end
    end

    #noisy

    assert_trace(pdef, 'nada')
  end
end

