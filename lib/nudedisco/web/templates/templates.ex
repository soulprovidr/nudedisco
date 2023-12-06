defmodule Nudedisco.Web.Templates do
  require EEx

  EEx.function_from_file(:def, :index, "lib/nudedisco/web/templates/partials/index.html.eex", [
    :sections
  ])

  EEx.function_from_file(
    :def,
    :headlines_section,
    "lib/nudedisco/web/templates/partials/headlines.html.eex",
    [:feed_tuples]
  )

  EEx.function_from_file(
    :def,
    :images_section,
    "lib/nudedisco/web/templates/partials/images.html.eex",
    [
      :feed_tuple
    ]
  )

  EEx.function_from_file(
    :def,
    :subscription_success,
    "lib/nudedisco/web/templates/partials/subscription_success.html.eex",
    []
  )

  EEx.function_from_file(
    :def,
    :subscription_error,
    "lib/nudedisco/web/templates/partials/subscription_error.html.eex",
    []
  )
end
