defmodule Andromeda do
  @moduledoc """
  Andromeda keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def validate_required(%{} = params, fields) when is_list(fields) do
    Enum.reduce_while(fields, {:ok, params}, fn f, state ->
      v = Map.get(params, f)
      err = {:error, {f, :required}}

      cond do
        not Map.has_key?(params, f) -> {:halt, err}
        not (!!v and v != "") -> {:halt, err}
        true -> {:cont, state}
      end
    end)
  end

  def validate_change(params, f, cb) when is_function(cb, 1) do
    if v = Map.get(params, f) do
      case cb.(v) do
        true -> {:ok, params}
        :ok -> {:ok, params}
        false -> {:error, {f, :invalid}}
        err -> err
      end
    else
      {:ok, params}
    end
  end

  def update_change(params, f, cb) when is_function(cb, 1) do
    {:ok, Map.update(params, f, nil, cb)}
  end

  def model(table) do
    quote do
      use GenServer
      import Andromeda
      alias __MODULE__

      @table unquote(table)

      def start_link(_opts) do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end
    end
  end

  defmacro __using__(opts) do
    type = Keyword.fetch!(opts, :type)

    case type do
      :model ->
        table = Keyword.fetch!(opts, :table)
        model(table)
    end
  end
end
