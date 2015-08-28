module HashDiff
  class Comparison < Struct.new(:left, :right)
  
    def diff
      @diff ||= find_differences { |l, r| [l, r] }
    end

    def left_diff
      @left_diff ||= find_differences { |_, r| r }
    end

    def right_diff
      @right_diff ||= find_differences { |l, _| l }
    end

    protected

    def find_differences(&reporter)
      combined_attribute_keys.reduce({ }, &reduction_strategy(reporter))
    end

    private

    def reduction_strategy(reporter)
      lambda do |diff, key|
        diff[key] = report(key, reporter) if not equal?(key)
        diff
      end
    end

    def combined_attribute_keys
      (left.keys + right.keys).uniq
    end

    def equal?(key)
      left[key] == right[key]
    end

    def hash?(value)
      value.is_a? Hash
    end

    def comparable?(key)
      hash?(left[key]) and hash?(right[key])
    end

    def report(key, reporter)
      if comparable?(key)
        self.class.new(left[key], right[key]).find_differences(&reporter)
      else
        reporter.call(left[key], right[key])
      end
    end
  end
end
