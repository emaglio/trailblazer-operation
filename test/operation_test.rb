require "test_helper"

class DeclarativeApiTest < Minitest::Spec
  #---
  #- step, pass, fail

  # Test: step/pass/fail
  # * do they deviate properly?
  class Create < Trailblazer::Operation
    step :decide!
    pass :wasnt_ok!
    pass :was_ok!
    fail :return_true!
    fail :return_false!

    def decide!(options, decide:raise, **)
      options["a"] = true
      decide
    end

    def wasnt_ok!(options, **)
      options["y"] = false
    end

    def was_ok!(options, **)
      options["x"] = true
    end

    def return_true! (options, **); options["b"] = true end
    def return_false!(options, **); options["c"] = false end
  end

  it { Create.({}, decide: true).inspect("a", "x", "y", "b", "c").must_equal %{<Result:true [true, true, false, nil, nil] >} }
  it { Create.({}, decide: false).inspect("a", "x", "y", "b", "c").must_equal %{<Result:false [true, nil, nil, true, false] >} }

  #---
  #- trace

  it do

  end

  #---
  #- empty class
  class Noop < Trailblazer::Operation
  end

  it { Noop.().inspect("params").must_equal %{<Result:true [{}] >} }

  #---
  #- pass
  #- fail
  class Update < Trailblazer::Operation
    pass ->(options, **)         { options["a"] = false }
    step ->(options, params:raise, **) { options["b"] = params[:decide] }
    fail ->(options, **)         { options["c"] = true }
  end

  it { Update.(decide: true).inspect("a", "b", "c").must_equal %{<Result:true [false, true, nil] >} }
  it { Update.(decide: false).inspect("a", "b", "c").must_equal %{<Result:false [false, false, true] >} }


  #---
  #- Operation[] and Operation[]=
  class Index < Trailblazer::Operation
    self["model.class"] = Module

    step ->(options, **) { options["a"] = options["model.class"] }
  end

  it { Index.({}).inspect("a", "model.class").must_equal %{<Result:true [Module, Module] >} }
end
