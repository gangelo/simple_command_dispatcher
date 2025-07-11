# frozen_string_literal: true

require 'spec_helper'

describe Kernel do
  describe '#eigenclass' do
    context 'with class objects' do
      it 'returns the eigenclass of a class' do
        test_class = Class.new
        eigenclass = test_class.eigenclass

        expect(eigenclass).to be_a(Class)
        expect(eigenclass).to be < Class
        expect(eigenclass.inspect).to match(/^#<Class:/)
      end

      it 'returns different eigenclasses for different classes' do
        class1 = Class.new
        class2 = Class.new

        expect(class1.eigenclass).not_to eq(class2.eigenclass)
      end

      it 'returns the same eigenclass when called multiple times' do
        test_class = Class.new
        eigenclass1 = test_class.eigenclass
        eigenclass2 = test_class.eigenclass

        expect(eigenclass1).to eq(eigenclass2)
        expect(eigenclass1.object_id).to eq(eigenclass2.object_id)
      end
    end

    context 'with instance objects' do
      it 'returns the eigenclass of an instance' do
        instance = Object.new
        eigenclass = instance.eigenclass

        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^#<Class:/)
      end

      it 'returns different eigenclasses for different instances' do
        instance1 = Object.new
        instance2 = Object.new

        expect(instance1.eigenclass).not_to eq(instance2.eigenclass)
      end

      it 'allows defining singleton methods on the eigenclass' do
        instance = Object.new
        eigenclass = instance.eigenclass

        eigenclass.define_method(:test_method) { 'test result' }

        expect(instance.test_method).to eq('test result')
      end
    end

    context 'with module objects' do
      it 'returns the eigenclass of a module' do
        test_module = Module.new
        eigenclass = test_module.eigenclass

        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^#<Class:/)
      end

      it 'allows access to module-level methods' do
        test_module = Module.new
        test_module.eigenclass.define_method(:module_method) { 'module result' }

        expect(test_module.module_method).to eq('module result')
      end
    end

    context 'with named classes' do
      it 'returns eigenclass for named class' do
        class TestClass
          def self.get_eigenclass
            eigenclass
          end
        end

        eigenclass = TestClass.get_eigenclass
        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to eq('#<Class:TestClass>')
      end

      it 'eigenclass can define class methods' do
        class TestClassWithEigen
          eigenclass.define_method(:eigen_method) { 'eigen result' }
        end

        expect(TestClassWithEigen.eigen_method).to eq('eigen result')
      end
    end

    context 'with built-in objects' do
      it 'returns eigenclass for string' do
        string = 'test'
        eigenclass = string.class.eigenclass

        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^#<Class:/)
      end

      it 'returns eigenclass for integer' do
        number = 42
        eigenclass = number.class.eigenclass

        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^#<Class:/)
      end

      it 'returns eigenclass for array' do
        array = [1, 2, 3]
        eigenclass = array.class.eigenclass

        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^#<Class:/)
      end

      it 'returns eigenclass for hash' do
        hash = { key: 'value' }
        eigenclass = hash.class.eigenclass

        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^#<Class:/)
      end
    end

    context 'practical usage scenarios' do
      it 'can be used to check if class has specific methods' do
        class TestMethodClass
          def self.class_method
            'class method'
          end
        end

        eigenclass = TestMethodClass.eigenclass
        expect(eigenclass.public_method_defined?(:class_method)).to be true
      end

      it 'can be used to dynamically add class methods' do
        class DynamicClass
        end

        DynamicClass.eigenclass.define_method(:dynamic_method) do
          'dynamically added'
        end

        expect(DynamicClass.dynamic_method).to eq('dynamically added')
      end

      it 'can be used in command validation context' do
        class ValidCommand
          def self.call
            'valid command'
          end
        end

        # This simulates how eigenclass might be used in command validation
        eigenclass = ValidCommand.eigenclass
        has_call_method = eigenclass.public_method_defined?(:call)

        expect(has_call_method).to be true
        expect(ValidCommand.call).to eq('valid command')
      end
    end

    context 'edge cases' do
      it 'handles nil object' do
        eigenclass = nil.eigenclass
        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^NilClass/)
      end

      it 'handles true object' do
        eigenclass = true.eigenclass
        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^TrueClass/)
      end

      it 'handles false object' do
        eigenclass = false.eigenclass
        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^FalseClass/)
      end

      it 'handles symbol object' do
        eigenclass = :test.class.eigenclass
        expect(eigenclass).to be_a(Class)
        expect(eigenclass.inspect).to match(/^#<Class:/)
      end
    end

    context 'inheritance behavior' do
      it 'eigenclass hierarchy follows class hierarchy' do
        class ParentClass
        end

        class ChildClass < ParentClass
        end

        parent_eigenclass = ParentClass.eigenclass
        child_eigenclass = ChildClass.eigenclass

        expect(child_eigenclass.superclass).to eq(parent_eigenclass)
      end

      it 'eigenclass can access inherited methods' do
        class ParentWithMethod
          def self.parent_method
            'parent method'
          end
        end

        class ChildWithEigen < ParentWithMethod
          def self.get_eigenclass
            eigenclass
          end
        end

        child_eigenclass = ChildWithEigen.get_eigenclass
        expect(child_eigenclass.public_method_defined?(:parent_method)).to be true
      end
    end
  end
end
