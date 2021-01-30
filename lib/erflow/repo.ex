defmodule Erflow.Repo do
  use Ecto.Repo,
    otp_app: :erflow,
    adapter: Ecto.Adapters.Postgres
end
