defmodule Erflow.Base.Job do
  alias Erflow.Base.Dag, as: BaseDag
  @callback build() :: {:ok, %BaseDag{}} | {:error, String.t}

  def build!(implementation, contents) do
    IO.inspect(implementation)
    case implementation.build(contents) do
      {:ok, data} -> data
      {:error, error} -> raise ArgumentError, "Building error: #{error}"
    end
  end
end