$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib'))

require 'minitest'
require 'minitest/autorun'

require 'ruby_dig'

class RubyDigTest
  class Diggable
    def dig(*keys)
      keys
    end
  end

  describe RubyDig do
    describe "Array" do
      it "digs an array by index" do
        assert_equal 'one', ['zero', 'one', 'two'].dig(1)
      end

      it "digs a nested array by index" do
        assert_equal 'twelve', ['zero', ['ten', 'eleven', 'twelve'], 'two'].dig(1, 2)
      end

      it "raises TypeError when nested array doesn't support dig" do
        assert_raises(TypeError) { ['zero', 'one', 'two'].dig(1, 2) }
      end

      it "returns nil when dig not found" do
        assert_equal nil, ['zero', 'one', 'two'].dig(4)
      end

      it "raises TypeError when dig index not an integer" do
        assert_raises(TypeError) { ['zero', 'one', 'two'].dig(:four) }
      end

      it "digs into any object that implements dig" do
        assert_equal [:a, :b], [0, Diggable.new].dig(1, :a, :b)
      end

      it "returns the value false" do
        assert_equal false, [:a, [true, false]].dig(1, 1)
      end
    end

    describe "Hash" do
      it "digs a hash by key" do
        assert_equal 'Homer', {first: "Homer", last: "Simpson"}.dig(:first)
      end

      it "digs a nested hash by keys" do
        assert_equal 'Homer', {mom: {first: "Marge", last: "Bouvier"}, dad: {first: "Homer", last: "Simpson"}}.dig(:dad, :first)
      end

      it "raises TypeError when nested hash doesn't support dig" do
        assert_raises(TypeError) { {mom: {first: "Marge", last: "Bouvier"}, dad: "Homer Simpson"}.dig(:dad, :first) }
      end

      it "returns nil when dig not found" do
        assert_equal nil, {first: "Homer", last: "Simpson"}.dig(:middle)
      end

      it "digs into any object that implements dig" do
        assert_equal [:a, :b], {diggable: Diggable.new}.dig(:diggable, :a, :b)
      end

      it "returns the value false" do
        assert_equal false, {first: "Homer", last: "Simpson", sobber: false}.dig(:sobber)
      end
    end

    describe "Struct" do
      Person = Struct.new(:first, :last, :misc)

      it "digs a struct by key" do
        assert_equal 'Homer', Person.new("Homer", "Simpson").dig(:first)
      end

      it "digs a struct by index" do
        assert_equal 'Homer', Person.new("Homer", "Simpson").dig(0)
      end

      it "digs a nested struct by keys" do
        assert_equal 'Bart', Person.new("Marge", "Bouvier", ["Lisa", "Bart", "Maggie"]).dig(:misc, 1)
      end

      it "raises TypeError when nested hash doesn't support dig" do
        assert_raises(TypeError) { Person.new("Marge", "Bouvier", "Lisa").dig(:misc, 1) }
      end

      it "returns nil when dig not found" do
        assert_equal nil, Person.new("Homer", "Simpson").dig(:invalid)
        assert_equal nil, Person.new("Homer", "Simpson").dig(3)
      end

      it "digs into any object that implements dig" do
        assert_equal [:a, :b], Person.new("Homer", "Simpson", Diggable.new).dig(:misc, :a, :b)
      end

      it "returns the value false" do
        assert_equal false, Person.new("Homer", "Simpson", false).dig(:misc)
      end
    end

    describe "Nested Hash and Array" do
      it "navigates both" do
        assert_equal 'Lisa', {mom: {first: "Marge", last: "Bouvier"},
                              dad: {first: "Homer", last: "Simpson"},
                              kids: [{first: "Bart"}, {first: "Lisa"}]}.dig(:kids, 1, :first)
      end
    end
  end
end
