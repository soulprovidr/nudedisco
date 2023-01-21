defmodule Nudedisco.Templates do
  require EEx
  EEx.function_from_file(:def, :index, "lib/nudedisco/templates/index.html", [:items])
end
