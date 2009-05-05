require File.dirname(__FILE__) + '/spec_helper'

class FooTask < ProtoProcessor::Tasks::BaseTask
  
  def process
    @input << 'a'
  end
end

describe "BaseTask" do
  before do
    @input = ''
    @options = {}
    @report = {}
    @task = FooTask.new([@input, @options, @report])
  end
  
  it "should raise if less than 3 arguments" do
    lambda {
      FooTask.new(['bar'])
    }.should raise_error(ArgumentError)
  end
  
  it "should raise if argument is not enumerable" do
    lambda {
      FooTask.new(1)
    }.should raise_error(ArgumentError)
  end
  
  it "should have input, options and report" do
    @task.input.should == @input
    @task.options.should == @options
    @task.report.should == @report
  end
  
  describe "running" do
    
    it "should invoke :process" do
      @task.should_receive(:process)
      @task.run
    end
    
    it "should return modified input" do
      output = @task.run
      output[0].should == 'a'
    end
    
    it "should return options" do
      output = @task.run
      output[1].should == @options
    end
    
    it "should return report with task name entry" do
      output = @task.run
      output[2].has_key?(:FooTask).should be_true
    end
    
  end
  
end

class BarTask < ProtoProcessor::Tasks::BaseTask
  
  def process
    @input << 'b'
  end
end

describe "decorating the same or other tasks" do
  
  it "should iteratively process" do
    input, options, report = '', {}, {}
    1.upto(5) do |i|
      task = FooTask.new([input, options, report])
      input, options, report = task.run
    end
    
    task = BarTask.new([input, options, report])
    input, options, report = task.run
    
    input.should == 'aaaaab'
    report[:FooTask].size.should == 5
    report[:BarTask].size.should == 1
  end
end