defmodule Nudedisco.Templates do
  require EEx

  EEx.function_from_file(:def, :index, "lib/nudedisco/templates/partials/index.eex", [:sections])

  EEx.function_from_file(
    :def,
    :headlines_section,
    "lib/nudedisco/templates/partials/headlines.eex",
    [:feed_configs]
  )

  EEx.function_from_file(:def, :images_section, "lib/nudedisco/templates/partials/images.eex", [
    :feed_config
  ])
end
