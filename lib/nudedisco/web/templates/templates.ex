defmodule Nudedisco.Web.Templates do
  require EEx

  EEx.function_from_file(:def, :index, "lib/nudedisco/web/templates/partials/index.eex", [
    :sections
  ])

  EEx.function_from_file(
    :def,
    :headlines_section,
    "lib/nudedisco/web/templates/partials/headlines.eex",
    [:feed_configs]
  )

  EEx.function_from_file(
    :def,
    :images_section,
    "lib/nudedisco/web/templates/partials/images.eex",
    [
      :feed_config
    ]
  )
end
