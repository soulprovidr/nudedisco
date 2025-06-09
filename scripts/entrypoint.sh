#!/bin/bash

cd /app

_build/prod/rel/nudedisco/bin/nudedisco eval "Nudedisco.Release.create_db"
_build/prod/rel/nudedisco/bin/nudedisco eval "Nudedisco.Release.migrate"
_build/prod/rel/nudedisco/bin/nudedisco eval "Nudedisco.Release.populate_feeds"
_build/prod/rel/nudedisco/bin/nudedisco start