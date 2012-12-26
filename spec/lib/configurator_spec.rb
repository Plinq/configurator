require 'configurator'

describe Configurator do
  it "extends objects without exploding" do
    lambda {
      class FooBar
        extend Configurator
      end
    }.should_not raise_error
  end

  describe "mixed into a class" do
    before do
      class TestClass
        extend Configurator
      end
    end

    it "defines a `config` method" do
      TestClass.should respond_to(:config)
    end

    describe "adds a `config` method that" do
      it "accepts a block" do
        lambda {
          TestClass.config { inspect }
        }.should_not raise_error
      end

      it "executes the block in the context of the configured class' new configuration instance" do
        TestClass.config.should_receive(:puts).and_return(nil)
        TestClass.config { puts "ohai" }
      end
    end

    describe "adds an `option` method that" do
      it "allows developers to declare class-level options" do
        TestClass.send(:option, :do_something)
        TestClass.config.defaults.key?(:do_something).should be_true
      end

      it "allows developers to declare defaults on options" do
        TestClass.send(:option, :do_something, true)
        TestClass.config.defaults[:do_something].should be_true
      end

      it "defines getter methods on the config class method" do
        TestClass.send(:option, :do_something)
        TestClass.config.do_something.should be_nil
      end

      it "defines setter methods on the class" do
        TestClass.send(:option, :do_something)
        lambda { TestClass.config.do_something = "ohai" }.should_not raise_error
      end

      describe "that adds a class-level accessor that" do
        it "returns default values when a developer has not overriden it" do
          TestClass.send(:option, :do_something, "now!")
          TestClass.config.do_something.should == "now!"
        end

        it "returns overriden values when a developer has overriden them" do
          TestClass.send(:option, :do_something, "now!")
          TestClass.config do
            do_something "later..."
          end
          TestClass.config.do_something.should == "later..."
        end

        it "uses a lambda to defer processing until it's called" do
          TestClass.send(:option, :payment_method, lambda {
            defined?(Paypal) ? :paypal : :plinq
          })
          TestClass.config.payment_method.should == :plinq
        end

        it "accepts a setter format" do
          TestClass.send(:option, :do_something, "now!")
          TestClass.config.do_something = "later..."
          TestClass.config.do_something.should == "later..."
        end
      end
    end

    describe '#option with sub-options' do
      before :each do
        TestClass.send(:option, :advanced_options) do
          option :bitrate, 1024
          option :fps, 30
        end
      end

      it "accepts a block that creates a sub-configuration" do
        TestClass.config.advanced_options.bitrate.should == 1024
        TestClass.config.advanced_options.fps.should == 30
      end

      it "accepts a hash that for a sub-configuration" do
        TestClass.config.advanced_options = {
          bitrate: 2000,
          fps: 60
        }
        TestClass.config.advanced_options.bitrate.should == 2000
        TestClass.config.advanced_options.fps.should == 60
      end

      it "doesn't overwrite a defaults hash if you set one value but not the other" do
        TestClass.config.advanced_options = {bitrate: 2000}
        TestClass.config.advanced_options.bitrate.should == 2000
        TestClass.config.advanced_options.fps.should == 30
      end

      it "accepts even MORE options below the other ones, yo" do
        TestClass.send(:option, :sub) do
          option(:name, :face)
          option(:sub) do
            option(:name, :fiz)
          end
        end
        TestClass.config.sub.name.should == :face
        TestClass.config.sub.sub.name.should == :fiz
      end
    end

    it "adds an `options` method that defines many options with default nil values" do
      TestClass.should_receive(:option).once.with(:host)
      TestClass.should_receive(:option).once.with(:api_key)
      TestClass.send :options, :host, :api_key
    end
  end
end
