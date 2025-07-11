# frozen_string_literal: true

require 'spec_helper'

describe SimpleCommandDispatcher::Helpers::TrimAll do
  let(:test_class) do
    Class.new do
      include SimpleCommandDispatcher::Helpers::TrimAll
    end
  end

  subject(:helper) { test_class.new }

  describe '#trim_all' do
    context 'with basic strings' do
      it 'removes spaces from string' do
        expect(helper.trim_all('hello world')).to eq('helloworld')
      end

      it 'removes leading spaces' do
        expect(helper.trim_all('   hello')).to eq('hello')
      end

      it 'removes trailing spaces' do
        expect(helper.trim_all('hello   ')).to eq('hello')
      end

      it 'removes spaces from both ends' do
        expect(helper.trim_all('   hello   ')).to eq('hello')
      end

      it 'removes multiple spaces between words' do
        expect(helper.trim_all('hello    world')).to eq('helloworld')
      end
    end

    context 'with different whitespace types' do
      it 'removes tabs' do
        expect(helper.trim_all("hello\tworld")).to eq('helloworld')
      end

      it 'removes newlines' do
        expect(helper.trim_all("hello\nworld")).to eq('helloworld')
      end

      it 'removes carriage returns' do
        expect(helper.trim_all("hello\rworld")).to eq('helloworld')
      end

      it 'removes form feeds' do
        expect(helper.trim_all("hello\fworld")).to eq('helloworld')
      end

      it 'removes vertical tabs' do
        expect(helper.trim_all("hello\vworld")).to eq('helloworld')
      end

      it 'removes mixed whitespace types' do
        expect(helper.trim_all("hello \t\n\r\f\v world")).to eq('helloworld')
      end
    end

    context 'with edge cases' do
      it 'returns empty string for empty string' do
        expect(helper.trim_all('')).to eq('')
      end

      it 'returns empty string for string with only spaces' do
        expect(helper.trim_all('   ')).to eq('')
      end

      it 'returns empty string for string with only tabs' do
        expect(helper.trim_all("\t\t\t")).to eq('')
      end

      it 'returns empty string for string with only newlines' do
        expect(helper.trim_all("\n\n\n")).to eq('')
      end

      it 'returns empty string for mixed whitespace only' do
        expect(helper.trim_all(" \t\n\r\f\v ")).to eq('')
      end

      it 'handles string with no whitespace' do
        expect(helper.trim_all('hello')).to eq('hello')
      end

      it 'handles single character' do
        expect(helper.trim_all('a')).to eq('a')
      end

      it 'handles single space' do
        expect(helper.trim_all(' ')).to eq('')
      end
    end

    context 'with complex strings' do
      it 'removes whitespace from module-like strings' do
        expect(helper.trim_all('Api :: Auth :: V1')).to eq('Api::Auth::V1')
      end

      it 'removes whitespace from route-like strings' do
        expect(helper.trim_all(' /api / auth / v1 ')).to eq('/api/auth/v1')
      end

      it 'handles strings with multiple consecutive whitespace' do
        expect(helper.trim_all('hello     world     test')).to eq('helloworldtest')
      end

      it 'handles strings with mixed content and whitespace' do
        expect(helper.trim_all('  Api::   Auth   ::V1  ')).to eq('Api::Auth::V1')
      end
    end

    context 'with special characters' do
      it 'preserves non-whitespace special characters' do
        expect(helper.trim_all('hello@world.com')).to eq('hello@world.com')
      end

      it 'removes whitespace but preserves special chars' do
        expect(helper.trim_all('hello @ world . com')).to eq('hello@world.com')
      end

      it 'handles underscores' do
        expect(helper.trim_all('hello _ world')).to eq('hello_world')
      end

      it 'handles hyphens' do
        expect(helper.trim_all('hello - world')).to eq('hello-world')
      end

      it 'handles numbers' do
        expect(helper.trim_all('api v 1')).to eq('apiv1')
      end
    end

    context 'with unicode characters' do
      it 'preserves unicode characters' do
        expect(helper.trim_all('café naïve')).to eq('cafénaïve')
      end

      it 'handles unicode whitespace' do
        # Unicode non-breaking space (U+00A0)
        expect(helper.trim_all("hello\u00A0world")).to eq('helloworld')
      end

      it 'handles emoji' do
        expect(helper.trim_all('hello 😀 world')).to eq('hello😀world')
      end
    end

    context 'with real-world examples' do
      it 'cleans up namespace strings' do
        input = '  Api  ::  Auth  ::  V1  '
        expected = 'Api::Auth::V1'
        expect(helper.trim_all(input)).to eq(expected)
      end

      it 'cleans up route strings' do
        input = ' /api / auth / v1 / authenticate '
        expected = '/api/auth/v1/authenticate'
        expect(helper.trim_all(input)).to eq(expected)
      end

      it 'cleans up class names' do
        input = '  MyClass  Name  '
        expected = 'MyClassName'
        expect(helper.trim_all(input)).to eq(expected)
      end

      it 'handles multiline strings' do
        input = "Api::\n  Auth::\n  V1"
        expected = 'Api::Auth::V1'
        expect(helper.trim_all(input)).to eq(expected)
      end
    end
  end
end
