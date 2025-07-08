![](/priv/preview.jpg)

# nudedisco

RSS-powered album reviews aggregator.

[![CI](https://github.com/soulprovidr/nudedisco/actions/workflows/ci.yaml/badge.svg)](https://github.com/soulprovidr/nudedisco/actions/workflows/ci.yaml)
[![Deploy](https://github.com/soulprovidr/nudedisco/actions/workflows/deploy.yaml/badge.svg)](https://github.com/soulprovidr/nudedisco/actions/workflows/deploy.yaml)

## Installation

1. Install [Elixir](https://elixir-lang.org/install.html).
1. Clone the project:

    ```bash
    $ git clone git@github.com:soulprovidr/nudedisco.git
    $ cd nudedisco
    ```

1. Install the project dependencies:

    ```bash
    $ mix deps.get
    ```

1. Run the project locally:

    ```bash
    $ iex -S mix
    ```


## Deployment

1. Set up environment variables:

    ```bash
    $ export OPENAI_API_KEY=your_api_key_here
    ```

2. Build the release:

    ```bash
    $ MIX_ENV=prod mix release
    ```

3. Run the release:

    ```bash
    $ _build/prod/rel/nudedisco/bin/nudedisco start
    ```

The application will be available at `http://localhost:4000`.

