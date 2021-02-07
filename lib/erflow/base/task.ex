defmodule Erflow.Base.Task do
  defstruct [:name, :mod, :fun, :args]
  require Logger
  @type t() :: %__MODULE__{
    name: Atom.t(),
    mod: String.t()| nil,
    fun: String.t()| nil,
    args: String.t()| nil,
  }



  def new(%{name: name, mod: mod, fun: fun, args: args}) do
    %__MODULE__{name: name, mod: mod, fun: fun, args: args}
  end
  def new(%{name: name, mod: mod, fun: fun}) do
    %__MODULE__{name: name, mod: mod, fun: fun, args: nil}
  end
  def new(%{name: name}) when is_atom(name) do
    %__MODULE__{name: Atom.to_string(name), mod: nil, fun: nil, args: nil}
  end
  def new(%{name: name}) do
    %__MODULE__{name: name, mod: nil, fun: nil, args: nil}
  end


end
