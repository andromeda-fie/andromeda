defmodule Andromeda.Repo do
  use Ecto.Repo,
    otp_app: :andromeda,
    adapter: Ecto.Adapters.Postgres
end
