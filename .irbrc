require 'irb/completion'
require 'rubygems'

if defined? Rails
  module Rails::ConsoleMethods
    alias r reload!
    alias q exit

    require_relative('lawbite_irbrc')
  end
end

# Overriding Object class
class Object
  # Easily print methods local to an object's class
  def lm
    (methods - Object.instance_methods).sort
  end

  # look up source location of a method
  def sl(method_name)
    method(method_name).source_location
  rescue StandardError
    "#{method_name} not found"
  end

  # display method source in rails console
  def ds(method_name)
    method(method_name).source.display
  end
end

# history command
def history(count = 0)
  # Get history into an array
  history_array = Readline::HISTORY.to_a

  # if count is > 0 we'll use it.
  # otherwise set it to 0
  count = count.positive? ? count : 0

  if count.positive?
    from = history_array.length - count
    history_array = history_array[from..]
  end

  print history_array.join("\n")
end

# copy a string to the clipboard
def cp(string)
  `echo "#{string}" | pbcopy`
  puts 'copied in clipboard'
end
