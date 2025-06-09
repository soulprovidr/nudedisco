#!/bin/bash

/app/_build/prod/rel/nudedisco/bin/nudedisco eval "Nudedisco.Release.create_db"
/app/_build/prod/rel/nudedisco/bin/nudedisco eval "Nudedisco.Release.migrate"
/app/_build/prod/rel/nudedisco/bin/nudedisco eval "Nudedisco.Release.populate_feeds"
/app/_build/prod/rel/nudedisco/bin/nudedisco start